require "rails_helper"

RSpec.describe "Login do Portal do Estudante (F02/F03)", type: :request do
  let!(:aluno) { create(:usuario_estudante, password: "senhaCorreta") }

  it "exibe a tela de login" do
    get login_estudante_path
    expect(response.body).to include("Entrar no Portal do Estudante")
  end

  it "leva direto à recarga quem já está logado" do
    login_estudante(aluno)
    get login_estudante_path
    expect(response).to redirect_to(new_recarga_path)
  end

  it "autentica o estudante e leva à recarga" do
    expect { login_estudante(aluno) }.to change(SessaoAutenticacao, :count).by(1)
    expect(response).to redirect_to(new_recarga_path)
    follow_redirect!
    expect(response.body).to include("Recarga de Saldo")
    expect(response.body).to include(aluno.nome)
  end

  it "volta para a página pedida antes do login" do
    recarga = create(:recarga, estudante: aluno.estudante)
    get recarga_path(recarga)
    expect(response).to redirect_to(login_estudante_path)
    login_estudante(aluno)
    expect(response).to redirect_to(recarga_path(recarga))
  end

  it "indica só a senha quando a matrícula foi preenchida" do
    post login_estudante_path, params: { matricula: aluno.identificacao, senha: "" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Senha é obrigatória")
    expect(response.body).not_to include("Matrícula é obrigatória")
  end

  it "indica campos obrigatórios" do
    post login_estudante_path, params: { matricula: "", senha: "" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Matrícula é obrigatória")
    expect(response.body).to include("Senha é obrigatória")
  end

  it "rejeita senha incorreta e conta inativa" do
    login_estudante(aluno, senha: "errada123")
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Não foi possível autenticar as credenciais.")

    aluno.update!(ativo: false)
    login_estudante(aluno)
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "recusa funcionário sem cadastro de estudante como credencial inválida" do
    funcionario = create(:funcionario)
    expect do
      post login_estudante_path, params: { matricula: funcionario.identificacao, senha: "senhaCorreta" }
    end.not_to change(SessaoAutenticacao, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include(SessoesEstudanteController::MSG_FALHA)
  end

  it "encerra a sessão no logout" do
    login_estudante(aluno)
    delete logout_estudante_path
    expect(response).to redirect_to(login_estudante_path)
    expect(SessaoAutenticacao.last).to be_encerrada
    get new_recarga_path
    expect(response).to redirect_to(login_estudante_path)
  end

  it "logout sem sessão só volta ao login" do
    expect { delete logout_estudante_path }.not_to change(SessaoAutenticacao, :count)
    expect(response).to redirect_to(login_estudante_path)
  end

  it "não guarda como retorno uma página pedida por POST" do
    post recargas_path, params: { solicitacao_recarga: { quantidade_almocos: "1", metodo: "pix" } }
    expect(response).to redirect_to(login_estudante_path)
    login_estudante(aluno)
    expect(response).to redirect_to(new_recarga_path)
  end

  it "pede novo login quando a sessão expira" do
    login_estudante(aluno)
    travel_to(SessaoAutenticacao::DURACAO.from_now + 1.minute) do
      get new_recarga_path
      expect(response).to redirect_to(login_estudante_path)
      follow_redirect!
      expect(response.body).to include("Sua sessão expirou. Faça login novamente.")
    end
  end

  it "a sessão de estudante não dá acesso à aplicação de controle" do
    login_estudante(aluno)
    get controle_root_path
    expect(response).to redirect_to(controle_login_path)
  end
end
