# Dados do cartão de crédito informados no pagamento (F02). Não são persistidos:
# servem só para validar o formato e pedir a autorização ao gateway simulado.
class DadosCartao
  include ActiveModel::Model
  include ActiveModel::Attributes

  MSG_INVALIDOS = "Dados do cartão inválidos".freeze

  attribute :numero, :string
  attribute :nome, :string
  attribute :validade, :string
  attribute :cvv, :string

  validates :nome, presence: { message: "Informe o nome impresso no cartão" }
  validate :numero_valido
  validate :validade_futura
  validate :cvv_valido

  def numero_normalizado
    numero.to_s.gsub(/[\s.-]/, "")
  end

  def ultimos_digitos
    numero_normalizado.last(4)
  end

  private

  def numero_valido
    return if numero_normalizado.match?(/\A\d{16}\z/) && luhn_valido?(numero_normalizado)

    errors.add(:numero, "Número do cartão inválido")
  end

  def validade_futura
    correspondencia = validade.to_s.strip.match(%r{\A(\d{2})/(\d{2})\z})
    mes = correspondencia && correspondencia[1].to_i
    if mes.nil? || !mes.between?(1, 12)
      errors.add(:validade, "Validade inválida: use o formato MM/AA")
    elsif Date.new(2000 + correspondencia[2].to_i, mes, 1).end_of_month < Date.current
      errors.add(:validade, "Cartão vencido")
    end
  end

  def cvv_valido
    errors.add(:cvv, "CVV inválido: informe 3 dígitos") unless cvv.to_s.strip.match?(/\A\d{3}\z/)
  end

  def luhn_valido?(digitos)
    soma = digitos.reverse.chars.each_with_index.sum do |char, indice|
      valor = char.to_i
      next valor if indice.even?

      valor *= 2
      valor > 9 ? valor - 9 : valor
    end
    (soma % 10).zero?
  end
end
