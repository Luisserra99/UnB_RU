# F11 — Exportação do Extrato e Histórico de Refeições em PDF/CSV (responsável: Tarsila).
# Gera o arquivo com os mesmos filtros da tela. Sem lançamentos ou em caso de falha, volta para o
# extrato com a mensagem e nenhum arquivo é baixado.
class ExportacoesExtratoController < PortalEstudanteController
  include EntregaDeExportacao

  # POST /extrato/exportacoes: exporta o extrato do estudante da sessão em PDF ou CSV.
  #
  # Argumentos:: +params[:formato]+ ("pdf" ou "csv"), +params[:tipo]+, +params[:periodo]+ e
  #              +params[:catraca_id]+, todos opcionais.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: grava um ExportacaoRelatorio; com lançamentos, envia o arquivo como anexo;
  #                      sem lançamentos ou em caso de falha, redireciona para o extrato com os
  #                      mesmos filtros e +flash[:alert]+ com o motivo.
  def create
    relatorio = Extratos::Relatorio.new(estudante_atual, filtros_extrato)
    resultado = Extratos::Exportar.call(usuario: estudante_atual.usuario, relatorio: relatorio,
                                        formato: params[:formato])
    entregar_exportacao(resultado, tipo_mime: resultado.tipo_mime,
                                   voltar_para: extrato_path(relatorio.filtros.compact))
  end

  private

  # Separa os filtros aceitos pelo extrato: só os três previstos. O estudante vem sempre da sessão.
  #
  # Argumentos:: nenhum (lê +params+).
  # Retorno:: ActionController::Parameters com +tipo+, +periodo+ e +catraca_id+.
  # Efeitos colaterais:: nenhum.
  def filtros_extrato
    params.permit(:tipo, :periodo, :catraca_id)
  end
end
