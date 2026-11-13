# F07 — RN07.2: todos os acessos registrados na catraca, de qualquer sessão ou operador,
# e nunca os de outras catracas. Mais recentes primeiro, paginado.
module HistoricoCatraca
  class Consulta
    POR_PAGINA = 25

    attr_reader :catraca, :pagina

    def initialize(catraca, pagina: 1)
      @catraca = catraca
      @pagina = [ pagina.to_i, 1 ].max
    end

    def registros
      escopo.includes(:estudante)
            .order(lido_em: :desc, id: :desc)
            .offset((pagina - 1) * POR_PAGINA)
            .limit(POR_PAGINA)
    end

    def total
      @total ||= escopo.count
    end

    def total_paginas
      [ (total.to_f / POR_PAGINA).ceil, 1 ].max
    end

    def passagens
      escopo.realizado.count
    end

    def total_debitado
      escopo.realizado.sum(:valor_previsto).to_d
    end

    def vazio?
      total.zero?
    end

    private

    def escopo
      RegistroAcesso.joins(:configuracao_ponto_acesso)
                    .where(configuracao_ponto_acessos: { catraca_id: catraca.id })
    end
  end
end
