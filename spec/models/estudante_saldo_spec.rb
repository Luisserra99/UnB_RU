require "rails_helper"

RSpec.describe Estudante, "#saldo", type: :model do
  it "é zero sem lançamentos" do
    expect(create(:estudante).saldo).to eq(0)
  end

  it "soma créditos e débitos" do
    estudante = create(:estudante, saldo: 10)
    create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: -2.5)
    expect(estudante.saldo).to eq(BigDecimal("7.50"))
    expect(estudante.saldo).to be_a(BigDecimal)
  end

  it "aceita saldo inicial arbitrário pela factory" do
    expect(create(:estudante, saldo: 2).saldo).to eq(BigDecimal("2.00"))
    expect(create(:usuario_estudante, saldo: 7.5).estudante.saldo).to eq(BigDecimal("7.50"))
  end

  it "não considera recargas pendentes" do
    estudante = create(:estudante)
    create(:recarga, estudante: estudante, quantidade: 5)
    expect(estudante.saldo).to eq(0)
  end
end
