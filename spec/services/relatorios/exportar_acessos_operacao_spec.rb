require "rails_helper"

RSpec.describe Relatorios::ExportarAcessosOperacao do
  let(:agora) { Time.zone.local(2026, 10, 16, 20, 0) }
  let(:administrador) { create(:administrador, nome: "Daniel Dezan Baby") }
  let(:darcy) { create(:restaurante, nome: "RU Darcy Ribeiro", quantidade_pisos: 1) }
  let!(:catraca) { create(:catraca, piso: darcy.pisos.first, identificacao: "Catraca 01") }
  let(:filtros) { { inicio: "2026-10-14", fim: "2026-10-15", agrupar: "1" } }

  def exportar(filtros_usados = filtros)
    relatorio = Relatorios::AcessosOperacao.new(filtros_usados, agora: agora)
    described_class.call(usuario: administrador, relatorio: relatorio, agora: agora)
  end

  around { |exemplo| travel_to(agora) { exemplo.run } }

  context "com acessos no período" do
    before do
      acesso_na_catraca(catraca, em: Time.zone.local(2026, 10, 14, 7, 30), referencia: "A001")
      acesso_na_catraca(catraca, em: Time.zone.local(2026, 10, 15, 12, 10), referencia: "A002")
    end

    it "gera o PDF com emissor, emissão, filtros, agrupamento, acessos e totais (RN12.3 e RN12.4)" do
      resultado = exportar
      texto = texto_de_pdf(resultado.conteudo)

      expect(resultado).to be_sucesso
      expect(resultado.nome_arquivo).to match(/\Arelatorio-operacao-2026-10-14-a-2026-10-15-\d+\.pdf\z/)
      expect(texto).to include("Emitido por: Daniel Dezan Baby (#{administrador.identificacao})",
                               "Emitido em: 16/10/2026 20:00", "Período: 14/10/2026 a 15/10/2026",
                               "Restaurante: Todos", "Catraca: Todas", "Agrupamento: Restaurante e catraca",
                               "A001 14/10/2026 07:30", "A002 15/10/2026 12:10",
                               "Subtotal RU Darcy Ribeiro · Catraca 01: 2 acessos · R$ 9,00",
                               "Total RU Darcy Ribeiro: 2 acessos · R$ 9,00",
                               "Total geral: 2 acessos", "Total debitado: R$ 9,00")
    end

    it "registra a exportação com filtros, agrupamento, totais e SHA-256" do
      resultado = exportar
      exportacao = resultado.exportacao.reload

      expect(exportacao).to be_concluida
      expect(exportacao).to have_attributes(usuario: administrador, tipo: "operacao_global", formato: "pdf",
                                            quantidade_registros: 2, total_debitos: BigDecimal("9.00"))
      expect(exportacao.filtros).to include("inicio" => "2026-10-14", "fim" => "2026-10-15")
      expect(exportacao.agrupamentos).to eq("por" => %w[restaurante catraca])
      expect(exportacao.arquivo_sha256).to eq(Digest::SHA256.hexdigest(resultado.conteudo))
    end

    it "em caso de falha, informa, não entrega arquivo e não altera os acessos (RN12.8)" do
      antes = MovimentacaoSaldo.order(:id).pluck(:id, :valor)
      allow(Relatorios::AcessosOperacaoPdf).to receive(:new).and_raise(StandardError, "falha simulada")

      resultado = exportar

      expect(resultado).not_to be_sucesso
      expect(resultado.conteudo).to be_nil
      expect(resultado.mensagem).to eq("Não foi possível gerar o PDF. Tente novamente")
      expect(resultado.exportacao.reload).to be_falhou
      expect(MovimentacaoSaldo.order(:id).pluck(:id, :valor)).to eq(antes)
    end
  end

  it "não gera arquivo quando o período não tem acessos (RN12.6)" do
    resultado = exportar

    expect(resultado).not_to be_sucesso
    expect(resultado.mensagem).to eq("Não há acessos para os filtros selecionados")
    expect(resultado.exportacao.reload).to be_sem_dados
  end

  it "não gera nem registra nada quando o período está invertido (RN12.7)" do
    resultado = exportar(inicio: "2026-10-16", fim: "2026-10-14")

    expect(resultado).not_to be_sucesso
    expect(resultado.mensagem).to eq("A data inicial deve ser anterior ou igual à data final")
    expect(ExportacaoRelatorio.count).to eq(0)
  end
end
