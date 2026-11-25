require "digest"

module Extratos
  # F11 — Exportação do extrato em PDF ou CSV (responsável: Tarsila).
  # Registra cada pedido em ExportacaoRelatorio: começa como "processando" e termina como
  # "concluida" (com o SHA-256 do arquivo), "sem_dados" ou "falhou". O arquivo não é guardado
  # no servidor: é gerado e entregue na mesma requisição.
  class Exportar
    # Formatos aceitos: o tipo MIME e o gerador do conteúdo de cada um.
    FORMATOS = {
      "pdf" => { tipo_mime: "application/pdf", gerador: ->(relatorio, exportacao, emitido_em) {
        Pdf.new(relatorio, emitido_em: emitido_em, numero_exportacao: exportacao.id).render
      } },
      "csv" => { tipo_mime: "text/csv; charset=utf-8", gerador: ->(relatorio, _exportacao, _emitido_em) {
        PlanilhaCsv.new(relatorio).render
      } }
    }.freeze
    # Formato usado quando o pedido não informa um formato aceito.
    FORMATO_PADRAO = "pdf".freeze

    # Mensagem do filtro sem lançamentos, que não gera arquivo.
    MSG_SEM_LANCAMENTOS = "Não há lançamentos para os filtros selecionados".freeze
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
    # Argumentos:: +usuario+ (Usuario): usuário do estudante que pediu o arquivo;
    #              +relatorio+ (Relatorio): extrato já filtrado;
    #              +formato+ (String): "pdf" ou "csv" (outro valor vira FORMATO_PADRAO);
    #              +agora+ (Time): momento do pedido.
    # Retorno:: o novo Exportar.
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
    # Retorno:: Resultado com o arquivo quando há lançamentos; Resultado só com MSG_SEM_LANCAMENTOS
    #           quando o filtro está vazio; Resultado só com MSG_FALHA quando a geração falha.
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
      ExportacaoRelatorio.create!(usuario: @usuario, tipo: :extrato_estudante, formato: @formato,
                                  filtros: @relatorio.filtros, solicitada_em: @agora)
    end

    # Encerra a exportação de um filtro sem lançamentos.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: Resultado sem arquivo, com MSG_SEM_LANCAMENTOS.
    # Efeitos colaterais:: atualiza a exportação para "sem_dados".
    def sem_dados(exportacao)
      exportacao.update!(status: :sem_dados, quantidade_registros: 0)
      Resultado.new(exportacao: exportacao, mensagem: MSG_SEM_LANCAMENTOS)
    end

    # Gera o arquivo e registra a conclusão, com os totais e o SHA-256 do conteúdo.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: Resultado com o conteúdo, o nome do arquivo e o tipo MIME.
    # Efeitos colaterais:: atualiza a exportação para "concluida".
    def concluir(exportacao)
      configuracao = FORMATOS.fetch(@formato)
      conteudo = configuracao[:gerador].call(@relatorio, exportacao, @agora)
      nome = nome_arquivo(exportacao)
      exportacao.update!(dados_da_conclusao(nome, conteudo))
      Resultado.new(exportacao: exportacao, conteudo: conteudo, nome_arquivo: nome,
                    tipo_mime: configuracao[:tipo_mime])
    end

    # Reúne os atributos gravados quando a exportação termina com sucesso.
    #
    # Argumentos:: +nome+ (String): nome do arquivo; +conteudo+ (String): bytes do arquivo.
    # Retorno:: Hash de atributos de ExportacaoRelatorio.
    # Efeitos colaterais:: nenhum.
    def dados_da_conclusao(nome, conteudo)
      { status: :concluida, emitida_em: Time.current, quantidade_registros: @relatorio.lancamentos.size,
        total_debitos: @relatorio.total_gasto, total_creditos: @relatorio.total_recarregado,
        arquivo_chave: "extratos/#{nome}", arquivo_sha256: Digest::SHA256.hexdigest(conteudo) }
    end

    # Registra a falha da exportação, sem entregar arquivo.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio ou nil): pedido registrado, se chegou a ser gravado;
    #              +erro+ (StandardError): exceção ocorrida.
    # Retorno:: Resultado sem arquivo, com MSG_FALHA.
    # Efeitos colaterais:: escreve o erro no log e atualiza a exportação para "falhou".
    def falhar(exportacao, erro)
      Rails.logger.error("Falha ao exportar extrato: #{erro.class}: #{erro.message}")
      exportacao&.update(status: :falhou)
      Resultado.new(exportacao: exportacao, mensagem: MSG_FALHA)
    end

    # Monta o nome do arquivo com a matrícula, o momento do pedido e o número da exportação.
    #
    # Argumentos:: +exportacao+ (ExportacaoRelatorio): pedido registrado.
    # Retorno:: String, como "extrato-190000001-20240514-200000-7.pdf".
    # Efeitos colaterais:: nenhum.
    def nome_arquivo(exportacao)
      carimbo = @agora.in_time_zone.strftime("%Y%m%d-%H%M%S")
      "extrato-#{@relatorio.estudante.matricula}-#{carimbo}-#{exportacao.id}.#{@formato}"
    end
  end
end
