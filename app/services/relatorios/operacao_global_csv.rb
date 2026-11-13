require "csv"

# F09 — CSV do Relatório Global de Operação (responsável: Tarsila).
# Uma linha por restaurante e uma linha de total, sempre com os filtros aplicados nas primeiras colunas.
module Relatorios
  class OperacaoGlobalCsv
    BOM = "﻿".freeze
    CABECALHO = %w[data_contabil turno unidade_gestora restaurante acessos arrecadacao_bruta].freeze
    TOTAL = "Total Consolidado".freeze

    def initialize(relatorio)
      @relatorio = relatorio
    end

    def render
      BOM + CSV.generate(col_sep: ";") do |csv|
        csv << CABECALHO
        @relatorio.linhas.each { |linha| csv << contexto + [ linha.restaurante.nome, linha.acessos, decimal(linha.arrecadacao) ] }
        csv << contexto + [ TOTAL, @relatorio.total_acessos, decimal(@relatorio.arrecadacao_global) ]
      end
    end

    private

    def contexto
      [ @relatorio.data.strftime(OperacaoGlobal::FORMATO_DATA), @relatorio.turno_nome, @relatorio.unidade_nome ]
    end

    def decimal(valor)
      format("%.2f", valor).tr(".", ",")
    end
  end
end
