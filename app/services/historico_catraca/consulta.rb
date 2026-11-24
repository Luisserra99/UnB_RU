# F07 — RN07.2: todos os acessos registrados na catraca, de qualquer sessão ou operador,
# e nunca os de outras catracas. Mais recentes primeiro, paginado.
module HistoricoCatraca
  # Consulta paginada dos registros de acesso de uma catraca, com os totais da tela do histórico.
  class Consulta
    # Quantidade de registros por página.
    POR_PAGINA = 25

    # Catraca consultada.
    attr_reader :catraca
    # Página pedida (1 ou mais).
    attr_reader :pagina

    # Prepara a consulta de uma catraca.
    #
    # Argumentos:: +catraca+ (Catraca): catraca do ponto de acesso atual; +pagina+ (Integer, String
    #              ou nil, opcional): página pedida; valores inválidos ou menores que 1 viram 1.
    # Retorno:: nova Consulta.
    # Efeitos colaterais:: nenhum.
    def initialize(catraca, pagina: 1)
      @catraca = catraca
      @pagina = [ pagina.to_i, 1 ].max
    end

    # Registros da página atual, dos mais recentes aos mais antigos, com o estudante carregado.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso com até POR_PAGINA itens; vazia se a página
    #           passa do fim.
    # Efeitos colaterais:: consulta o banco quando a relação é percorrida.
    def registros
      escopo.includes(:estudante)
            .order(lido_em: :desc, id: :desc)
            .offset((pagina - 1) * POR_PAGINA)
            .limit(POR_PAGINA)
    end

    # Quantidade de registros da catraca, em todas as páginas.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer (zero ou mais).
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def total
      @total ||= escopo.count
    end

    # Quantidade de páginas da listagem.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer, no mínimo 1 (mesmo sem registros).
    # Efeitos colaterais:: os de #total.
    def total_paginas
      [ (total.to_f / POR_PAGINA).ceil, 1 ].max
    end

    # Quantidade de passagens efetivas (acessos realizados) na catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer (zero ou mais).
    # Efeitos colaterais:: consulta o banco.
    def passagens
      escopo.realizado.count
    end

    # Soma dos valores debitados nas passagens efetivas da catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal; zero sem passagens.
    # Efeitos colaterais:: consulta o banco.
    def total_debitado
      escopo.realizado.sum(:valor_previsto).to_d
    end

    # Indica se a catraca não tem nenhum registro (RN07.3).
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: os de #total.
    def vazio?
      total.zero?
    end

    private

    # Registros de acesso feitos em qualquer configuração de ponto de acesso desta catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso, sem ordem nem paginação.
    # Efeitos colaterais:: nenhum (a consulta só roda quando a relação é usada).
    def escopo
      RegistroAcesso.joins(:configuracao_ponto_acesso)
                    .where(configuracao_ponto_acessos: { catraca_id: catraca.id })
    end
  end
end
