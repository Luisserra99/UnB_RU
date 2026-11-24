# Vincula o consumo às recargas efetivamente creditadas, para auditoria por método de pagamento.
class RateioConsumo < ApplicationRecord
  belongs_to :movimentacao_saldo
  belongs_to :recarga
  validates :valor, numericality: { greater_than: 0 }
  validates :recarga_id, uniqueness: { scope: :movimentacao_saldo_id }
  validate :origens_e_limites

  private

  # Confere as origens do rateio antes de validar os limites financeiros.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta as origens e adiciona erros em +base+ ou +valor+.
  def origens_e_limites
    return unless movimentacao_saldo && recarga && valor
    unless origens_compativeis?
      errors.add(:base, "Rateio exige débito e recarga confirmada do mesmo estudante")
      return
    end
    validar_credito_disponivel
    validar_limite_do_debito
  end

  # Exige um débito e uma recarga confirmada pertencentes ao mesmo estudante.
  #
  # Argumentos:: nenhum; requer as duas origens presentes.
  # Retorno:: true se as origens são compatíveis; false caso contrário.
  # Efeitos colaterais:: consulta as associações, sem gravar alterações.
  def origens_compativeis?
    movimentacao_saldo.debito_refeicao? && recarga.confirmada? &&
      recarga.estudante_id == movimentacao_saldo.estudante_id
  end

  # Limita o consumo ao crédito real da recarga, excluindo este rateio da soma.
  #
  # Argumentos:: nenhum; requer origens compatíveis e +valor+ preenchido.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta o crédito e os rateios; adiciona erro em +valor+ se excedido.
  def validar_credito_disponivel
    if consumido_da_recarga + valor > credito_da_recarga
      errors.add(:valor, "excede o crédito disponível da recarga")
    end
  end

  # Limita a soma dos rateios ao valor absoluto do débito, excluindo este registro.
  #
  # Argumentos:: nenhum; requer origens compatíveis e +valor+ preenchido.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta os rateios e adiciona erro em +valor+ se o débito for excedido.
  def validar_limite_do_debito
    if consumido_do_debito + valor > movimentacao_saldo.valor.abs
      errors.add(:valor, "excede o débito")
    end
  end

  # Obtém o crédito efetivamente associado à recarga.
  #
  # Argumentos:: nenhum.
  # Retorno:: BigDecimal do crédito; 0 se não há movimentação de crédito.
  # Efeitos colaterais:: consulta a movimentação associada, sem gravar alterações.
  def credito_da_recarga
    recarga.movimentacao_saldo&.valor || 0
  end

  # Soma o consumo da recarga sem contar este registro numa atualização.
  #
  # Argumentos:: nenhum.
  # Retorno:: BigDecimal com a soma dos demais rateios da recarga, ou zero.
  # Efeitos colaterais:: consulta os rateios no banco, sem gravar alterações.
  def consumido_da_recarga
    self.class.where(recarga: recarga).where.not(id: id).sum(:valor)
  end

  # Soma as parcelas do débito sem contar este registro numa atualização.
  #
  # Argumentos:: nenhum.
  # Retorno:: BigDecimal com a soma dos demais rateios do débito, ou zero.
  # Efeitos colaterais:: consulta os rateios no banco, sem gravar alterações.
  def consumido_do_debito
    self.class.where(movimentacao_saldo: movimentacao_saldo).where.not(id: id).sum(:valor)
  end
end
