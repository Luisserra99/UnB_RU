module Relatorios
  # F12 — Acessos do Relatório de Operação, para auditoria (responsável: Tarsila).
  # Lista cada acesso realizado em um período, com filtros de restaurante e catraca, subtotais
  # por restaurante e catraca e paginação para a tela. A tela e o PDF usam este mesmo objeto.
  class AcessosOperacao
    # Mensagem do período com data inicial depois da final (RN12.7).
    MSG_PERIODO_INVERTIDO = "A data inicial deve ser anterior ou igual à data final".freeze
    # Formato das datas exibidas ("16/10/2026").
    FORMATO_DATA = "%d/%m/%Y".freeze
    # Sem filtro, mostra os últimos 7 dias: hoje e os 6 anteriores.
    DIAS_PADRAO = 6
    # Acessos por página na tela quando o filtro não informa.
    POR_PAGINA_PADRAO = 20
    # Maior quantidade de acessos por página aceita.
    POR_PAGINA_MAXIMO = 100
    # Nome exibido de cada refeição, pelo código do TipoRefeicao.
    REFEICOES = { TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã", TipoRefeicao::ALMOCO => "Almoço",
                  TipoRefeicao::JANTAR => "Jantar" }.freeze
    # Nome exibido quando o acesso não tem refeição conhecida.
    REFEICAO_SEM_TIPO = "Refeição".freeze
    # Campos do agrupamento, gravados em ExportacaoRelatorio#agrupamentos.
    AGRUPAMENTO = %w[restaurante catraca].freeze
    # Associações carregadas junto com os registros, para não consultar o banco a cada linha.
    ASSOCIACOES = [ :estudante, :movimentacao_saldo, { servico_refeicao: :tipo_refeicao },
                    { configuracao_ponto_acesso: %i[restaurante catraca] } ].freeze

    # Um acesso realizado: +referencia+ (String de 8 caracteres), +momento+ (Time), +matricula+,
    # +restaurante+, +catraca+ e +refeicao+ (Strings) e +valor+ debitado (BigDecimal positivo).
    Acesso = Struct.new(:referencia, :momento, :matricula, :restaurante, :catraca, :refeicao, :valor, keyword_init: true)
    # Subtotal de uma catraca dentro de um restaurante: nomes, +acessos+ (Array de Acesso),
    # +quantidade+ (Integer) e +total+ debitado (BigDecimal).
    Subtotal = Struct.new(:restaurante, :catraca, :acessos, :quantidade, :total, keyword_init: true)
    # Total de um restaurante: nome, +catracas+ (Array de Subtotal), +quantidade+ e +total+.
    Grupo = Struct.new(:restaurante, :catracas, :quantidade, :total, keyword_init: true)

    # Primeiro dia do período (Date).
    attr_reader :inicio
    # Último dia do período (Date).
    attr_reader :fim
    # Restaurante do filtro (Restaurante), ou nil para todos.
    attr_reader :restaurante
    # Catraca do filtro (Catraca), ou nil para todas.
    attr_reader :catraca
    # Página pedida na tela (Integer, a partir de 1).
    attr_reader :pagina
    # Acessos por página na tela (Integer).
    attr_reader :por_pagina

    # Cria o relatório a partir dos filtros da tela. Valores inválidos voltam ao padrão, porque
    # os parâmetros vêm do navegador.
    #
    # Argumentos:: +filtros+ (Hash ou ActionController::Parameters): +inicio+ e +fim+ (datas ISO),
    #              +restaurante_id+, +catraca_id+, +agrupar+, +pagina+ e +por_pagina+, todos opcionais;
    #              +agora+ (Time): momento de referência para o período padrão.
    # Retorno:: o novo AcessosOperacao.
    # Efeitos colaterais:: consulta o banco para carregar os restaurantes e as catracas dos filtros.
    def initialize(filtros = {}, agora: Time.current)
      filtros = filtros.to_h.with_indifferent_access
      definir_periodo(filtros, agora.in_time_zone.to_date)
      definir_locais(filtros)
      definir_exibicao(filtros)
    end

    # Informa o erro de preenchimento do período (RN12.7).
    #
    # Argumentos:: nenhum.
    # Retorno:: String MSG_PERIODO_INVERTIDO quando a data inicial é posterior à final; nil quando
    #           o período é válido.
    # Efeitos colaterais:: nenhum.
    def erro
      MSG_PERIODO_INVERTIDO if inicio > fim
    end

    # Diz se o relatório pode ser consultado e exportado.
    #
    # Argumentos:: nenhum.
    # Retorno:: true quando não há erro de preenchimento; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def valido?
      erro.nil?
    end

    # Diz se foi pedido o agrupamento por restaurante e catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: nenhum.
    def agrupado?
      @agrupado
    end

    # Lista todos os acessos do filtro, em ordem cronológica. Os limites do período são
    # inclusivos (RN12.2).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Acesso; Array vazio quando o período é inválido ou não há acessos.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def acessos
      @acessos ||= valido? ? consulta.map { |registro| montar_acesso(registro) } : []
    end

    # Diz se o filtro não encontrou nenhum acesso.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado.
    def vazio?
      acessos.empty?
    end

    # Conta os acessos do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer.
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado.
    def quantidade
      acessos.size
    end

    # Soma o valor debitado em todos os acessos do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal (zero sem acessos).
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado.
    def total_debitado
      somar_valores(acessos)
    end

    # Agrupa os acessos por restaurante e, dentro dele, por catraca, com os subtotais. Catracas de
    # mesmo nome em restaurantes diferentes nunca se misturam, porque cada catraca é agrupada
    # dentro do seu restaurante (RN12.5).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Grupo, em ordem alfabética de restaurante.
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado; guarda o resultado.
    def grupos
      @grupos ||= acessos.group_by(&:restaurante).sort.map do |nome, do_restaurante|
        montar_grupo(nome, do_restaurante)
      end
    end

    # Calcula quantas páginas a tela tem.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer, no mínimo 1.
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado.
    def total_paginas
      [ (quantidade.to_f / por_pagina).ceil, 1 ].max
    end

    # Ajusta a página pedida ao total de páginas existente.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer entre 1 e #total_paginas.
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado.
    def pagina_atual
      [ pagina, total_paginas ].min
    end

    # Separa os acessos exibidos na página atual da tela.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Acesso com até #por_pagina itens; Array vazio sem acessos.
    # Efeitos colaterais:: consulta o banco se #acessos ainda não foi chamado.
    def acessos_da_pagina
      acessos.slice((pagina_atual - 1) * por_pagina, por_pagina) || []
    end

    # Descreve o período do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: String, como "14/10/2026 a 15/10/2026".
    # Efeitos colaterais:: nenhum.
    def periodo_nome
      "#{inicio.strftime(FORMATO_DATA)} a #{fim.strftime(FORMATO_DATA)}"
    end

    # Descreve o filtro de restaurante.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com o nome do restaurante; "Todos" sem filtro.
    # Efeitos colaterais:: nenhum.
    def restaurante_nome
      restaurante&.nome || "Todos"
    end

    # Descreve o filtro de catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com a identificação da catraca; "Todas" sem filtro.
    # Efeitos colaterais:: nenhum.
    def catraca_nome
      catraca&.identificacao || "Todas"
    end

    # Descreve o agrupamento aplicado.
    #
    # Argumentos:: nenhum.
    # Retorno:: "Restaurante e catraca" quando agrupado; "Sem agrupamento" caso contrário.
    # Efeitos colaterais:: nenhum.
    def agrupamento_nome
      agrupado? ? "Restaurante e catraca" : "Sem agrupamento"
    end

    # Monta as opções do campo de restaurante do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [nome, id], começando por ["Todos", ""].
    # Efeitos colaterais:: nenhum (os restaurantes já foram carregados em +new+).
    def opcoes_restaurante
      [ [ "Todos", "" ] ] + restaurantes.map { |item| [ item.nome, item.id ] }
    end

    # Monta as opções do campo de catraca do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares ["Catraca · Restaurante", id], começando por ["Todas", ""].
    # Efeitos colaterais:: nenhum (as catracas já foram carregadas em +new+).
    def opcoes_catraca
      [ [ "Todas", "" ] ] + catracas.map { |item| [ "#{item.identificacao} · #{item.piso.restaurante.nome}", item.id ] }
    end

    # Devolve os filtros na forma em que são reenviados pelo formulário e gravados em
    # ExportacaoRelatorio.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash com as chaves "inicio", "fim", "restaurante_id", "catraca_id" e "agrupar";
    #           filtros não usados ficam com nil.
    # Efeitos colaterais:: nenhum.
    def filtros
      { "inicio" => inicio.iso8601, "fim" => fim.iso8601, "restaurante_id" => restaurante&.id,
        "catraca_id" => catraca&.id, "agrupar" => (agrupado? ? "1" : nil) }
    end

    # Devolve o agrupamento na forma gravada em ExportacaoRelatorio.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash { "por" => AGRUPAMENTO } quando agrupado; Hash vazio caso contrário.
    # Efeitos colaterais:: nenhum.
    def agrupamentos
      agrupado? ? { "por" => AGRUPAMENTO } : {}
    end

    private

    # Define o período: sem filtro, vai de seis dias atrás até hoje.
    #
    # Argumentos:: +filtros+ (Hash): filtros recebidos; +hoje+ (Date): data de referência.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define +@inicio+ e +@fim+.
    def definir_periodo(filtros, hoje)
      @fim = interpretar_data(filtros[:fim], hoje)
      @inicio = interpretar_data(filtros[:inicio], [ hoje - DIAS_PADRAO, @fim ].min)
    end

    # Define o restaurante e a catraca do filtro, aceitando só os que existem.
    #
    # Argumentos:: +filtros+ (Hash): filtros recebidos.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define +@restaurante+ e +@catraca+; consulta o banco.
    def definir_locais(filtros)
      @restaurante = encontrar_por_id(restaurantes, filtros[:restaurante_id])
      @catraca = encontrar_por_id(catracas, filtros[:catraca_id])
    end

    # Define como a tela exibe os acessos: agrupamento e paginação.
    #
    # Argumentos:: +filtros+ (Hash): filtros recebidos.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define +@agrupado+, +@por_pagina+ e +@pagina+.
    def definir_exibicao(filtros)
      @agrupado = ActiveModel::Type::Boolean.new.cast(filtros[:agrupar]) || false
      @por_pagina = interpretar_por_pagina(filtros[:por_pagina])
      @pagina = [ filtros[:pagina].to_i, 1 ].max
    end

    # Lê a quantidade de acessos por página, limitada entre 1 e POR_PAGINA_MAXIMO.
    #
    # Argumentos:: +valor+ (String, Integer ou nil): quantidade pedida.
    # Retorno:: Integer; POR_PAGINA_PADRAO quando nada foi pedido.
    # Efeitos colaterais:: nenhum.
    def interpretar_por_pagina(valor)
      valor.present? ? valor.to_i.clamp(1, POR_PAGINA_MAXIMO) : POR_PAGINA_PADRAO
    end

    # Procura numa lista o registro com o id informado.
    #
    # Argumentos:: +lista+ (Array de registros): onde procurar; +id+ (String, Integer ou nil): id pedido.
    # Retorno:: o registro encontrado; nil quando o id não existe na lista.
    # Efeitos colaterais:: nenhum.
    def encontrar_por_id(lista, id)
      lista.find { |item| item.id.to_s == id.to_s }
    end

    # Carrega os restaurantes que podem ser escolhidos no filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Restaurante, em ordem alfabética.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def restaurantes
      @restaurantes ||= Restaurante.order(:nome).to_a
    end

    # Carrega as catracas que podem ser escolhidas no filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Catraca, ordenado por restaurante e identificação.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def catracas
      @catracas ||= Catraca.includes(piso: :restaurante).to_a
                           .sort_by { |item| [ item.piso.restaurante.nome, item.identificacao ] }
    end

    # Monta a consulta dos acessos do período, restrita ao restaurante e à catraca do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é percorrida).
    def consulta
      local = filtro_de_local
      local.empty? ? registros_do_periodo : registros_do_periodo.where(configuracao_ponto_acessos: local)
    end

    # Monta a consulta dos acessos realizados (com débito) dentro do período, em ordem cronológica.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso, com as associações usadas já incluídas.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é percorrida).
    def registros_do_periodo
      RegistroAcesso.realizado.joins(:movimentacao_saldo, :configuracao_ponto_acesso).includes(*ASSOCIACOES)
                    .where(passagem_em: intervalo_do_periodo).order(:passagem_em, :id)
    end

    # Converte o período em um intervalo de horários, do início do primeiro dia ao fim do último.
    #
    # Argumentos:: nenhum.
    # Retorno:: Range de Time.
    # Efeitos colaterais:: nenhum.
    def intervalo_do_periodo
      inicio.in_time_zone.beginning_of_day..fim.in_time_zone.end_of_day
    end

    # Reúne as condições de restaurante e catraca escolhidas no filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash com +restaurante_id+ e/ou +catraca_id+; Hash vazio sem filtro de local.
    # Efeitos colaterais:: nenhum.
    def filtro_de_local
      { restaurante_id: restaurante&.id, catraca_id: catraca&.id }.compact
    end

    # Converte um registro do banco em um Acesso do relatório.
    #
    # Argumentos:: +registro+ (RegistroAcesso): acesso realizado, com débito.
    # Retorno:: Acesso.
    # Efeitos colaterais:: nenhum.
    def montar_acesso(registro)
      Acesso.new(referencia: registro.referencia_evento.first(8), momento: registro.passagem_em.in_time_zone,
                 matricula: registro.estudante&.matricula, refeicao: nome_da_refeicao(registro),
                 valor: registro.movimentacao_saldo.valor.abs, **local_do_acesso(registro.configuracao_ponto_acesso))
    end

    # Lê o restaurante e a catraca do ponto de acesso em que a passagem aconteceu.
    #
    # Argumentos:: +ponto+ (ConfiguracaoPontoAcesso): ponto de acesso do registro.
    # Retorno:: Hash com +restaurante+ (nome) e +catraca+ (identificação).
    # Efeitos colaterais:: nenhum.
    def local_do_acesso(ponto)
      { restaurante: ponto.restaurante.nome, catraca: ponto.catraca.identificacao }
    end

    # Descobre o nome da refeição servida no acesso.
    #
    # Argumentos:: +registro+ (RegistroAcesso): acesso realizado.
    # Retorno:: String de REFEICOES; REFEICAO_SEM_TIPO quando o acesso não tem serviço de refeição.
    # Efeitos colaterais:: nenhum.
    def nome_da_refeicao(registro)
      REFEICOES.fetch(registro.servico_refeicao&.tipo_refeicao&.codigo, REFEICAO_SEM_TIPO)
    end

    # Monta o total de um restaurante com os subtotais das suas catracas.
    #
    # Argumentos:: +nome+ (String): nome do restaurante; +do_restaurante+ (Array de Acesso): seus acessos.
    # Retorno:: Grupo.
    # Efeitos colaterais:: nenhum.
    def montar_grupo(nome, do_restaurante)
      Grupo.new(restaurante: nome, catracas: subtotais_por_catraca(nome, do_restaurante),
                quantidade: do_restaurante.size, total: somar_valores(do_restaurante))
    end

    # Monta o subtotal de cada catraca de um restaurante.
    #
    # Argumentos:: +nome+ (String): nome do restaurante; +do_restaurante+ (Array de Acesso): seus acessos.
    # Retorno:: Array de Subtotal, em ordem alfabética de catraca.
    # Efeitos colaterais:: nenhum.
    def subtotais_por_catraca(nome, do_restaurante)
      do_restaurante.group_by(&:catraca).sort.map do |catraca, da_catraca|
        Subtotal.new(restaurante: nome, catraca: catraca, acessos: da_catraca,
                     quantidade: da_catraca.size, total: somar_valores(da_catraca))
      end
    end

    # Soma o valor debitado de uma lista de acessos.
    #
    # Argumentos:: +lista+ (Array de Acesso): acessos a somar.
    # Retorno:: BigDecimal (zero para lista vazia).
    # Efeitos colaterais:: nenhum.
    def somar_valores(lista)
      lista.sum(BigDecimal("0"), &:valor)
    end

    # Converte o texto de uma data do filtro.
    #
    # Argumentos:: +texto+ (String ou nil): data no formato ISO ("2026-10-14");
    #              +padrao+ (Date): data usada quando o texto é inválido.
    # Retorno:: Date do texto; +padrao+ quando o texto não é uma data.
    # Efeitos colaterais:: nenhum.
    def interpretar_data(texto, padrao)
      Date.iso8601(texto.to_s)
    rescue Date::Error
      padrao
    end
  end
end
