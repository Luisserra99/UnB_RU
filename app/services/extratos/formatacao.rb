# F11 — Formatação compartilhada pelo PDF e pelo CSV do extrato (responsável: Tarsila).
module Extratos
  module Formatacao
    FORMATO_DATA_HORA = "%d/%m/%Y %H:%M".freeze

    module_function

    def data_hora(momento)
      momento.in_time_zone.strftime(FORMATO_DATA_HORA)
    end

    def reais(valor)
      ActiveSupport::NumberHelper.number_to_currency(valor, locale: :"pt-BR")
    end

    # Débitos com sinal de menos e créditos com sinal de mais, como na tela.
    def valor_com_sinal(valor)
      "#{valor.negative? ? '-' : '+'} #{reais(valor.abs)}"
    end
  end
end
