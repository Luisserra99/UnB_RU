# Relatórios administrativos de operação dos restaurantes (F09 e F12).
module Relatorios
  # F09 — Relatório Global de Operação (responsável: Tarsila).
  # Consolida os acessos realizados nos restaurantes de uma unidade gestora em uma data contábil,
  # com filtro opcional de turno. A tela, o CSV e o PDF usam este mesmo objeto.
  #
  # A arrecadação é a soma dos valores realmente debitados em cada acesso (MovimentacaoSaldo),
  # e não "acessos x tarifa": assim o café da manhã entra com a tarifa que foi cobrada.
  class OperacaoGlobal
    # Código do filtro que inclui todos os turnos.
    TURNO_TODOS = "todos".freeze
    # Turnos aceitos no filtro e o nome exibido de cada um.
    TURNOS = {
      TURNO_TODOS => "Todos os Turnos (Café, Almoço, Jantar)",
      TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã",
      TipoRefeicao::ALMOCO => "Almoço",
      TipoRefeicao::JANTAR => "Jantar"
    }.freeze
    # Métodos de pagamento das recargas e o nome exibido de cada um (RN09.10).
    METODOS = {
      "pix" => "PIX Institucional Instantâneo",
      "cartao_credito" => "Cartão de Crédito / Débito"
    }.freeze
    # Formato das datas exibidas ("24/10/2025").
    FORMATO_DATA = "%d/%m/%Y".freeze
    # Expressão SQL do valor arrecadado: os débitos são gravados com sinal negativo.
    SOMA_DEBITADA = "SUM(-movimentacao_saldos.valor)".freeze
    # Quantidade e valor de quem não teve acessos.
    SEM_ACESSOS = [ 0, BigDecimal("0") ].freeze

    # Linha da consolidação: +restaurante+ (Restaurante), +acessos+ (Integer) e +arrecadacao+ (BigDecimal).
    Linha = Struct.new(:restaurante, :acessos, :arrecadacao, keyword_init: true)
    # Valor liquidado por método de pagamento: +metodo+ (código), +nome+ (String), +valor+
    # (BigDecimal) e +percentual+ da arrecadação (Integer).
    Liquidacao = Struct.new(:metodo, :nome, :valor, :percentual, keyword_init: true)
    # Totais de uma refeição: +codigo+, +nome+, +acessos+ (Integer), +arrecadacao+ (BigDecimal) e
    # +horario+ ("11:00 – 14:30", ou nil sem serviço cadastrado).
    Turno = Struct.new(:codigo, :nome, :acessos, :arrecadacao, :horario, keyword_init: true)

    # Data contábil do relatório (Date).
    attr_reader :data
    # Código do turno filtrado (String, chave de TURNOS).
    attr_reader :turno
    # Unidade gestora do relatório (UnidadeGestora), ou nil se nenhuma está cadastrada.
    attr_reader :unidade
    # Momento de referência do relatório (ActiveSupport::TimeWithZone).
    attr_reader :agora

    # Cria o relatório a partir dos filtros da tela. Valores fora das listas permitidas voltam ao
    # padrão, porque os parâmetros vêm do navegador (RN09.3).
    #
    # Argumentos:: +filtros+ (Hash ou ActionController::Parameters): +data+ (ISO), +turno+ e
    #              +unidade_id+, todos opcionais; +agora+ (Time): momento de referência, que define "hoje".
    # Retorno:: o novo OperacaoGlobal.
    # Efeitos colaterais:: consulta o banco para carregar as unidades gestoras ativas.
    def initialize(filtros = {}, agora: Time.current)
      filtros = filtros.to_h.with_indifferent_access
      @agora = agora.in_time_zone
      @data = interpretar_data(filtros[:data])
      @turno = TURNOS.key?(filtros[:turno]) ? filtros[:turno] : TURNO_TODOS
      @unidade = escolher_unidade(filtros[:unidade_id])
    end

    # Lista uma linha por restaurante da unidade, na ordem da numeração, inclusive os que não
    # tiveram acessos (RN09.7 e RN09.8).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Linha.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def linhas
      @linhas ||= begin
        totais = totais_por("configuracao_ponto_acessos.restaurante_id", acessos)
        restaurantes.map { |restaurante| montar_linha(restaurante, totais) }
      end
    end

    # Soma os acessos de todos os restaurantes.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer.
    # Efeitos colaterais:: consulta o banco se #linhas ainda não foi chamado.
    def total_acessos
      linhas.sum(&:acessos)
    end

    # Soma a arrecadação de todos os restaurantes.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal (zero sem acessos).
    # Efeitos colaterais:: consulta o banco se #linhas ainda não foi chamado.
    def arrecadacao_global
      linhas.sum(BigDecimal("0"), &:arrecadacao)
    end

    # Diz se não houve nenhum acesso com os filtros escolhidos.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: consulta o banco se #linhas ainda não foi chamado.
    def vazio?
      total_acessos.zero?
    end

    # Calcula o valor liquidado por método de pagamento das recargas que custearam os
    # acessos (RN09.10).
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Liquidacao, um por método de METODOS, inclusive os zerados.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def liquidacoes
      @liquidacoes ||= begin
        valores = valores_liquidados
        METODOS.map { |metodo, nome| montar_liquidacao(metodo, nome, valores.fetch(metodo, 0).to_d) }
      end
    end

    # Soma o valor liquidado em todos os métodos de pagamento.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal.
    # Efeitos colaterais:: consulta o banco se #liquidacoes ainda não foi chamado.
    def soma_liquidacoes
      liquidacoes.sum(BigDecimal("0"), &:valor)
    end

    # Calcula a diferença entre o arrecadado e o liquidado, que deve ser zero (RN09.11).
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal.
    # Efeitos colaterais:: consulta o banco se #linhas ou #liquidacoes ainda não foram chamados.
    def divergencia_contabil
      arrecadacao_global - soma_liquidacoes
    end

    # Calcula o valor médio debitado por acesso.
    #
    # Argumentos:: nenhum.
    # Retorno:: BigDecimal com duas casas; zero sem acessos.
    # Efeitos colaterais:: consulta o banco se #linhas ainda não foi chamado.
    def ticket_medio
      vazio? ? BigDecimal("0") : (arrecadacao_global / total_acessos).round(2)
    end

    # Conta as transações validadas: cada acesso realizado é uma transação com débito.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer, igual a #total_acessos.
    # Efeitos colaterais:: consulta o banco se #linhas ainda não foi chamado.
    def transacoes_validadas
      total_acessos
    end

    # Distribui os acessos e a arrecadação por refeição, com o horário de cada uma.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Turno: café da manhã, almoço e jantar, inclusive os zerados.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def distribuicao_por_refeicao
      @distribuicao_por_refeicao ||= begin
        totais = totais_por("tipo_refeicoes.codigo", acessos.joins(servico_refeicao: :tipo_refeicao))
        TURNOS.except(TURNO_TODOS).map { |codigo, nome| montar_turno(codigo, nome, totais) }
      end
    end

    # Conta as catracas online: ativas e em operação agora, isto é, com um ponto de acesso
    # confirmado por um funcionário com sessão válida (F05). É o critério de Catraca#em_operacao?.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer.
    # Efeitos colaterais:: consulta o banco.
    def catracas_online
      catracas_da_unidade.where(ativa: true)
                         .where(id: ConfiguracaoPontoAcesso.em_sessoes_validas.select(:catraca_id)).count
    end

    # Conta as catracas cadastradas nos restaurantes da unidade.
    #
    # Argumentos:: nenhum.
    # Retorno:: Integer.
    # Efeitos colaterais:: consulta o banco.
    def catracas_cadastradas
      catracas_da_unidade.count
    end

    # Diz se a data contábil é o dia de hoje.
    #
    # Argumentos:: nenhum.
    # Retorno:: true ou false.
    # Efeitos colaterais:: nenhum.
    def hoje?
      data == agora.to_date
    end

    # Descreve a data contábil.
    #
    # Argumentos:: nenhum.
    # Retorno:: String "Hoje (24/10/2025)" quando é hoje; "23/10/2025" nos outros dias.
    # Efeitos colaterais:: nenhum.
    def data_nome
      hoje? ? "Hoje (#{data.strftime(FORMATO_DATA)})" : data.strftime(FORMATO_DATA)
    end

    # Descreve o turno filtrado.
    #
    # Argumentos:: nenhum.
    # Retorno:: String de TURNOS.
    # Efeitos colaterais:: nenhum.
    def turno_nome
      TURNOS.fetch(turno)
    end

    # Descreve a unidade gestora do relatório.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com o nome da unidade; "Nenhuma unidade gestora cadastrada" quando não há.
    # Efeitos colaterais:: nenhum.
    def unidade_nome
      unidade&.nome || "Nenhuma unidade gestora cadastrada"
    end

    # Monta as opções do campo de turno do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [nome, código].
    # Efeitos colaterais:: nenhum.
    def opcoes_turno
      TURNOS.map { |codigo, nome| [ nome, codigo ] }
    end

    # Monta as opções do campo de unidade gestora do formulário.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de pares [nome, id].
    # Efeitos colaterais:: nenhum (as unidades já foram carregadas em +new+).
    def opcoes_unidade
      unidades.map { |unidade| [ unidade.nome, unidade.id ] }
    end

    # Devolve os filtros na forma em que são reenviados pelo formulário e gravados em
    # ExportacaoRelatorio.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash com as chaves "data", "turno" e "unidade_id".
    # Efeitos colaterais:: nenhum.
    def filtros
      { "data" => data.iso8601, "turno" => turno, "unidade_id" => unidade&.id }
    end

    private

    # Carrega as unidades gestoras que podem ser escolhidas no filtro.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de UnidadeGestora ativas, em ordem alfabética.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def unidades
      @unidades ||= UnidadeGestora.ativas.order(:nome).to_a
    end

    # Escolhe a unidade do relatório: a do filtro, senão a padrão, senão a primeira.
    #
    # Argumentos:: +id+ (String, Integer ou nil): unidade pedida no filtro.
    # Retorno:: UnidadeGestora; nil quando não há unidade ativa cadastrada.
    # Efeitos colaterais:: consulta o banco por meio de #unidades.
    def escolher_unidade(id)
      unidades.find { |unidade| unidade.id.to_s == id.to_s } ||
        unidades.find { |unidade| unidade.nome == UnidadeGestora::NOME_PADRAO } || unidades.first
    end

    # Carrega os restaurantes ativos da unidade.
    #
    # Argumentos:: nenhum.
    # Retorno:: Array de Restaurante, na ordem da numeração; Array vazio sem unidade.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def restaurantes
      @restaurantes ||= unidade ? unidade.restaurantes.ativos.order(:numero).to_a : []
    end

    # Conta os acessos e soma o valor debitado, agrupando por uma coluna.
    #
    # Argumentos:: +coluna+ (String): coluna SQL do agrupamento, escrita no código (nunca vem do
    #              usuário); +consulta+ (ActiveRecord::Relation): acessos a totalizar.
    # Retorno:: Hash { valor da coluna => [quantidade (Integer), valor (BigDecimal)] }.
    # Efeitos colaterais:: consulta o banco.
    def totais_por(coluna, consulta)
      consulta.group(coluna).pluck(Arel.sql(coluna), Arel.sql("COUNT(*)"), Arel.sql(SOMA_DEBITADA))
              .to_h { |chave, quantidade, valor| [ chave, [ quantidade, valor.to_d ] ] }
    end

    # Monta a linha de um restaurante com os seus totais.
    #
    # Argumentos:: +restaurante+ (Restaurante): restaurante da linha;
    #              +totais+ (Hash): resultado de #totais_por, indexado pelo id do restaurante.
    # Retorno:: Linha (zerada quando o restaurante não teve acessos).
    # Efeitos colaterais:: nenhum.
    def montar_linha(restaurante, totais)
      quantidade, valor = totais.fetch(restaurante.id, SEM_ACESSOS)
      Linha.new(restaurante: restaurante, acessos: quantidade, arrecadacao: valor)
    end

    # Monta os totais de uma refeição, com o seu horário.
    #
    # Argumentos:: +codigo+ (String): código do TipoRefeicao; +nome+ (String): nome exibido;
    #              +totais+ (Hash): resultado de #totais_por, indexado pelo código da refeição.
    # Retorno:: Turno (zerado quando a refeição não teve acessos).
    # Efeitos colaterais:: consulta o banco na primeira chamada, para ler os horários.
    def montar_turno(codigo, nome, totais)
      quantidade, valor = totais.fetch(codigo, SEM_ACESSOS)
      Turno.new(codigo: codigo, nome: nome, acessos: quantidade, arrecadacao: valor,
                horario: horarios_das_refeicoes[codigo])
    end

    # Soma, por método de pagamento, o valor das recargas confirmadas consumido nos acessos.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash { método (String) => valor (BigDecimal) }, só com os métodos usados.
    # Efeitos colaterais:: consulta o banco.
    def valores_liquidados
      RateioConsumo.where(movimentacao_saldo_id: acessos.select("movimentacao_saldos.id"))
                   .joins(recarga: :pagamentos).where(pagamentos: { status: "confirmado" })
                   .group("pagamentos.metodo").sum("rateio_consumos.valor")
    end

    # Monta a liquidação de um método de pagamento.
    #
    # Argumentos:: +metodo+ (String): código do método; +nome+ (String): nome exibido;
    #              +valor+ (BigDecimal): valor liquidado no método.
    # Retorno:: Liquidacao, com o percentual sobre a arrecadação.
    # Efeitos colaterais:: nenhum.
    def montar_liquidacao(metodo, nome, valor)
      Liquidacao.new(metodo: metodo, nome: nome, valor: valor, percentual: percentual_de(valor))
    end

    # Calcula o horário de cada refeição na unidade: do início mais cedo ao fim mais tarde entre
    # os serviços cadastrados nos restaurantes.
    #
    # Argumentos:: nenhum.
    # Retorno:: Hash { código da refeição => "11:00 – 14:30" }; refeição sem serviço não aparece.
    # Efeitos colaterais:: consulta o banco na primeira chamada e guarda o resultado.
    def horarios_das_refeicoes
      @horarios_das_refeicoes ||= ServicoRefeicao.joins(:tipo_refeicao).where(restaurante: restaurantes)
                                                 .pluck("tipo_refeicoes.codigo", :inicio, :fim)
                                                 .group_by(&:first)
                                                 .transform_values { |servicos| faixa_de_horario(servicos) }
    end

    # Resume os horários dos serviços de uma refeição numa única faixa.
    #
    # Argumentos:: +servicos+ (Array de [código, início, fim]): serviços da mesma refeição.
    # Retorno:: String, como "11:00 – 14:30".
    # Efeitos colaterais:: nenhum.
    def faixa_de_horario(servicos)
      inicio = servicos.map { |servico| servico[1] }.min
      fim = servicos.map { |servico| servico[2] }.max
      "#{inicio.strftime('%H:%M')} – #{fim.strftime('%H:%M')}"
    end

    # Monta a consulta das catracas dos restaurantes da unidade.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de Catraca.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é usada).
    def catracas_da_unidade
      Catraca.joins(piso: :restaurante).where(restaurantes: { unidade_gestora_id: unidade&.id })
    end

    # Monta a consulta dos acessos realizados (com débito) na data contábil, na unidade e no
    # turno escolhidos.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é usada).
    def acessos
      turno == TURNO_TODOS ? acessos_do_dia : acessos_do_dia.where(servico_refeicao_id: servicos_do_turno)
    end

    # Monta a consulta dos acessos realizados na data contábil e na unidade, em qualquer turno.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é usada).
    def acessos_do_dia
      RegistroAcesso.realizado.joins(:movimentacao_saldo, configuracao_ponto_acesso: :restaurante)
                    .where(restaurantes: { unidade_gestora_id: unidade&.id })
                    .where(passagem_em: data.in_time_zone.all_day)
    end

    # Monta a subconsulta dos serviços de refeição do turno filtrado.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation com os ids de ServicoRefeicao do turno.
    # Efeitos colaterais:: nenhum (a consulta só roda quando é usada).
    def servicos_do_turno
      ServicoRefeicao.joins(:tipo_refeicao).where(tipo_refeicoes: { codigo: turno }).select(:id)
    end

    # Calcula quanto um valor representa da arrecadação global.
    #
    # Argumentos:: +valor+ (BigDecimal): parte da arrecadação.
    # Retorno:: Integer de 0 a 100, arredondado; 0 quando não há arrecadação.
    # Efeitos colaterais:: consulta o banco se #linhas ainda não foi chamado.
    def percentual_de(valor)
      total = arrecadacao_global
      total.zero? ? 0 : (valor * 100 / total).round
    end

    # Converte o texto da data contábil do filtro.
    #
    # Argumentos:: +texto+ (String ou nil): data no formato ISO ("2025-10-24").
    # Retorno:: Date do texto; a data de hoje quando o texto não é uma data.
    # Efeitos colaterais:: nenhum.
    def interpretar_data(texto)
      Date.iso8601(texto.to_s)
    rescue Date::Error
      agora.to_date
    end
  end
end
