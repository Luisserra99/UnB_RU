module AutenticacaoHelpers
  def login_controle(usuario, senha: "senhaCorreta")
    post controle_login_path, params: { identificacao: usuario.identificacao, senha: senha }
  end
end

RSpec.configure do |config|
  config.include AutenticacaoHelpers, type: :request
end
