require "pdf-reader"

# Apoio aos cenários de features/relatorio_global_acesso.feature (F09) — responsável: Tarsila.
# Os cenários trabalham com milhares de acessos, então os registros são gravados em lote
# (insert_all), sem passar pelas factories uma a uma.
module RelatorioGlobal
  UNIDADE = "Campus Darcy Ribeiro".freeze
  TURNOS = {
    "Café da Manhã" => { codigo: TipoRefeicao::CAFE_DA_MANHA, inicio: "06:30", fim: "09:00", hora: [ 7, 30 ] },
    "Almoço" => { codigo: TipoRefeicao::ALMOCO, inicio: "11:00", fim: "14:30", hora: [ 12, 0 ] },
    "Jantar" => { codigo: TipoRefeicao::JANTAR, inicio: "17:00", fim: "20:00", hora: [ 18, 30 ] }
  }.freeze
  METODOS = { "PIX Institucional Instantâneo" => :pix, "Cartão de Crédito / Débito" => :cartao_credito }.freeze
  TAMANHO_LOTE = 500
  CREDITO_DAS_RECARGAS = 500_000

  def rg_data(texto)
    Date.strptime(texto, "%d/%m/%Y")
  end

  # "2.100" -> 2100
  def rg_inteiro(texto)
    texto.to_s.delete(".").to_i
  end

  def rg_unidade
    @rg_unidade ||= UnidadeGestora.find_or_create_by!(nome: UNIDADE)
  end

  def rg_criar_restaurantes(quantidade)
    (1..quantidade).each do |numero|
      restaurante = create(:restaurante, unidade_gestora: rg_unidade, nome: "Restaurante #{numero}", quantidade_pisos: 1)
      create(:catraca, piso: restaurante.pisos.first, identificacao: "Catraca #{format('%02d', numero)}")
      rg_ponto(restaurante) # um funcionário opera a catraca: é isso que a deixa online
    end
  end

  def rg_catracas_online
    Catraca.where(id: ConfiguracaoPontoAcesso.em_sessoes_validas.select(:catraca_id)).count
  end

  # Encerra a operação de `quantidade` catracas, que passam a contar como offline.
  def rg_desligar_catracas(quantidade)
    ConfiguracaoPontoAcesso.abertas.order(:id).last(quantidade).each do |ponto|
      ponto.update!(finalizada_em: Time.current)
    end
  end

  def rg_restaurante(nome)
    Restaurante.find_by!(nome: nome)
  end

  def rg_ponto(restaurante)
    @rg_pontos ||= {}
    @rg_pontos[restaurante.id] ||= create(:configuracao_ponto_acesso, catraca: restaurante.catracas.first)
  end

  def rg_servico(restaurante, turno)
    @rg_servicos ||= {}
    @rg_servicos[[ restaurante.id, turno ]] ||= begin
      dados = TURNOS.fetch(turno)
      tipo = create(:tipo_refeicao, codigo: dados[:codigo], nome: turno)
      create(:servico_refeicao, restaurante: restaurante, tipo_refeicao: tipo, dia_semana: 5,
                                inicio: dados[:inicio], fim: dados[:fim])
    end
  end

  def rg_estudante
    @rg_estudante ||= create(:usuario_estudante).estudante
  end

  # Uma recarga confirmada por método de pagamento, com crédito de sobra para custear os acessos.
  def rg_recarga(metodo)
    @rg_recargas ||= {}
    @rg_recargas[metodo] ||= begin
      recarga = create(:recarga, estudante: rg_estudante, valor_unitario: CREDITO_DAS_RECARGAS)
      create(:pagamento, metodo, recarga: recarga).confirmar!
      recarga.reload
    end
  end

  # Grava `quantidade` acessos realizados, cada um com seu débito e o rateio entre os métodos.
  # `participacoes` é { pix: 0.72, cartao_credito: 0.28 }.
  def rg_registrar_acessos(restaurante:, turno:, data:, quantidade:, valor:, participacoes:)
    return if quantidade.zero?

    momento = Time.zone.local(data.year, data.month, data.day, *TURNOS.fetch(turno)[:hora])
    ponto = rg_ponto(restaurante)
    servico = rg_servico(restaurante, turno)
    @rg_sequencia ||= 0
    quantidade.times.each_slice(TAMANHO_LOTE) do |fatia|
      registros = fatia.map do
        @rg_sequencia += 1
        { configuracao_ponto_acesso_id: ponto.id, estudante_id: rg_estudante.id, servico_refeicao_id: servico.id,
          referencia_evento: "relatorio-global-#{@rg_sequencia}", identificacao_lida: rg_estudante.matricula,
          valor_previsto: valor, estado: "realizado", mensagem: "Boa refeição", lido_em: momento - 2.seconds,
          liberado_em: momento - 2.seconds, passagem_em: momento, bloqueado_em: momento }
      end
      ids_registros = RegistroAcesso.insert_all!(registros, returning: [ :id ]).rows.flatten
      debitos = ids_registros.map do |id|
        { estudante_id: rg_estudante.id, registro_acesso_id: id, natureza: "debito_refeicao", valor: -valor,
          ocorrida_em: momento }
      end
      ids_debitos = MovimentacaoSaldo.insert_all!(debitos, returning: [ :id ]).rows.flatten
      RateioConsumo.insert_all!(ids_debitos.flat_map { |id| rg_rateios(id, valor, participacoes) })
    end
  end

  # Divide o valor do débito entre os métodos; o último recebe o resto, para a soma fechar em centavos.
  def rg_rateios(id_debito, valor, participacoes)
    restante = valor
    metodos = participacoes.select { |_metodo, parte| parte.positive? }.to_a
    metodos.each_with_index.filter_map do |(metodo, parte), indice|
      fatia = indice == metodos.size - 1 ? restante : (valor * parte).round(2)
      restante -= fatia
      { movimentacao_saldo_id: id_debito, recarga_id: rg_recarga(metodo).id, valor: fatia } if fatia.positive?
    end
  end

  def rg_login_administrador
    @rg_administrador = create(:administrador, nome: "Administradora Geral", password: "senhaCorreta")
    fazer_login(@rg_administrador, "senhaCorreta")
  end

  def rg_abrir_relatorio
    visit admin_relatorio_global_path
  end

  def rg_linha_restaurante(nome)
    find("#tabela-consolidacao tbody tr") { |linha| linha.has_css?(".restaurante-nome", text: nome, exact_text: true) }
  end

  # Textos das células de uma linha. Nas células com selo, barra ou legenda, vale só o nome.
  def rg_celulas(linha)
    linha.all("th, td").map do |celula|
      nome = celula.first(".restaurante-nome, .metodo-nome", minimum: 0)
      (nome || celula).text.squish
    end
  end

  def rg_texto_pdf
    expect(page.response_headers["Content-Type"]).to start_with("application/pdf")
    PDF::Reader.new(StringIO.new(page.source.b)).pages.map(&:text).join("\n").squish
  end

  def rg_linhas_csv
    expect(page.response_headers["Content-Type"]).to start_with("text/csv")
    page.source.force_encoding("UTF-8").delete_prefix("﻿").lines.map { |linha| linha.chomp.split(";") }.drop(1)
  end
end
World(RelatorioGlobal)
