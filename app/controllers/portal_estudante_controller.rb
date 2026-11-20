# Base das telas do Portal do Estudante que exigem login de estudante (F02/F03). Toda ação das
# subclasses passa antes por AutenticacaoEstudante#exigir_estudante!, que redireciona ao login
# quem não está autenticado como estudante.
class PortalEstudanteController < ApplicationController
  before_action :exigir_estudante!
end
