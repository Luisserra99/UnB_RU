# Login do Portal do Estudante em request specs (F02/F03).
module AutenticacaoEstudanteHelpers
  def login_estudante(usuario, senha: "senhaCorreta")
    post login_estudante_path, params: { matricula: usuario.identificacao, senha: senha }
  end
end

RSpec.configure do |config|
  config.include AutenticacaoEstudanteHelpers, type: :request
end
