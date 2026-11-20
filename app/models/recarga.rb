# Pedido de recarga de saldo (F02). O saldo só é creditado quando um pagamento é confirmado (RN02.2).
class Recarga < ApplicationRecord
  enum :status, { pendente: "pendente", confirmada: "confirmada", expirada: "expirada", cancelada: "cancelada" },
       validate: true

  has_many :rateios_consumo, class_name: "RateioConsumo", dependent: :restrict_with_error
  belongs_to :estudante
  has_many :itens, -> { order(:id) }, class_name: "ItemRecarga", dependent: :destroy, inverse_of: :recarga
  has_many :pagamentos, -> { order(:created_at, :id) }, dependent: :destroy, inverse_of: :recarga
  has_one :movimentacao_saldo, dependent: :restrict_with_error

  validates :solicitada_em, presence: true
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
  validates :itens, presence: { message: "deve ter ao menos uma refeição" }
  validates :confirmada_em, presence: true, if: :confirmada?
  validate :valor_total_igual_a_soma_dos_itens

  # Recargas da mais nova para a mais antiga.
  scope :recentes, -> { order(solicitada_em: :desc, id: :desc) }

  # Devolve a tentativa de pagamento mais recente.
  #
  # Argumentos:: nenhum.
  # Retorno:: Pagamento, ou nil se a recarga ainda não tem pagamento.
  # Efeitos colaterais:: consulta o banco se os pagamentos não estiverem carregados.
  def pagamento_atual
    pagamentos.last
  end

  # Busca o item de um tipo de refeição.
  #
  # Argumentos:: +codigo+ (String): código do tipo, ex.: TipoRefeicao::ALMOCO.
  # Retorno:: ItemRecarga, ou nil se a recarga não tem esse tipo.
  # Efeitos colaterais:: carrega os itens e os tipos, se ainda não carregados.
  def item_do_tipo(codigo)
    itens.find { |item| item.tipo_refeicao.codigo == codigo }
  end

  # Subtotal de um tipo de refeição.
  #
  # Argumentos:: +codigo+ (String): código do tipo.
  # Retorno:: BigDecimal; zero se a recarga não tem esse tipo.
  # Efeitos colaterais:: os de #item_do_tipo.
  def subtotal_do_tipo(codigo)
    item_do_tipo(codigo)&.subtotal || BigDecimal("0")
  end

  # Confirma a recarga e credita o valor no saldo. Chamado por Pagamento#confirmar!, dentro da
  # mesma transação.
  #
  # Argumentos:: +em+ (Time): momento da confirmação.
  # Retorno:: a MovimentacaoSaldo de crédito criada.
  # Efeitos colaterais:: grava a recarga como confirmada e cria o crédito no saldo do estudante;
  #                      levanta ActiveRecord::RecordInvalid se algum dos dois for inválido.
  def confirmar!(em:)
    update!(status: :confirmada, confirmada_em: em)
    MovimentacaoSaldo.create!(estudante: estudante, recarga: self, natureza: :credito_recarga,
                              valor: valor_total, ocorrida_em: em)
  end

  private

  # Validação: o valor total deve ser a soma dos subtotais dos itens (RN02.5).
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +valor_total+ quando a soma não confere.
  def valor_total_igual_a_soma_dos_itens
    return if valor_total.nil? || itens.empty?

    soma = itens.sum(BigDecimal("0")) { |item| item.subtotal }
    errors.add(:valor_total, "deve ser igual à soma dos itens") unless soma == valor_total
  end
end
