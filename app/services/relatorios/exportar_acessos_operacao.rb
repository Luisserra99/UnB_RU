require "digest"

module Relatorios
  # F12 — Exportação em PDF dos acessos do Relatório de Operação (responsável: Tarsila).
  # Registra cada pedido em ExportacaoRelatorio, com filtros e agrupamento. Em caso de falha,
  # nenhum arquivo incompleto é entregue e os acessos não são alterados (RN12.8).
  class ExportarAcessosOperacao
    # Mensagem do filtro sem acessos, que não gera arquivo.
    MSG_SEM_ACESSOS = "Não há acessos para os filtros selecionados".freeze
    # Mensagem de falha na geração do PDF.
    MSG_FALHA = "Não foi possível gerar o PDF. Tente novamente".freeze

    # Resultado da exportação: +exportacao+ (ExportacaoRelatorio), +conteudo+ (bytes do PDF),
    # +nome_arquivo+ e +mensagem+ (motivo, quando não há arquivo).
    Resultado = Struct.new(:exportacao, :conteudo, :nome_arquivo, :mensagem, keyword_init: true) do
      # Diz se a exportação gerou um arquivo.
      #
      # Argumentos:: nenhum.
      # Retorno:: true quando há conteúdo para baixar; false caso contrário.
      # Efeitos colaterais:: nenhum.
      def sucesso?
        conteudo.present?
      end
    end

    # Cria o serviço e executa a exportação.
    #
    # Argumentos:: os mesmos de +new+.
    # Retorno:: Resultado, como em #call.
    # Efeitos colaterais:: os mesmos de #call.
    def self.call(...)
      new(...).call
    end

    # Prepara a exportação.
    #
    # Argumentos:: +usuario+ (Usuario): administrador que pediu o arquivo;
    #              +relatorio+ (AcessosOperacao): relatório já filtrado;
    #              +agora+ (Time): momento do pedido.
    # Retorno:: o novo ExportarAcessosOperacao.
    # Efeitos colaterais:: nenhum.
    def initialize(usuario:, relatorio:, agora: Time.current)
      @usuario = usuario
      @relatorio = relatorio
      @agora = agora
    end

    # Registra o pedido e gera o PDF. Período inválido é erro de preenchimento: nada é gerado nem
    # registrado (RN12.7).
    #
    # Argumentos:: nenhum.
    # Retorno:: Resultado com o PDF quando há acessos; Resultado só com a mensagem do relatório
    #           quando o período é inválido; Resultado só com MSG_SEM_ACESSOS quando o filtro não
    #           encontra acessos; Resultado só com MSG_FALHA quando a geração falha.
    # Efeitos colaterais:: com período válido, grava um ExportacaoRelatorio e o atualiza para
    #                      "concluida", "sem_dados" ou "falhou"; em caso de falha, registra o erro
    #                      no log. Não altera os acessos nem lança exceção (RN12.8).
    def call
      return Resultado.new(mensagem: @relatorio.erro) unless @relatorio.valido?

      exportacao = registrar_pedido
      @relatorio.vazio? ? sem_dados(exportacao) : concluir(exportacao)
    rescue StandardError => e
      falhar(exportacao, e)
    end

    private

    # Grava o pedido de exportação, ainda em processamento, com os filtros e o agrupamento.
    #
    # Argumentos:: nenhum.
    # Retorno:: ExportacaoRelatorio com status "processando".
    # Efeitos colaterais:: grava um ExportacaoRelatorio; lança ActiveRecord::RecordInvalid se inválido.
    def registrar_pedido
      ExportacaoRelatorio.create!(usuario: @usuario, tipo: :operacao_global, formato: :pdf,
                                  filtros: @relatorio.filtros, agrupamentos: @relatorio.agrupamentos,
                                  solicitada_em: @agora)
    end

    # Encerra a exportação de um filtro sem acessos.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: Resultado sem arquivo, com MSG_SEM_ACESSOS.
    # Efeitos colaterais:: atualiza a exportação para "sem_dados".
    def sem_dados(exportacao)
      exportacao.update!(status: :sem_dados, quantidade_registros: 0)
      Resultado.new(exportacao: exportacao, mensagem: MSG_SEM_ACESSOS)
    end

    # Gera o PDF e registra a conclusão, com os totais e o SHA-256 do conteúdo.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: Resultado com o conteúdo e o nome do arquivo.
    # Efeitos colaterais:: atualiza a exportação para "concluida".
    def concluir(exportacao)
      conteudo = AcessosOperacaoPdf.new(@relatorio, emissor: @usuario, emitido_em: @agora,
                                                    numero_exportacao: exportacao.id).render
      nome = "relatorio-operacao-#{@relatorio.inicio.iso8601}-a-#{@relatorio.fim.iso8601}-#{exportacao.id}.pdf"
      exportacao.update!(dados_da_conclusao(nome, conteudo))
      Resultado.new(exportacao: exportacao, conteudo: conteudo, nome_arquivo: nome)
    end

    # Reúne os atributos gravados quando a exportação termina com sucesso.
    #
    # Argumentos:: +nome+ (String): nome do arquivo; +conteudo+ (String): bytes do PDF.
    # Retorno:: Hash de atributos de ExportacaoRelatorio.
    # Efeitos colaterais:: nenhum.
    def dados_da_conclusao(nome, conteudo)
      { status: :concluida, emitida_em: Time.current, quantidade_registros: @relatorio.quantidade,
        total_debitos: @relatorio.total_debitado, total_creditos: 0,
        arquivo_chave: "relatorios/#{nome}", arquivo_sha256: Digest::SHA256.hexdigest(conteudo) }
    end

    # Registra a falha da exportação, sem entregar arquivo.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio ou nil): pedido registrado, se chegou a ser gravado;
    #              +erro+ (StandardError): exceção ocorrida.
    # Retorno:: Resultado sem arquivo, com MSG_FALHA.
    # Efeitos colaterais:: escreve o erro no log e atualiza a exportação para "falhou".
    def falhar(exportacao, erro)
      Rails.logger.error("Falha ao exportar acessos do relatório de operação: #{erro.class}: #{erro.message}")
      exportacao&.update(status: :falhou)
      Resultado.new(exportacao: exportacao, mensagem: MSG_FALHA)
    end
  end
end
