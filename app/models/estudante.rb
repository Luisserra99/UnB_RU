class Estudante < ApplicationRecord
  FORMATO_MATRICULA = /\A\d{9}\z/

  belongs_to :usuario

  normalizes :matricula, with: ->(valor) { valor.strip }

  validates :matricula, presence: true, uniqueness: true, format: { with: FORMATO_MATRICULA }
  validates :usuario_id, uniqueness: true

  scope :com_vinculo_ativo, -> { where(vinculo_ativo: true) }

  delegate :nome, :email, to: :usuario
end
