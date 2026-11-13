require "rails_helper"

RSpec.describe Extratos::Exportar do
  let(:agora) { Time.zone.local(2024, 5, 14, 20, 0) }
  let(:usuario) { create(:usuario_estudante, nome: "Ana Beatriz Silva") }
  let(:estudante) { usuario.estudante }
  let(:ponto) { create(:configuracao_ponto_acesso) }
  let(:relatorio) { Extratos::Relatorio.new(estudante, {}, agora: agora) }

  def exportar(formato, relatorio_usado = relatorio)
    described_class.call(usuario: usuario, relatorio: relatorio_usado, formato: formato, agora: agora)
  end

  around { |exemplo| travel_to(agora) { exemplo.run } }

  context "com lançamentos" do
    before do
      recarga_do_extrato(estudante, em: Time.zone.local(2024, 5, 10, 14, 0))
      refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 14, 12, 20), ponto: ponto,
                                     tipo: tipo_refeicao_de(TipoRefeicao::ALMOCO, "Almoço"))
    end

    it "gera um PDF com identificação, filtros, totais e lançamentos" do
      resultado = exportar("pdf")
      texto = texto_do_pdf(resultado.conteudo)

      expect(resultado).to be_sucesso
      expect(resultado.tipo_mime).to eq("application/pdf")
      expect(resultado.nome_arquivo).to match(/\Aextrato-#{estudante.matricula}-20240514-200000-\d+\.pdf\z/)
      expect(texto).to include("Estudante: Ana Beatriz Silva", "Matrícula: #{estudante.matricula}",
                               "Período de referência: Últimos 30 dias", "Data de emissão: 14/05/2024 20:00",
                               "Total gasto: R$ 4,50", "Total recarregado: R$ 45,00", "Saldo atual: R$ 40,50",
                               "Refeições realizadas: 1", "14/05/2024 12:20 Almoço", "Registros auditáveis")
    end

    it "não declara assinatura digital que não foi feita" do
      resultado = exportar("pdf")

      expect(texto_do_pdf(resultado.conteudo)).not_to include("assinad")
      expect(resultado.exportacao.assinatura_status).to eq("nao_aplicavel")
    end

    it "gera um CSV com cabeçalho e uma linha por lançamento" do
      resultado = exportar("csv")
      linhas = resultado.conteudo.delete_prefix("﻿").lines.map(&:chomp)

      expect(resultado.tipo_mime).to start_with("text/csv")
      expect(resultado.nome_arquivo).to end_with(".csv")
      expect(linhas.first).to eq("data_hora;evento;local;catraca;valor")
      expect(linhas.size).to eq(3)
      expect(linhas.second).to start_with("14/05/2024 12:20;Almoço;").and end_with(";-4,50")
      expect(linhas.third).to end_with(";45,00")
    end

    it "registra a exportação concluída com totais e SHA-256 do arquivo" do
      resultado = exportar("pdf")
      exportacao = resultado.exportacao.reload

      expect(exportacao).to be_concluida
      expect(exportacao).to have_attributes(usuario: usuario, tipo: "extrato_estudante", formato: "pdf",
                                            quantidade_registros: 2, total_debitos: BigDecimal("4.50"),
                                            total_creditos: BigDecimal("45.00"))
      expect(exportacao.filtros).to eq("tipo" => "todas", "periodo" => "30_dias", "catraca_id" => nil)
      expect(exportacao.arquivo_sha256).to eq(Digest::SHA256.hexdigest(resultado.conteudo))
      expect(exportacao.arquivo_chave).to eq("extratos/#{resultado.nome_arquivo}")
      expect(exportacao.emitida_em).to be_present
    end

    it "usa PDF quando o formato pedido não é suportado" do
      expect(exportar("docx").exportacao.formato).to eq("pdf")
    end

    it "registra a falha e não entrega arquivo quando a geração quebra" do
      allow(Extratos::Pdf).to receive(:new).and_raise(StandardError, "sem memória")

      resultado = exportar("pdf")

      expect(resultado).not_to be_sucesso
      expect(resultado.conteudo).to be_nil
      expect(resultado.mensagem).to eq("Não foi possível gerar o arquivo. Tente novamente")
      expect(resultado.exportacao.reload).to be_falhou
      expect(resultado.exportacao.arquivo_sha256).to be_nil
    end
  end

  context "sem lançamentos para os filtros" do
    it "registra sem_dados e devolve a mensagem, sem arquivo" do
      resultado = exportar("pdf")

      expect(resultado).not_to be_sucesso
      expect(resultado.mensagem).to eq("Não há lançamentos para os filtros selecionados")
      expect(resultado.exportacao.reload).to be_sem_dados
      expect(resultado.exportacao.quantidade_registros).to eq(0)
    end
  end
end
