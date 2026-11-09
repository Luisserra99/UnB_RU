class Estudante < ApplicationRecord
  FORMATO_MATRICULA = /\A\d{9}\z/

  belongs_to :usuario
  # F02/F03 (Luis): recargas e extrato do saldo.
  has_many :recargas, dependent: :restrict_with_error
  has_many :movimentacoes_saldo, class_name: "MovimentacaoSaldo", dependent: :restrict_with_error

  normalizes :matricula, with: ->(valor) { valor.strip }

  validates :matricula, presence: true, uniqueness: true, format: { with: FORMATO_MATRICULA }
  validates :usuario_id, uniqueness: true

  scope :com_vinculo_ativo, -> { where(vinculo_ativo: true) }

  delegate :nome, :email, to: :usuario

  # Saldo em reais: soma dos créditos (positivos) e débitos (negativos) de MovimentacaoSaldo.
  def saldo
    movimentacoes_saldo.sum(:valor).to_d
  end
end
