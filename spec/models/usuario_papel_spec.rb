require "rails_helper"

RSpec.describe UsuarioPapel, type: :model do
  it "usa chave primária composta (usuario_id, papel_id)" do
    expect(described_class.primary_key).to eq(%w[usuario_id papel_id])
  end

  it "não permite o mesmo papel duas vezes para o usuário" do
    funcionario = create(:funcionario)
    papel = funcionario.papeis.first
    expect(described_class.new(usuario: funcionario, papel: papel)).not_to be_valid
  end
end
