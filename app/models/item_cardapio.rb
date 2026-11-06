class ItemCardapio < ApplicationRecord
  belongs_to :opcao_cardapio

  normalizes :descricao, with: ->(valor) { valor.squish }

  validates :categoria, :descricao, presence: true
  validates :ordem, numericality: { only_integer: true, greater_than: 0 },
                    uniqueness: { scope: :opcao_cardapio_id }
end
