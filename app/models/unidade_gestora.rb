# Unidade gestora (campus) que agrupa e numera os restaurantes (F08).
# Não pode ser removida enquanto tiver restaurantes.
class UnidadeGestora < ApplicationRecord
  # Nome da unidade pré-selecionada no cadastro de restaurante.
  NOME_PADRAO = "Campus Darcy Ribeiro".freeze

  has_many :restaurantes, dependent: :restrict_with_error

  normalizes :nome, with: ->(valor) { valor.squish }

  validates :nome, presence: true, uniqueness: true

  # Unidades em funcionamento.
  scope :ativas, -> { where(ativa: true) }

  # Busca a unidade gestora padrão, pré-selecionada no cadastro de restaurante.
  #
  # Argumentos:: nenhum.
  # Retorno:: a UnidadeGestora com o nome NOME_PADRAO; nil se ela não está cadastrada.
  # Efeitos colaterais:: consulta o banco.
  def self.padrao
    find_by(nome: NOME_PADRAO)
  end
end
