module Relatorios
  # F09 — PDF oficial do Relatório Global de Operação (responsável: Tarsila).
  # Mostra os mesmos dados da tela, mais os filtros, a data e hora de emissão e o emissor (RN09.13).
  class OperacaoGlobalPdf
    include Extratos::Formatacao
    include Extratos::ComposicaoPdf

    # Título do documento.
    TITULO = "Relatório Global de Operação".freeze
    # Colunas numéricas das tabelas, alinhadas à direita.
    COLUNAS_NUMERICAS = (1..2).freeze

    # Prepara o gerador do PDF.
    #
    # Argumentos:: +relatorio+ (OperacaoGlobal): relatório já filtrado;
    #              +emissor+ (Usuario): administrador que pediu o documento;
    #              +emitido_em+ (Time): data e hora da emissão;
    #              +numero_exportacao+ (Integer ou nil): id do ExportacaoRelatorio, escrito no rodapé.
    # Retorno:: o novo OperacaoGlobalPdf.
    # Efeitos colaterais:: nenhum.
    def initialize(relatorio, emissor:, emitido_em:, numero_exportacao: nil)
      @relatorio = relatorio
      @emissor = emissor
      @emitido_em = emitido_em
      @numero_exportacao = numero_exportacao
    end

    # Gera o PDF com cabeçalho, indicadores, consolidação, liquidação, distribuição e rodapé.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com os bytes do PDF.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def render
      documento = novo_documento(TITULO, margin: 40)
      cabecalho(documento)
      indicadores(documento)
      consolidacao(documento)
      liquidacao(documento)
      distribuicao(documento)
      rodape(documento)
      documento.render
    end

    private

    # Relatório que alimenta o documento (OperacaoGlobal).
    attr_reader :relatorio
    # Administrador que pediu o documento (Usuario).
    attr_reader :emissor
    # Data e hora da emissão (Time).
    attr_reader :emitido_em
    # Id do ExportacaoRelatorio (Integer), ou nil.
    attr_reader :numero_exportacao

    # Escreve o cabeçalho: título, filtros, emissão e emissor (RN09.13).
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o cabeçalho ao documento.
    def cabecalho(documento)
      escrever_linhas(documento, [ [ SISTEMA, ESTILO_SECUNDARIO ], [ TITULO, ESTILO_TITULO ] ])
      documento.move_down 8
      escrever_linhas(documento, linhas_de_filtros + linhas_de_emissao)
      documento.move_down 14
    end

    # Lista as linhas com os filtros aplicados.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: nenhum.
    def linhas_de_filtros
      [ "Data contábil: #{relatorio.data.strftime(OperacaoGlobal::FORMATO_DATA)}",
        "Janela de serviço: #{relatorio.turno_nome}", "Unidade gestora: #{relatorio.unidade_nome}" ]
    end

    # Lista as linhas que identificam quando o documento foi emitido e por quem.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: nenhum.
    def linhas_de_emissao
      [ "Emitido em: #{data_hora(emitido_em)}", "Emitido por: #{emissor.nome} (#{emissor.identificacao})" ]
    end

    # Escreve a seção de indicadores.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a seção ao documento; consulta o banco por meio do relatório.
    def indicadores(documento)
      secao(documento, "Indicadores")
      escrever_linhas(documento, indicadores_de_movimento + indicadores_de_conferencia)
      documento.move_down 14
    end

    # Lista os indicadores de movimento do dia: catracas, arrecadação e refeições.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: consulta o banco por meio do relatório.
    def indicadores_de_movimento
      [ "Catracas online: #{relatorio.catracas_online}/#{relatorio.catracas_cadastradas}",
        "Arrecadação global: #{reais(relatorio.arrecadacao_global)}",
        "Refeições servidas: #{relatorio.total_acessos}" ]
    end

    # Lista os indicadores de conferência: ticket médio, transações e divergências (RN09.11).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: consulta o banco por meio do relatório.
    def indicadores_de_conferencia
      [ "Ticket médio por estudante: #{reais(relatorio.ticket_medio)}",
        "Transações validadas: #{relatorio.transacoes_validadas}",
        "Divergências contábeis: #{reais(relatorio.divergencia_contabil)}" ]
    end

    # Escreve a tabela de acessos e arrecadação por restaurante, com a linha de total.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a seção ao documento.
    def consolidacao(documento)
      linhas = relatorio.linhas.map { |linha| linha_de_restaurante(linha) }
      linhas << [ "Total Consolidado", relatorio.total_acessos.to_s, reais(relatorio.arrecadacao_global) ]
      tabela(documento, "Consolidação operacional dos restaurantes",
             [ "Restaurante", "Acessos", "Arrecadação bruta" ], linhas, destacar_ultima: true)
    end

    # Converte uma linha da consolidação nas células da tabela.
    #
    # Argumentos:: +linha+ (OperacaoGlobal::Linha): totais de um restaurante.
    # Retorno:: Array de 3 Strings: nome, acessos e arrecadação.
    # Efeitos colaterais:: nenhum.
    def linha_de_restaurante(linha)
      [ linha.restaurante.nome, linha.acessos.to_s, reais(linha.arrecadacao) ]
    end

    # Escreve a tabela do valor liquidado por método de pagamento, com a linha de total (RN09.10).
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a seção ao documento.
    def liquidacao(documento)
      linhas = relatorio.liquidacoes.map { |item| [ item.nome, "#{item.percentual}%", reais(item.valor) ] }
      linhas << [ "Total liquidado", "", reais(relatorio.soma_liquidacoes) ]
      tabela(documento, "Métodos de liquidação", [ "Método", "Participação", "Valor liquidado" ], linhas,
             destacar_ultima: true)
    end

    # Escreve a tabela de acessos e arrecadação por refeição.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a seção ao documento.
    def distribuicao(documento)
      linhas = relatorio.distribuicao_por_refeicao.map { |item| [ item.nome, item.acessos.to_s, reais(item.arrecadacao) ] }
      tabela(documento, "Distribuição por refeição", [ "Refeição", "Acessos", "Arrecadação" ], linhas)
    end

    # Escreve uma seção com título e tabela.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem; +titulo+ (String): nome da
    #              seção; +cabecalho+ (Array de String): nomes das colunas; +linhas+ (Array de Arrays
    #              de String): dados; +destacar_ultima+ (Boolean): última linha em negrito (total).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a seção ao documento.
    def tabela(documento, titulo, cabecalho, linhas, destacar_ultima: false)
      secao(documento, titulo)
      desenhar_tabela(documento, [ cabecalho ] + linhas, colunas_a_direita: COLUNAS_NUMERICAS,
                                                         destacar_ultima: destacar_ultima)
      documento.move_down 14
    end

    # Escreve o rodapé, com o número da exportação quando existe.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o rodapé ao documento.
    def rodape(documento)
      documento.text "Documento somente leitura, gerado a partir dos acessos registrados." \
                     "#{registro_da_exportacao(numero_exportacao)}", **ESTILO_RODAPE
    end
  end
end
