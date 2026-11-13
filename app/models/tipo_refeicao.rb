class TipoRefeicao < ApplicationRecord
  CAFE_DA_MANHA = "cafe_da_manha".freeze
  ALMOCO = "almoco".freeze
  JANTAR = "jantar".freeze
  CODIGOS = [ CAFE_DA_MANHA, ALMOCO, JANTAR ].freeze

  has_many :servicos_refeicao, class_name: "ServicoRefeicao", dependent: :restrict_with_error

  validates :codigo, presence: true, uniqueness: true, inclusion: { in: CODIGOS }
  validates :nome, presence: true

  scope :ordenados, -> { in_order_of(:codigo, CODIGOS) }
end
