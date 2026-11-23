require "rails_helper"

RSpec.describe RateioConsumo, type: :model do
  let(:estudante) { create(:estudante) }
  let(:credito) { create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: 5) }
  let(:debito) { create(:movimentacao_saldo, estudante: estudante, valor: -5) }

  it "aceita o consumo exato e não conta o próprio rateio novamente na atualização" do
    rateio = described_class.create!(movimentacao_saldo: debito, recarga: credito.recarga, valor: 5)
    expect(rateio.reload).to be_valid
    expect { rateio.update!(valor: 5) }.not_to raise_error
    expect(described_class.sum(:valor)).to eq(5)
  end

  it "não permite financiar um débito com recarga pendente" do
    recarga = create(:recarga, estudante: estudante)
    rateio = described_class.new(movimentacao_saldo: debito, recarga: recarga, valor: 1)
    expect(rateio).not_to be_valid
    expect(rateio.errors[:base]).to include("Rateio exige débito e recarga confirmada do mesmo estudante")
  end

  it "não permite usar crédito como destino do consumo" do
    rateio = described_class.new(movimentacao_saldo: credito, recarga: credito.recarga, valor: 1)
    expect(rateio).not_to be_valid
    expect(rateio.errors[:base]).to be_present
  end

  it "não permite consumir recarga confirmada sem movimentação real de crédito" do
    recarga = create(:recarga, estudante: estudante, status: :confirmada, confirmada_em: Time.current)
    rateio = described_class.new(movimentacao_saldo: debito, recarga: recarga, valor: 1)
    expect(rateio).not_to be_valid
    expect(rateio.errors[:valor]).to include("excede o crédito disponível da recarga")
  end

  it "contabiliza o consumo de outros débitos na disponibilidade da recarga" do
    described_class.create!(movimentacao_saldo: debito, recarga: credito.recarga, valor: 4)
    outro_debito = create(:movimentacao_saldo, estudante: estudante, valor: -2)
    rateio = described_class.new(movimentacao_saldo: outro_debito, recarga: credito.recarga, valor: 2)
    expect(rateio).not_to be_valid
    expect(rateio.errors[:valor]).to include("excede o crédito disponível da recarga")
  end

  it "contabiliza outras recargas no limite do mesmo débito" do
    described_class.create!(movimentacao_saldo: debito, recarga: credito.recarga, valor: 4)
    outro_credito = create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: 5)
    rateio = described_class.new(movimentacao_saldo: debito, recarga: outro_credito.recarga, valor: 2)
    expect(rateio).not_to be_valid
    expect(rateio.errors[:valor]).to include("excede o débito")
  end

  it "relata campos ausentes sem executar cálculos sobre origens nulas" do
    rateio = described_class.new
    expect(rateio).not_to be_valid
    expect(rateio.errors.attribute_names).to include(:movimentacao_saldo, :recarga, :valor)
  end
end
