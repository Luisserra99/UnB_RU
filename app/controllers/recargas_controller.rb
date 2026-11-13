# F02 — Recarga de Saldo (responsável: Luis).
# Sem JavaScript, o botão "Calcular total" reenvia o formulário com acao=calcular e só recalcula.
class RecargasController < PortalEstudanteController
  MSG_PAGAMENTO_CONFIRMADO = "Pagamento confirmado. Saldo atualizado.".freeze
  MSG_PAGAMENTO_RECUSADO = "Pagamento recusado pela operadora. Verifique os dados ou use outro cartão.".freeze
  MSG_COBRANCA_SEM_CARTAO = "Esta cobrança não aceita pagamento com cartão.".freeze

  before_action :carregar_recarga, only: %i[show pagar_cartao simular_confirmacao]

  def new
    @solicitacao = SolicitacaoRecarga.new(estudante: estudante_atual)
  end

  def create
    @solicitacao = SolicitacaoRecarga.new(estudante: estudante_atual, **params_solicitacao)
    return render(:new) if params[:acao] == "calcular"

    if @solicitacao.salvar
      redirect_to recarga_path(@solicitacao.recarga), notice: @solicitacao.mensagem_sucesso
    else
      flash.now[:alert] = @solicitacao.errors.map(&:message).uniq.join(". ")
      render :new, status: :unprocessable_content
    end
  end

  def show
    @pagamento.expirar_se_vencido!
    @dados_cartao = DadosCartao.new
  end

  def pagar_cartao
    unless @pagamento&.cartao_credito? && @recarga.pendente? && !@pagamento.confirmado?
      return redirect_to(recarga_path(@recarga), alert: MSG_COBRANCA_SEM_CARTAO)
    end

    @dados_cartao = DadosCartao.new(parametros_aninhados(:dados_cartao).permit(:numero, :nome, :validade, :cvv))
    unless @dados_cartao.valid?
      flash.now[:alert] = DadosCartao::MSG_INVALIDOS
      return render(:show, status: :unprocessable_content)
    end

    pagamento = @pagamento.recusado? ? nova_tentativa_cartao : @pagamento
    Pagamentos::ProcessarRetorno.call(pagamento, Pagamentos::GatewaySimulado.autorizar_cartao(@dados_cartao))
    if pagamento.confirmado?
      redirect_to recarga_path(@recarga), notice: MSG_PAGAMENTO_CONFIRMADO
    else
      redirect_to recarga_path(@recarga), alert: MSG_PAGAMENTO_RECUSADO
    end
  end

  # Simula o aviso do banco de que o PIX foi pago. Não existe em produção.
  def simular_confirmacao
    return head(:not_found) unless Rails.env.local?

    Pagamentos::ProcessarRetorno.call(@pagamento, "Confirmada") if @pagamento&.pix?
    if @pagamento&.confirmado?
      redirect_to recarga_path(@recarga), notice: MSG_PAGAMENTO_CONFIRMADO
    else
      redirect_to recarga_path(@recarga), alert: "Não foi possível confirmar: o código PIX não está mais pendente."
    end
  end

  private

  # Só encontra recargas do próprio estudante (RN03.1): a de outra pessoa dá 404.
  def carregar_recarga
    @recarga = estudante_atual.recargas.includes(itens: :tipo_refeicao).find(params[:id])
    @pagamento = @recarga.pagamento_atual
  end

  def params_solicitacao
    parametros_aninhados(:solicitacao_recarga)
      .permit(:quantidade_cafes, :quantidade_almocos, :metodo).to_h.symbolize_keys
  end

  # Um campo aninhado enviado como texto (ex.: solicitacao_recarga=abc) responde 400 em vez de 500.
  def parametros_aninhados(chave)
    valor = params.fetch(chave, ActionController::Parameters.new)
    raise ActionController::BadRequest, "Parâmetro #{chave} malformado" unless valor.is_a?(ActionController::Parameters)

    valor
  end

  def nova_tentativa_cartao
    @recarga.pagamentos.create!(metodo: :cartao_credito, valor_solicitado: @recarga.valor_total)
  end
end
