require "digest"

# F12 — Exportação em PDF dos acessos do Relatório de Operação (responsável: Tarsila).
# Registra cada pedido em ExportacaoRelatorio, com filtros e agrupamento. Em caso de falha,
# nenhum arquivo incompleto é entregue e os acessos não são alterados (RN12.8).
module Relatorios
  class ExportarAcessosOperacao
    MSG_SEM_ACESSOS = "Não há acessos para os filtros selecionados".freeze
    MSG_FALHA = "Não foi possível gerar o PDF. Tente novamente".freeze

    Resultado = Struct.new(:exportacao, :conteudo, :nome_arquivo, :mensagem, keyword_init: true) do
      def sucesso?
        conteudo.present?
      end
    end

    def self.call(...)
      new(...).call
    end

    def initialize(usuario:, relatorio:, agora: Time.current)
      @usuario = usuario
      @relatorio = relatorio
      @agora = agora
    end

    def call
      # Período inválido é erro de preenchimento: nada é gerado nem registrado (RN12.7).
      return Resultado.new(mensagem: @relatorio.erro) unless @relatorio.valido?

      exportacao = ExportacaoRelatorio.create!(usuario: @usuario, tipo: :operacao_global, formato: :pdf,
                                               filtros: @relatorio.filtros, agrupamentos: @relatorio.agrupamentos,
                                               solicitada_em: @agora)
      return sem_dados(exportacao) if @relatorio.vazio?

      concluir(exportacao)
    rescue StandardError => e
      Rails.logger.error("Falha ao exportar acessos do relatório de operação: #{e.class}: #{e.message}")
      exportacao&.update(status: :falhou)
      Resultado.new(exportacao: exportacao, mensagem: MSG_FALHA)
    end

    private

    def sem_dados(exportacao)
      exportacao.update!(status: :sem_dados, quantidade_registros: 0)
      Resultado.new(exportacao: exportacao, mensagem: MSG_SEM_ACESSOS)
    end

    def concluir(exportacao)
      conteudo = AcessosOperacaoPdf.new(@relatorio, emissor: @usuario, emitido_em: @agora,
                                                    numero_exportacao: exportacao.id).render
      nome = "relatorio-operacao-#{@relatorio.inicio.iso8601}-a-#{@relatorio.fim.iso8601}-#{exportacao.id}.pdf"
      exportacao.update!(status: :concluida, emitida_em: Time.current, quantidade_registros: @relatorio.quantidade,
                         total_debitos: @relatorio.total_debitado, total_creditos: 0,
                         arquivo_chave: "relatorios/#{nome}", arquivo_sha256: Digest::SHA256.hexdigest(conteudo))
      Resultado.new(exportacao: exportacao, conteudo: conteudo, nome_arquivo: nome)
    end
  end
end
