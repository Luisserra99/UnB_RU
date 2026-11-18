# F03 — Extrato e Histórico de Refeições (responsável: Luis).
# GET /extrato mostra o extrato do estudante logado. GET /estudantes/:estudante_id/extrato só é
# permitido para o próprio estudante (RN03.1); para outro, responde 403 sem expor dados.
class ExtratosController < PortalEstudanteController
  # Aviso quando o estudante tenta ver o extrato de outra pessoa (RN03.1).
  MSG_ACESSO_NEGADO = "Acesso negado: você só pode consultar o próprio extrato e histórico.".freeze

  # GET /extrato ou /estudantes/:estudante_id/extrato: mostra saldo, recargas e refeições.
  #
  # Argumentos:: +params[:estudante_id]+ (opcional) e os filtros da F11: +tipo+, +periodo+,
  #              +catraca_id+ e +pagina+.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: para outro estudante, renderiza +acesso_negado+ com status 403; caso
  #                      contrário, define @consulta e @relatorio e renderiza +show+.
  def show
    return negar_acesso if extrato_de_outro_estudante?

    @consulta = Extratos::Consulta.new(estudante_atual)
    # F11 (Tarsila): lançamentos filtrados, totais e exportação.
    @relatorio = Extratos::Relatorio.new(estudante_atual, filtros_do_relatorio)
  end

  private

  # Indica se a rota pede o extrato de um estudante diferente do logado.
  #
  # Argumentos:: nenhum (lê +params[:estudante_id]+).
  # Retorno:: true quando há +estudante_id+ e ele não é o do estudante logado; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def extrato_de_outro_estudante?
    params[:estudante_id].present? && params[:estudante_id].to_s != estudante_atual.id.to_s
  end

  # Nega o acesso ao extrato de outra pessoa, sem expor dados (RN03.1).
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: põe MSG_ACESSO_NEGADO no flash e renderiza +acesso_negado+ com status 403.
  def negar_acesso
    flash.now[:alert] = MSG_ACESSO_NEGADO
    render :acesso_negado, status: :forbidden
  end

  # Filtra os parâmetros aceitos pelo relatório do extrato (F11).
  #
  # Argumentos:: nenhum (lê +params+).
  # Retorno:: ActionController::Parameters com +tipo+, +periodo+, +catraca_id+ e +pagina+.
  # Efeitos colaterais:: nenhum.
  def filtros_do_relatorio
    params.permit(:tipo, :periodo, :catraca_id, :pagina)
  end
end
