# F12 — Acessos do Relatório de Operação, para auditoria (responsável: Tarsila).
# Lista cada acesso realizado em um período, com filtros de restaurante e catraca, subtotais
# por restaurante e catraca e paginação para a tela. A tela e o PDF usam este mesmo objeto.
module Relatorios
  class AcessosOperacao
    MSG_PERIODO_INVERTIDO = "A data inicial deve ser anterior ou igual à data final".freeze
    FORMATO_DATA = "%d/%m/%Y".freeze
    DIAS_PADRAO = 6 # sem filtro, mostra os últimos 7 dias (hoje e os 6 anteriores)
    POR_PAGINA_PADRAO = 20
    POR_PAGINA_MAXIMO = 100
    REFEICOES = { TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã", TipoRefeicao::ALMOCO => "Almoço",
                  TipoRefeicao::JANTAR => "Jantar" }.freeze
    AGRUPAMENTO = %w[restaurante catraca].freeze

    Acesso = Struct.new(:referencia, :momento, :matricula, :restaurante, :catraca, :refeicao, :valor, keyword_init: true)
    Subtotal = Struct.new(:restaurante, :catraca, :acessos, :quantidade, :total, keyword_init: true)
    Grupo = Struct.new(:restaurante, :catracas, :quantidade, :total, keyword_init: true)

    attr_reader :inicio, :fim, :restaurante, :catraca, :pagina, :por_pagina

    # Valores inválidos voltam ao padrão: os parâmetros vêm do navegador.
    def initialize(filtros = {}, agora: Time.current)
      filtros = filtros.to_h.with_indifferent_access
      hoje = agora.in_time_zone.to_date
      @fim = interpretar_data(filtros[:fim], hoje)
      @inicio = interpretar_data(filtros[:inicio], [ hoje - DIAS_PADRAO, @fim ].min)
      @restaurante = restaurantes.find { |item| item.id.to_s == filtros[:restaurante_id].to_s }
      @catraca = catracas.find { |item| item.id.to_s == filtros[:catraca_id].to_s }
      @agrupado = ActiveModel::Type::Boolean.new.cast(filtros[:agrupar]) || false
      @por_pagina = filtros[:por_pagina].to_i.clamp(1, POR_PAGINA_MAXIMO) if filtros[:por_pagina].present?
      @por_pagina ||= POR_PAGINA_PADRAO
      @pagina = [ filtros[:pagina].to_i, 1 ].max
    end

    # RN12.7: período com data inicial depois da final é rejeitado.
    def erro
      MSG_PERIODO_INVERTIDO if inicio > fim
    end

    def valido?
      erro.nil?
    end

    def agrupado?
      @agrupado
    end

    # Todos os acessos do filtro, em ordem cronológica. Os limites do período são inclusivos (RN12.2).
    def acessos
      @acessos ||= valido? ? consulta.map { |registro| montar_acesso(registro) } : []
    end

    def vazio?
      acessos.empty?
    end

    def quantidade
      acessos.size
    end

    def total_debitado
      acessos.sum(BigDecimal("0"), &:valor)
    end

    # Subtotais por restaurante e, dentro dele, por catraca. Catracas de mesmo nome em restaurantes
    # diferentes nunca se misturam, porque a chave do agrupamento inclui o restaurante (RN12.5).
    def grupos
      @grupos ||= acessos.group_by(&:restaurante).sort.map do |restaurante, do_restaurante|
        catracas = do_restaurante.group_by(&:catraca).sort.map do |catraca, da_catraca|
          Subtotal.new(restaurante: restaurante, catraca: catraca, acessos: da_catraca,
                       quantidade: da_catraca.size, total: da_catraca.sum(BigDecimal("0"), &:valor))
        end
        Grupo.new(restaurante: restaurante, catracas: catracas, quantidade: do_restaurante.size,
                  total: do_restaurante.sum(BigDecimal("0"), &:valor))
      end
    end

    # --- Paginação da tela ---

    def total_paginas
      [ (quantidade.to_f / por_pagina).ceil, 1 ].max
    end

    def pagina_atual
      [ pagina, total_paginas ].min
    end

    def acessos_da_pagina
      acessos.slice((pagina_atual - 1) * por_pagina, por_pagina) || []
    end

    # --- Nomes e opções dos filtros ---

    def periodo_nome
      "#{inicio.strftime(FORMATO_DATA)} a #{fim.strftime(FORMATO_DATA)}"
    end

    def restaurante_nome
      restaurante&.nome || "Todos"
    end

    def catraca_nome
      catraca&.identificacao || "Todas"
    end

    def agrupamento_nome
      agrupado? ? "Restaurante e catraca" : "Sem agrupamento"
    end

    def opcoes_restaurante
      [ [ "Todos", "" ] ] + restaurantes.map { |item| [ item.nome, item.id ] }
    end

    def opcoes_catraca
      [ [ "Todas", "" ] ] + catracas.map { |item| [ "#{item.identificacao} · #{item.piso.restaurante.nome}", item.id ] }
    end

    # Filtros na forma em que são reenviados pelo formulário e gravados em ExportacaoRelatorio.
    def filtros
      { "inicio" => inicio.iso8601, "fim" => fim.iso8601, "restaurante_id" => restaurante&.id,
        "catraca_id" => catraca&.id, "agrupar" => (agrupado? ? "1" : nil) }
    end

    def agrupamentos
      agrupado? ? { "por" => AGRUPAMENTO } : {}
    end

    private

    def restaurantes
      @restaurantes ||= Restaurante.order(:nome).to_a
    end

    def catracas
      @catracas ||= Catraca.includes(piso: :restaurante).to_a
                           .sort_by { |item| [ item.piso.restaurante.nome, item.identificacao ] }
    end

    def consulta
      registros = RegistroAcesso.realizado.joins(:movimentacao_saldo, :configuracao_ponto_acesso)
                                .includes(:estudante, :movimentacao_saldo, servico_refeicao: :tipo_refeicao,
                                          configuracao_ponto_acesso: %i[restaurante catraca])
                                .where(passagem_em: inicio.in_time_zone.beginning_of_day..fim.in_time_zone.end_of_day)
                                .order(:passagem_em, :id)
      registros = registros.where(configuracao_ponto_acessos: { restaurante_id: restaurante.id }) if restaurante
      registros = registros.where(configuracao_ponto_acessos: { catraca_id: catraca.id }) if catraca
      registros
    end

    def montar_acesso(registro)
      ponto = registro.configuracao_ponto_acesso
      codigo = registro.servico_refeicao&.tipo_refeicao&.codigo
      Acesso.new(referencia: registro.referencia_evento.first(8), momento: registro.passagem_em.in_time_zone,
                 matricula: registro.estudante&.matricula, restaurante: ponto.restaurante.nome,
                 catraca: ponto.catraca.identificacao, refeicao: REFEICOES.fetch(codigo, "Refeição"),
                 valor: registro.movimentacao_saldo.valor.abs)
    end

    def interpretar_data(texto, padrao)
      Date.iso8601(texto.to_s)
    rescue Date::Error
      padrao
    end
  end
end
