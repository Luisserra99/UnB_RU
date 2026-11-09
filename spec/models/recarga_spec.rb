require "rails_helper"

RSpec.describe Recarga, type: :model do
  let(:estudante) { create(:estudante) }

  it "é válida com itens cuja soma é o valor total" do
    expect(build(:recarga, estudante: estudante, quantidade: 3)).to be_valid
  end

  it "exige ao menos uma refeição" do
    recarga = described_class.new(estudante: estudante, solicitada_em: Time.current, valor_total: 4.5)
    expect(recarga).not_to be_valid
    expect(recarga.errors[:itens]).to be_present
  end

  it "exige valor total igual à soma dos itens" do
    recarga = build(:recarga, estudante: estudante, quantidade: 2)
    recarga.valor_total = 1
    expect(recarga).not_to be_valid
    expect(recarga.errors[:valor_total]).to include("deve ser igual à soma dos itens")
  end

  it "rejeita status desconhecido" do
    recarga = build(:recarga, estudante: estudante)
    recarga.status = "paga"
    expect(recarga).not_to be_valid
  end

  it "não aceita valor total zerado nem no banco" do
    recarga = create(:recarga, estudante: estudante)
    expect { recarga.update_column(:valor_total, 0) }.to raise_error(ActiveRecord::StatementInvalid)
  end

  describe "trait :confirmada" do
    it "credita o valor no saldo do estudante" do
      recarga = create(:recarga, :confirmada, estudante: estudante, quantidade: 5)
      expect(recarga).to be_confirmada
      expect(estudante.saldo).to eq(BigDecimal("22.50"))
    end
  end

  describe "#subtotal_do_tipo" do
    it "devolve zero para tipo sem item" do
      recarga = create(:recarga, estudante: estudante, quantidade: 2)
      expect(recarga.subtotal_do_tipo(TipoRefeicao::ALMOCO)).to eq(BigDecimal("9.00"))
      expect(recarga.subtotal_do_tipo(TipoRefeicao::CAFE_DA_MANHA)).to eq(0)
    end
  end
end
