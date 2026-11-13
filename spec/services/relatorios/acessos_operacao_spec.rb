require "rails_helper"

RSpec.describe Relatorios::AcessosOperacao do
  let(:agora) { Time.zone.local(2026, 10, 16, 20, 0) }
  let(:darcy) { create(:restaurante, nome: "RU Darcy Ribeiro", quantidade_pisos: 1) }
  let(:gama) { create(:restaurante, nome: "RU Gama", quantidade_pisos: 1) }
  let!(:darcy_um) { create(:catraca, piso: darcy.pisos.first, identificacao: "Catraca 01") }
  let!(:darcy_dois) { create(:catraca, piso: darcy.pisos.first, identificacao: "Catraca 02") }
  let!(:gama_um) { create(:catraca, piso: gama.pisos.first, identificacao: "Catraca 01") }

  def relatorio(filtros = {})
    described_class.new({ inicio: "2026-10-14", fim: "2026-10-15" }.merge(filtros), agora: agora)
  end

  around { |exemplo| travel_to(agora) { exemplo.run } }

  before do
    acesso_na_catraca(darcy_um, em: Time.zone.local(2026, 10, 14, 0, 0), referencia: "A001")
    acesso_na_catraca(darcy_um, em: Time.zone.local(2026, 10, 15, 12, 10), referencia: "A002")
    acesso_na_catraca(darcy_dois, em: Time.zone.local(2026, 10, 15, 12, 20), referencia: "A003")
    acesso_na_catraca(gama_um, em: Time.zone.local(2026, 10, 15, 23, 59), referencia: "A004")
    acesso_na_catraca(gama_um, em: Time.zone.local(2026, 10, 16, 0, 0), referencia: "A005")
  end

  it "lista em ordem cronológica os acessos do período, com limites inclusivos (RN12.2)" do
    expect(relatorio.acessos.map(&:referencia)).to eq(%w[A001 A002 A003 A004])
    expect(relatorio.quantidade).to eq(4)
    expect(relatorio.total_debitado).to eq(BigDecimal("18.00"))
  end

  it "descreve cada acesso com os dados de auditoria (RN12.3)" do
    acesso = relatorio.acessos.second

    expect(acesso).to have_attributes(referencia: "A002", restaurante: "RU Darcy Ribeiro", catraca: "Catraca 01",
                                      refeicao: "Refeição", valor: BigDecimal("4.50"))
    expect(acesso.matricula).to match(/\A\d{9}\z/)
    expect(acesso.momento).to eq(Time.zone.local(2026, 10, 15, 12, 10))
  end

  it "filtra por restaurante e por catraca" do
    expect(relatorio(restaurante_id: darcy.id).acessos.map(&:referencia)).to eq(%w[A001 A002 A003])
    expect(relatorio(catraca_id: darcy_um.id).acessos.map(&:referencia)).to eq(%w[A001 A002])
    expect(relatorio(restaurante_id: gama.id, catraca_id: gama_um.id).acessos.map(&:referencia)).to eq(%w[A004])
  end

  it "ignora restaurante e catraca inexistentes" do
    resultado = relatorio(restaurante_id: "999999", catraca_id: "abc")

    expect(resultado.restaurante_nome).to eq("Todos")
    expect(resultado.catraca_nome).to eq("Todas")
    expect(resultado.quantidade).to eq(4)
  end

  it "não mistura catracas de mesmo nome de restaurantes diferentes nos subtotais (RN12.5)" do
    grupos = relatorio(agrupar: "1").grupos
    resumo = grupos.flat_map { |grupo| grupo.catracas.map { |sub| [ sub.restaurante, sub.catraca, sub.quantidade, sub.total ] } }

    expect(resumo).to eq([ [ "RU Darcy Ribeiro", "Catraca 01", 2, BigDecimal("9.00") ],
                          [ "RU Darcy Ribeiro", "Catraca 02", 1, BigDecimal("4.50") ],
                          [ "RU Gama", "Catraca 01", 1, BigDecimal("4.50") ] ])
    expect(grupos.map { |grupo| [ grupo.restaurante, grupo.quantidade, grupo.total ] })
      .to eq([ [ "RU Darcy Ribeiro", 3, BigDecimal("13.50") ], [ "RU Gama", 1, BigDecimal("4.50") ] ])
  end

  it "registra o agrupamento só quando ele foi pedido" do
    expect(relatorio.agrupamentos).to eq({})
    expect(relatorio(agrupar: "1").agrupamentos).to eq("por" => %w[restaurante catraca])
    expect(relatorio(agrupar: "1").agrupamento_nome).to eq("Restaurante e catraca")
  end

  it "rejeita período com a data inicial depois da final (RN12.7)" do
    resultado = relatorio(inicio: "2026-10-16", fim: "2026-10-14")

    expect(resultado).not_to be_valido
    expect(resultado.erro).to eq("A data inicial deve ser anterior ou igual à data final")
    expect(resultado.acessos).to be_empty
  end

  it "aceita período de um único dia" do
    expect(relatorio(inicio: "2026-10-15", fim: "2026-10-15").acessos.map(&:referencia)).to eq(%w[A002 A003 A004])
  end

  it "usa os últimos 7 dias quando não há datas ou elas são inválidas" do
    resultado = described_class.new({ inicio: "ontem", fim: "" }, agora: agora)

    expect([ resultado.inicio, resultado.fim ]).to eq([ Date.new(2026, 10, 10), Date.new(2026, 10, 16) ])
    expect(resultado.quantidade).to eq(5)
  end

  it "fica vazio quando o período não tem acessos" do
    expect(relatorio(inicio: "2026-10-01", fim: "2026-10-02")).to be_vazio
  end

  it "não lista leituras recusadas" do
    create(:registro_acesso, configuracao_ponto_acesso: ConfiguracaoPontoAcesso.first, estado: "recusado",
                             liberado_em: nil, passagem_em: nil, bloqueado_em: nil,
                             lido_em: Time.zone.local(2026, 10, 15, 13, 0))

    expect(relatorio.quantidade).to eq(4)
  end

  describe "paginação da tela" do
    it "divide a listagem sem afetar os totais" do
      resultado = relatorio(por_pagina: "2", pagina: "2")

      expect(resultado.total_paginas).to eq(2)
      expect(resultado.acessos_da_pagina.map(&:referencia)).to eq(%w[A003 A004])
      expect(resultado.quantidade).to eq(4)
    end

    it "limita página e tamanho a valores válidos" do
      resultado = relatorio(por_pagina: "0", pagina: "99")

      expect(resultado.por_pagina).to eq(1)
      expect(resultado.pagina_atual).to eq(4)
      expect(relatorio(por_pagina: "5000").por_pagina).to eq(100)
    end
  end
end
