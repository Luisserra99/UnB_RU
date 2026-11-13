require "rails_helper"

RSpec.describe Extratos::Consulta do
  let(:estudante) { create(:estudante) }
  let(:outro) { create(:estudante) }
  subject(:consulta) { described_class.new(estudante) }

  context "sem lançamentos" do
    it "fica vazio e com saldo zero (RN03.4)" do
      expect(consulta).to be_vazio
      expect(consulta.saldo).to eq(0)
      expect(consulta.movimentacoes).to be_empty
      expect(consulta.refeicoes).to be_empty
      expect(consulta.ultimas_recargas).to be_empty
    end
  end

  context "com recarga e refeições" do
    let!(:credito) do
      create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: BigDecimal("22.50"),
                                                    ocorrida_em: Time.zone.local(2026, 11, 2, 9, 0))
    end
    let!(:almoco) do
      create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: BigDecimal("-4.50"),
                                                    ocorrida_em: Time.zone.local(2026, 11, 5, 12, 30))
    end
    let!(:jantar) do
      create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: BigDecimal("-4.50"),
                                                    ocorrida_em: Time.zone.local(2026, 11, 6, 18, 5))
    end

    before { create(:movimentacao_saldo, :credito_recarga, estudante: outro, valor: BigDecimal("50.00")) }

    it "calcula o saldo pela soma das movimentações" do
      expect(consulta.saldo).to eq(BigDecimal("13.50"))
    end

    it "lista só as movimentações do próprio estudante, mais recentes primeiro (RN03.1)" do
      expect(consulta.movimentacoes.map(&:id)).to eq([ jantar.id, almoco.id, credito.id ])
    end

    it "lista as refeições com data, horário e tipo (RN03.2)" do
      refeicao = consulta.refeicoes.first
      expect(refeicao.data).to eq(Date.new(2026, 11, 6))
      expect(refeicao.horario).to eq("18:05")
      expect(refeicao.tipo).to eq("Refeição")
      expect(refeicao.valor).to eq(BigDecimal("4.50"))
      expect(consulta.refeicoes.size).to eq(2)
    end

    it "usa o tipo da refeição quando a movimentação o informa (extensão da F06)" do
      tipo = create(:tipo_refeicao, codigo: TipoRefeicao::JANTAR)
      allow_any_instance_of(MovimentacaoSaldo).to receive(:tipo_refeicao).and_return(tipo)
      expect(consulta.refeicoes.first.tipo).to eq(tipo.nome)
    end

    it "traz as últimas recargas confirmadas (RN03.3)" do
      expect(consulta.ultimas_recargas).to eq([ credito.recarga ])
      expect(consulta).not_to be_vazio
    end
  end

  it "não inclui recargas pendentes entre as últimas recargas" do
    create(:recarga, estudante: estudante)
    expect(consulta.ultimas_recargas).to be_empty
  end
end
