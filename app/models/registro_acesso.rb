class RegistroAcesso < ApplicationRecord
  LIMITE_PASSAGEM = 5.seconds
  enum :estado, { recusado: "recusado", liberado: "liberado", realizado: "realizado", cancelado: "cancelado" }, validate: true
  belongs_to :configuracao_ponto_acesso
  belongs_to :estudante, optional: true
  belongs_to :servico_refeicao, optional: true
  belongs_to :tarifa_refeicao, optional: true
  has_one :movimentacao_saldo, dependent: :restrict_with_error
  delegate :restaurante, :catraca, :funcionario, to: :configuracao_ponto_acesso

  validates :referencia_evento, presence: true, uniqueness: true, length: { maximum: 64 }
  validates :identificacao_lida, length: { maximum: 100 }
  validates :lido_em, :mensagem, presence: true
  validates :valor_previsto, numericality: { greater_than: 0 }, allow_nil: true
  validate :coerencia_da_passagem

  def limite_em
    liberado_em && liberado_em + LIMITE_PASSAGEM
  end

  def catraca_liberada?
    liberado_em.present?
  end

  def acesso_realizado?
    passagem_em.present?
  end

  private

  def coerencia_da_passagem
    if realizado? && (estudante.nil? || liberado_em.nil? || passagem_em.nil? || bloqueado_em.nil?)
      errors.add(:base, "Passagem exige estudante, liberação e bloqueio")
    end
    if passagem_em && (liberado_em.nil? || passagem_em < liberado_em || passagem_em > limite_em)
      errors.add(:passagem_em, "deve ocorrer em até 5 segundos após a liberação")
    end
  end
end
