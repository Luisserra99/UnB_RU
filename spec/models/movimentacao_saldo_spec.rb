require "rails_helper"

RSpec.describe MovimentacaoSaldo, type: :model do
  let(:estudante) { create(:estudante) }

  describe "crédito de recarga" do
    it "exige recarga confirmada do mesmo estudante" do
      pendente = create(:recarga, estudante: estudante)
      credito = described_class.new(estudante: estudante, recarga: pendente, natureza: "credito_recarga",
                                    valor: pendente.valor_total, ocorrida_em: Time.current)
      expect(credito).not_to be_valid
      expect(credito.errors[:recarga]).to include("deve estar confirmada")

      de_outro = create(:recarga, estudante: create(:estudante), status: "confirmada", confirmada_em: Time.current)
      credito.recarga = de_outro
      expect(credito).not_to be_valid
      expect(credito.errors[:recarga]).to include("deve ser do mesmo estudante")
    end

    it "exige valor positivo" do
      credito = build(:movimentacao_saldo, :credito_recarga, estudante: estudante)
      credito.valor = -1
      expect(credito).not_to be_valid
    end

    it "descreve a recarga com o método de pagamento" do
      recarga = create(:recarga, :confirmada, estudante: estudante)
      expect(recarga.movimentacao_saldo.descricao).to eq("Recarga de Saldo (Cartão de Crédito)")
    end
  end

  describe "débito de refeição" do
    it "exige valor negativo e não aceita recarga" do
      debito = build(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: 4.5)
      expect(debito).not_to be_valid
      expect(debito.errors[:valor]).to include("do débito deve ser negativo")
    end

    it "é descrito como refeição" do
      expect(build(:movimentacao_saldo, :debito_refeicao).descricao).to eq("Refeição")
    end
  end

  it "o banco rejeita lançamento incoerente" do
    debito = create(:movimentacao_saldo, :debito_refeicao, estudante: estudante)
    expect { debito.update_column(:valor, 5) }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "lista os mais recentes primeiro" do
    antigo = create(:movimentacao_saldo, estudante: estudante, ocorrida_em: 2.days.ago)
    novo = create(:movimentacao_saldo, estudante: estudante, ocorrida_em: 1.day.ago)
    expect(estudante.movimentacoes_saldo.recentes).to eq([ novo, antigo ])
  end
end
