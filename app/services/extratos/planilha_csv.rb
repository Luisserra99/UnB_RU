require "csv"

# F11 — Arquivo CSV do extrato (responsável: Tarsila).
# Usa ponto e vírgula e BOM UTF-8 para abrir corretamente em planilhas em português.
module Extratos
  class PlanilhaCsv
    include Formatacao

    BOM = "﻿".freeze
    CABECALHO = %w[data_hora evento local catraca valor].freeze

    def initialize(relatorio)
      @relatorio = relatorio
    end

    def render
      BOM + CSV.generate(col_sep: ";") do |csv|
        csv << CABECALHO
        @relatorio.lancamentos.each do |lancamento|
          csv << [ data_hora(lancamento.momento), lancamento.descricao, lancamento.local,
                  lancamento.catraca, valor_decimal(lancamento.valor) ]
        end
      end
    end

    private

    # "-4,50": número com vírgula decimal, sem símbolo de moeda, para a planilha somar.
    def valor_decimal(valor)
      format("%.2f", valor).tr(".", ",")
    end
  end
end
