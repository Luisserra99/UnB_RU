# Papel de acesso de um Usuario (estudante, funcionário ou administrador).
class Papel < ApplicationRecord
  # Código do papel de estudante (Portal do Estudante).
  ESTUDANTE = "estudante".freeze
  # Código do papel de funcionário (aplicação de controle).
  FUNCIONARIO = "funcionario".freeze
  # Código do papel de administrador (aplicação de controle e administração).
  ADMINISTRADOR = "administrador".freeze
  # Papéis que dão acesso à aplicação de controle.
  CODIGOS_CONTROLE = [ FUNCIONARIO, ADMINISTRADOR ].freeze

  has_many :usuario_papeis, dependent: :restrict_with_error
  has_many :usuarios, through: :usuario_papeis

  validates :codigo, presence: true, uniqueness: true
  validates :descricao, presence: true
end
