require "rails_helper"

RSpec.describe Papel, type: :model do
  it "é válido com código e descrição" do
    expect(Papel.new(codigo: "funcionario", descricao: "Funcionário")).to be_valid
  end

  it "exige código único e descrição" do
    Papel.create!(codigo: "funcionario", descricao: "Funcionário")
    expect(Papel.new(codigo: "funcionario", descricao: "x")).not_to be_valid
    expect(Papel.new(codigo: "outro", descricao: "")).not_to be_valid
    expect(Papel.new(codigo: "", descricao: "Sem código")).not_to be_valid
  end

  it "pode ser removido quando nenhum usuário tem o papel" do
    papel = Papel.create!(codigo: "sem_uso", descricao: "Sem uso")
    expect(papel.destroy).to be_truthy
    expect(Papel.exists?(papel.id)).to be(false)
  end

  it "não pode ser removido enquanto houver usuários com o papel" do
    funcionario = create(:funcionario)
    papel = funcionario.papeis.first
    expect(papel.destroy).to be(false)
    expect(Papel.exists?(papel.id)).to be(true)
  end

  it "considera funcionário e administrador como papéis de controle" do
    expect(Papel::CODIGOS_CONTROLE).to contain_exactly(Papel::FUNCIONARIO, Papel::ADMINISTRADOR)
    expect(Papel::CODIGOS_CONTROLE).not_to include(Papel::ESTUDANTE)
  end
end
