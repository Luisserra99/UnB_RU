require "digest"

# F11 — Exportação do extrato em PDF ou CSV (responsável: Tarsila).
# Registra cada pedido em ExportacaoRelatorio: começa como "processando" e termina como
# "concluida" (com o SHA-256 do arquivo), "sem_dados" ou "falhou". O arquivo não é guardado
# no servidor: é gerado e entregue na mesma requisição.
module Extratos
  class Exportar
    FORMATOS = {
      "pdf" => { tipo_mime: "application/pdf", gerador: ->(relatorio, exportacao, emitido_em) {
        Pdf.new(relatorio, emitido_em: emitido_em, numero_exportacao: exportacao.id).render
      } },
      "csv" => { tipo_mime: "text/csv; charset=utf-8", gerador: ->(relatorio, _exportacao, _emitido_em) {
        PlanilhaCsv.new(relatorio).render
      } }
    }.freeze
    FORMATO_PADRAO = "pdf".freeze

    MSG_SEM_LANCAMENTOS = "Não há lançamentos para os filtros selecionados".freeze
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
      exportacao = ExportacaoRelatorio.create!(usuario: @usuario, tipo: :extrato_estudante, formato: @formato,
                                               filtros: @relatorio.filtros, solicitada_em: @agora)
      return sem_dados(exportacao) if @relatorio.vazio?

      concluir(exportacao)
    rescue StandardError => e
      Rails.logger.error("Falha ao exportar extrato: #{e.class}: #{e.message}")
      exportacao&.update(status: :falhou)
      Resultado.new(exportacao: exportacao, mensagem: MSG_FALHA)
    end

    private

    def sem_dados(exportacao)
      exportacao.update!(status: :sem_dados, quantidade_registros: 0)
      Resultado.new(exportacao: exportacao, mensagem: MSG_SEM_LANCAMENTOS)
    end

    def concluir(exportacao)
      configuracao = FORMATOS.fetch(@formato)
      conteudo = configuracao[:gerador].call(@relatorio, exportacao, @agora)
      nome = nome_arquivo(exportacao)
      exportacao.update!(status: :concluida, emitida_em: Time.current,
                         quantidade_registros: @relatorio.lancamentos.size,
                         total_debitos: @relatorio.total_gasto, total_creditos: @relatorio.total_recarregado,
                         arquivo_chave: "extratos/#{nome}", arquivo_sha256: Digest::SHA256.hexdigest(conteudo))
      Resultado.new(exportacao: exportacao, conteudo: conteudo, nome_arquivo: nome,
                    tipo_mime: configuracao[:tipo_mime])
    end

    def nome_arquivo(exportacao)
      carimbo = @agora.in_time_zone.strftime("%Y%m%d-%H%M%S")
      "extrato-#{@relatorio.estudante.matricula}-#{carimbo}-#{exportacao.id}.#{@formato}"
    end
  end
end
