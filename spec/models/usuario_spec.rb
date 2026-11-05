require "rails_helper"

RSpec.describe Usuario, type: :model do
  describe "validações" do
    it "é válido com os atributos da factory" do
      expect(build(:usuario)).to be_valid
    end

    it "exige nome, identificação e email" do
      usuario = build(:usuario, nome: "", identificacao: "", email: "")
      expect(usuario).not_to be_valid
      expect(usuario.errors.attribute_names).to include(:nome, :identificacao, :email)
    end

    it "não permite identificação repetida" do
      create(:usuario, identificacao: "funcionario01")
      expect(build(:usuario, identificacao: "funcionario01")).not_to be_valid
    end

    it "não permite email repetido, ignorando maiúsculas" do
      create(:usuario, email: "fulano@unb.br")
      expect(build(:usuario, email: "FULANO@unb.br")).not_to be_valid
    end

    it "rejeita email em formato inválido" do
      expect(build(:usuario, email: "sem-arroba")).not_to be_valid
    end

    it "exige senha com no mínimo 8 caracteres" do
      expect(build(:usuario, password: "1234567")).not_to be_valid
      expect(build(:usuario, password: "12345678")).to be_valid
    end

    it "normaliza email e identificação" do
      usuario = create(:usuario, email: "  Fulano@UNB.br ", identificacao: " func ")
      expect(usuario.email).to eq("fulano@unb.br")
      expect(usuario.identificacao).to eq("func")
    end
  end

  describe ".autenticar" do
    let!(:usuario) { create(:funcionario, identificacao: "funcionario01", password: "senhaCorreta") }

    it "retorna o usuário com credenciais corretas" do
      expect(described_class.autenticar("funcionario01", "senhaCorreta")).to eq(usuario)
    end

    it "retorna nil com senha incorreta" do
      expect(described_class.autenticar("funcionario01", "errada123")).to be_nil
    end

    it "retorna nil para identificação não cadastrada" do
      expect(described_class.autenticar("desconhecido", "senhaCorreta")).to be_nil
    end

    it "retorna nil para usuário inativo" do
      usuario.update!(ativo: false)
      expect(described_class.autenticar("funcionario01", "senhaCorreta")).to be_nil
    end

    it "retorna nil com campos vazios" do
      expect(described_class.autenticar("", "senhaCorreta")).to be_nil
      expect(described_class.autenticar("funcionario01", "")).to be_nil
    end
  end

  describe "papéis" do
    it "identifica funcionário, administrador e estudante" do
      expect(create(:funcionario)).to have_attributes(funcionario?: true, estudante?: false, pode_acessar_controle?: true)
      expect(create(:administrador)).to have_attributes(administrador?: true, pode_acessar_controle?: true)
      expect(create(:usuario_estudante)).to have_attributes(estudante?: true, pode_acessar_controle?: false)
    end

    it "não duplica um papel já atribuído" do
      funcionario = create(:funcionario)
      expect { funcionario.atribuir_papel!(Papel::FUNCIONARIO) }.not_to change(UsuarioPapel, :count)
    end
  end
end
