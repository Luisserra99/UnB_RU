require "pdf-reader"

# Apoio aos testes da F09 (Tarsila): cria acessos realizados com débito e rateio por método de pagamento.
module RelatorioGlobalHelpers
  HORAS = { TipoRefeicao::CAFE_DA_MANHA => [ "06:30", "09:00", 7 ], TipoRefeicao::ALMOCO => [ "11:00", "14:30", 12 ],
            TipoRefeicao::JANTAR => [ "17:00", "20:00", 18 ] }.freeze
  NOMES = { TipoRefeicao::CAFE_DA_MANHA => "Café da Manhã", TipoRefeicao::ALMOCO => "Almoço",
            TipoRefeicao::JANTAR => "Jantar" }.freeze

  # Catraca "online" é a que está em operação: tem um ponto de acesso aberto numa sessão válida.
  def restaurante_com_catraca(unidade, nome, online: true)
    restaurante = create(:restaurante, unidade_gestora: unidade, nome: nome, quantidade_pisos: 1)
    catraca = create(:catraca, piso: restaurante.pisos.first)
    create(:configuracao_ponto_acesso, catraca: catraca) if online
    restaurante
  end

  def recarga_confirmada(estudante, metodo, valor: 1000)
    recarga = create(:recarga, estudante: estudante, valor_unitario: valor)
    create(:pagamento, metodo, recarga: recarga).confirmar!
    recarga.reload
  end

  # Um acesso realizado no restaurante, no turno e no dia informados, pago com a recarga indicada.
  def acesso_realizado(restaurante, turno:, dia:, recarga:, valor: "4.50")
    inicio, fim, hora = HORAS.fetch(turno)
    tipo = create(:tipo_refeicao, codigo: turno, nome: NOMES.fetch(turno))
    servico = ServicoRefeicao.find_by(restaurante: restaurante, tipo_refeicao: tipo) ||
              create(:servico_refeicao, restaurante: restaurante, tipo_refeicao: tipo, dia_semana: 5,
                                        inicio: inicio, fim: fim)
    ponto = ConfiguracaoPontoAcesso.find_by(restaurante: restaurante) ||
            create(:configuracao_ponto_acesso, catraca: restaurante.catracas.first)
    momento = Time.zone.local(dia.year, dia.month, dia.day, hora, 15)
    registro = create(:registro_acesso, configuracao_ponto_acesso: ponto, estudante: recarga.estudante,
                                        servico_refeicao: servico, lido_em: momento - 2.seconds,
                                        liberado_em: momento - 2.seconds, passagem_em: momento, bloqueado_em: momento)
    debito = create(:movimentacao_saldo, :debito_refeicao, estudante: recarga.estudante, registro_acesso: registro,
                                                           valor: -BigDecimal(valor), ocorrida_em: momento)
    RateioConsumo.create!(movimentacao_saldo: debito, recarga: recarga, valor: BigDecimal(valor))
    registro
  end

  def texto_de_pdf(conteudo)
    PDF::Reader.new(StringIO.new(conteudo)).pages.map(&:text).join("\n").squish
  end
end

RSpec.configure do |config|
  config.include RelatorioGlobalHelpers
end
