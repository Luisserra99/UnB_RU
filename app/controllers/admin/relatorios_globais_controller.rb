module Admin
  # F09 — Relatório Global de Operação (responsável: Tarsila).
  # Somente leitura e restrito a administradores (RN09.1 e RN09.2); o controle de acesso
  # fica em Admin::RelatoriosBaseController.
  class RelatoriosGlobaisController < RelatoriosBaseController
    # GET /admin/relatorio-global: mostra o relatório com os filtros escolhidos.
    #
    # Argumentos:: +params[:data]+, +params[:turno]+ e +params[:unidade_id]+, todos opcionais.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: define +@relatorio+ e renderiza +show+.
    def show
      @relatorio = Relatorios::OperacaoGlobal.new(filtros_relatorio)
    end

    # POST /admin/relatorio-global/exportacoes: exporta o relatório em PDF ou CSV (RN09.12 e RN09.13).
    #
    # Argumentos:: +params[:formato]+ ("pdf" ou "csv") e os mesmos filtros de +show+.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: grava um ExportacaoRelatorio; com acessos, envia o arquivo como anexo;
    #                      sem acessos ou em caso de falha, redireciona para o relatório com os
    #                      mesmos filtros e +flash[:alert]+ com o motivo.
    def exportar
      relatorio = Relatorios::OperacaoGlobal.new(filtros_relatorio)
      resultado = Relatorios::ExportarOperacaoGlobal.call(usuario: funcionario_atual, relatorio: relatorio,
                                                          formato: params[:formato])
      entregar_exportacao(resultado, tipo_mime: resultado.tipo_mime,
                                     voltar_para: admin_relatorio_global_path(relatorio.filtros.compact))
    end

    private

    # Separa os filtros aceitos pelo relatório: só os três previstos.
    #
    # Argumentos:: nenhum (lê +params+).
    # Retorno:: ActionController::Parameters com +data+, +turno+ e +unidade_id+.
    # Efeitos colaterais:: nenhum.
    def filtros_relatorio
      params.permit(:data, :turno, :unidade_id)
    end
  end
end
