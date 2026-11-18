# Lançamento no saldo do estudante. O saldo é a soma dos valores (Estudante#saldo).
# - credito_recarga (F02): valor positivo, gerado pela confirmação de uma recarga.
# - debito_refeicao (F06, Daniel): valor negativo, gerado pela passagem na catraca. O débito
#   exige registro de passagem realizada do mesmo estudante.
class MovimentacaoSaldo < ApplicationRecord
  enum :natureza, { credito_recarga: "credito_recarga", debito_refeicao: "debito_refeicao" }, validate: true

  belongs_to :estudante
  belongs_to :recarga, optional: true
  belongs_to :registro_acesso, optional: true
  has_many :rateios_consumo, class_name: "RateioConsumo", dependent: :restrict_with_error

  validates :valor, presence: true
  validates :ocorrida_em, presence: true
  validates :recarga_id, uniqueness: true, allow_nil: true
  validates :registro_acesso_id, uniqueness: true, allow_nil: true
  validate :coerencia_da_origem

  # Lançamentos do mais novo para o mais antigo.
  scope :recentes, -> { order(ocorrida_em: :desc, id: :desc) }
  # Só os créditos de recarga.
  scope :creditos, -> { credito_recarga }
  # Só os débitos de refeição.
  scope :debitos, -> { debito_refeicao }

  # Descreve o lançamento para o extrato (F03).
  #
  # Argumentos:: nenhum.
  # Retorno:: String: "Recarga de Saldo (PIX)" (ou sem o método, se não houver pagamento confirmado)
  #           para créditos; "Refeição: Almoço" (ou só "Refeição", sem tipo) para débitos.
  # Efeitos colaterais:: pode consultar a recarga e os pagamentos, se não estiverem carregados.
  def descricao
    credito_recarga? ? descricao_do_credito : [ "Refeição", tipo_refeicao&.nome ].compact.join(": ")
  end

  # Tipo real da refeição consumida, usado no extrato.
  #
  # Argumentos:: nenhum.
  # Retorno:: TipoRefeicao do serviço da passagem, ou nil para créditos e débitos sem serviço.
  # Efeitos colaterais:: pode consultar o registro de acesso e o serviço, se não estiverem carregados.
  def tipo_refeicao
    registro_acesso&.servico_refeicao&.tipo_refeicao
  end

  private

  # Descreve um crédito com o método do pagamento confirmado da recarga.
  #
  # Argumentos:: nenhum.
  # Retorno:: String, ex.: "Recarga de Saldo (Cartão de Crédito)" ou "Recarga de Saldo".
  # Efeitos colaterais:: pode consultar a recarga e os pagamentos.
  def descricao_do_credito
    metodo = recarga&.pagamentos&.find(&:confirmado?)&.nome_metodo
    metodo ? "Recarga de Saldo (#{metodo})" : "Recarga de Saldo"
  end

  # Validação: o lançamento deve ser coerente com a sua natureza (crédito ou débito).
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: os de #validar_credito ou de #validar_debito; nada sem valor.
  def coerencia_da_origem
    return if valor.nil?

    credito_recarga? ? validar_credito : validar_debito
  end

  # Validação do crédito: valor positivo, sem registro de acesso e com recarga válida.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erros em +valor+, +registro_acesso_id+ e +recarga+.
  def validar_credito
    errors.add(:valor, "do crédito deve ser positivo") unless valor.positive?
    errors.add(:registro_acesso_id, "não se aplica a crédito") if registro_acesso_id.present?
    validar_recarga_do_credito
  end

  # Validação do crédito: a recarga é obrigatória, deve estar confirmada e ser do mesmo estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erros em +recarga+.
  def validar_recarga_do_credito
    return errors.add(:recarga, "é obrigatória para crédito") if recarga.nil?

    errors.add(:recarga, "deve estar confirmada") unless recarga.confirmada?
    errors.add(:recarga, "deve ser do mesmo estudante") unless recarga.estudante_id == estudante_id
  end

  # Validação do débito: passagem realizada pelo mesmo estudante, valor negativo e sem recarga.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erros em +registro_acesso+, +valor+ e +recarga+.
  def validar_debito
    validar_passagem_do_debito
    errors.add(:valor, "do débito deve ser negativo") unless valor.negative?
    errors.add(:recarga, "não se aplica a débito") if recarga_id.present?
  end

  # Validação do débito: o registro de acesso é obrigatório e deve ser uma passagem realizada pelo
  # mesmo estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erros em +registro_acesso+.
  def validar_passagem_do_debito
    return errors.add(:registro_acesso, "é obrigatório para débito") unless registro_acesso
    return if registro_acesso.realizado? && registro_acesso.estudante_id == estudante_id

    errors.add(:registro_acesso, "deve ser uma passagem realizada pelo mesmo estudante")
  end
end
