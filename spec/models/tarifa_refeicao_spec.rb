require "rails_helper"

RSpec.describe TarifaRefeicao, type: :model do
  let(:almoco) { create(:tipo_refeicao, codigo: TipoRefeicao::ALMOCO, nome: "Almoço") }

  it "exige valor positivo" do
    tarifa = described_class.new(tipo_refeicao: almoco, valor: 0, vigente_desde: Time.current)
    expect(tarifa).not_to be_valid
    expect(tarifa.errors[:valor]).to be_present
  end

  it "exige fim da vigência posterior ao início" do
    inicio = Time.zone.local(2026, 1, 1)
    tarifa = described_class.new(tipo_refeicao: almoco, valor: 4.5, vigente_desde: inicio, vigente_ate: inicio)
    expect(tarifa).not_to be_valid
    expect(tarifa.errors[:vigente_ate]).to be_present
  end

  it "impede vigências sobrepostas do mesmo tipo" do
    described_class.create!(tipo_refeicao: almoco, valor: 4.5, vigente_desde: Time.zone.local(2026, 1, 1))
    nova = described_class.new(tipo_refeicao: almoco, valor: 5, vigente_desde: Time.zone.local(2026, 6, 1))
    expect(nova).not_to be_valid
    expect(nova.errors[:base]).to include("Já existe uma tarifa vigente para este tipo de refeição nesse período")
  end

  it "permite vigências consecutivas" do
    described_class.create!(tipo_refeicao: almoco, valor: 4.5, vigente_desde: Time.zone.local(2026, 1, 1),
                            vigente_ate: Time.zone.local(2026, 6, 1))
    nova = described_class.new(tipo_refeicao: almoco, valor: 5, vigente_desde: Time.zone.local(2026, 6, 1))
    expect(nova).to be_valid
  end

  describe ".vigente_para" do
    it "devolve a tarifa vigente no momento, por tipo ou código" do
      antiga = described_class.create!(tipo_refeicao: almoco, valor: 4, vigente_desde: Time.zone.local(2026, 1, 1),
                                       vigente_ate: Time.zone.local(2026, 6, 1))
      atual = described_class.create!(tipo_refeicao: almoco, valor: 4.5, vigente_desde: Time.zone.local(2026, 6, 1))

      expect(described_class.vigente_para(almoco, Time.zone.local(2026, 3, 1))).to eq(antiga)
      expect(described_class.vigente_para(TipoRefeicao::ALMOCO, Time.zone.local(2026, 7, 1))).to eq(atual)
      expect(described_class.vigente_para(TipoRefeicao::ALMOCO, Time.zone.local(2025, 7, 1))).to be_nil
      expect(described_class.vigente_para("inexistente")).to be_nil
    end
  end
end
