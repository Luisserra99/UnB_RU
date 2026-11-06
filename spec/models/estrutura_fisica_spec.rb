require "rails_helper"

RSpec.describe UnidadeGestora, type: :model do
  it "exige nome único" do
    create(:unidade_gestora, nome: "Campus Gama")
    expect(UnidadeGestora.new(nome: "Campus Gama")).not_to be_valid
    expect(UnidadeGestora.new(nome: "")).not_to be_valid
  end

  it "localiza a unidade padrão pelo nome" do
    unidade = create(:unidade_gestora, nome: UnidadeGestora::NOME_PADRAO)
    expect(UnidadeGestora.padrao).to eq(unidade)
  end

  it "não pode ser removida enquanto tiver restaurantes" do
    unidade = create(:restaurante).unidade_gestora
    expect(unidade.destroy).to be(false)
  end
end

RSpec.describe Piso, type: :model do
  let(:restaurante) { create(:restaurante) }

  it "exige número positivo" do
    expect(Piso.new(restaurante: restaurante, numero: 0)).not_to be_valid
    expect(Piso.new(restaurante: restaurante, numero: -1)).not_to be_valid
  end

  it "exige número único no restaurante" do
    expect(Piso.new(restaurante: restaurante, numero: 1)).not_to be_valid
    expect(Piso.new(restaurante: create(:restaurante), numero: 2)).to be_valid
  end

  it "não pode ser removido enquanto tiver catracas" do
    piso = restaurante.pisos.first
    create(:catraca, piso: piso)
    expect(piso.destroy).to be(false)
  end

  it "se apresenta como Piso N" do
    expect(Piso.new(numero: 3).nome).to eq("Piso 3")
  end
end
