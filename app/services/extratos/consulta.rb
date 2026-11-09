# F03 — Extrato e Histórico de Refeições (responsável: Luis).
# Reúne o que o estudante vê no extrato: saldo atual, últimas recargas confirmadas, todas as
# movimentações e o histórico de refeições (débitos). Sempre a partir de um único estudante (RN03.1).
module Extratos
  class Consulta
    LIMITE_RECARGAS = 10
    REFEICAO_SEM_TIPO = "Refeição".freeze

    Refeicao = Struct.new(:data, :horario, :tipo, :valor, keyword_init: true)

    attr_reader :estudante

    def initialize(estudante)
      @estudante = estudante
    end

    def saldo
      estudante.saldo
    end

    # RN03.3: últimas recargas com crédito efetivado (pagamento confirmado).
    def ultimas_recargas
      @ultimas_recargas ||= estudante.recargas.confirmada.includes(:itens, :pagamentos)
                                     .order(confirmada_em: :desc, id: :desc).limit(LIMITE_RECARGAS).to_a
    end

    def movimentacoes
      @movimentacoes ||= estudante.movimentacoes_saldo.recentes.includes(recarga: :pagamentos).to_a
    end

    # RN03.2: data, horário e tipo de cada refeição. O tipo vem de MovimentacaoSaldo#tipo_refeicao,
    # que passa a ser preenchido quando a F06 (RegistroAcesso) existir.
    def refeicoes
      @refeicoes ||= movimentacoes.select(&:debito_refeicao?).map do |mov|
        momento = mov.ocorrida_em.in_time_zone
        Refeicao.new(data: momento.to_date, horario: momento.strftime("%H:%M"),
                     tipo: mov.tipo_refeicao&.nome || REFEICAO_SEM_TIPO, valor: mov.valor.abs)
      end
    end

    # RN03.4
    def vazio?
      movimentacoes.empty?
    end
  end
end
