# Passos de features/autenticacao_funcionario.feature (F04) — responsável: Weldo.

SENHA_PADRAO_FUNCIONARIO = "senhaCorreta".freeze

def criar_funcionario(identificacao, ativo:)
  @senha = SENHA_PADRAO_FUNCIONARIO
  @usuario = create(:funcionario, identificacao: identificacao, password: @senha, ativo: ativo)
end

def preencher_login(identificacao, senha)
  @identificacao_informada = identificacao
  @senha_informada = senha
  fill_in "identificacao", with: identificacao
  fill_in "senha", with: senha
end

def fazer_login(usuario, senha)
  visit controle_login_path
  preencher_login(usuario.identificacao, senha)
  click_button "Entrar no Sistema"
end

# --- Dado ---

Dado("que o funcionário {string} está cadastrado e ativo") do |identificacao|
  criar_funcionario(identificacao, ativo: true)
end

Dado("que o funcionário {string} está cadastrado e inativo") do |identificacao|
  criar_funcionario(identificacao, ativo: false)
end

Dado("que a senha correta desse funcionário é {string}") do |senha|
  @senha = senha
  @usuario.update!(password: senha)
end

Dado("que a identificação {string} não está cadastrada") do |identificacao|
  expect(Usuario.exists?(identificacao: identificacao)).to be(false)
end

Dado("que ele está na tela de login da aplicação de controle") do
  visit controle_login_path
end

Dado("que a tela de login da aplicação de controle está aberta") do
  visit controle_login_path
end

Dado("que o usuário possui somente uma conta de estudante ativa") do
  @senha = "Estudante@123"
  @usuario = create(:usuario_estudante, password: @senha)
end

Dado("que o funcionário possui uma sessão autenticada") do
  criar_funcionario("funcionario01", ativo: true)
  fazer_login(@usuario, @senha)
  expect(page).to have_content("Sessão autenticada")
end

Dado("que o usuário não possui uma sessão autenticada de funcionário") do
  expect(SessaoAutenticacao.ativas).to be_empty
end

Dado("que a sessão autenticada do funcionário expirou") do
  step "que o funcionário possui uma sessão autenticada"
  SessaoAutenticacao.update_all(expira_em: 1.minute.ago)
end

# --- Quando ---

Quando("ele informa sua identificação e a senha correta") do
  preencher_login(@usuario.identificacao, @senha)
end

Quando("ele informa sua identificação e uma senha incorreta") do
  preencher_login(@usuario.identificacao, "senhaIncorreta")
end

Quando("o usuário informa a identificação {string} e uma senha") do |identificacao|
  preencher_login(identificacao, "qualquerSenha123")
end

Quando("ele informa a identificação {string} e a senha {string}") do |identificacao, senha|
  preencher_login(identificacao, senha)
end

Quando("ele informa suas credenciais corretas de estudante") do
  preencher_login(@usuario.identificacao, @senha)
end

Quando("confirma o login") do
  click_button "Entrar no Sistema"
end

Quando("ele solicita sair da aplicação de controle") do
  click_button "Sair"
end

Quando("ele tenta acessar diretamente uma função da aplicação de controle") do
  visit controle_root_path
end

Quando("ele tenta acessar uma função da aplicação de controle") do
  visit controle_root_path
end

# --- Então ---

def esperar_tela_de_login
  expect(page).to have_current_path(controle_login_path)
  expect(page).to have_content("Autenticação do Operador")
end

def esperar_funcao_de_controle_nao_executada
  expect(page).not_to have_content("Operador Autenticado")
  expect(page).not_to have_css("#ponto-acesso")
  esperar_tela_de_login
end

Então("o sistema deve autenticar a sessão do funcionário") do
  expect(page).to have_current_path(controle_root_path)
  expect(page).to have_content("Sessão autenticada")
  expect(@usuario.sessoes.ativas.count).to eq(1)
end

Então("deve apresentar a escolha do restaurante e da catraca do ponto de acesso") do
  within("#ponto-acesso") do
    expect(page).to have_content("Escolha do restaurante e da catraca")
  end
end

Então("o sistema deve encerrar a sessão") do
  expect(@usuario.sessoes.ativas).to be_empty
  expect(@usuario.sessoes.last.encerrada_em).to be_present
end

Então("deve apresentar a tela de login") do
  esperar_tela_de_login
end

Então("deve manter a tela de login") do
  expect(page).to have_content("Autenticação do Operador")
  expect(page).to have_button("Entrar no Sistema")
end

Então("deve exigir novo login para acessar as funções de controle") do
  visit controle_root_path
  esperar_funcao_de_controle_nao_executada
  expect(page).to have_content(AutenticacaoFuncionario::MSG_LOGIN_OBRIGATORIO)
end

Então("o sistema deve informar que não foi possível autenticar as credenciais") do
  expect(page).to have_content(Controle::SessoesController::MSG_FALHA)
end

Então("não deve criar uma sessão autenticada") do
  expect(SessaoAutenticacao.count).to eq(0)
end

Então("não deve criar uma sessão de funcionário") do
  expect(SessaoAutenticacao.count).to eq(0)
end

Então("o sistema deve indicar os campos obrigatórios não preenchidos") do
  expect(page).to have_content("Preencha os campos obrigatórios")
  if @identificacao_informada.blank?
    expect(page).to have_content("Identificação é obrigatória")
  else
    expect(page).not_to have_content("Identificação é obrigatória")
  end
  if @senha_informada.blank?
    expect(page).to have_content("Senha é obrigatória")
  else
    expect(page).not_to have_content("Senha é obrigatória")
  end
end

Então("o sistema deve negar o acesso à aplicação de controle") do
  expect(page).to have_content(Controle::SessoesController::MSG_SOMENTE_FUNCIONARIOS)
end

Então("o sistema deve exigir login de funcionário") do
  esperar_tela_de_login
  expect(page).to have_content(AutenticacaoFuncionario::MSG_LOGIN_OBRIGATORIO)
end

Então("o sistema deve exigir novo login de funcionário") do
  esperar_tela_de_login
  expect(page).to have_content(AutenticacaoFuncionario::MSG_SESSAO_EXPIRADA)
end

Então("não deve executar a função solicitada") do
  esperar_funcao_de_controle_nao_executada
end
