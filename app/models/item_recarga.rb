# Quantidade comprada de um tipo de refeição numa recarga, com o preço da tarifa no momento da compra.
class ItemRecarga < ApplicationRecord
  belongs_to :recarga, inverse_of: :itens
  belongs_to :tipo_refeicao
  belongs_to :tarifa_refeicao

  validates :quantidade, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :valor_unitario, presence: true, numericality: { greater_than: 0 }
  validates :tipo_refeicao_id, uniqueness: { scope: :recarga_id }
  validate :tarifa_do_mesmo_tipo

  # Calcula o valor do item: quantidade × valor unitário.
  #
  # Argumentos:: nenhum.
  # Retorno:: BigDecimal; zero se a quantidade ou o valor unitário não estiverem preenchidos.
  # Efeitos colaterais:: nenhum.
  def subtotal
    return BigDecimal("0") if quantidade.nil? || valor_unitario.nil?

    valor_unitario * quantidade
  end

  private

  # Validação: a tarifa deve ser do mesmo tipo de refeição do item.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +tarifa_refeicao+ quando os tipos não conferem.
  def tarifa_do_mesmo_tipo
    return if tarifa_refeicao.nil? || tipo_refeicao_id.nil?
    return if tarifa_refeicao.tipo_refeicao_id == tipo_refeicao_id

    errors.add(:tarifa_refeicao, "não corresponde ao tipo de refeição")
  end
end
