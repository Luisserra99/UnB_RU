# Extrato do estudante: consulta (F03) e relatório e exportação (F11).
module Extratos
  # F03 — Extrato e Histórico de Refeições (responsável: Luis).
  # Reúne o que o estudante vê no extrato: saldo atual, últimas recargas confirmadas, todas as
  # movimentações e o histórico de refeições (débitos). Sempre a partir de um único estudante (RN03.1).
  class Consulta
    # Quantas recargas confirmadas o extrato mostra (RN03.3).
    LIMITE_RECARGAS = 10
    # Nome exibido para refeição sem tipo conhecido.
    REFEICAO_SEM_TIPO = "Refeição".freeze

    # Linha do histórico de refeições: +data+ (Date), +horario+ ("HH:MM"), +tipo+ (String) e
    # +valor+ (BigDecimal positivo).
    Refeicao = Struct.new(:data, :horario, :tipo, :valor, keyword_init: true)

    # Estudante consultado (Estudante).
    attr_reader :estudante

    # Cria a consulta do extrato.
    #
    # Argumentos:: +estudante+ (Estudante): dono do extrato.
    # Retorno:: a nova Consulta.
    # Efeitos colaterais:: nenhum (as consultas ao banco acontecem nos outros métodos).
    def initialize(estudante)
      @estudante = estudante
    end

    # Saldo atual do estudante.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal (zero sem lançamentos).
    # Efeitos colaterais:: consulta o banco.
    def saldo
      estudante.saldo
    end

    # Últimas recargas com crédito efetivado, isto é, com pagamento confirmado (RN03.3).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de até LIMITE_RECARGAS Recargas, da confirmação mais recente para a mais
    #           antiga; vazio se não houver.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def ultimas_recargas
      @ultimas_recargas ||= estudante.recargas.confirmada.includes(:itens, :pagamentos)
                                     .order(confirmada_em: :desc, id: :desc).limit(LIMITE_RECARGAS).to_a
    end

    # Todas as movimentações do estudante, das mais recentes para as mais antigas.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de MovimentacaoSaldo (vazio sem lançamentos).
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def movimentacoes
      @movimentacoes ||= estudante.movimentacoes_saldo.recentes.includes(recarga: :pagamentos).to_a
    end

    # Histórico de refeições: data, horário e tipo de cada débito (RN03.2).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Refeicao, das mais recentes para as mais antigas; vazio sem refeições.
    # Efeitos colaterais:: os de #movimentacoes; guarda o resultado.
    def refeicoes
      @refeicoes ||= movimentacoes.select(&:debito_refeicao?).map { |movimentacao| refeicao_de(movimentacao) }
    end

    # Indica se o estudante ainda não tem nenhum lançamento (RN03.4).
    #
    # Argumentos:: nenhum.
    # Retorno:: true sem movimentações; false caso contrário.
    # Efeitos colaterais:: os de #movimentacoes.
    def vazio?
      movimentacoes.empty?
    end

    private

    # Converte um débito numa linha do histórico de refeições. O tipo vem de
    # MovimentacaoSaldo#tipo_refeicao; sem ele, usa REFEICAO_SEM_TIPO.
    #
    # Argumentos:: +movimentacao+ (MovimentacaoSaldo): débito de refeição.
    # Retorno:: Refeicao com data e horário no fuso da aplicação e o valor positivo.
    # Efeitos colaterais:: os de MovimentacaoSaldo#tipo_refeicao.
    def refeicao_de(movimentacao)
      momento = movimentacao.ocorrida_em.in_time_zone
      Refeicao.new(data: momento.to_date, horario: momento.strftime("%H:%M"),
                   tipo: movimentacao.tipo_refeicao&.nome || REFEICAO_SEM_TIPO, valor: movimentacao.valor.abs)
    end
  end
end
