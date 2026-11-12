require "rails_helper"

RSpec.describe Relatorios::ExportarOperacaoGlobal do
  let(:agora) { Time.zone.local(2025, 10, 24, 15, 0) }
  let(:administrador) { create(:administrador, nome: "Administradora Geral") }
  let(:unidade) { create(:unidade_gestora, nome: "Campus Darcy Ribeiro") }
  let!(:restaurante) { restaurante_com_catraca(unidade, "Restaurante 1") }
  let(:estudante) { create(:usuario_estudante).estudante }
  let(:relatorio) { Relatorios::OperacaoGlobal.new({}, agora: agora) }

  def exportar(formato)
    described_class.call(usuario: administrador, relatorio: relatorio, formato: formato, agora: agora)
  end

  around { |exemplo| travel_to(agora) { exemplo.run } }

  context "com acessos" do
    before do
      pix = recarga_confirmada(estudante, :pix)
      acesso_realizado(restaurante, turno: TipoRefeicao::ALMOCO, dia: agora.to_date, recarga: pix)
      acesso_realizado(restaurante, turno: TipoRefeicao::CAFE_DA_MANHA, dia: agora.to_date, recarga: pix, valor: "2.50")
    end

    it "gera o PDF oficial com dados, filtros, emissão e emissor (RN09.13)" do
      resultado = exportar("pdf")
      texto = texto_de_pdf(resultado.conteudo)

      expect(resultado).to be_sucesso
      expect(resultado.nome_arquivo).to match(/\Arelatorio-global-2025-10-24-\d+\.pdf\z/)
      expect(texto).to include("Relatório Global de Operação", "Data contábil: 24/10/2025",
                               "Janela de serviço: Todos os Turnos (Café, Almoço, Jantar)",
                               "Unidade gestora: Campus Darcy Ribeiro", "Emitido em: 24/10/2025 15:00",
                               "Emitido por: Administradora Geral (#{administrador.identificacao})",
                               "Arrecadação global: R$ 7,00", "Restaurante 1 2 R$ 7,00",
                               "Total Consolidado 2 R$ 7,00", "PIX Institucional Instantâneo 100% R$ 7,00")
    end

    it "gera o CSV com uma linha por restaurante e o total (RN09.12)" do
      linhas = exportar("csv").conteudo.delete_prefix("﻿").lines.map(&:chomp)

      expect(linhas).to eq([
        "data_contabil;turno;unidade_gestora;restaurante;acessos;arrecadacao_bruta",
        "24/10/2025;Todos os Turnos (Café, Almoço, Jantar);Campus Darcy Ribeiro;Restaurante 1;2;7,00",
        "24/10/2025;Todos os Turnos (Café, Almoço, Jantar);Campus Darcy Ribeiro;Total Consolidado;2;7,00"
      ])
    end

    it "registra a exportação concluída, com emissor, filtros, totais e SHA-256" do
      resultado = exportar("csv")
      exportacao = resultado.exportacao.reload

      expect(exportacao).to be_concluida
      expect(exportacao).to have_attributes(usuario: administrador, tipo: "operacao_global", formato: "csv",
                                            quantidade_registros: 2, total_debitos: BigDecimal("7.00"))
      expect(exportacao.filtros).to eq("data" => "2025-10-24", "turno" => "todos", "unidade_id" => unidade.id)
      expect(exportacao.arquivo_sha256).to eq(Digest::SHA256.hexdigest(resultado.conteudo))
    end

    it "registra a falha e não entrega arquivo quando a geração quebra" do
      allow(Relatorios::OperacaoGlobalPdf).to receive(:new).and_raise(StandardError, "falha simulada")

      resultado = exportar("pdf")

      expect(resultado).not_to be_sucesso
      expect(resultado.mensagem).to eq("Não foi possível gerar o arquivo. Tente novamente")
      expect(resultado.exportacao.reload).to be_falhou
    end
  end

  context "sem acessos" do
    it "registra sem_dados e não entrega arquivo" do
      resultado = exportar("pdf")

      expect(resultado).not_to be_sucesso
      expect(resultado.mensagem).to eq("Nenhum acesso encontrado")
      expect(resultado.exportacao.reload).to be_sem_dados
    end
  end
end
