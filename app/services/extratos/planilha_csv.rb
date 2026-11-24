require "csv"

module Extratos
  # F11 — Arquivo CSV do extrato (responsável: Tarsila).
  # Usa ponto e vírgula e BOM UTF-8 para abrir corretamente em planilhas em português.
  class PlanilhaCsv
    include Formatacao

    # Marca de início de arquivo UTF-8, para a planilha abrir os acentos corretamente.
    BOM = "﻿".freeze
    # Nomes das colunas.
    CABECALHO = %w[data_hora evento local catraca valor].freeze

    # Prepara o gerador do CSV.
    #
    # Argumentos:: +relatorio+ (Relatorio): extrato já filtrado.
    # Retorno:: o novo PlanilhaCsv.
    # Efeitos colaterais:: nenhum.
    def initialize(relatorio)
      @relatorio = relatorio
    end

    # Gera o CSV com uma linha por lançamento, separado por ponto e vírgula e com BOM UTF-8.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com o conteúdo do arquivo.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def render
      BOM + CSV.generate(col_sep: ";") do |csv|
        csv << CABECALHO
        @relatorio.lancamentos.each { |lancamento| csv << linha(lancamento) }
      end
    end

    private

    # Converte um lançamento nas células de uma linha do CSV.
    #
    # Argumentos:: +lancamento+ (Relatorio::Lancamento): lançamento a exportar.
    # Retorno:: Array de 5 células, na ordem de CABECALHO.
    # Efeitos colaterais:: nenhum.
    def linha(lancamento)
      [ data_hora(lancamento.momento), lancamento.descricao, lancamento.local,
        lancamento.catraca, valor_decimal(lancamento.valor) ]
    end

    # Formata um valor com vírgula decimal e sem símbolo de moeda, para a planilha somar.
    #
    # Argumentos:: +valor+ (BigDecimal): valor do lançamento, com sinal.
    # Retorno:: String, como "-4,50".
    # Efeitos colaterais:: nenhum.
    def valor_decimal(valor)
      format("%.2f", valor).tr(".", ",")
    end
  end
end
