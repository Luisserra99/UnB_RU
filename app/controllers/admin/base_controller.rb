module Admin
  # Base das telas de administração: além da sessão de funcionário, exige o papel de administrador.
  class BaseController < Controle::BaseController
    MSG_SOMENTE_ADMINISTRADORES = "Acesso negado: esta função é restrita a administradores.".freeze

    before_action :exigir_administrador!

    private

    def exigir_administrador!
      return if funcionario_atual.administrador?

      redirect_to controle_root_path, alert: MSG_SOMENTE_ADMINISTRADORES
    end
  end
end
