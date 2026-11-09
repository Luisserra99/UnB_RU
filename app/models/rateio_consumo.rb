# Vincula o consumo às recargas efetivamente creditadas, para auditoria por método de pagamento.
class RateioConsumo < ApplicationRecord
  belongs_to :movimentacao_saldo
  belongs_to :recarga
  validates :valor, numericality: { greater_than: 0 }
  validates :recarga_id, uniqueness: { scope: :movimentacao_saldo_id }
  validate :origens_e_limites

  private

  def origens_e_limites
    return unless movimentacao_saldo && recarga && valor
    unless movimentacao_saldo.debito_refeicao? && recarga.confirmada? && recarga.estudante_id == movimentacao_saldo.estudante_id
      errors.add(:base, "Rateio exige débito e recarga confirmada do mesmo estudante")
      return
    end
    credito = recarga.movimentacao_saldo&.valor || 0
    consumido = self.class.where(recarga: recarga).where.not(id: id).sum(:valor)
    errors.add(:valor, "excede o crédito disponível da recarga") if consumido + valor > credito
    total = self.class.where(movimentacao_saldo: movimentacao_saldo).where.not(id: id).sum(:valor)
    errors.add(:valor, "excede o débito") if total + valor > movimentacao_saldo.valor.abs
  end
end
