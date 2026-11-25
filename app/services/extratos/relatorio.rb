module Extratos
  # F11 — Exportação do Extrato e Histórico de Refeições (responsável: Tarsila).
  # Monta os lançamentos do estudante conforme os filtros da tela (tipo de refeição, catraca e
  # período) e calcula os totais. A tela, o PDF e o CSV usam este mesmo objeto, por isso mostram
  # sempre os mesmos dados. O estudante vem da sessão, nunca de um parâmetro (RN03.1).
  class Relatorio
    # Código do filtro que inclui todos os tipos de lançamento.
    TIPO_TODOS = "todas".freeze
    # Código do filtro e do lançamento de recarga.
    TIPO_RECARGA = "recarga".freeze
    # Tipos aceitos no filtro e o nome exibido de cada um.
    TIPOS = {
      TIPO_TODOS => "Todas as Refeições",
      TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã",
      TipoRefeicao::ALMOCO => "Almoço",
      TipoRefeicao::JANTAR => "Jantar",
      TIPO_RECARGA => "Recarga de Saldo"
    }.freeze

    # Período usado quando o filtro não informa um período aceito.
    PERIODO_PADRAO = "30_dias".freeze
    # Períodos aceitos no filtro: nome exibido e quantos dias antes de hoje o período começa.
    PERIODOS = {
      "hoje" => [ "Hoje", 0 ],
      "7_dias" => [ "Últimos 7 dias", 7 ],
      PERIODO_PADRAO => [ "Últimos 30 dias", 30 ]
    }.freeze

    # Lançamentos por página na tela; a exportação sempre traz todos.
    POR_PAGINA = 10

    # Nome do evento de recarga.
    EVENTO_RECARGA = "Recarga de Saldo".freeze
    # Nome do evento de refeição sem tipo conhecido.
    EVENTO_REFEICAO = "Refeição".freeze
    # Ordem em que as refeições aparecem no resumo: a ordem do dia e, por fim, as sem tipo.
    ORDEM_DAS_REFEICOES = (TIPOS.values + [ EVENTO_REFEICAO ]).freeze

    # Linha do extrato: +momento+ (Time), +evento+, +local+ e +catraca+ (Strings ou nil), +valor+
    # (BigDecimal: positivo na recarga, negativo na refeição), +tipo+ (código de TIPOS),
    # +catraca_id+ e +metodo+ (forma de pagamento da recarga; nil nas refeições).
    Lancamento = Struct.new(:momento, :evento, :local, :catraca, :valor, :tipo, :catraca_id, :metodo,
                            keyword_init: true) do
      # Diz se o lançamento é um crédito (recarga).
      #
      # Argumentos:: nenhum.
      # Retorno:: true para recarga; false para refeição.
      # Efeitos colaterais:: nenhum.
      def credito?
        valor.positive?
      end

      # Descreve o evento com o método de pagamento, para os arquivos exportados.
      #
      # Argumentos:: nenhum.
      # Retorno:: String, como "Recarga de Saldo (PIX)"; só o evento quando não há método.
      # Efeitos colaterais:: nenhum.
      def descricao
        metodo ? "#{evento} (#{metodo})" : evento
      end
    end

    # Dono do extrato (Estudante).
    attr_reader :estudante
    # Código do tipo filtrado (String, chave de TIPOS).
    attr_reader :tipo
    # Código do período filtrado (String, chave de PERIODOS).
    attr_reader :periodo
    # Id da catraca filtrada (Integer), ou nil para todas.
    attr_reader :catraca_id
    # Momento de referência do extrato (Time).
    attr_reader :agora
    # Página pedida na tela (Integer, a partir de 1).
    attr_reader :pagina

    # Cria o relatório a partir dos filtros da tela. Valores fora das listas permitidas voltam ao
    # padrão, porque os parâmetros vêm do navegador.
    #
    # Argumentos:: +estudante+ (Estudante): dono do extrato, sempre o da sessão;
    #              +filtros+ (Hash ou ActionController::Parameters): +tipo+, +periodo+, +catraca_id+
    #              e +pagina+, todos opcionais; +agora+ (Time): momento de referência do período.
    # Retorno:: o novo Relatorio.
    # Efeitos colaterais:: consulta o banco para carregar as catracas disponíveis.
    def initialize(estudante, filtros = {}, agora: Time.current)
      @estudante = estudante
      @agora = agora
      definir_filtros(filtros.to_h.with_indifferent_access)
    end

    # Lista os lançamentos do estudante que atendem aos filtros, do mais recente para o mais antigo.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Lancamento.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def lancamentos
      @lancamentos ||= todos_lancamentos.select { |lancamento| corresponde?(lancamento) }
    end

    # Diz se os filtros não encontraram nenhum lançamento.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def vazio?
      lancamentos.empty?
    end

    # Diz se o estudante tem algum lançamento, com qualquer filtro. Decide se a exportação fica
    # disponível na tela.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: consulta o banco.
    def possui_lancamentos?
      estudante.movimentacoes_saldo.exists?
    end

    # Soma o valor gasto nas refeições do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal positivo (zero sem refeições).
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def total_gasto
      lancamentos.reject(&:credito?).sum(BigDecimal("0")) { |lancamento| lancamento.valor.abs }
    end

    # Soma o valor das recargas do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal (zero sem recargas).
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def total_recarregado
      lancamentos.select(&:credito?).sum(BigDecimal("0"), &:valor)
    end

    # Conta as refeições do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def refeicoes_realizadas
      lancamentos.count { |lancamento| !lancamento.credito? }
    end

    # Conta as recargas do filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def quantidade_recargas
      lancamentos.count(&:credito?)
    end

    # Conta as refeições do filtro por tipo, na ordem do dia.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash, como { "Café da Manhã" => 1, "Almoço" => 2 }; tipos sem refeição não aparecem.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def refeicoes_por_tipo
      lancamentos.reject(&:credito?).map(&:evento).tally.slice(*ORDEM_DAS_REFEICOES)
    end

    # Calcula quantas páginas a tela tem.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer, no mínimo 1.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def total_paginas
      [ (lancamentos.size.to_f / POR_PAGINA).ceil, 1 ].max
    end

    # Ajusta a página pedida ao total de páginas existente.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer entre 1 e #total_paginas.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def pagina_atual
      [ pagina, total_paginas ].min
    end

    # Separa os lançamentos exibidos na página atual da tela.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Lancamento com até POR_PAGINA itens; Array vazio sem lançamentos.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def lancamentos_da_pagina
      lancamentos.slice((pagina_atual - 1) * POR_PAGINA, POR_PAGINA) || []
    end

    # Calcula a posição do primeiro e do último lançamento da página atual, para o texto
    # "Exibindo 1–10 de 24".
    #
    # Argumentos:: nenhum.
    # Retorno:: Array [primeiro, último] (Integers).
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def intervalo_da_pagina
      primeiro = (pagina_atual - 1) * POR_PAGINA + 1
      [ primeiro, primeiro + lancamentos_da_pagina.size - 1 ]
    end

    # Lista os números de página a exibir na paginação: a primeira, a última e as vizinhas da atual.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Integers em ordem crescente, com nil onde há um salto entre páginas,
    #           como [1, nil, 4, 5, 6, nil, 9].
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def paginas_visiveis
      paginas_candidatas.each_with_object([]) do |numero, lista|
        lista << nil if salto_entre?(lista.last, numero)
        lista << numero
      end
    end

    # Diz se algum filtro diferente do padrão está aplicado.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: nenhum.
    def filtrado?
      tipo != TIPO_TODOS || periodo != PERIODO_PADRAO || catraca_id.present?
    end

    # Informa o saldo atual do estudante, que não depende dos filtros.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal.
    # Efeitos colaterais:: consulta o banco.
    def saldo_atual
      estudante.saldo
    end

    # Descreve o tipo filtrado.
    #
    # Argumentos:: nenhum.
    # Retorno:: String de TIPOS.
    # Efeitos colaterais:: nenhum.
    def tipo_nome
      TIPOS.fetch(tipo)
    end

    # Descreve o período filtrado.
    #
    # Argumentos:: nenhum.
    # Retorno:: String, como "Últimos 30 dias".
    # Efeitos colaterais:: nenhum.
    def periodo_nome
      PERIODOS.fetch(periodo).first
    end

    # Descreve o filtro de catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: String "Catraca · Restaurante" da catraca filtrada; o rótulo de todas as catracas
    #           sem filtro.
    # Efeitos colaterais:: nenhum (as catracas já foram carregadas em +new+).
    def catraca_nome
      catraca = catracas.find { |item| item.id == catraca_id }
      catraca ? nome_catraca(catraca) : rotulo_todas_catracas
    end

    # Calcula o início do período filtrado.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveSupport::TimeWithZone no começo do primeiro dia do período.
    # Efeitos colaterais:: nenhum.
    def inicio_periodo
      (agora.in_time_zone - PERIODOS.fetch(periodo).last.days).beginning_of_day
    end

    # Monta as opções do campo de tipo do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [nome, código].
    # Efeitos colaterais:: nenhum.
    def opcoes_tipo
      TIPOS.map { |codigo, nome| [ nome, codigo ] }
    end

    # Monta as opções do campo de período do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [nome, código].
    # Efeitos colaterais:: nenhum.
    def opcoes_periodo
      PERIODOS.map { |codigo, (nome, _dias)| [ nome, codigo ] }
    end

    # Monta as opções do campo de catraca do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [nome, id], começando pelo rótulo de todas as catracas com id "".
    # Efeitos colaterais:: nenhum (as catracas já foram carregadas em +new+).
    def opcoes_catraca
      [ [ rotulo_todas_catracas, "" ] ] + catracas.map { |catraca| [ nome_catraca(catraca), catraca.id ] }
    end

    # Devolve os filtros na forma em que são reenviados pelo formulário e gravados em
    # ExportacaoRelatorio.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash com as chaves "tipo", "periodo" e "catraca_id".
    # Efeitos colaterais:: nenhum.
    def filtros
      { "tipo" => tipo, "periodo" => periodo, "catraca_id" => catraca_id }
    end

    private

    # Lê os filtros recebidos, trocando pelo padrão os valores que não estão nas listas permitidas.
    #
    # Argumentos:: +filtros+ (Hash com acesso indiferente): filtros da tela.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define +@tipo+, +@periodo+, +@catraca_id+ e +@pagina+; consulta o banco
    #                      para validar a catraca.
    def definir_filtros(filtros)
      @tipo = valor_permitido(TIPOS, filtros[:tipo], TIPO_TODOS)
      @periodo = valor_permitido(PERIODOS, filtros[:periodo], PERIODO_PADRAO)
      @catraca_id = id_de_catraca_disponivel(filtros[:catraca_id])
      @pagina = [ filtros[:pagina].to_i, 1 ].max
    end

    # Aceita o valor de um filtro só quando ele está na lista permitida.
    #
    # Argumentos:: +permitidos+ (Hash): lista cujas chaves são os valores aceitos;
    #              +valor+ (String ou nil): valor recebido; +padrao+ (String): valor usado no lugar
    #              de um valor não aceito.
    # Retorno:: +valor+ quando está na lista; +padrao+ caso contrário.
    # Efeitos colaterais:: nenhum.
    def valor_permitido(permitidos, valor, padrao)
      permitidos.key?(valor) ? valor : padrao
    end

    # Confere se a catraca pedida no filtro existe entre as disponíveis.
    #
    # Argumentos:: +id+ (String, Integer ou nil): catraca pedida.
    # Retorno:: Integer com o id da catraca; nil quando o filtro está vazio ou a catraca não existe.
    # Efeitos colaterais:: consulta o banco por meio de #catracas.
    def id_de_catraca_disponivel(id)
      catracas.map(&:id).find { |disponivel| disponivel.to_s == id.to_s }
    end

    # Lista as páginas que entram na paginação, antes de marcar os saltos.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Integers em ordem crescente e sem repetição: a primeira página, a última
    #           e a atual com as suas vizinhas, descartadas as que não existem.
    # Efeitos colaterais:: consulta o banco se #lancamentos ainda não foi chamado.
    def paginas_candidatas
      vizinhas = ((pagina_atual - 1)..(pagina_atual + 1)).to_a
      ([ 1, total_paginas ] + vizinhas).uniq.sort.select { |numero| numero.between?(1, total_paginas) }
    end

    # Diz se há páginas omitidas entre duas páginas exibidas em sequência.
    #
    # Argumentos:: +anterior+ (Integer ou nil): última página já listada;
    #              +numero+ (Integer): próxima página a listar.
    # Retorno:: true quando há ao menos uma página entre as duas; false caso contrário ou quando
    #           não há página anterior.
    # Efeitos colaterais:: nenhum.
    def salto_entre?(anterior, numero)
      anterior.present? && numero - anterior > 1
    end

    # Carrega as catracas que podem ser escolhidas no filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Catraca disponíveis, ordenado por restaurante e identificação.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def catracas
      @catracas ||= Catraca.disponiveis.includes(piso: :restaurante).to_a
                           .sort_by { |catraca| [ catraca.piso.restaurante.nome, catraca.identificacao ] }
    end

    # Monta o rótulo da opção que não filtra por catraca.
    #
    # Argumentos:: nenhum.
    # Retorno:: String "Todas as N Catracas" com mais de uma catraca; "Todas as Catracas" caso contrário.
    # Efeitos colaterais:: nenhum.
    def rotulo_todas_catracas
      catracas.size > 1 ? "Todas as #{catracas.size} Catracas" : "Todas as Catracas"
    end

    # Descreve uma catraca com o seu restaurante.
    #
    # Argumentos:: +catraca+ (Catraca): catraca a descrever.
    # Retorno:: String, como "Catraca 01 · RU Darcy Ribeiro".
    # Efeitos colaterais:: nenhum.
    def nome_catraca(catraca)
      "#{catraca.identificacao} · #{catraca.piso.restaurante.nome}"
    end

    # Diz se um lançamento atende aos três filtros: período, tipo e catraca.
    #
    # Argumentos:: +lancamento+ (Lancamento): lançamento a avaliar.
    # Retorno:: true ou false.
    # Efeitos colaterais:: nenhum.
    def corresponde?(lancamento)
      no_periodo?(lancamento) && do_tipo?(lancamento) && da_catraca?(lancamento)
    end

    # Diz se o lançamento aconteceu dentro do período filtrado.
    #
    # Argumentos:: +lancamento+ (Lancamento): lançamento a avaliar.
    # Retorno:: true quando o momento está entre #inicio_periodo e +agora+; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def no_periodo?(lancamento)
      lancamento.momento.between?(inicio_periodo, agora)
    end

    # Diz se o lançamento é do tipo filtrado.
    #
    # Argumentos:: +lancamento+ (Lancamento): lançamento a avaliar.
    # Retorno:: true quando não há filtro de tipo ou o tipo coincide; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def do_tipo?(lancamento)
      tipo == TIPO_TODOS || lancamento.tipo == tipo
    end

    # Diz se o lançamento passou pela catraca filtrada.
    #
    # Argumentos:: +lancamento+ (Lancamento): lançamento a avaliar.
    # Retorno:: true quando não há filtro de catraca ou a catraca coincide; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def da_catraca?(lancamento)
      catraca_id.nil? || lancamento.catraca_id == catraca_id
    end

    # Converte todas as movimentações de saldo do estudante em lançamentos, sem aplicar filtros.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Lancamento, do mais recente para o mais antigo.
    # Efeitos colaterais:: consulta o banco.
    def todos_lancamentos
      movimentacoes.map { |mov| mov.credito_recarga? ? lancamento_de_recarga(mov) : lancamento_de_refeicao(mov) }
    end

    # Monta a consulta das movimentações do estudante, com as associações usadas no extrato.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de MovimentacaoSaldo, das mais recentes para as mais antigas.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é percorrida).
    def movimentacoes
      estudante.movimentacoes_saldo.recentes.includes(
        recarga: :pagamentos,
        registro_acesso: [ { servico_refeicao: :tipo_refeicao },
                          { configuracao_ponto_acesso: [ :restaurante, { catraca: :piso } ] } ]
      )
    end

    # Converte um crédito de recarga em lançamento.
    #
    # Argumentos:: +mov+ (MovimentacaoSaldo): crédito de recarga.
    # Retorno:: Lancamento sem local nem catraca, com o método do pagamento confirmado.
    # Efeitos colaterais:: nenhum.
    def lancamento_de_recarga(mov)
      metodo = mov.recarga&.pagamentos&.find(&:confirmado?)&.nome_metodo
      Lancamento.new(momento: mov.ocorrida_em.in_time_zone, evento: EVENTO_RECARGA,
                     local: nil, catraca: nil, metodo: metodo,
                     valor: mov.valor, tipo: TIPO_RECARGA, catraca_id: nil)
    end

    # Converte um débito de refeição em lançamento.
    #
    # Argumentos:: +mov+ (MovimentacaoSaldo): débito de refeição.
    # Retorno:: Lancamento com o tipo da refeição e, quando conhecidos, o local e a catraca.
    # Efeitos colaterais:: nenhum.
    def lancamento_de_refeicao(mov)
      codigo = mov.tipo_refeicao&.codigo
      Lancamento.new(momento: mov.ocorrida_em.in_time_zone, evento: TIPOS.fetch(codigo, EVENTO_REFEICAO),
                     valor: mov.valor, tipo: codigo, **local_da_refeicao(mov.registro_acesso&.configuracao_ponto_acesso))
    end

    # Lê onde a refeição foi servida, a partir do ponto de acesso da passagem.
    #
    # Argumentos:: +ponto+ (ConfiguracaoPontoAcesso ou nil): ponto de acesso do registro.
    # Retorno:: Hash com +local+ ("Restaurante - Piso"), +catraca+ (identificação) e +catraca_id+;
    #           todos nil quando o débito não tem ponto de acesso.
    # Efeitos colaterais:: nenhum.
    def local_da_refeicao(ponto)
      catraca = ponto&.catraca
      { local: [ ponto&.restaurante&.nome, catraca&.piso&.nome ].compact.join(" - ").presence,
        catraca: catraca&.identificacao, catraca_id: catraca&.id }
    end
  end
end
