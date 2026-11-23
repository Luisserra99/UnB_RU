module Admin
  # F12 — Exportação em PDF do Relatório de Operação, para auditoria (responsável: Tarsila).
  # Lista os acessos realizados por período, restaurante e catraca, e exporta todos em PDF.
  class AcessosOperacaoController < RelatoriosBaseController
    # GET /admin/relatorio-global/acessos: lista os acessos do filtro, paginados.
    #
    # Argumentos:: +params[:inicio]+, +params[:fim]+, +params[:restaurante_id]+,
    #              +params[:catraca_id]+, +params[:agrupar]+, +params[:pagina]+ e
    #              +params[:por_pagina]+, todos opcionais.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: define +@relatorio+ e renderiza +index+; com período inválido, define
    #                      +flash.now[:alert]+ com o erro (RN12.7).
    def index
      @relatorio = Relatorios::AcessosOperacao.new(filtros_acessos)
      flash.now[:alert] = @relatorio.erro if @relatorio.erro
    end

    # POST /admin/relatorio-global/acessos/exportacoes: exporta em PDF todos os acessos do filtro (RN12.2).
    #
    # Argumentos:: os mesmos filtros de +index+ (a página atual não entra na exportação).
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: com período válido, grava um ExportacaoRelatorio; com acessos, envia o
    #                      PDF como anexo; com período inválido, sem acessos ou em caso de falha,
    #                      redireciona para a lista com os mesmos filtros e +flash[:alert]+ com o motivo.
    def exportar
      relatorio = Relatorios::AcessosOperacao.new(filtros_acessos)
      resultado = Relatorios::ExportarAcessosOperacao.call(usuario: funcionario_atual, relatorio: relatorio)
      entregar_exportacao(resultado, tipo_mime: "application/pdf",
                                     voltar_para: admin_acessos_relatorio_global_path(relatorio.filtros.compact))
    end

    private

    # Separa os filtros aceitos pela lista de acessos.
    #
    # Argumentos:: nenhum (lê +params+).
    # Retorno:: ActionController::Parameters com os filtros, o agrupamento e a paginação.
    # Efeitos colaterais:: nenhum.
    def filtros_acessos
      params.permit(:inicio, :fim, :restaurante_id, :catraca_id, :agrupar, :pagina, :por_pagina)
    end
  end
end
