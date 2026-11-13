require "pdf-reader"

# Apoio aos cenários de features/exportacao_pdf_relatorio_operacao.feature (F12) — responsável: Tarsila.
module AuditoriaAcessos
  HORARIOS = { "Café da Manhã" => [ TipoRefeicao::CAFE_DA_MANHA, "06:30", "09:00" ],
               "Almoço" => [ TipoRefeicao::ALMOCO, "11:00", "14:30" ],
               "Jantar" => [ TipoRefeicao::JANTAR, "17:00", "20:00" ] }.freeze
  LINHA_ACESSO = /\AA\d{3} /

  def aud_momento(texto)
    Time.zone.strptime(texto, "%d/%m/%Y %H:%M")
  end

  def aud_data_iso(texto)
    Date.strptime(texto, "%d/%m/%Y").iso8601
  end

  def aud_restaurante(nome)
    Restaurante.find_by(nome: nome) || create(:restaurante, nome: nome, quantidade_pisos: 1)
  end

  def aud_catraca(restaurante, identificacao)
    restaurante.catracas.find_by(identificacao: identificacao) ||
      create(:catraca, piso: restaurante.pisos.first, identificacao: identificacao)
  end

  def aud_ponto(catraca)
    @aud_pontos ||= {}
    @aud_pontos[catraca.id] ||= create(:configuracao_ponto_acesso, catraca: catraca)
  end

  def aud_servico(restaurante, refeicao)
    codigo, inicio, fim = HORARIOS.fetch(refeicao)
    tipo = create(:tipo_refeicao, codigo: codigo, nome: refeicao)
    ServicoRefeicao.find_by(restaurante: restaurante, tipo_refeicao: tipo) ||
      create(:servico_refeicao, restaurante: restaurante, tipo_refeicao: tipo, dia_semana: 4, inicio: inicio, fim: fim)
  end

  def aud_estudante(matricula)
    Estudante.find_by(matricula: matricula) || create(:usuario_estudante, identificacao: matricula).estudante
  end

  # Cria o acesso realizado e o débito correspondente; a referência (A001...) identifica a linha no PDF.
  def aud_registrar(linha)
    restaurante = aud_restaurante(linha["restaurante"])
    estudante = aud_estudante(linha["matricula"])
    momento = aud_momento(linha["data_hora"])
    registro = create(:registro_acesso, configuracao_ponto_acesso: aud_ponto(aud_catraca(restaurante, linha["catraca"])),
                                        estudante: estudante, servico_refeicao: aud_servico(restaurante, linha["refeicao"]),
                                        referencia_evento: linha["acesso"], lido_em: momento - 2.seconds,
                                        liberado_em: momento - 2.seconds, passagem_em: momento, bloqueado_em: momento)
    create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, registro_acesso: registro,
                                                  valor: -reais(linha["valor_debitado"]), ocorrida_em: momento)
  end

  def aud_aplicar_filtros
    click_button "Aplicar filtros"
  end

  def aud_exportar_diretamente(parametros = {})
    page.driver.submit :post, exportar_admin_acessos_relatorio_global_path, parametros
  end

  def aud_baixou_pdf?
    page.response_headers["Content-Type"].to_s.start_with?("application/pdf")
  end

  def aud_paginas_pdf
    expect(aud_baixou_pdf?).to be(true), "esperava um PDF, mas a resposta foi uma página"
    PDF::Reader.new(StringIO.new(page.source.b)).pages.map(&:text)
  end

  def aud_texto_pdf
    aud_paginas_pdf.join("\n").squish
  end

  # Linhas da tabela de acessos no PDF, uma por acesso ("A001 14/10/2026 07:30 ...").
  def aud_linhas_pdf
    aud_paginas_pdf.flat_map(&:lines).map(&:squish).grep(LINHA_ACESSO)
  end

  def aud_referencias_pdf
    aud_linhas_pdf.map { |linha| linha.split.first }
  end

  def aud_lista(texto)
    texto.split(",").map(&:strip)
  end

  def aud_retrato_dos_acessos
    RegistroAcesso.order(:id).map do |registro|
      [ registro.referencia_evento, registro.estado, registro.passagem_em, registro.movimentacao_saldo&.valor ]
    end
  end
end
World(AuditoriaAcessos)
