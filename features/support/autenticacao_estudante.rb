# Login do Portal do Estudante nos cenários (F02/F03/F11).
# Uso: @estudante_usuario = login_estudante  (cria um estudante e entra pela tela /entrar)
module AutenticacaoEstudanteSteps
  SENHA_ESTUDANTE_TESTE = "Estudante@123".freeze

  def login_estudante(usuario = nil, senha: SENHA_ESTUDANTE_TESTE)
    usuario ||= create(:usuario_estudante, password: senha)
    visit login_estudante_path
    fill_in "Matrícula", with: usuario.identificacao
    fill_in "Senha", with: senha
    click_button "Entrar"
    expect(page).to have_button("Sair")
    usuario
  end
end
World(AutenticacaoEstudanteSteps)
