module Relatorios
  # F12 — PDF de auditoria do Relatório de Operação (responsável: Tarsila).
  # Traz todos os acessos do filtro, o emissor, a data e hora da emissão, os filtros e o
  # agrupamento aplicados (RN12.3 e RN12.4), com subtotais quando agrupado (RN12.5).
  class AcessosOperacaoPdf
    include Extratos::Formatacao
    include Extratos::ComposicaoPdf

    # Título do documento.
    TITULO = "Relatório Global de Operação".freeze
    # Linha abaixo do título, que identifica a finalidade do documento.
    SUBTITULO = "Acessos registrados — auditoria interna".freeze
    # Nomes das colunas da tabela de acessos.
    CABECALHO = [ "Acesso", "Data e hora", "Matrícula", "Restaurante", "Catraca", "Refeição", "Valor debitado" ].freeze
    # Índice da coluna de valor, alinhada à direita.
    COLUNA_VALOR = 6
    # Estilo das linhas de total (restaurante e geral).
    ESTILO_TOTAL = { size: 10, style: :bold }.freeze

    # Prepara o gerador do PDF.
    #
    # Argumentos:: +relatorio+ (AcessosOperacao): relatório já filtrado e válido;
    #              +emissor+ (Usuario): administrador que pediu o documento;
    #              +emitido_em+ (Time): data e hora da emissão;
    #              +numero_exportacao+ (Integer ou nil): id do ExportacaoRelatorio, escrito no cabeçalho.
    # Retorno:: o novo AcessosOperacaoPdf.
    # Efeitos colaterais:: nenhum.
    def initialize(relatorio, emissor:, emitido_em:, numero_exportacao: nil)
      @relatorio = relatorio
      @emissor = emissor
      @emitido_em = emitido_em
      @numero_exportacao = numero_exportacao
    end

    # Gera o PDF em paisagem, com cabeçalho, acessos, totais e numeração de páginas.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com os bytes do PDF.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def render
      documento = novo_documento(TITULO, page_layout: :landscape, margin: 36)
      cabecalho(documento)
      corpo(documento)
      totais(documento)
      numerar_paginas(documento)
      documento.render
    end

    private

    # Relatório de acessos que alimenta o documento (AcessosOperacao).
    attr_reader :relatorio
    # Administrador que pediu o documento (Usuario).
    attr_reader :emissor
    # Data e hora da emissão (Time).
    attr_reader :emitido_em
    # Id do ExportacaoRelatorio (Integer), ou nil.
    attr_reader :numero_exportacao

    # Escreve o cabeçalho: título, emissor, emissão, filtros e agrupamento (RN12.3 e RN12.4).
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o cabeçalho ao documento.
    def cabecalho(documento)
      escrever_linhas(documento, linhas_de_titulo)
      documento.move_down 8
      escrever_linhas(documento, linhas_de_emissao + linhas_de_filtros)
      documento.move_down 12
    end

    # Lista as linhas de título do documento, com seus estilos.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [String, Hash de estilo].
    # Efeitos colaterais:: nenhum.
    def linhas_de_titulo
      [ [ SISTEMA, ESTILO_SECUNDARIO ], [ TITULO, ESTILO_TITULO ], [ SUBTITULO, ESTILO_SECUNDARIO ] ]
    end

    # Lista as linhas que identificam quem emitiu o documento e quando.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: nenhum.
    def linhas_de_emissao
      [ "Emitido por: #{emissor.nome} (#{emissor.identificacao})", "Emitido em: #{data_hora(emitido_em)}" ]
    end

    # Lista as linhas com os filtros e o agrupamento aplicados e, se houver, o número da exportação.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: nenhum.
    def linhas_de_filtros
      [ "Período: #{relatorio.periodo_nome}", "Restaurante: #{relatorio.restaurante_nome}",
        "Catraca: #{relatorio.catraca_nome}", "Agrupamento: #{relatorio.agrupamento_nome}",
        linha_da_exportacao ].compact
    end

    # Monta a linha com o número da exportação.
    #
    # Argumentos:: nenhum.
    # Retorno:: String "Exportação nº N"; nil quando o documento não tem número.
    # Efeitos colaterais:: nenhum.
    def linha_da_exportacao
      "Exportação nº #{numero_exportacao}" if numero_exportacao
    end

    # Escreve os acessos: agrupados por restaurante e catraca ou numa tabela única.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta os acessos ao documento.
    def corpo(documento)
      relatorio.agrupado? ? corpo_agrupado(documento) : tabela(documento, relatorio.acessos)
    end

    # Escreve um bloco por restaurante, com as suas catracas e os subtotais (RN12.5).
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta os blocos ao documento.
    def corpo_agrupado(documento)
      relatorio.grupos.each { |grupo| bloco_do_restaurante(documento, grupo) }
    end

    # Escreve o bloco de um restaurante: nome, catracas e total do restaurante.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem;
    #              +grupo+ (AcessosOperacao::Grupo): restaurante com os seus subtotais.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o bloco ao documento.
    def bloco_do_restaurante(documento, grupo)
      secao(documento, "Restaurante: #{grupo.restaurante}")
      grupo.catracas.each { |subtotal| bloco_da_catraca(documento, subtotal) }
      documento.text "Total #{grupo.restaurante}: #{resumo(grupo)}", **ESTILO_TOTAL
      documento.move_down 14
    end

    # Escreve o bloco de uma catraca: nome, tabela de acessos e subtotal.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem;
    #              +subtotal+ (AcessosOperacao::Subtotal): catraca com os seus acessos.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o bloco ao documento.
    def bloco_da_catraca(documento, subtotal)
      local = "#{subtotal.restaurante} · #{subtotal.catraca}"
      documento.text local, **ESTILO_TOTAL
      tabela(documento, subtotal.acessos)
      documento.text "Subtotal #{local}: #{resumo(subtotal)}", size: 10
      documento.move_down 10
    end

    # Resume um grupo ou subtotal em quantidade e valor.
    #
    # Argumentos:: +parte+ (AcessosOperacao::Grupo ou AcessosOperacao::Subtotal): responde a
    #              +quantidade+ e +total+.
    # Retorno:: String, como "2 acessos · R$ 9,00".
    # Efeitos colaterais:: nenhum.
    def resumo(parte)
      "#{contagem(parte.quantidade)} · #{reais(parte.total)}"
    end

    # Desenha a tabela de acessos.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem;
    #              +acessos+ (Array de AcessosOperacao::Acesso): acessos a listar.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a tabela ao documento.
    def tabela(documento, acessos)
      linhas = acessos.map { |acesso| linha_da_tabela(acesso) }
      desenhar_tabela(documento, [ CABECALHO ] + linhas, colunas_a_direita: COLUNA_VALOR)
      documento.move_down 6
    end

    # Converte um acesso nas células de uma linha da tabela.
    #
    # Argumentos:: +acesso+ (AcessosOperacao::Acesso): acesso a exibir.
    # Retorno:: Array de 7 Strings, na ordem de CABECALHO.
    # Efeitos colaterais:: nenhum.
    def linha_da_tabela(acesso)
      [ acesso.referencia, data_hora(acesso.momento), acesso.matricula.to_s, acesso.restaurante,
        acesso.catraca, acesso.refeicao, reais(acesso.valor) ]
    end

    # Escreve o total geral de acessos e o total debitado.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta os totais ao documento.
    def totais(documento)
      documento.move_down 6
      documento.text "Total geral: #{contagem(relatorio.quantidade)}", size: 11, style: :bold
      documento.text "Total debitado: #{reais(relatorio.total_debitado)}", size: 11, style: :bold
    end

    # Numera as páginas no rodapé ("Página 1 de 3").
    #
    # Argumentos:: +documento+ (Prawn::Document): documento já com todo o conteúdo.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a numeração a todas as páginas do documento.
    def numerar_paginas(documento)
      documento.number_pages "Página <page> de <total>", at: [ documento.bounds.right - 120, -8 ], width: 120,
                                                         align: :right, size: 8
    end

    # Escreve a quantidade de acessos com o plural correto.
    #
    # Argumentos:: +quantidade+ (Integer): número de acessos.
    # Retorno:: String, como "1 acesso" ou "2 acessos".
    # Efeitos colaterais:: nenhum.
    def contagem(quantidade)
      "#{quantidade} #{quantidade == 1 ? 'acesso' : 'acessos'}"
    end
  end
end
