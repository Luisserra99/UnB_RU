# Apoio aos testes da F12 (Tarsila): cria um acesso realizado numa catraca específica, com débito.
module AuditoriaAcessosHelpers
  def acesso_na_catraca(catraca, em:, referencia:, estudante: nil, valor: "4.50")
    estudante ||= create(:usuario_estudante).estudante
    ponto = ConfiguracaoPontoAcesso.find_by(catraca: catraca) || create(:configuracao_ponto_acesso, catraca: catraca)
    registro = create(:registro_acesso, configuracao_ponto_acesso: ponto, estudante: estudante,
                                        referencia_evento: referencia, lido_em: em - 2.seconds,
                                        liberado_em: em - 2.seconds, passagem_em: em, bloqueado_em: em)
    create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, registro_acesso: registro,
                                                  valor: -BigDecimal(valor), ocorrida_em: em)
    registro
  end
end

RSpec.configure do |config|
  config.include AuditoriaAcessosHelpers
end
