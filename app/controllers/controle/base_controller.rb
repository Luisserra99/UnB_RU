module Controle
  # Base de todas as funções da aplicação de controle: exige sessão de funcionário válida.
  class BaseController < ApplicationController
    layout "controle"
    before_action :exigir_funcionario!
  end
end
