require "rails_helper"

RSpec.describe ItemRecarga, type: :model do
  it "calcula o subtotal pela quantidade e o valor unitário" do
    item = described_class.new(quantidade: 5, valor_unitario: BigDecimal("2.50"))
    expect(item.subtotal).to eq(BigDecimal("12.50"))
  end

  it "exige quantidade inteira positiva" do
    item = build(:item_recarga, quantidade: 0)
    expect(item).not_to be_valid
    expect(item.errors[:quantidade]).to be_present
  end

  it "exige tarifa do mesmo tipo de refeição" do
    cafe = create(:tarifa_refeicao, :cafe)
    almoco = create(:tarifa_refeicao, :almoco)
    item = build(:item_recarga, tarifa_refeicao: cafe, tipo_refeicao: almoco.tipo_refeicao)
    expect(item).not_to be_valid
    expect(item.errors[:tarifa_refeicao]).to include("não corresponde ao tipo de refeição")
  end
end
