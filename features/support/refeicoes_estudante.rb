# Registro de refeições do estudante nos cenários (F03, e depois F11).
# PONTO ÚNICO a trocar quando a F06 (Daniel) existir: hoje cria só o débito em MovimentacaoSaldo;
# depois deve passar pela catraca e criar o RegistroAcesso junto com o débito.
module RefeicoesEstudante
  def registrar_refeicao(estudante, em:, valor: BigDecimal("4.50"))
    FactoryBot.create(:movimentacao_saldo, :debito_refeicao, estudante: estudante,
                                                             valor: -BigDecimal(valor.to_s).abs, ocorrida_em: em)
  end
end
World(RefeicoesEstudante)
