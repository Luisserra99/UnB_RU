module Admin
  # F09 — Relatório Global de Operação (responsável: Tarsila).
  # Somente leitura e restrito a administradores (RN09.1 e RN09.2). Não herda de Admin::BaseController
  # porque o cenário pede uma resposta própria para quem está logado sem ser administrador:
  # a mensagem "Acesso não autorizado", sem exibir nenhum dado operacional.
  class RelatoriosGlobaisController < ApplicationController
    MSG_ACESSO_NAO_AUTORIZADO = "Acesso não autorizado".freeze

    layout "controle"
    before_action :exigir_administrador_do_relatorio!

    def show
      @relatorio = Relatorios::OperacaoGlobal.new(filtros_relatorio)
    end

    def exportar
      relatorio = Relatorios::OperacaoGlobal.new(filtros_relatorio)
      resultado = Relatorios::ExportarOperacaoGlobal.call(usuario: funcionario_atual, relatorio: relatorio,
                                                          formato: params[:formato])
      if resultado.sucesso?
        send_data resultado.conteudo, filename: resultado.nome_arquivo, type: resultado.tipo_mime,
                                      disposition: "attachment"
      else
        redirect_to admin_relatorio_global_path(relatorio.filtros.compact), alert: resultado.mensagem
      end
    end

    private

    # Só os três filtros previstos são aceitos.
    def filtros_relatorio
      params.permit(:data, :turno, :unidade_id)
    end

    def exigir_administrador_do_relatorio!
      return if funcionario_atual&.administrador?

      if funcionario_autenticado? || estudante_autenticado?
        flash.now[:alert] = MSG_ACESSO_NAO_AUTORIZADO
        render :acesso_negado, status: :forbidden
      else
        exigir_funcionario! # sem sessão (ou expirada): vai para o login da aplicação de controle
      end
    end
  end
end
