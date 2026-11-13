require "digest"

# F09 — Exportação do Relatório Global de Operação em CSV ou PDF (responsável: Tarsila).
# Segue o mesmo ciclo da exportação do extrato (F11): registra o pedido em ExportacaoRelatorio
# como "processando" e termina como "concluida", "sem_dados" ou "falhou".
module Relatorios
  class ExportarOperacaoGlobal
    FORMATOS = { "pdf" => "application/pdf", "csv" => "text/csv; charset=utf-8" }.freeze
    FORMATO_PADRAO = "pdf".freeze
    MSG_SEM_ACESSOS = "Nenhum acesso encontrado".freeze
    MSG_FALHA = "Não foi possível gerar o arquivo. Tente novamente".freeze

    Resultado = Struct.new(:exportacao, :conteudo, :nome_arquivo, :tipo_mime, :mensagem, keyword_init: true) do
      def sucesso?
        conteudo.present?
      end
    end

    def self.call(...)
      new(...).call
    end

    def initialize(usuario:, relatorio:, formato:, agora: Time.current)
      @usuario = usuario
      @relatorio = relatorio
      @formato = FORMATOS.key?(formato.to_s) ? formato.to_s : FORMATO_PADRAO
      @agora = agora
    end

    def call
      exportacao = ExportacaoRelatorio.create!(usuario: @usuario, tipo: :operacao_global, formato: @formato,
                                               filtros: @relatorio.filtros, solicitada_em: @agora)
      return sem_dados(exportacao) if @relatorio.vazio?

      concluir(exportacao)
    rescue StandardError => e
      Rails.logger.error("Falha ao exportar relatório global: #{e.class}: #{e.message}")
      exportacao&.update(status: :falhou)
      Resultado.new(exportacao: exportacao, mensagem: MSG_FALHA)
    end

    private

    def sem_dados(exportacao)
      exportacao.update!(status: :sem_dados, quantidade_registros: 0)
      Resultado.new(exportacao: exportacao, mensagem: MSG_SEM_ACESSOS)
    end

    def concluir(exportacao)
      conteudo = gerar(exportacao)
      nome = "relatorio-global-#{@relatorio.data.iso8601}-#{exportacao.id}.#{@formato}"
      exportacao.update!(status: :concluida, emitida_em: Time.current,
                         quantidade_registros: @relatorio.total_acessos,
                         total_debitos: @relatorio.arrecadacao_global, total_creditos: 0,
                         arquivo_chave: "relatorios/#{nome}", arquivo_sha256: Digest::SHA256.hexdigest(conteudo))
      Resultado.new(exportacao: exportacao, conteudo: conteudo, nome_arquivo: nome, tipo_mime: FORMATOS.fetch(@formato))
    end

    def gerar(exportacao)
      return OperacaoGlobalCsv.new(@relatorio).render if @formato == "csv"

      OperacaoGlobalPdf.new(@relatorio, emissor: @usuario, emitido_em: @agora, numero_exportacao: exportacao.id).render
    end
  end
end
