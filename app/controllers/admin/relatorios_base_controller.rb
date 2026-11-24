# Área administrativa da aplicação de controle.
module Admin
  # Base dos relatórios administrativos (F09 e F12) — responsável: Tarsila.
  # Somente administradores com sessão válida (RN09.1 e RN12.1). Não herda de Admin::BaseController
  # porque os cenários pedem uma resposta própria para quem está logado sem ser administrador:
  # a mensagem "Acesso não autorizado", sem exibir nenhum dado operacional nem gerar arquivo.
  class RelatoriosBaseController < ApplicationController
    include EntregaDeExportacao

    # Mensagem exibida a quem está logado sem ser administrador.
    MSG_ACESSO_NAO_AUTORIZADO = "Acesso não autorizado".freeze

    layout "controle"
    before_action :exigir_administrador_do_relatorio!

    private

    # Barra quem não é administrador antes de qualquer ação dos relatórios (RN09.1 e RN12.1).
    #
    # Argumentos:: nenhum (lê a sessão do funcionário e a do estudante).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: para administrador, nenhum; para funcionário sem o papel ou estudante
    #                      logado, define +flash.now[:alert]+ e renderiza a tela de acesso negado
    #                      com status 403; sem sessão (ou com sessão expirada), redireciona para o
    #                      login da aplicação de controle.
    def exigir_administrador_do_relatorio!
      return if funcionario_atual&.administrador?
      return exigir_funcionario! unless funcionario_autenticado? || estudante_autenticado?

      flash.now[:alert] = MSG_ACESSO_NAO_AUTORIZADO
      render "admin/relatorios_globais/acesso_negado", status: :forbidden
    end
  end
end
