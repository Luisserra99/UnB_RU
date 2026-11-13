require "pdf-reader"

# Apoio aos cenários de features/exportacao_PDF_historico_estudante.feature (F11) — responsável: Tarsila.
# Cria refeições completas (restaurante, piso, catraca, serviço e passagem) e lê os arquivos baixados.
module ExtratoExportacao
  RESTAURANTE = "RU Darcy Ribeiro".freeze
  # Duas catracas por piso, como nos cenários: Catraca 01 e 02 no Piso 1, 03 e 04 no Piso 2, 05 e 06 no Piso 3.
  CATRACAS_POR_PISO = { 1 => [ "Catraca 01", "Catraca 02" ], 2 => [ "Catraca 03", "Catraca 04" ],
                        3 => [ "Catraca 05", "Catraca 06" ] }.freeze
  SERVICOS = {
    "Café da Manhã" => [ TipoRefeicao::CAFE_DA_MANHA, "06:30", "09:00" ],
    "Almoço" => [ TipoRefeicao::ALMOCO, "11:00", "14:30" ],
    "Jantar" => [ TipoRefeicao::JANTAR, "17:00", "20:00" ]
  }.freeze
  # Páginas abertas pelo passo "abri a página {string}" (F11 e F12).
  PAGINAS = { "Extrato e Histórico de Refeições" => :extrato_path,
              "Relatório Global de Operação" => :admin_acessos_relatorio_global_path }.freeze
  DATA_HORA = /\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}/

  def extrato_momento(texto)
    Time.zone.strptime(texto, "%d/%m/%Y %H:%M")
  end

  def extrato_restaurante
    @extrato_restaurante ||= Restaurante.find_by(nome: RESTAURANTE) || extrato_criar_restaurante
  end

  def extrato_criar_restaurante
    restaurante = create(:restaurante, nome: RESTAURANTE, quantidade_pisos: CATRACAS_POR_PISO.size)
    CATRACAS_POR_PISO.each do |numero, identificacoes|
      piso = restaurante.pisos.find_by!(numero: numero)
      identificacoes.each { |identificacao| create(:catraca, piso: piso, identificacao: identificacao) }
    end
    restaurante
  end

  def extrato_ponto_acesso(identificacao)
    @extrato_pontos ||= {}
    @extrato_pontos[identificacao] ||= begin
      catraca = extrato_restaurante.catracas.find_by!(identificacao: identificacao)
      create(:configuracao_ponto_acesso, catraca: catraca)
    end
  end

  def extrato_servico(evento)
    codigo, inicio, fim = SERVICOS.fetch(evento)
    tipo = create(:tipo_refeicao, codigo: codigo, nome: evento)
    ServicoRefeicao.find_by(restaurante: extrato_restaurante, tipo_refeicao: tipo) ||
      create(:servico_refeicao, restaurante: extrato_restaurante, tipo_refeicao: tipo, dia_semana: 1,
                                inicio: inicio, fim: fim)
  end

  def extrato_registrar_refeicao(estudante, evento:, em:, catraca: "Catraca 01", valor: BigDecimal("4.50"))
    registro = create(:registro_acesso, configuracao_ponto_acesso: extrato_ponto_acesso(catraca),
                                        estudante: estudante, servico_refeicao: extrato_servico(evento),
                                        lido_em: em - 2.seconds, liberado_em: em - 2.seconds,
                                        passagem_em: em, bloqueado_em: em)
    create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, registro_acesso: registro,
                                                  valor: -BigDecimal(valor.to_s).abs, ocorrida_em: em)
  end

  def extrato_registrar_recarga(estudante, em:, valor:)
    create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: BigDecimal(valor.to_s).abs,
                                                  ocorrida_em: em)
  end

  # Lançamentos antigos, fora de qualquer período dos filtros, que levam o saldo ao valor do cenário.
  def extrato_ajustar_saldo(estudante, saldo_esperado)
    diferenca = saldo_esperado - estudante.saldo
    antes = 90.days.ago.change(hour: 12)
    if diferenca.positive?
      extrato_registrar_recarga(estudante, em: antes, valor: diferenca)
    elsif diferenca.negative?
      extrato_registrar_refeicao(estudante, evento: "Almoço", em: antes, valor: diferenca.abs)
    end
  end

  def extrato_pagina(titulo)
    send(PAGINAS.fetch(titulo))
  end

  def extrato_baixou?(tipo_mime)
    page.response_headers["Content-Type"].to_s.start_with?(tipo_mime)
  end

  # Texto do PDF baixado, com os espaços normalizados para comparar frases inteiras.
  def extrato_texto_pdf
    expect(extrato_baixou?("application/pdf")).to be(true), "esperava um PDF, mas a resposta foi uma página"
    @extrato_texto_pdf ||= PDF::Reader.new(StringIO.new(page.source.b)).pages.map(&:text).join("\n").squish
  end

  def extrato_linhas_pdf
    PDF::Reader.new(StringIO.new(page.source.b)).pages.flat_map { |pagina| pagina.text.lines }
               .map(&:squish).select { |linha| linha.match?(/\A#{DATA_HORA}/) }
  end

  def extrato_linhas_csv
    expect(extrato_baixou?("text/csv")).to be(true), "esperava um CSV, mas a resposta foi uma página"
    page.source.force_encoding("UTF-8").delete_prefix("﻿").lines.map(&:chomp).drop(1)
  end
end
World(ExtratoExportacao)
