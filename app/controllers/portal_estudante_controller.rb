# Base das telas do Portal do Estudante que exigem login de estudante (F02/F03).
class PortalEstudanteController < ApplicationController
  before_action :exigir_estudante!
end
