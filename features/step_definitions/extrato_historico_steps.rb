# Passos de features/extrato_historico.feature (F03) — responsável: Luis.
# Helpers globais com prefixo `extrato_` para não colidir com os passos de outras features.

EXTRATO_MSG_VAZIO = "Não há histórico disponível. Você ainda não possui lançamentos.".freeze

Dado("que o usuário está autenticado") do
  @estudante_usuario = login_estudante
end

Dado("possui movimentações e refeições registradas") do
  estudante = @estudante_usuario.estudante
  @extrato_recarga = create(:movimentacao_saldo, :credito_recarga, estudante: estudante,
                                                                   valor: BigDecimal("22.50"),
                                                                   ocorrida_em: 2.days.ago.change(hour: 10))
  @extrato_refeicao = registrar_refeicao(estudante, em: 1.day.ago.change(hour: 12, min: 15))
end

Dado("não possui nenhuma movimentação ou refeição registrada") do
  expect(@estudante_usuario.estudante.movimentacoes_saldo).to be_empty
end

Quando("ele acessa seu extrato e histórico") do
  visit extrato_path
end

Quando("ele tenta acessar o extrato e histórico de outro usuário") do
  @extrato_outro = create(:usuario_estudante, saldo: 9).estudante
  visit extrato_estudante_path(@extrato_outro)
end

Então("o sistema exibe o saldo atual, as movimentações e os acessos registrados") do
  expect(page).to have_css("h1", text: "Extrato e Histórico de Refeições")
  expect(page).to have_css("#saldo-atual", text: formatar_reais(BigDecimal("18.00")))

  within("#movimentacoes") do
    expect(page).to have_content("Recarga de Saldo")
    expect(page).to have_content(formatar_reais(BigDecimal("22.50")))
    expect(page).to have_content("Refeição")
  end

  momento = @extrato_refeicao.ocorrida_em.in_time_zone
  within("#historico-refeicoes") do
    expect(page).to have_content(I18n.l(momento.to_date))
    expect(page).to have_content(momento.strftime("%H:%M"))
    expect(page).to have_content(Extratos::Consulta::REFEICAO_SEM_TIPO)
  end
end

Então("o sistema exibe uma mensagem informando que não há histórico disponível") do
  expect(page).to have_content(EXTRATO_MSG_VAZIO)
  expect(page).to have_no_css("#movimentacoes")
  expect(page).to have_css("#saldo-atual", text: formatar_reais(0))
end

Então("o sistema nega o acesso e exibe uma mensagem de erro") do
  expect(page.status_code).to eq(403)
  expect(page).to have_content(ExtratosController::MSG_ACESSO_NEGADO)
  # Nenhum dado do outro estudante aparece.
  expect(page).to have_no_content(@extrato_outro.matricula)
  expect(page).to have_no_content(formatar_reais(9))
end
