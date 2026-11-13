# F11 — Exportação do Extrato e Histórico de Refeições (responsável: Tarsila).
# Monta os lançamentos do estudante conforme os filtros da tela (tipo de refeição, catraca e
# período) e calcula os totais. A tela, o PDF e o CSV usam este mesmo objeto, por isso mostram
# sempre os mesmos dados. O estudante vem da sessão, nunca de um parâmetro (RN03.1).
module Extratos
  class Relatorio
    TIPO_TODOS = "todas".freeze
    TIPO_RECARGA = "recarga".freeze
    TIPOS = {
      TIPO_TODOS => "Todas as Refeições",
      TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã",
      TipoRefeicao::ALMOCO => "Almoço",
      TipoRefeicao::JANTAR => "Jantar",
      TIPO_RECARGA => "Recarga de Saldo"
    }.freeze

    PERIODO_PADRAO = "30_dias".freeze
    # Quantos dias antes de hoje o período começa.
    PERIODOS = {
      "hoje" => [ "Hoje", 0 ],
      "7_dias" => [ "Últimos 7 dias", 7 ],
      PERIODO_PADRAO => [ "Últimos 30 dias", 30 ]
    }.freeze

    POR_PAGINA = 10 # lançamentos por página na tela; a exportação sempre traz todos

    EVENTO_RECARGA = "Recarga de Saldo".freeze
    EVENTO_REFEICAO = "Refeição".freeze

    # `metodo`: forma de pagamento da recarga (PIX, Cartão de Crédito); nil nas refeições.
    Lancamento = Struct.new(:momento, :evento, :local, :catraca, :valor, :tipo, :catraca_id, :metodo,
                            keyword_init: true) do
      def credito?
        valor.positive?
      end

      # Evento com o método de pagamento, para os arquivos exportados: "Recarga de Saldo (PIX)".
      def descricao
        metodo ? "#{evento} (#{metodo})" : evento
      end
    end

    attr_reader :estudante, :tipo, :periodo, :catraca_id, :agora, :pagina

    # Valores fora das listas permitidas voltam ao padrão: o parâmetro vem do navegador.
    def initialize(estudante, filtros = {}, agora: Time.current)
      filtros = filtros.to_h.with_indifferent_access
      @estudante = estudante
      @agora = agora
      @tipo = TIPOS.key?(filtros[:tipo]) ? filtros[:tipo] : TIPO_TODOS
      @periodo = PERIODOS.key?(filtros[:periodo]) ? filtros[:periodo] : PERIODO_PADRAO
      @catraca_id = catracas.map(&:id).find { |id| id.to_s == filtros[:catraca_id].to_s }
      @pagina = [ filtros[:pagina].to_i, 1 ].max
    end

    def lancamentos
      @lancamentos ||= todos_lancamentos.select { |lancamento| corresponde?(lancamento) }
    end

    def vazio?
      lancamentos.empty?
    end

    # O estudante tem algum lançamento, com qualquer filtro? Decide se a exportação fica disponível.
    def possui_lancamentos?
      estudante.movimentacoes_saldo.exists?
    end

    def total_gasto
      lancamentos.reject(&:credito?).sum(BigDecimal("0")) { |lancamento| lancamento.valor.abs }
    end

    def total_recarregado
      lancamentos.select(&:credito?).sum(BigDecimal("0"), &:valor)
    end

    def refeicoes_realizadas
      lancamentos.count { |lancamento| !lancamento.credito? }
    end

    def quantidade_recargas
      lancamentos.count(&:credito?)
    end

    # Refeições do filtro contadas por tipo, na ordem do dia: { "Café da Manhã" => 1, "Almoço" => 2 }.
    def refeicoes_por_tipo
      contagem = lancamentos.reject(&:credito?).map(&:evento).tally
      (TIPOS.values + [ EVENTO_REFEICAO ]).filter_map { |nome| [ nome, contagem[nome] ] if contagem[nome] }.to_h
    end

    # --- Paginação da tela ---

    def total_paginas
      [ (lancamentos.size.to_f / POR_PAGINA).ceil, 1 ].max
    end

    def pagina_atual
      [ pagina, total_paginas ].min
    end

    def lancamentos_da_pagina
      lancamentos.slice((pagina_atual - 1) * POR_PAGINA, POR_PAGINA) || []
    end

    # Posição do primeiro e do último lançamento da página atual, para "Exibindo 1–10 de 24".
    def intervalo_da_pagina
      primeiro = (pagina_atual - 1) * POR_PAGINA + 1
      [ primeiro, primeiro + lancamentos_da_pagina.size - 1 ]
    end

    # Números de página a exibir: a primeira, a última e as vizinhas da atual. `nil` marca um salto.
    def paginas_visiveis
      numeros = ([ 1, total_paginas ] + ((pagina_atual - 1)..(pagina_atual + 1)).to_a).uniq.sort
                .select { |numero| numero.between?(1, total_paginas) }
      numeros.each_with_object([]) do |numero, lista|
        lista << nil if lista.last && numero - lista.last > 1
        lista << numero
      end
    end

    def filtrado?
      tipo != TIPO_TODOS || periodo != PERIODO_PADRAO || catraca_id.present?
    end

    def saldo_atual
      estudante.saldo
    end

    def tipo_nome
      TIPOS.fetch(tipo)
    end

    def periodo_nome
      PERIODOS.fetch(periodo).first
    end

    def catraca_nome
      catraca = catracas.find { |item| item.id == catraca_id }
      catraca ? nome_catraca(catraca) : rotulo_todas_catracas
    end

    def inicio_periodo
      (agora.in_time_zone - PERIODOS.fetch(periodo).last.days).beginning_of_day
    end

    def opcoes_tipo
      TIPOS.map { |codigo, nome| [ nome, codigo ] }
    end

    def opcoes_periodo
      PERIODOS.map { |codigo, (nome, _dias)| [ nome, codigo ] }
    end

    def opcoes_catraca
      [ [ rotulo_todas_catracas, "" ] ] + catracas.map { |catraca| [ nome_catraca(catraca), catraca.id ] }
    end

    # Filtros na forma em que são reenviados pelo formulário e gravados em ExportacaoRelatorio.
    def filtros
      { "tipo" => tipo, "periodo" => periodo, "catraca_id" => catraca_id }
    end

    private

    def catracas
      @catracas ||= Catraca.disponiveis.includes(piso: :restaurante).to_a
                           .sort_by { |catraca| [ catraca.piso.restaurante.nome, catraca.identificacao ] }
    end

    def rotulo_todas_catracas
      catracas.size > 1 ? "Todas as #{catracas.size} Catracas" : "Todas as Catracas"
    end

    def nome_catraca(catraca)
      "#{catraca.identificacao} · #{catraca.piso.restaurante.nome}"
    end

    def corresponde?(lancamento)
      return false if lancamento.momento < inicio_periodo || lancamento.momento > agora
      return false if tipo != TIPO_TODOS && lancamento.tipo != tipo

      catraca_id.nil? || lancamento.catraca_id == catraca_id
    end

    def todos_lancamentos
      movimentacoes.map { |mov| mov.credito_recarga? ? lancamento_de_recarga(mov) : lancamento_de_refeicao(mov) }
    end

    def movimentacoes
      estudante.movimentacoes_saldo.recentes.includes(
        recarga: :pagamentos,
        registro_acesso: [ { servico_refeicao: :tipo_refeicao },
                          { configuracao_ponto_acesso: [ :restaurante, { catraca: :piso } ] } ]
      )
    end

    def lancamento_de_recarga(mov)
      metodo = mov.recarga&.pagamentos&.find(&:confirmado?)&.nome_metodo
      Lancamento.new(momento: mov.ocorrida_em.in_time_zone, evento: EVENTO_RECARGA,
                     local: nil, catraca: nil, metodo: metodo,
                     valor: mov.valor, tipo: TIPO_RECARGA, catraca_id: nil)
    end

    def lancamento_de_refeicao(mov)
      ponto = mov.registro_acesso&.configuracao_ponto_acesso
      catraca = ponto&.catraca
      codigo = mov.tipo_refeicao&.codigo
      Lancamento.new(momento: mov.ocorrida_em.in_time_zone, evento: TIPOS.fetch(codigo, EVENTO_REFEICAO),
                     local: [ ponto&.restaurante&.nome, catraca&.piso&.nome ].compact.join(" - ").presence,
                     catraca: catraca&.identificacao, valor: mov.valor, tipo: codigo, catraca_id: catraca&.id)
    end
  end
end
