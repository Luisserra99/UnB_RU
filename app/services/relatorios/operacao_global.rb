# F09 — Relatório Global de Operação (responsável: Tarsila).
# Consolida os acessos realizados nos restaurantes de uma unidade gestora em uma data contábil,
# com filtro opcional de turno. A tela, o CSV e o PDF usam este mesmo objeto.
#
# A arrecadação é a soma dos valores realmente debitados em cada acesso (MovimentacaoSaldo),
# e não "acessos x tarifa": assim o café da manhã entra com a tarifa que foi cobrada.
module Relatorios
  class OperacaoGlobal
    TURNO_TODOS = "todos".freeze
    TURNOS = {
      TURNO_TODOS => "Todos os Turnos (Café, Almoço, Jantar)",
      TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã",
      TipoRefeicao::ALMOCO => "Almoço",
      TipoRefeicao::JANTAR => "Jantar"
    }.freeze
    METODOS = {
      "pix" => "PIX Institucional Instantâneo",
      "cartao_credito" => "Cartão de Crédito / Débito"
    }.freeze
    FORMATO_DATA = "%d/%m/%Y".freeze

    Linha = Struct.new(:restaurante, :acessos, :arrecadacao, keyword_init: true)
    Liquidacao = Struct.new(:metodo, :nome, :valor, :percentual, keyword_init: true)
    Turno = Struct.new(:codigo, :nome, :acessos, :arrecadacao, :horario, keyword_init: true)

    attr_reader :data, :turno, :unidade, :agora

    # Valores fora das listas permitidas voltam ao padrão: os parâmetros vêm do navegador.
    def initialize(filtros = {}, agora: Time.current)
      filtros = filtros.to_h.with_indifferent_access
      @agora = agora.in_time_zone
      @data = interpretar_data(filtros[:data])
      @turno = TURNOS.key?(filtros[:turno]) ? filtros[:turno] : TURNO_TODOS
      @unidade = unidades.find { |unidade| unidade.id.to_s == filtros[:unidade_id].to_s } ||
                 unidades.find { |unidade| unidade.nome == UnidadeGestora::NOME_PADRAO } || unidades.first
    end

    # Uma linha por restaurante da unidade, na ordem da numeração, inclusive os sem acessos (RN09.7 e RN09.8).
    def linhas
      @linhas ||= begin
        totais = acessos.group("configuracao_ponto_acessos.restaurante_id")
                        .pluck(Arel.sql("configuracao_ponto_acessos.restaurante_id"), Arel.sql("COUNT(*)"),
                               Arel.sql("SUM(-movimentacao_saldos.valor)"))
                        .to_h { |id, quantidade, valor| [ id, [ quantidade, valor.to_d ] ] }
        restaurantes.map do |restaurante|
          quantidade, valor = totais.fetch(restaurante.id, [ 0, BigDecimal("0") ])
          Linha.new(restaurante: restaurante, acessos: quantidade, arrecadacao: valor)
        end
      end
    end

    def total_acessos
      linhas.sum(&:acessos)
    end

    def arrecadacao_global
      linhas.sum(BigDecimal("0"), &:arrecadacao)
    end

    def vazio?
      total_acessos.zero?
    end

    # Valor liquidado por método de pagamento das recargas que custearam os acessos (RN09.10).
    def liquidacoes
      @liquidacoes ||= begin
        valores = RateioConsumo.where(movimentacao_saldo_id: acessos.select("movimentacao_saldos.id"))
                               .joins(recarga: :pagamentos).where(pagamentos: { status: "confirmado" })
                               .group("pagamentos.metodo").sum("rateio_consumos.valor")
        METODOS.map do |metodo, nome|
          valor = valores.fetch(metodo, 0).to_d
          Liquidacao.new(metodo: metodo, nome: nome, valor: valor, percentual: percentual_de(valor))
        end
      end
    end

    def soma_liquidacoes
      liquidacoes.sum(BigDecimal("0"), &:valor)
    end

    # Diferença entre o arrecadado e o liquidado: deve ser zero (RN09.11).
    def divergencia_contabil
      arrecadacao_global - soma_liquidacoes
    end

    def ticket_medio
      vazio? ? BigDecimal("0") : (arrecadacao_global / total_acessos).round(2)
    end

    def transacoes_validadas
      total_acessos
    end

    def distribuicao_por_refeicao
      @distribuicao_por_refeicao ||= begin
        totais = acessos.joins(servico_refeicao: :tipo_refeicao).group("tipo_refeicoes.codigo")
                        .pluck(Arel.sql("tipo_refeicoes.codigo"), Arel.sql("COUNT(*)"),
                               Arel.sql("SUM(-movimentacao_saldos.valor)"))
                        .to_h { |codigo, quantidade, valor| [ codigo, [ quantidade, valor.to_d ] ] }
        TURNOS.except(TURNO_TODOS).map do |codigo, nome|
          quantidade, valor = totais.fetch(codigo, [ 0, BigDecimal("0") ])
          Turno.new(codigo: codigo, nome: nome, acessos: quantidade, arrecadacao: valor,
                    horario: horarios_das_refeicoes[codigo])
        end
      end
    end

    # Catraca online = catraca ativa que está em operação agora: tem um ponto de acesso confirmado
    # por um funcionário com sessão válida (F05). É o mesmo critério de Catraca#em_operacao?.
    def catracas_online
      catracas_da_unidade.where(ativa: true)
                         .where(id: ConfiguracaoPontoAcesso.em_sessoes_validas.select(:catraca_id)).count
    end

    def catracas_cadastradas
      catracas_da_unidade.count
    end

    def hoje?
      data == agora.to_date
    end

    def data_nome
      hoje? ? "Hoje (#{data.strftime(FORMATO_DATA)})" : data.strftime(FORMATO_DATA)
    end

    def turno_nome
      TURNOS.fetch(turno)
    end

    def unidade_nome
      unidade&.nome || "Nenhuma unidade gestora cadastrada"
    end

    def opcoes_turno
      TURNOS.map { |codigo, nome| [ nome, codigo ] }
    end

    def opcoes_unidade
      unidades.map { |unidade| [ unidade.nome, unidade.id ] }
    end

    # Filtros na forma em que são reenviados pelo formulário e gravados em ExportacaoRelatorio.
    def filtros
      { "data" => data.iso8601, "turno" => turno, "unidade_id" => unidade&.id }
    end

    private

    def unidades
      @unidades ||= UnidadeGestora.ativas.order(:nome).to_a
    end

    def restaurantes
      @restaurantes ||= unidade ? unidade.restaurantes.ativos.order(:numero).to_a : []
    end

    # Horário de cada refeição na unidade ("11:00 – 14:30"): do início mais cedo ao fim mais tarde
    # entre os serviços cadastrados nos restaurantes. Refeição sem serviço fica sem horário.
    def horarios_das_refeicoes
      @horarios_das_refeicoes ||= ServicoRefeicao.joins(:tipo_refeicao).where(restaurante: restaurantes)
                                                 .pluck("tipo_refeicoes.codigo", :inicio, :fim)
                                                 .group_by(&:first).transform_values do |servicos|
        inicio = servicos.map { |servico| servico[1] }.min
        fim = servicos.map { |servico| servico[2] }.max
        "#{inicio.strftime('%H:%M')} – #{fim.strftime('%H:%M')}"
      end
    end

    def catracas_da_unidade
      Catraca.joins(piso: :restaurante).where(restaurantes: { unidade_gestora_id: unidade&.id })
    end

    # Acessos realizados (com débito) na data contábil, na unidade e no turno escolhidos.
    def acessos
      consulta = RegistroAcesso.realizado.joins(:movimentacao_saldo, configuracao_ponto_acesso: :restaurante)
                               .where(restaurantes: { unidade_gestora_id: unidade&.id })
                               .where(passagem_em: data.in_time_zone.all_day)
      return consulta if turno == TURNO_TODOS

      consulta.where(servico_refeicao_id: ServicoRefeicao.joins(:tipo_refeicao)
                                                        .where(tipo_refeicoes: { codigo: turno }).select(:id))
    end

    def percentual_de(valor)
      total = arrecadacao_global
      total.zero? ? 0 : (valor * 100 / total).round
    end

    def interpretar_data(texto)
      Date.iso8601(texto.to_s)
    rescue Date::Error
      agora.to_date
    end
  end
end
