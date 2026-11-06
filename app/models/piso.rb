class Piso < ApplicationRecord
  belongs_to :restaurante
  has_many :catracas, dependent: :restrict_with_error

  validates :numero, numericality: { only_integer: true, greater_than: 0 },
                     uniqueness: { scope: :restaurante_id }

  scope :ordenados, -> { order(:numero) }

  def nome
    "Piso #{numero}"
  end
end
