require "rails_helper"

RSpec.describe HistoricoCatraca::Consulta do
  let(:ponto) { create(:configuracao_ponto_acesso) }
  let(:catraca) { ponto.catraca }
  let(:base) { Time.zone.local(2026, 10, 14, 11, 30) }

  def registro(em:, configuracao: ponto, **atributos)
    create(:registro_acesso, configuracao_ponto_acesso: configuracao, lido_em: em, liberado_em: em,
                             passagem_em: em + 2.seconds, bloqueado_em: em + 2.seconds, valor_previsto: 2.5, **atributos)
  end

  it "traz só os registros da catraca, dos mais recentes aos mais antigos" do
    antigo = registro(em: base)
    novo = registro(em: base + 1.hour)
    registro(em: base + 30.minutes, configuracao: create(:configuracao_ponto_acesso))

    expect(described_class.new(catraca).registros).to eq([ novo, antigo ])
  end

  it "inclui registros de sessões anteriores na mesma catraca" do
    sessao_anterior = create(:configuracao_ponto_acesso, catraca: catraca,
                                                         confirmada_em: base - 1.hour, finalizada_em: base + 1.day)
    do_turno_anterior = registro(em: base, configuracao: sessao_anterior)

    expect(described_class.new(catraca).registros).to include(do_turno_anterior)
  end

  it "soma passagens e total debitado somente dos acessos realizados" do
    registro(em: base)
    registro(em: base + 1.minute)
    registro(em: base + 2.minutes, estado: "recusado", mensagem: "Saldo insuficiente",
             liberado_em: nil, passagem_em: nil, bloqueado_em: nil)

    consulta = described_class.new(catraca)
    expect(consulta.total).to eq(3)
    expect(consulta.passagens).to eq(2)
    expect(consulta.total_debitado).to eq(5)
  end

  it "pagina de #{described_class::POR_PAGINA} em #{described_class::POR_PAGINA}" do
    (described_class::POR_PAGINA + 2).times { |i| registro(em: base + i.minutes) }

    expect(described_class.new(catraca).registros.size).to eq(described_class::POR_PAGINA)
    segunda = described_class.new(catraca, pagina: 2)
    expect(segunda.registros.size).to eq(2)
    expect(segunda.total_paginas).to eq(2)
  end

  it "trata página inválida como a primeira" do
    expect(described_class.new(catraca, pagina: "abc").pagina).to eq(1)
    expect(described_class.new(catraca, pagina: -3).pagina).to eq(1)
  end

  it "fica vazia quando a catraca não tem registros" do
    consulta = described_class.new(catraca)
    expect(consulta).to be_vazio
    expect(consulta.total_paginas).to eq(1)
  end
end
