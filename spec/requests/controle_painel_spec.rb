require "rails_helper"

RSpec.describe "Proteção das funções de controle (F04)", type: :request do
  let!(:funcionario) { create(:funcionario, password: "senhaCorreta") }

  it "exige login quando não há sessão" do
    get controle_root_path
    expect(response).to redirect_to(controle_login_path)
    follow_redirect!
    expect(response.body).to include(AutenticacaoFuncionario::MSG_LOGIN_OBRIGATORIO)
  end

  it "não executa a função solicitada sem sessão" do
    expect_any_instance_of(Controle::PainelController).not_to receive(:show)
    get controle_root_path
  end

  it "permite o acesso com sessão válida" do
    login_controle(funcionario)
    get controle_root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(funcionario.nome)
  end

  it "exige novo login quando a sessão expirou" do
    login_controle(funcionario)
    travel(SessaoAutenticacao::DURACAO + 1.minute) do
      get controle_root_path
      expect(response).to redirect_to(controle_login_path)
      follow_redirect!
      expect(response.body).to include(AutenticacaoFuncionario::MSG_SESSAO_EXPIRADA)
    end
  end

  it "encerra o acesso se o funcionário for desativado durante a sessão" do
    login_controle(funcionario)
    funcionario.update!(ativo: false)
    get controle_root_path
    expect(response).to redirect_to(controle_login_path)
  end

  describe "escolha do restaurante" do
    let!(:catraca) { create(:catraca, identificacao: "CAT-01") }
    let(:restaurante) { catraca.restaurante }

    before { login_controle(funcionario) }

    it "lista as catracas disponíveis do restaurante escolhido" do
      create(:catraca, identificacao: "CAT-INATIVA", ativa: false, piso: catraca.piso)

      get controle_root_path(restaurante_id: restaurante.id)
      expect(response.body).to include('id="catracas-disponiveis"', "CAT-01")
      expect(response.body).not_to include("CAT-INATIVA")
    end

    it "não lista catracas quando o restaurante não existe ou está inativo" do
      get controle_root_path(restaurante_id: 0)
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('id="catracas-disponiveis"')

      restaurante.update!(ativo: false)
      get controle_root_path(restaurante_id: restaurante.id)
      expect(response.body).not_to include('id="catracas-disponiveis"')
    end
  end
end
