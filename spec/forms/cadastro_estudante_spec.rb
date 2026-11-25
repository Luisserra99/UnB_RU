require "rails_helper"

RSpec.describe CadastroEstudante do
  before { create(:papel, codigo: Papel::ESTUDANTE) }

  let(:atributos) do
    { nome: "Weldo Junior", matricula: "222014133", email: "222014133@aluno.unb.br", senha: "senhaSegura" }
  end

  def cadastro(**sobrescritas)
    described_class.new(atributos.merge(sobrescritas))
  end

  it "cria usuário, estudante e papel de estudante com dados válidos" do
    form = cadastro
    expect { expect(form.salvar).to be(true) }
      .to change(Usuario, :count).by(1).and change(Estudante, :count).by(1)

    usuario = form.usuario
    expect(usuario.identificacao).to eq("222014133")
    expect(usuario.estudante.matricula).to eq("222014133")
    expect(usuario).to be_estudante
    expect(usuario.authenticate("senhaSegura")).to eq(usuario)
  end

  it "aceita o domínio @unb.br e ignora maiúsculas no email" do
    expect(cadastro(email: "Weldo@UnB.br").salvar).to be(true)
  end

  it "rejeita matrícula com menos de 9 números" do
    form = cadastro(matricula: "22201413")
    expect { form.salvar }.not_to change(Usuario, :count)
    expect(form.errors[:matricula]).to include(CadastroEstudante::MSG_MATRICULA)
  end

  it "rejeita matrícula com letras" do
    form = cadastro(matricula: "abc123xyz")
    expect(form.salvar).to be(false)
    expect(form.errors[:matricula]).to include(CadastroEstudante::MSG_MATRICULA)
  end

  it "rejeita email fora do domínio da faculdade" do
    %w[weldo@gmail.com weldo@unb.br.com weldo@fakeunb.br].each do |email|
      form = cadastro(email: email)
      expect(form.salvar).to be(false), "esperava rejeitar #{email}"
      expect(form.errors[:email]).to include(CadastroEstudante::MSG_EMAIL)
    end
    expect(Usuario.count).to eq(0)
  end

  it "rejeita senha com menos de 8 caracteres" do
    form = cadastro(senha: "1234567")
    expect { form.salvar }.not_to change(Usuario, :count)
    expect(form.errors[:senha]).to include(CadastroEstudante::MSG_SENHA)
  end

  it "rejeita matrícula ou email já cadastrados" do
    cadastro.salvar
    repetido = cadastro(email: "outro@aluno.unb.br")
    expect(repetido.salvar).to be(false)
    expect(repetido.errors[:matricula]).to include("Matrícula já cadastrada")

    email_repetido = cadastro(matricula: "222014134")
    expect(email_repetido.salvar).to be(false)
    expect(email_repetido.errors[:email]).to include("Email já cadastrado")
  end

  it "rejeita matrícula já usada como identificação de outro usuário" do
    create(:usuario, identificacao: "222014133")
    form = cadastro
    expect(form.salvar).to be(false)
    expect(form.errors[:matricula]).to include("Matrícula já cadastrada")
  end

  it "exige o nome" do
    form = cadastro(nome: "")
    expect(form.salvar).to be(false)
    expect(form.errors[:nome]).to include("Nome é obrigatório")
  end

  it "ignora espaços em volta da matrícula e do email" do
    form = cadastro(matricula: " 222014133 ", email: " 222014133@aluno.unb.br ")
    expect(form.salvar).to be(true)
    expect(form.usuario).to have_attributes(identificacao: "222014133", email: "222014133@aluno.unb.br")
  end

  describe "quando o banco rejeita a gravação" do
    it "devolve false, informa o motivo e não deixa o usuário gravado pela metade" do
      allow_any_instance_of(Usuario).to receive(:atribuir_papel!).and_raise(ActiveRecord::RecordNotUnique, "papel repetido")

      form = cadastro
      expect(form.salvar).to be(false)
      expect(Usuario.count).to eq(0)
      expect(Estudante.count).to eq(0)
      expect(form.errors[:base]).to include("Não foi possível concluir o cadastro: papel repetido")
    end

    it "trata registro inválido no banco da mesma forma" do
      allow(Usuario).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Usuario.new))

      form = cadastro
      expect(form.salvar).to be(false)
      expect(form.errors[:base].first).to start_with("Não foi possível concluir o cadastro")
    end
  end

  describe ".dominio_da_faculdade?" do
    it "aceita os domínios da faculdade, com espaços e maiúsculas" do
      expect(described_class.dominio_da_faculdade?(" Fulano@ALUNO.unb.br ")).to be(true)
      expect(described_class.dominio_da_faculdade?("fulano@unb.br")).to be(true)
    end

    it "recusa outro domínio, email sem arroba e nil" do
      expect(described_class.dominio_da_faculdade?("fulano@gmail.com")).to be(false)
      expect(described_class.dominio_da_faculdade?("fulano")).to be(false)
      expect(described_class.dominio_da_faculdade?(nil)).to be(false)
    end
  end
end
