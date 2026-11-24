require "prawn"
require "prawn/table"

# As fontes embutidas do PDF cobrem os acentos do português; o aviso do Prawn não se aplica.
Prawn::Fonts::AFM.hide_m17n_warning = true

module Extratos
  # F09, F11 e F12 — Blocos de montagem comuns aos PDFs de relatório (responsável: Tarsila).
  # Reúne o que o extrato, o Relatório Global e o PDF de auditoria fazem do mesmo jeito: abrir o
  # documento, escrever uma sequência de linhas e desenhar uma tabela com cabeçalho destacado.
  module ComposicaoPdf
    # Nome do sistema, gravado como autor do PDF e escrito no topo de cada documento.
    SISTEMA = "RU UnB Digital".freeze
    # Cor dos títulos e dos nomes de seção.
    COR_TITULO = "003366".freeze
    # Cor de fundo da linha de cabeçalho das tabelas.
    COR_CABECALHO = "E8EEF4".freeze
    # Estilo da linha com o nome do sistema e dos textos secundários.
    ESTILO_SECUNDARIO = { size: 10, color: "666666" }.freeze
    # Estilo do título do documento.
    ESTILO_TITULO = { size: 18, style: :bold, color: COR_TITULO }.freeze
    # Estilo do nome de cada seção.
    ESTILO_SECAO = { size: 12, style: :bold, color: COR_TITULO }.freeze
    # Estilo do rodapé.
    ESTILO_RODAPE = { size: 8, color: "666666" }.freeze

    private

    # Abre um documento A4 em Helvetica, com o título e o sistema nos metadados.
    #
    # Argumentos:: +titulo+ (String): título gravado nos metadados do PDF;
    #              +opcoes+ (Hash): opções extras do Prawn, como +margin+ e +page_layout+.
    # Retorno:: Prawn::Document vazio, pronto para receber conteúdo.
    # Efeitos colaterais:: nenhum.
    def novo_documento(titulo, **opcoes)
      documento = Prawn::Document.new(page_size: "A4", info: { Title: titulo, Creator: SISTEMA }, **opcoes)
      documento.font "Helvetica"
      documento
    end

    # Escreve várias linhas de texto em sequência.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem;
    #              +linhas+ (Array): cada item é uma String ou um par [String, Hash de estilo].
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta as linhas ao documento.
    def escrever_linhas(documento, linhas)
      linhas.each do |texto, estilo|
        documento.text(texto, **(estilo || {}))
      end
    end

    # Escreve o nome de uma seção, com um pequeno espaço depois.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem; +titulo+ (String): nome da seção.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o título ao documento.
    def secao(documento, titulo)
      documento.text titulo, **ESTILO_SECAO
      documento.move_down 4
    end

    # Desenha uma tabela na largura da página, com a primeira linha destacada como cabeçalho.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem;
    #              +linhas+ (Array de Arrays de String): o cabeçalho seguido das linhas de dados;
    #              +colunas_a_direita+ (Integer ou Range): colunas alinhadas à direita (valores);
    #              +destacar_ultima+ (Boolean): põe a última linha em negrito (linha de total).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a tabela ao documento.
    def desenhar_tabela(documento, linhas, colunas_a_direita:, destacar_ultima: false)
      ultima = linhas.size - 1
      documento.table(linhas, header: true, width: documento.bounds.width,
                              cell_style: { size: 9, border_color: "CCCCCC" }) do
        row(0).font_style = :bold
        row(0).background_color = COR_CABECALHO
        row(ultima).font_style = :bold if destacar_ultima
        columns(colunas_a_direita).align = :right
      end
    end

    # Monta a frase final do rodapé com o número da exportação, quando ele existe.
    #
    # Argumentos:: +numero+ (Integer ou nil): identificador do ExportacaoRelatorio.
    # Retorno:: String " Exportação nº N."; String vazia quando não há número.
    # Efeitos colaterais:: nenhum.
    def registro_da_exportacao(numero)
      numero ? " Exportação nº #{numero}." : ""
    end
  end
end
