module Admin
  # F12 — Exportação em PDF do Relatório de Operação, para auditoria (responsável: Tarsila).
  # Lista os acessos realizados por período, restaurante e catraca, e exporta todos em PDF.
  class AcessosOperacaoController < RelatoriosBaseController
    def index
      @relatorio = Relatorios::AcessosOperacao.new(filtros_acessos)
      flash.now[:alert] = @relatorio.erro if @relatorio.erro
    end

    def exportar
      relatorio = Relatorios::AcessosOperacao.new(filtros_acessos)
      resultado = Relatorios::ExportarAcessosOperacao.call(usuario: funcionario_atual, relatorio: relatorio)

      if resultado.sucesso?
        send_data resultado.conteudo, filename: resultado.nome_arquivo, type: "application/pdf",
                                      disposition: "attachment"
      else
        redirect_to admin_acessos_relatorio_global_path(relatorio.filtros.compact), alert: resultado.mensagem
      end
    end

    private

    # A página atual não entra na exportação: o PDF sempre traz todos os acessos do filtro (RN12.2).
    def filtros_acessos
      params.permit(:inicio, :fim, :restaurante_id, :catraca_id, :agrupar, :pagina, :por_pagina)
    end
  end
end
