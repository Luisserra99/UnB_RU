# F02 — Recarga de Saldo (responsável: Luis).
# Sem JavaScript, o botão "Calcular total" reenvia o formulário com acao=calcular e só recalcula.
class RecargasController < PortalEstudanteController
  # Aviso depois de um pagamento confirmado (RN02.2).
  MSG_PAGAMENTO_CONFIRMADO = "Pagamento confirmado. Saldo atualizado.".freeze
  # Aviso depois de o gateway recusar o cartão.
  MSG_PAGAMENTO_RECUSADO = "Pagamento recusado pela operadora. Verifique os dados ou use outro cartão.".freeze
  # Aviso quando a cobrança não aceita (ou não aceita mais) pagamento com cartão.
  MSG_COBRANCA_SEM_CARTAO = "Esta cobrança não aceita pagamento com cartão.".freeze
  # Aviso quando a simulação de PIX encontra um código que não está mais pendente.
  MSG_PIX_NAO_PENDENTE = "Não foi possível confirmar: o código PIX não está mais pendente.".freeze

  before_action :carregar_recarga, only: %i[show pagar_cartao simular_confirmacao]

  # GET /recargas/new: mostra o formulário de recarga vazio.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum (renderiza +new+).
  # Efeitos colaterais:: define @solicitacao.
  def new
    @solicitacao = SolicitacaoRecarga.new(estudante: estudante_atual)
  end

  # POST /recargas: calcula o total ou gera a cobrança (RN02.1, RN02.5 e RN02.6).
  #
  # Argumentos:: +params[:solicitacao_recarga]+ (quantidades e método) e +params[:acao]+.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: com +acao=calcular+, só renderiza +new+ com o total. Com dados válidos,
  #                      grava a recarga pendente e redireciona para ela. Com dados inválidos,
  #                      renderiza +new+ com status 422 e o motivo no flash.
  def create
    @solicitacao = SolicitacaoRecarga.new(estudante: estudante_atual, **params_solicitacao)
    return render(:new) if somente_calcular?
    return redirect_to(recarga_path(@solicitacao.recarga), notice: @solicitacao.mensagem_sucesso) if @solicitacao.salvar

    flash.now[:alert] = @solicitacao.mensagem_erro
    render :new, status: :unprocessable_content
  end

  # GET /recargas/:id: mostra a cobrança (PIX ou cartão) e o seu status.
  #
  # Argumentos:: +params[:id]+ (recarga do estudante logado).
  # Retorno:: nenhum (renderiza +show+).
  # Efeitos colaterais:: expira no banco o PIX vencido (RN02.4); define @dados_cartao.
  def show
    @pagamento.expirar_se_vencido!
    @dados_cartao = DadosCartao.new
  end

  # POST /recargas/:id/pagar_cartao: paga a cobrança com cartão de crédito.
  #
  # Argumentos:: +params[:id]+ e +params[:dados_cartao]+ (número, nome, validade e CVV).
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: se a cobrança não aceita cartão, redireciona com MSG_COBRANCA_SEM_CARTAO.
  #                      Com dados inválidos, renderiza +show+ com status 422 sem chamar o gateway.
  #                      Com dados válidos, grava o resultado do gateway (e credita o saldo se
  #                      aprovado) e redireciona para a recarga.
  def pagar_cartao
    return redirect_to(recarga_path(@recarga), alert: MSG_COBRANCA_SEM_CARTAO) unless cobranca_cartao_em_aberto?

    @dados_cartao = DadosCartao.new(params_cartao)
    return dados_cartao_invalidos unless @dados_cartao.valid?

    redirecionar_apos_pagamento(cobrar_cartao, MSG_PAGAMENTO_RECUSADO)
  end

  # POST /recargas/:id/simular_confirmacao: simula o aviso do banco de que o PIX foi pago.
  # Só existe em desenvolvimento e teste.
  #
  # Argumentos:: +params[:id]+.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: fora de desenvolvimento e teste, responde 404. Em PIX pendente, confirma o
  #                      pagamento e credita o saldo; depois redireciona para a recarga.
  def simular_confirmacao
    return head(:not_found) unless Rails.env.local?

    Pagamentos::ProcessarRetorno.call(@pagamento, "Confirmada") if @pagamento&.pix?
    redirecionar_apos_pagamento(@pagamento, MSG_PIX_NAO_PENDENTE)
  end

  private

  # Carrega a recarga pedida e o seu pagamento atual. Só encontra recargas do próprio estudante
  # (RN03.1).
  #
  # Argumentos:: +params[:id]+.
  # Retorno:: o Pagamento atual (ou nil).
  # Efeitos colaterais:: define @recarga e @pagamento; levanta ActiveRecord::RecordNotFound (404)
  #                      para recarga inexistente ou de outro estudante.
  def carregar_recarga
    @recarga = estudante_atual.recargas.includes(itens: :tipo_refeicao).find(params[:id])
    @pagamento = @recarga.pagamento_atual
  end

  # Indica se o formulário foi enviado pelo botão "Calcular total".
  #
  # Argumentos:: nenhum (lê +params[:acao]+).
  # Retorno:: true para só recalcular; false para gerar a cobrança.
  # Efeitos colaterais:: nenhum.
  def somente_calcular?
    params[:acao] == "calcular"
  end

  # Filtra os campos do formulário de recarga.
  #
  # Argumentos:: nenhum (lê +params[:solicitacao_recarga]+).
  # Retorno:: Hash com chaves Symbol: +quantidade_cafes+, +quantidade_almocos+ e +metodo+.
  # Efeitos colaterais:: levanta ActionController::BadRequest se o parâmetro vier malformado.
  def params_solicitacao
    parametros_aninhados(:solicitacao_recarga)
      .permit(:quantidade_cafes, :quantidade_almocos, :metodo).to_h.symbolize_keys
  end

  # Filtra os campos do cartão.
  #
  # Argumentos:: nenhum (lê +params[:dados_cartao]+).
  # Retorno:: ActionController::Parameters com +numero+, +nome+, +validade+ e +cvv+.
  # Efeitos colaterais:: levanta ActionController::BadRequest se o parâmetro vier malformado.
  def params_cartao
    parametros_aninhados(:dados_cartao).permit(:numero, :nome, :validade, :cvv)
  end

  # Lê um parâmetro aninhado. Um campo enviado como texto (ex.: solicitacao_recarga=abc) responde
  # 400 em vez de 500.
  #
  # Argumentos:: +chave+ (Symbol): nome do parâmetro.
  # Retorno:: ActionController::Parameters (vazio quando o parâmetro não veio).
  # Efeitos colaterais:: levanta ActionController::BadRequest quando o valor não é um hash.
  def parametros_aninhados(chave)
    valor = params.fetch(chave, ActionController::Parameters.new)
    raise ActionController::BadRequest, "Parâmetro #{chave} malformado" unless valor.is_a?(ActionController::Parameters)

    valor
  end

  # Indica se a recarga ainda pode ser paga com cartão: pendente e com pagamento atual de cartão
  # ainda não confirmado.
  #
  # Argumentos:: nenhum (usa @recarga e @pagamento).
  # Retorno:: true ou false (nil quando não há pagamento).
  # Efeitos colaterais:: nenhum.
  def cobranca_cartao_em_aberto?
    @pagamento&.cartao_credito? && @recarga.pendente? && !@pagamento.confirmado?
  end

  # Responde ao envio de dados de cartão inválidos.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: põe DadosCartao::MSG_INVALIDOS no flash e renderiza +show+ com status 422.
  def dados_cartao_invalidos
    flash.now[:alert] = DadosCartao::MSG_INVALIDOS
    render :show, status: :unprocessable_content
  end

  # Pede a autorização do cartão ao gateway e registra o resultado. Depois de uma recusa, abre
  # uma nova tentativa em vez de reaproveitar o pagamento recusado.
  #
  # Argumentos:: nenhum (usa @recarga, @pagamento e @dados_cartao).
  # Retorno:: o Pagamento usado, já confirmado ou recusado.
  # Efeitos colaterais:: grava o status do pagamento; se aprovado, confirma a recarga e credita o
  #                      saldo; depois de uma recusa, cria um novo Pagamento.
  def cobrar_cartao
    pagamento = @pagamento.recusado? ? nova_tentativa_cartao : @pagamento
    Pagamentos::ProcessarRetorno.call(pagamento, Pagamentos::GatewaySimulado.autorizar_cartao(@dados_cartao))
  end

  # Redireciona para a recarga com o aviso do resultado do pagamento.
  #
  # Argumentos:: +pagamento+ (Pagamento ou nil): pagamento processado.
  #              +alerta+ (String): aviso usado quando o pagamento não foi confirmado.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: redireciona com MSG_PAGAMENTO_CONFIRMADO (notice) ou com +alerta+ (alert).
  def redirecionar_apos_pagamento(pagamento, alerta)
    if pagamento&.confirmado?
      redirect_to recarga_path(@recarga), notice: MSG_PAGAMENTO_CONFIRMADO
    else
      redirect_to recarga_path(@recarga), alert: alerta
    end
  end

  # Cria um novo pagamento de cartão para a recarga, no valor total.
  #
  # Argumentos:: nenhum (usa @recarga).
  # Retorno:: o Pagamento criado, pendente.
  # Efeitos colaterais:: grava um Pagamento no banco.
  def nova_tentativa_cartao
    @recarga.pagamentos.create!(metodo: :cartao_credito, valor_solicitado: @recarga.valor_total)
  end
end
