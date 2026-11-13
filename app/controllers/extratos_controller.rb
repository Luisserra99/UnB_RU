# F03 — Extrato e Histórico de Refeições (responsável: Luis).
# GET /extrato mostra o extrato do estudante logado. GET /estudantes/:estudante_id/extrato só é
# permitido para o próprio estudante (RN03.1); para outro, responde 403 sem expor dados.
class ExtratosController < PortalEstudanteController
  MSG_ACESSO_NEGADO = "Acesso negado: você só pode consultar o próprio extrato e histórico.".freeze

  def show
    if params[:estudante_id].present? && params[:estudante_id].to_s != estudante_atual.id.to_s
      flash.now[:alert] = MSG_ACESSO_NEGADO
      return render(:acesso_negado, status: :forbidden)
    end

    @consulta = Extratos::Consulta.new(estudante_atual)
    # F11 (Tarsila): lançamentos filtrados, totais e exportação.
    @relatorio = Extratos::Relatorio.new(estudante_atual, params.permit(:tipo, :periodo, :catraca_id, :pagina))
  end
end
