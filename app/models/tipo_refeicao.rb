# Tipo de refeição servido pelo RU (F10): café da manhã, almoço ou jantar.
class TipoRefeicao < ApplicationRecord
  # Código do café da manhã.
  CAFE_DA_MANHA = "cafe_da_manha".freeze
  # Código do almoço.
  ALMOCO = "almoco".freeze
  # Código do jantar.
  JANTAR = "jantar".freeze
  # Códigos aceitos, na sequência do dia.
  CODIGOS = [ CAFE_DA_MANHA, ALMOCO, JANTAR ].freeze

  has_many :servicos_refeicao, class_name: "ServicoRefeicao", dependent: :restrict_with_error

  validates :codigo, presence: true, uniqueness: true, inclusion: { in: CODIGOS }
  validates :nome, presence: true

  # Tipos na sequência do dia (café, almoço, jantar).
  scope :ordenados, -> { in_order_of(:codigo, CODIGOS) }
end
