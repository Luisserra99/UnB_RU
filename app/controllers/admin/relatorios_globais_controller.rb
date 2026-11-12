module Admin
  # F09 — Relatório Global de Operação (responsável: Tarsila).
  # Somente leitura e restrito a administradores (RN09.1 e RN09.2); o controle de acesso
  # fica em Admin::RelatoriosBaseController.
  class RelatoriosGlobaisController < RelatoriosBaseController
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
  end
end
