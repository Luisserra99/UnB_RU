require "rails_helper"

RSpec.describe "Login de funcionário (F04)", type: :request do
  let!(:funcionario) { create(:funcionario, identificacao: "funcionario01", password: "senhaCorreta") }

  describe "GET /controle/login" do
    it "exibe a tela de login" do
      get controle_login_path
      expect(response.body).to include("Autenticação do Operador")
    end

    it "tem link para voltar à página inicial" do
      get controle_login_path
      expect(response.body).to include("Voltar ao início")
      expect(response.body).to include(%(href="#{root_path}"))
    end

    it "redireciona ao painel se já houver sessão" do
      login_controle(funcionario)
      get controle_login_path
      expect(response).to redirect_to(controle_root_path)
    end
  end

  describe "POST /controle/login" do
    it "autentica funcionário ativo e pede o ponto de acesso" do
      expect { login_controle(funcionario) }.to change(SessaoAutenticacao, :count).by(1)
      expect(response).to redirect_to(controle_root_path)
      follow_redirect!
      expect(response.body).to include("Escolha do restaurante e da catraca")
    end

    it "permite administrador na aplicação de controle" do
      admin = create(:administrador)
      login_controle(admin)
      expect(response).to redirect_to(controle_root_path)
    end

    shared_examples "falha de autenticação" do |mensagem|
      it "não cria sessão e mantém a tela de login" do
        expect { post controle_login_path, params: params }.not_to change(SessaoAutenticacao, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Autenticação do Operador")
        expect(response.body).to include(mensagem)
      end
    end

    context "com senha incorreta" do
      let(:params) { { identificacao: "funcionario01", senha: "errada123" } }
      include_examples "falha de autenticação", "Não foi possível autenticar as credenciais"
    end

    context "com identificação não cadastrada" do
      let(:params) { { identificacao: "desconhecido", senha: "qualquer123" } }
      include_examples "falha de autenticação", "Não foi possível autenticar as credenciais"
    end

    context "com funcionário inativo" do
      before { funcionario.update!(ativo: false) }
      let(:params) { { identificacao: "funcionario01", senha: "senhaCorreta" } }
      include_examples "falha de autenticação", "Não foi possível autenticar as credenciais"
    end

    context "com conta somente de estudante" do
      let(:estudante) { create(:usuario_estudante, password: "senhaCorreta") }
      let(:params) { { identificacao: estudante.identificacao, senha: "senhaCorreta" } }
      include_examples "falha de autenticação", "Acesso negado"
    end

    context "sem identificação" do
      let(:params) { { identificacao: "", senha: "senhaCorreta" } }
      include_examples "falha de autenticação", "Identificação é obrigatória"
    end

    context "sem senha" do
      let(:params) { { identificacao: "funcionario01", senha: "" } }
      include_examples "falha de autenticação", "Senha é obrigatória"
    end
  end

  describe "DELETE /controle/logout" do
    it "encerra a sessão e exige novo login" do
      login_controle(funcionario)
      sessao = SessaoAutenticacao.last

      delete controle_logout_path
      expect(response).to redirect_to(controle_login_path)
      expect(sessao.reload.encerrada_em).to be_present

      get controle_root_path
      expect(response).to redirect_to(controle_login_path)
    end
  end
end
