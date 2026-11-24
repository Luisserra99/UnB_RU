require "rails_helper"

RSpec.describe UsuarioPapel, type: :model do
  it "usa chave primária composta (usuario_id, papel_id)" do
    expect(described_class.primary_key).to eq(%w[usuario_id papel_id])
  end

  it "é válido para um papel que o usuário ainda não tem" do
    funcionario = create(:funcionario)
    papel = create(:papel, codigo: Papel::ADMINISTRADOR)
    expect(described_class.new(usuario: funcionario, papel: papel)).to be_valid
  end

  it "não permite o mesmo papel duas vezes para o usuário" do
    funcionario = create(:funcionario)
    papel = funcionario.papeis.first
    expect(described_class.new(usuario: funcionario, papel: papel)).not_to be_valid
  end

  it "exige usuário e papel" do
    ligacao = described_class.new
    expect(ligacao).not_to be_valid
    expect(ligacao.errors.attribute_names).to include(:usuario, :papel)
  end
end
