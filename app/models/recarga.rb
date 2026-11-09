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

  scope :recentes, -> { order(solicitada_em: :desc, id: :desc) }

  def pagamento_atual
    pagamentos.last
  end

  def item_do_tipo(codigo)
    itens.find { |item| item.tipo_refeicao.codigo == codigo }
  end

  def subtotal_do_tipo(codigo)
    item_do_tipo(codigo)&.subtotal || BigDecimal("0")
  end

  # Chamado por Pagamento#confirmar!, dentro da mesma transação.
  def confirmar!(em:)
    update!(status: :confirmada, confirmada_em: em)
    MovimentacaoSaldo.create!(estudante: estudante, recarga: self, natureza: :credito_recarga,
                              valor: valor_total, ocorrida_em: em)
  end

  private

  def valor_total_igual_a_soma_dos_itens
    return if valor_total.nil? || itens.empty?

    soma = itens.sum(BigDecimal("0")) { |item| item.subtotal }
    errors.add(:valor_total, "deve ser igual à soma dos itens") unless soma == valor_total
  end
end
