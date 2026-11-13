require "rails_helper"

RSpec.describe Catraca, type: :model do
  let(:restaurante) { create(:restaurante, quantidade_pisos: 2) }
  let(:piso_1) { restaurante.pisos.find_by!(numero: 1) }
  let(:piso_2) { restaurante.pisos.find_by!(numero: 2) }

  it "nasce ativa e offline" do
    catraca = Catraca.create!(piso: piso_1, identificacao: "Catraca 01")
    expect(catraca).to be_ativa
    expect(catraca).not_to be_online
  end

  it "exige identificação" do
    catraca = Catraca.new(piso: piso_1, identificacao: " ")
    expect(catraca).not_to be_valid
    expect(catraca.errors[:identificacao]).to include("Identificação da catraca é obrigatória")
  end

  it "exige piso existente" do
    catraca = Catraca.new(identificacao: "Catraca 01")
    expect(catraca).not_to be_valid
    expect(catraca.errors[:piso]).to include("Piso inexistente para este restaurante")
  end

  it "rejeita identificação repetida no mesmo restaurante, inclusive em outro piso" do
    Catraca.create!(piso: piso_1, identificacao: "Catraca 01")
    repetida = Catraca.new(piso: piso_2, identificacao: "Catraca 01")
    expect(repetida).not_to be_valid
    expect(repetida.errors[:identificacao]).to include("Já existe uma catraca com essa identificação neste restaurante")
  end

  it "aceita a mesma identificação em outro restaurante" do
    Catraca.create!(piso: piso_1, identificacao: "Catraca 01")
    outro_piso = create(:restaurante).pisos.first
    expect(Catraca.new(piso: outro_piso, identificacao: "Catraca 01")).to be_valid
  end

  it "continua válida ao editar sem mudar a identificação" do
    catraca = Catraca.create!(piso: piso_1, identificacao: "Catraca 01")
    expect(catraca.update(ativa: false)).to be(true)
  end

  it "lista como disponíveis somente as ativas" do
    ativa = create(:catraca, piso: piso_1)
    create(:catraca, piso: piso_1, ativa: false)
    expect(Catraca.disponiveis).to eq([ ativa ])
  end

  describe "remoção" do
    let(:catraca) { create(:catraca, piso: piso_1) }

    it "é permitida quando a catraca não está em operação" do
      expect(catraca.destroy).to be_truthy
    end

    it "é impedida quando a catraca está em operação" do
      allow(catraca).to receive(:em_operacao?).and_return(true)
      expect(catraca.destroy).to be(false)
      expect(catraca.errors.full_messages).to include("Não é possível remover uma catraca em operação")
    end
  end
end
