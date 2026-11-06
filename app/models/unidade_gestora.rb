class UnidadeGestora < ApplicationRecord
  NOME_PADRAO = "Campus Darcy Ribeiro".freeze

  has_many :restaurantes, dependent: :restrict_with_error

  normalizes :nome, with: ->(valor) { valor.squish }

  validates :nome, presence: true, uniqueness: true

  scope :ativas, -> { where(ativa: true) }

  def self.padrao
    find_by(nome: NOME_PADRAO)
  end
end
