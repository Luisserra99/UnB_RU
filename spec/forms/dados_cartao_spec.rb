require "rails_helper"

RSpec.describe DadosCartao do
  include ActiveSupport::Testing::TimeHelpers

  let(:validos) { { numero: "4111 1111 1111 1111", nome: "Fulana", validade: "12/30", cvv: "123" } }

  around { |exemplo| travel_to(Time.zone.local(2026, 11, 9)) { exemplo.run } }

  it "aceita dados válidos" do
    expect(described_class.new(validos)).to be_valid
  end

  it "rejeita número que não passa no algoritmo de Luhn ou sem 16 dígitos" do
    expect(described_class.new(validos.merge(numero: "4111 1111 1111 1112"))).not_to be_valid
    expect(described_class.new(validos.merge(numero: "4111"))).not_to be_valid
  end

  it "rejeita cartão vencido e validade mal formatada" do
    expect(described_class.new(validos.merge(validade: "10/26"))).not_to be_valid
    expect(described_class.new(validos.merge(validade: "11/26"))).to be_valid
    expect(described_class.new(validos.merge(validade: "13/30"))).not_to be_valid
    expect(described_class.new(validos.merge(validade: "1230"))).not_to be_valid
  end

  it "exige CVV de 3 dígitos e nome" do
    expect(described_class.new(validos.merge(cvv: "12"))).not_to be_valid
    expect(described_class.new(validos.merge(nome: ""))).not_to be_valid
  end

  it "expõe só os últimos dígitos" do
    expect(described_class.new(validos).ultimos_digitos).to eq("1111")
  end
end
