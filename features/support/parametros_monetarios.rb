# Tipo de parâmetro compartilhado para valores em reais nos cenários ("R$ 1.234,56").
# Uso: Então("o saldo do estudante deve ser R$ {dinheiro}") { |valor| ... } — valor é BigDecimal.
# Não redefina {dinheiro} em outro arquivo: nomes repetidos fazem o Cucumber falhar.
ParameterType(
  name: "dinheiro",
  regexp: /\d{1,3}(?:\.\d{3})*,\d{2}/,
  type: BigDecimal,
  transformer: ->(texto) { BigDecimal(texto.delete(".").tr(",", ".")) }
)

module ValoresMonetarios
  # Aceita "1.234,56" ou um número. Atenção: em passos com regex, o Cucumber já converte
  # grupos que casam com {dinheiro} em BigDecimal, então o valor pode chegar convertido.
  def reais(valor)
    return BigDecimal(valor.to_s) if valor.is_a?(Numeric)

    BigDecimal(valor.to_s.delete(".").tr(",", "."))
  end

  def formatar_reais(valor)
    ActiveSupport::NumberHelper.number_to_currency(valor, locale: :"pt-BR")
  end
end
World(ValoresMonetarios)
