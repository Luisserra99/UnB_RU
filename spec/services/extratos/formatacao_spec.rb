require "rails_helper"

# Sprint 3 — formatação compartilhada pelos arquivos exportados (F09, F11 e F12).
RSpec.describe Extratos::Formatacao do
  describe ".data_hora" do
    it "formata o momento no fuso da aplicação" do
      expect(described_class.data_hora(Time.zone.local(2024, 5, 14, 12, 20))).to eq("14/05/2024 12:20")
    end

    it "converte para o fuso da aplicação um momento informado em UTC" do
      momento = Time.utc(2024, 5, 14, 15, 20)

      expect(described_class.data_hora(momento)).to eq(momento.in_time_zone.strftime("%d/%m/%Y %H:%M"))
    end
  end

  describe ".reais" do
    it "formata o valor em reais, com vírgula decimal" do
      expect(described_class.reais(BigDecimal("4.5"))).to eq("R$ 4,50")
    end

    it "separa os milhares com ponto" do
      expect(described_class.reais(1234.5)).to eq("R$ 1.234,50")
    end
  end

  describe ".valor_com_sinal" do
    it "põe o sinal de mais nos créditos" do
      expect(described_class.valor_com_sinal(BigDecimal("45"))).to eq("+ R$ 45,00")
    end

    it "põe o sinal de menos nos débitos, sem repetir o sinal no valor" do
      expect(described_class.valor_com_sinal(BigDecimal("-4.5"))).to eq("- R$ 4,50")
    end
  end
end
