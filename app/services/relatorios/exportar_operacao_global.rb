require "digest"

module Relatorios
  # F09 — Exportação do Relatório Global de Operação em CSV ou PDF (responsável: Tarsila).
  # Segue o mesmo ciclo da exportação do extrato (F11): registra o pedido em ExportacaoRelatorio
  # como "processando" e termina como "concluida", "sem_dados" ou "falhou".
  class ExportarOperacaoGlobal
    # Formatos aceitos e o tipo MIME de cada um.
    FORMATOS = { "pdf" => "application/pdf", "csv" => "text/csv; charset=utf-8" }.freeze
    # Formato usado quando o pedido não informa um formato aceito.
    FORMATO_PADRAO = "pdf".freeze
    # Mensagem do relatório sem acessos, que não gera arquivo.
    MSG_SEM_ACESSOS = "Nenhum acesso encontrado".freeze
    # Mensagem de falha na geração do arquivo.
    MSG_FALHA = "Não foi possível gerar o arquivo. Tente novamente".freeze

    # Resultado da exportação: +exportacao+ (ExportacaoRelatorio), +conteudo+ (bytes do arquivo),
    # +nome_arquivo+, +tipo_mime+ e +mensagem+ (motivo, quando não há arquivo).
    Resultado = Struct.new(:exportacao, :conteudo, :nome_arquivo, :tipo_mime, :mensagem, keyword_init: true) do
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
    #              +relatorio+ (OperacaoGlobal): relatório já filtrado;
    #              +formato+ (String): "pdf" ou "csv" (outro valor vira FORMATO_PADRAO);
    #              +agora+ (Time): momento do pedido.
    # Retorno:: o novo ExportarOperacaoGlobal.
    # Efeitos colaterais:: nenhum.
    def initialize(usuario:, relatorio:, formato:, agora: Time.current)
      @usuario = usuario
      @relatorio = relatorio
      @formato = FORMATOS.key?(formato.to_s) ? formato.to_s : FORMATO_PADRAO
      @agora = agora
    end

    # Registra o pedido e gera o arquivo.
    #
    # Argumentos:: nenhum.
    # Retorno:: Resultado com o arquivo quando há acessos; Resultado só com MSG_SEM_ACESSOS quando
    #           o relatório está vazio; Resultado só com MSG_FALHA quando a geração falha.
    # Efeitos colaterais:: grava um ExportacaoRelatorio e o atualiza para "concluida", "sem_dados"
    #                      ou "falhou"; em caso de falha, registra o erro no log. Não lança exceção.
    def call
      exportacao = registrar_pedido
      @relatorio.vazio? ? sem_dados(exportacao) : concluir(exportacao)
    rescue StandardError => e
      falhar(exportacao, e)
    end

    private

    # Grava o pedido de exportação, ainda em processamento.
    #
    # Argumentos:: nenhum.
    # Retorno:: ExportacaoRelatorio com status "processando".
    # Efeitos colaterais:: grava um ExportacaoRelatorio; lança ActiveRecord::RecordInvalid se inválido.
    def registrar_pedido
      ExportacaoRelatorio.create!(usuario: @usuario, tipo: :operacao_global, formato: @formato,
                                  filtros: @relatorio.filtros, solicitada_em: @agora)
    end

    # Encerra a exportação de um relatório sem acessos.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: Resultado sem arquivo, com MSG_SEM_ACESSOS.
    # Efeitos colaterais:: atualiza a exportação para "sem_dados".
    def sem_dados(exportacao)
      exportacao.update!(status: :sem_dados, quantidade_registros: 0)
      Resultado.new(exportacao: exportacao, mensagem: MSG_SEM_ACESSOS)
    end

    # Gera o arquivo e registra a conclusão, com os totais e o SHA-256 do conteúdo.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: Resultado com o conteúdo, o nome do arquivo e o tipo MIME.
    # Efeitos colaterais:: atualiza a exportação para "concluida".
    def concluir(exportacao)
      conteudo = gerar(exportacao)
      nome = "relatorio-global-#{@relatorio.data.iso8601}-#{exportacao.id}.#{@formato}"
      exportacao.update!(dados_da_conclusao(nome, conteudo))
      Resultado.new(exportacao: exportacao, conteudo: conteudo, nome_arquivo: nome, tipo_mime: FORMATOS.fetch(@formato))
    end

    # Reúne os atributos gravados quando a exportação termina com sucesso.
    #
    # Argumentos:: +nome+ (String): nome do arquivo; +conteudo+ (String): bytes do arquivo.
    # Retorno:: Hash de atributos de ExportacaoRelatorio.
    # Efeitos colaterais:: nenhum.
    def dados_da_conclusao(nome, conteudo)
      { status: :concluida, emitida_em: Time.current, quantidade_registros: @relatorio.total_acessos,
        total_debitos: @relatorio.arrecadacao_global, total_creditos: 0,
        arquivo_chave: "relatorios/#{nome}", arquivo_sha256: Digest::SHA256.hexdigest(conteudo) }
    end

    # Registra a falha da exportação, sem entregar arquivo.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio ou nil): pedido registrado, se chegou a ser gravado;
    #              +erro+ (StandardError): exceção ocorrida.
    # Retorno:: Resultado sem arquivo, com MSG_FALHA.
    # Efeitos colaterais:: escreve o erro no log e atualiza a exportação para "falhou".
    def falhar(exportacao, erro)
      Rails.logger.error("Falha ao exportar relatório global: #{erro.class}: #{erro.message}")
      exportacao&.update(status: :falhou)
      Resultado.new(exportacao: exportacao, mensagem: MSG_FALHA)
    end

    # Gera o conteúdo do arquivo no formato pedido.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado, cujo id vai no PDF.
    # Retorno:: String com o conteúdo do CSV ou os bytes do PDF.
    # Efeitos colaterais:: nenhum além das consultas do relatório.
    def gerar(exportacao)
      return OperacaoGlobalCsv.new(@relatorio).render if @formato == "csv"

      OperacaoGlobalPdf.new(@relatorio, emissor: @usuario, emitido_em: @agora, numero_exportacao: exportacao.id).render
    end
  end
end
