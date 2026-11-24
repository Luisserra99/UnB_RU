module Extratos
  # F11 — Formatação compartilhada pelo PDF e pelo CSV do extrato e pelos PDFs dos relatórios
  # administrativos (responsável: Tarsila).
  module Formatacao
    # Formato de data e hora dos arquivos exportados ("14/05/2024 12:20").
    FORMATO_DATA_HORA = "%d/%m/%Y %H:%M".freeze

    module_function

    # Formata um momento no fuso da aplicação.
    #
    # Argumentos:: +momento+ (Time): data e hora a formatar.
    # Retorno:: String, como "14/05/2024 12:20".
    # Efeitos colaterais:: nenhum.
    def data_hora(momento)
      momento.in_time_zone.strftime(FORMATO_DATA_HORA)
    end

    # Formata um valor em reais.
    #
    # Argumentos:: +valor+ (Numeric): valor a formatar.
    # Retorno:: String, como "R$ 4,50".
    # Efeitos colaterais:: nenhum.
    def reais(valor)
      ActiveSupport::NumberHelper.number_to_currency(valor, locale: :"pt-BR")
    end

    # Formata um valor com o sinal na frente, como na tela: menos nos débitos e mais nos créditos.
    #
    # Argumentos:: +valor+ (Numeric): valor do lançamento, negativo para débito.
    # Retorno:: String, como "- R$ 4,50" ou "+ R$ 45,00".
    # Efeitos colaterais:: nenhum.
    def valor_com_sinal(valor)
      "#{valor.negative? ? '-' : '+'} #{reais(valor.abs)}"
    end
  end
end
