# Cadastro de estudante de um Usuario (F01): matrícula, vínculo e saldo para as refeições.
class Estudante < ApplicationRecord
  # Formato da matrícula: exatamente 9 números (RN01.1).
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

  # Saldo do estudante, em reais.
  #
  # Argumentos:: nenhum.
  # Retorno:: BigDecimal com a soma dos créditos (positivos) e débitos (negativos) de
  #           MovimentacaoSaldo; zero sem movimentações.
  # Efeitos colaterais:: consulta o banco.
  def saldo
    movimentacoes_saldo.sum(:valor).to_d
  end
end
