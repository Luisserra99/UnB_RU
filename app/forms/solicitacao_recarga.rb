# Formulário da recarga de saldo (F02): calcula subtotais e total pelas tarifas vigentes
# e, ao confirmar, cria a Recarga, seus itens e o Pagamento pendente numa única transação.
class SolicitacaoRecarga
  include ActiveModel::Model
  include ActiveModel::Attributes

  MSG_COBRANCA_ZERADA = "Não é possível gerar uma cobrança zerada".freeze
  MSG_SUCESSO_PIX = "Código PIX gerado. Válido por 10 minutos.".freeze
  MSG_SUCESSO_CARTAO = "Cobrança gerada com sucesso".freeze
  QUANTIDADE_MAXIMA = 100

  # A interface agrupa almoço e jantar numa só categoria: ela é registrada como um item do tipo
  # `almoco`, com a tarifa do almoço. O crédito é em reais e serve para qualquer refeição.
  CATEGORIAS = {
    cafes: { codigo: TipoRefeicao::CAFE_DA_MANHA, rotulo: "Cafés da Manhã", unitario: "Café da Manhã" },
    almocos: { codigo: TipoRefeicao::ALMOCO, rotulo: "Almoços/Jantares", unitario: "Almoço/Jantar" }
  }.freeze

  attribute :quantidade_cafes, :string
  attribute :quantidade_almocos, :string
  attribute :metodo, :string

  attr_reader :estudante, :recarga

  validate :quantidades_validas
  validate :tarifas_disponiveis
  validate :total_positivo
  validates :metodo, inclusion: { in: Pagamento.metodos.keys, message: "Selecione o método de pagamento" }

  def initialize(estudante:, **atributos)
    @estudante = estudante
    super(**atributos)
  end

  def quantidade(categoria)
    valor = public_send("quantidade_#{categoria}").to_s.strip
    return 0 if valor.empty?

    Integer(valor, 10)
  rescue ArgumentError
    nil
  end

  def tarifa(categoria)
    @tarifas ||= {}
    @tarifas[categoria] ||= TarifaRefeicao.vigente_para(CATEGORIAS.fetch(categoria)[:codigo])
  end

  def preco(categoria)
    tarifa(categoria)&.valor
  end

  def subtotal(categoria)
    qtd = quantidade(categoria)
    return BigDecimal("0") if qtd.nil? || qtd.negative? || preco(categoria).nil?

    preco(categoria) * qtd
  end

  def valor_total
    CATEGORIAS.keys.sum(BigDecimal("0")) { |categoria| subtotal(categoria) }
  end

  def zerada?
    valor_total.zero?
  end

  def tarifas_cadastradas?
    CATEGORIAS.keys.all? { |categoria| tarifa(categoria) }
  end

  def mensagem_sucesso
    metodo == "pix" ? MSG_SUCESSO_PIX : MSG_SUCESSO_CARTAO
  end

  def salvar
    return false unless valid?

    agora = Time.current
    ActiveRecord::Base.transaction do
      @recarga = estudante.recargas.build(solicitada_em: agora, valor_total: valor_total)
      CATEGORIAS.each_key do |categoria|
        qtd = quantidade(categoria)
        next if qtd.zero?

        @recarga.itens.build(tipo_refeicao: tarifa(categoria).tipo_refeicao, tarifa_refeicao: tarifa(categoria),
                             quantidade: qtd, valor_unitario: preco(categoria))
      end
      pagamento = @recarga.pagamentos.build(metodo: metodo, valor_solicitado: valor_total)
      Pagamentos::GatewaySimulado.emitir_pix(pagamento, agora) if pagamento.pix?
      @recarga.save!
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  end

  private

  def quantidades_validas
    CATEGORIAS.each do |categoria, config|
      qtd = quantidade(categoria)
      next if qtd && qtd.between?(0, QUANTIDADE_MAXIMA)

      errors.add(:"quantidade_#{categoria}",
                 "#{config[:rotulo]}: informe um número inteiro entre 0 e #{QUANTIDADE_MAXIMA}")
    end
  end

  def tarifas_disponiveis
    errors.add(:base, "As tarifas das refeições não estão cadastradas") unless tarifas_cadastradas?
  end

  def total_positivo
    return if errors.any?

    errors.add(:base, MSG_COBRANCA_ZERADA) if zerada?
  end
end
