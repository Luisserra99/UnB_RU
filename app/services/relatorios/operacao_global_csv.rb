require "csv"

module Relatorios
  # F09 — CSV do Relatório Global de Operação (responsável: Tarsila).
  # Uma linha por restaurante e uma linha de total, sempre com os filtros aplicados nas primeiras colunas.
  class OperacaoGlobalCsv
    # Marca de início de arquivo UTF-8, para a planilha abrir os acentos corretamente.
    BOM = "﻿".freeze
    # Nomes das colunas.
    CABECALHO = %w[data_contabil turno unidade_gestora restaurante acessos arrecadacao_bruta].freeze
    # Texto da coluna de restaurante na linha de total.
    TOTAL = "Total Consolidado".freeze

    # Prepara o gerador do CSV.
    #
    # Argumentos:: +relatorio+ (OperacaoGlobal): relatório já filtrado.
    # Retorno:: o novo OperacaoGlobalCsv.
    # Efeitos colaterais:: nenhum.
    def initialize(relatorio)
      @relatorio = relatorio
    end

    # Gera o CSV, separado por ponto e vírgula e com BOM UTF-8.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com o conteúdo do arquivo.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def render
      BOM + CSV.generate(col_sep: ";") do |csv|
        linhas.each { |linha| csv << linha }
      end
    end

    private

    # Lista todas as linhas do arquivo: cabeçalho, restaurantes e total.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Arrays, um por linha do CSV.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def linhas
      restaurantes = @relatorio.linhas.map do |linha|
        linha_de_dados(linha.restaurante.nome, linha.acessos, linha.arrecadacao)
      end
      [ CABECALHO ] + restaurantes + [ linha_de_dados(TOTAL, @relatorio.total_acessos, @relatorio.arrecadacao_global) ]
    end

    # Monta uma linha de dados, precedida dos filtros aplicados.
    #
    # Argumentos:: +nome+ (String): restaurante ou TOTAL; +acessos+ (Integer): quantidade;
    #              +arrecadacao+ (BigDecimal): valor arrecadado.
    # Retorno:: Array de 6 células, na ordem de CABECALHO.
    # Efeitos colaterais:: nenhum.
    def linha_de_dados(nome, acessos, arrecadacao)
      contexto + [ nome, acessos, decimal(arrecadacao) ]
    end

    # Monta as três primeiras colunas de cada linha, com os filtros aplicados.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array com data contábil, turno e unidade gestora (Strings).
    # Efeitos colaterais:: nenhum.
    def contexto
      [ @relatorio.data.strftime(OperacaoGlobal::FORMATO_DATA), @relatorio.turno_nome, @relatorio.unidade_nome ]
    end

    # Formata um valor com vírgula decimal e sem símbolo de moeda, para a planilha somar.
    #
    # Argumentos:: +valor+ (BigDecimal): valor a formatar.
    # Retorno:: String, como "11,50".
    # Efeitos colaterais:: nenhum.
    def decimal(valor)
      format("%.2f", valor).tr(".", ",")
    end
  end
end
