# Dados do cartão de crédito informados no pagamento (F02). Não são persistidos:
# servem só para validar o formato e pedir a autorização ao gateway simulado.
class DadosCartao
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Aviso genérico mostrado quando algum dado do cartão é inválido.
  MSG_INVALIDOS = "Dados do cartão inválidos".freeze
  # Formato aceito para a validade: MM/AA.
  FORMATO_VALIDADE = %r{\A(\d{2})/(\d{2})\z}

  attribute :numero, :string
  attribute :nome, :string
  attribute :validade, :string
  attribute :cvv, :string

  validates :nome, presence: { message: "Informe o nome impresso no cartão" }
  validate :numero_valido
  validate :validade_futura
  validate :cvv_valido

  # Remove espaços, pontos e hífens do número do cartão.
  #
  # Argumentos:: nenhum.
  # Retorno:: String só com o que sobrou do número (vazia se não informado).
  # Efeitos colaterais:: nenhum.
  def numero_normalizado
    numero.to_s.gsub(/[\s.-]/, "")
  end

  # Devolve os 4 últimos dígitos do cartão, os únicos que podem ser exibidos.
  #
  # Argumentos:: nenhum.
  # Retorno:: String com até 4 caracteres.
  # Efeitos colaterais:: nenhum.
  def ultimos_digitos
    numero_normalizado.last(4)
  end

  private

  # Validação: o número deve ter 16 dígitos e passar no algoritmo de Luhn.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +numero+ quando inválido.
  def numero_valido
    return if numero_normalizado.match?(/\A\d{16}\z/) && luhn_valido?(numero_normalizado)

    errors.add(:numero, "Número do cartão inválido")
  end

  # Validação: a validade deve estar no formato MM/AA e não pode ter passado.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +validade+ quando o formato é inválido ou o cartão venceu.
  def validade_futura
    vencimento = fim_da_validade
    if vencimento.nil?
      errors.add(:validade, "Validade inválida: use o formato MM/AA")
    elsif vencimento < Date.current
      errors.add(:validade, "Cartão vencido")
    end
  end

  # Converte a validade "MM/AA" no último dia do mês correspondente.
  #
  # Argumentos:: nenhum.
  # Retorno:: Date do último dia do mês da validade, ou nil se o formato ou o mês forem inválidos.
  # Efeitos colaterais:: nenhum.
  def fim_da_validade
    mes, ano = mes_e_ano_da_validade
    Date.new(2000 + ano, mes, 1).end_of_month if mes&.between?(1, 12)
  end

  # Separa o mês e o ano (com 2 dígitos) da validade digitada.
  #
  # Argumentos:: nenhum.
  # Retorno:: Array [mes, ano] de Integers, ou nil se a validade não estiver no formato MM/AA.
  # Efeitos colaterais:: nenhum.
  def mes_e_ano_da_validade
    validade.to_s.strip.match(FORMATO_VALIDADE)&.captures&.map(&:to_i)
  end

  # Validação: o CVV deve ter 3 dígitos.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +cvv+ quando inválido.
  def cvv_valido
    errors.add(:cvv, "CVV inválido: informe 3 dígitos") unless cvv.to_s.strip.match?(/\A\d{3}\z/)
  end

  # Confere o dígito verificador do cartão pelo algoritmo de Luhn.
  #
  # Argumentos:: +digitos+ (String): número do cartão só com dígitos.
  # Retorno:: true quando a soma de Luhn é múltipla de 10; false caso contrário.
  # Efeitos colaterais:: nenhum.
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
