module Admin
  # Base dos relatórios administrativos (F09 e F12) — responsável: Tarsila.
  # Somente administradores com sessão válida (RN09.1 e RN12.1). Não herda de Admin::BaseController
  # porque os cenários pedem uma resposta própria para quem está logado sem ser administrador:
  # a mensagem "Acesso não autorizado", sem exibir nenhum dado operacional nem gerar arquivo.
  class RelatoriosBaseController < ApplicationController
    MSG_ACESSO_NAO_AUTORIZADO = "Acesso não autorizado".freeze

    layout "controle"
    before_action :exigir_administrador_do_relatorio!

    private

    def exigir_administrador_do_relatorio!
      return if funcionario_atual&.administrador?

      if funcionario_autenticado? || estudante_autenticado?
        flash.now[:alert] = MSG_ACESSO_NAO_AUTORIZADO
        render "admin/relatorios_globais/acesso_negado", status: :forbidden
      else
        exigir_funcionario! # sem sessão (ou expirada): vai para o login da aplicação de controle
      end
    end
  end
end
