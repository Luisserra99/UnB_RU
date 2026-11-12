require "pdf-reader"

# Apoio aos testes da F11 (Tarsila): cria refeições com restaurante, catraca e tipo definidos.
module ExtratoExportacaoHelpers
  def tipo_refeicao_de(codigo, nome)
    create(:tipo_refeicao, codigo: codigo, nome: nome)
  end

  def refeicao_do_extrato(estudante, em:, ponto:, tipo: nil, valor: "4.50")
    servico = tipo && (ServicoRefeicao.find_by(restaurante: ponto.restaurante, tipo_refeicao: tipo) ||
                       create(:servico_refeicao, restaurante: ponto.restaurante, tipo_refeicao: tipo,
                                                 dia_semana: TipoRefeicao::CODIGOS.index(tipo.codigo),
                                                 inicio: "11:00", fim: "14:30"))
    registro = create(:registro_acesso, configuracao_ponto_acesso: ponto, estudante: estudante,
                                        servico_refeicao: servico, lido_em: em - 2.seconds,
                                        liberado_em: em - 2.seconds, passagem_em: em, bloqueado_em: em)
    create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, registro_acesso: registro,
                                                  valor: -BigDecimal(valor), ocorrida_em: em)
  end

  def recarga_do_extrato(estudante, em:, valor: "45.00")
    create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: BigDecimal(valor), ocorrida_em: em)
  end

  def texto_do_pdf(conteudo)
    PDF::Reader.new(StringIO.new(conteudo)).pages.map(&:text).join("\n").squish
  end
end

RSpec.configure do |config|
  config.include ExtratoExportacaoHelpers
end
