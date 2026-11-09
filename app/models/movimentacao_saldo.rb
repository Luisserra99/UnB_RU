# Lançamento no saldo do estudante. O saldo é a soma dos valores (Estudante#saldo).
# - credito_recarga (F02): valor positivo, gerado pela confirmação de uma recarga.
# - debito_refeicao (F06, Daniel): valor negativo, gerado pela passagem na catraca. Hoje o débito
#   ainda não exige registro_acesso_id, porque RegistroAcesso ainda não existe.
class MovimentacaoSaldo < ApplicationRecord
  enum :natureza, { credito_recarga: "credito_recarga", debito_refeicao: "debito_refeicao" }, validate: true

  belongs_to :estudante
  belongs_to :recarga, optional: true

  validates :valor, presence: true
  validates :ocorrida_em, presence: true
  validates :recarga_id, uniqueness: true, allow_nil: true
  validates :registro_acesso_id, uniqueness: true, allow_nil: true
  validate :coerencia_da_origem

  scope :recentes, -> { order(ocorrida_em: :desc, id: :desc) }
  scope :creditos, -> { credito_recarga }
  scope :debitos, -> { debito_refeicao }

  def descricao
    if credito_recarga?
      metodo = recarga&.pagamentos&.find(&:confirmado?)&.nome_metodo
      metodo ? "Recarga de Saldo (#{metodo})" : "Recarga de Saldo"
    else
      ["Refeição", tipo_refeicao&.nome].compact.join(": ")
    end
  end

  # Ponto de extensão para a F06: o tipo virá de RegistroAcesso -> ServicoRefeicao -> TipoRefeicao.
  def tipo_refeicao
    nil
  end

  private

  def coerencia_da_origem
    return if valor.nil?

    credito_recarga? ? validar_credito : validar_debito
  end

  def validar_credito
    errors.add(:valor, "do crédito deve ser positivo") unless valor.positive?
    errors.add(:registro_acesso_id, "não se aplica a crédito") if registro_acesso_id.present?
    if recarga.nil?
      errors.add(:recarga, "é obrigatória para crédito")
    else
      errors.add(:recarga, "deve estar confirmada") unless recarga.confirmada?
      errors.add(:recarga, "deve ser do mesmo estudante") unless recarga.estudante_id == estudante_id
    end
  end

  def validar_debito
    errors.add(:valor, "do débito deve ser negativo") unless valor.negative?
    errors.add(:recarga, "não se aplica a débito") if recarga_id.present?
  end
end
