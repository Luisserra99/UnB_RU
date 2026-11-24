module Extratos
  # F11 — Documento PDF do extrato (responsável: Tarsila).
  # Recebe um Extratos::Relatorio já filtrado e devolve os bytes do PDF. Não consulta o banco
  # além do que o relatório consulta.
  class Pdf
    include Formatacao
    include ComposicaoPdf

    # Título do documento.
    TITULO = "Extrato e Histórico de Refeições".freeze
    # Nomes das colunas da tabela de lançamentos.
    CABECALHO_TABELA = [ "Data e hora", "Evento", "Local", "Catraca", "Valor" ].freeze
    # Texto do rodapé. O documento não declara assinatura digital, que não é feita.
    INDICACAO_AUDITORIA = "Registros auditáveis".freeze
    # Índice da coluna de valor, alinhada à direita.
    COLUNA_VALOR = 4

    # Prepara o gerador do PDF.
    #
    # Argumentos:: +relatorio+ (Relatorio): extrato já filtrado;
    #              +emitido_em+ (Time): data e hora da emissão;
    #              +numero_exportacao+ (Integer ou nil): id do ExportacaoRelatorio, escrito no rodapé.
    # Retorno:: o novo Pdf.
    # Efeitos colaterais:: nenhum.
    def initialize(relatorio, emitido_em:, numero_exportacao: nil)
      @relatorio = relatorio
      @emitido_em = emitido_em
      @numero_exportacao = numero_exportacao
    end

    # Gera o PDF com cabeçalho, resumo, tabela de lançamentos e rodapé.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com os bytes do PDF.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def render
      documento = novo_documento(TITULO, margin: 40)
      cabecalho(documento)
      resumo(documento)
      tabela(documento)
      rodape(documento)
      documento.render
    end

    private

    # Extrato que alimenta o documento (Relatorio).
    attr_reader :relatorio
    # Data e hora da emissão (Time).
    attr_reader :emitido_em
    # Id do ExportacaoRelatorio (Integer), ou nil.
    attr_reader :numero_exportacao

    # Escreve o cabeçalho: título, estudante, filtros e data de emissão.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o cabeçalho ao documento.
    def cabecalho(documento)
      escrever_linhas(documento, [ [ SISTEMA, ESTILO_SECUNDARIO ], [ TITULO, ESTILO_TITULO ] ])
      documento.move_down 8
      escrever_linhas(documento, linhas_do_estudante + linhas_de_filtros)
      documento.move_down 14
    end

    # Lista as linhas que identificam o estudante.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: nenhum.
    def linhas_do_estudante
      estudante = relatorio.estudante
      [ "Estudante: #{estudante.nome}", "Matrícula: #{estudante.matricula}" ]
    end

    # Lista as linhas com os filtros aplicados e a data de emissão.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: nenhum.
    def linhas_de_filtros
      [ "Período de referência: #{relatorio.periodo_nome}", "Tipo de refeição: #{relatorio.tipo_nome}",
        "Catraca: #{relatorio.catraca_nome}", "Data de emissão: #{data_hora(emitido_em)}" ]
    end

    # Escreve a seção de resumo, com o saldo e os totais do filtro.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a seção ao documento; consulta o banco por meio do relatório.
    def resumo(documento)
      secao(documento, "Resumo")
      escrever_linhas(documento, linhas_de_valores + linhas_de_quantidades)
      documento.move_down 14
    end

    # Lista as três primeiras linhas do resumo: saldo, gasto e refeições realizadas.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: consulta o banco por meio do relatório.
    def linhas_de_valores
      [ "Saldo atual: #{reais(relatorio.saldo_atual)}", "Total gasto: #{reais(relatorio.total_gasto)}",
        "Refeições realizadas: #{relatorio.refeicoes_realizadas}" ]
    end

    # Lista as duas últimas linhas do resumo: total recarregado e quantidade de lançamentos.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Strings.
    # Efeitos colaterais:: consulta o banco por meio do relatório, se ele ainda não foi consultado.
    def linhas_de_quantidades
      [ "Total recarregado: #{reais(relatorio.total_recarregado)}", "Lançamentos: #{relatorio.lancamentos.size}" ]
    end

    # Desenha a tabela de lançamentos.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta a tabela ao documento.
    def tabela(documento)
      linhas = relatorio.lancamentos.map { |lancamento| linha_da_tabela(lancamento) }
      desenhar_tabela(documento, [ CABECALHO_TABELA ] + linhas, colunas_a_direita: COLUNA_VALOR)
    end

    # Converte um lançamento nas células de uma linha da tabela.
    #
    # Argumentos:: +lancamento+ (Relatorio::Lancamento): lançamento a exibir.
    # Retorno:: Array de 5 Strings, na ordem de CABECALHO_TABELA.
    # Efeitos colaterais:: nenhum.
    def linha_da_tabela(lancamento)
      [ data_hora(lancamento.momento), lancamento.descricao, lancamento.local.to_s,
        lancamento.catraca.to_s, valor_com_sinal(lancamento.valor) ]
    end

    # Escreve o rodapé, com o número da exportação quando existe.
    #
    # Argumentos:: +documento+ (Prawn::Document): documento em montagem.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: acrescenta o rodapé ao documento.
    def rodape(documento)
      documento.move_down 14
      documento.text "#{INDICACAO_AUDITORIA}.#{registro_da_exportacao(numero_exportacao)}", **ESTILO_RODAPE
    end
  end
end
