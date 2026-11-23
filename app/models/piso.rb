# Piso de um restaurante (F08), numerado a partir de 1, onde ficam as catracas.
# Não pode ser removido enquanto tiver catracas.
class Piso < ApplicationRecord
  belongs_to :restaurante
  has_many :catracas, dependent: :restrict_with_error

  validates :numero, numericality: { only_integer: true, greater_than: 0 },
                     uniqueness: { scope: :restaurante_id }

  # Pisos em ordem crescente de número.
  scope :ordenados, -> { order(:numero) }

  # Monta o nome exibido do piso.
  #
  # Argumentos:: nenhum.
  # Retorno:: String no formato "Piso N".
  # Efeitos colaterais:: nenhum.
  def nome
    "Piso #{numero}"
  end
end
