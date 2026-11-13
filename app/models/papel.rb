class Papel < ApplicationRecord
  ESTUDANTE = "estudante".freeze
  FUNCIONARIO = "funcionario".freeze
  ADMINISTRADOR = "administrador".freeze
  CODIGOS_CONTROLE = [ FUNCIONARIO, ADMINISTRADOR ].freeze

  has_many :usuario_papeis, dependent: :restrict_with_error
  has_many :usuarios, through: :usuario_papeis

  validates :codigo, presence: true, uniqueness: true
  validates :descricao, presence: true
end
