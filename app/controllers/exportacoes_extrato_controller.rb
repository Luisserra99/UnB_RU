# F11 — Exportação do Extrato e Histórico de Refeições em PDF/CSV (responsável: Tarsila).
# POST /extrato/exportacoes gera o arquivo com os mesmos filtros da tela. Sem lançamentos ou em
# caso de falha, volta para o extrato com a mensagem e nenhum arquivo é baixado.
class ExportacoesExtratoController < PortalEstudanteController
  def create
    relatorio = Extratos::Relatorio.new(estudante_atual, filtros_extrato)
    resultado = Extratos::Exportar.call(usuario: estudante_atual.usuario, relatorio: relatorio,
                                        formato: params[:formato])

    if resultado.sucesso?
      send_data resultado.conteudo, filename: resultado.nome_arquivo, type: resultado.tipo_mime,
                                    disposition: "attachment"
    else
      redirect_to extrato_path(relatorio.filtros.compact), alert: resultado.mensagem
    end
  end

  private

  # Só os três filtros previstos são aceitos; o estudante vem sempre da sessão.
  def filtros_extrato
    params.permit(:tipo, :periodo, :catraca_id)
  end
end
