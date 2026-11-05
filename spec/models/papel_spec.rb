require "rails_helper"

RSpec.describe Papel, type: :model do
  it "exige código único e descrição" do
    Papel.create!(codigo: "funcionario", descricao: "Funcionário")
    expect(Papel.new(codigo: "funcionario", descricao: "x")).not_to be_valid
    expect(Papel.new(codigo: "outro", descricao: "")).not_to be_valid
  end

  it "não pode ser removido enquanto houver usuários com o papel" do
    funcionario = create(:funcionario)
    papel = funcionario.papeis.first
    expect(papel.destroy).to be(false)
    expect(Papel.exists?(papel.id)).to be(true)
  end
end
