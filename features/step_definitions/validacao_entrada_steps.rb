# F06 — Daniel Dezan Baby, 232046097.
Before("@operacao_catraca") { travel_to Time.zone.local(2026, 11, 9, 12) }

Dado("que o valor da refeição é R$ {dinheiro}") do |valor|
  @valor_refeicao = valor
end
Dado("que o aluno de matrícula {string} está cadastrado") do |matricula|
  @aluno = create(:estudante, matricula: matricula)
  @operador_terminal = create(:funcionario)
  @catraca_terminal = create(:catraca)
  @servico_terminal = create(:servico_refeicao, restaurante: @catraca_terminal.restaurante, dia_semana: Time.current.wday)
  create(:tarifa_refeicao, tipo_refeicao: @servico_terminal.tipo_refeicao, valor: @valor_refeicao)
  fazer_login(@operador_terminal, "senhaCorreta")
  page.driver.submit :post, controle_ponto_acesso_path, restaurante_id: @catraca_terminal.restaurante.id, catraca_id: @catraca_terminal.id
  visit controle_terminal_path
end
Dado("que o aluno {string} possui saldo de R$ {dinheiro}") do |matricula, saldo|
  aluno = Estudante.find_by!(matricula: matricula)
  SaldoInicialFactory.creditar(aluno, saldo)
end
Quando("a identificação {string} é lida na catraca") do |identificacao|
  fill_in "Matrícula do estudante", with: identificacao
  click_button "Ler identificação"
  @leitura = RegistroAcesso.order(:id).last
end
Quando("é verificado que o aluno de identificação {string} possui saldo suficiente") do |_matricula|
  expect(@leitura.saldo_lido).to be >= @leitura.valor_previsto
end
Quando("é verificado que o aluno de identificação {string} não possui saldo suficiente") do |_matricula|
  expect(@leitura.saldo_lido).to be < @leitura.valor_previsto
end
Quando("a catraca é liberada") do
  expect(@leitura).to be_liberado
  expect(page).to have_button("Simular passagem")
end
Quando("o aluno passa pela catraca em {int} segundos") do |segundos|
  travel segundos.seconds
  click_button "Simular passagem"
end
Quando("o aluno não passa pela catraca em até {int} segundos") do |segundos|
  travel (segundos + 1).seconds
  click_button "Verificar tempo limite"
end
Quando("o aluno tenta passar pela catraca após {int} segundos") do |segundos|
  travel segundos.seconds
  click_button "Simular passagem" if @leitura.liberado?
end
Então("a catraca deve ser bloqueada") do
  expect(@leitura.reload).not_to be_liberado
  expect(page).not_to have_button("Simular passagem")
end
Então("a catraca não deve receber o comando de liberação") do
  expect(@leitura.reload.liberado_em).to be_nil
  expect(page).not_to have_button("Simular passagem")
end
Então("o saldo do aluno {string} deve ser R$ {dinheiro}") do |matricula, saldo|
  expect(Estudante.find_by!(matricula: matricula).saldo).to eq(saldo)
end

# Cenários da F05 que atravessam a integração com os registros da F06.
Quando("realiza uma operação de controle registrada em {string} às {string}") do |data, hora|
  momento = Time.zone.strptime("#{data} #{hora}", "%d/%m/%Y %H:%M:%S")
  sessao_ponto.update!(autenticada_em: momento - 1.hour, expira_em: momento + 8.hours)
  travel_to momento
  @registro_operacao = Catracas::Operar.new(sessao_ponto.ponto_acesso_atual).ler(identificacao: "desconhecido", referencia: SecureRandom.uuid)
end
Então("o registro da operação deve identificar o funcionário {string}") do |identificacao|
  expect(@registro_operacao.funcionario.identificacao).to eq(identificacao)
end
Então("deve identificar o restaurante {string} e a catraca {string}") do |nome, identificacao|
  expect(@registro_operacao.restaurante.nome).to eq(nome)
  expect(@registro_operacao.catraca.identificacao).to eq(identificacao)
end
Então("deve identificar a data {string} e a hora {string}") do |data, hora|
  expect(@registro_operacao.lido_em.strftime("%d/%m/%Y %H:%M:%S")).to eq("#{data} #{hora}")
end
Então("os novos registros de operação devem utilizar o novo ponto de acesso") do
  @registro_novo = Catracas::Operar.new(sessao_ponto.ponto_acesso_atual).ler(identificacao: "desconhecido", referencia: SecureRandom.uuid)
  expect(@registro_novo.configuracao_ponto_acesso).to eq(sessao_ponto.ponto_acesso_atual)
end
Então("os registros anteriores devem manter o ponto de acesso em que foram gerados") do
  expect(@ponto_anterior.reload.finalizada_em).to be_present
  expect(@ponto_anterior.catraca.identificacao).to eq("CAT-01")
  expect(@registro_anterior.reload.configuracao_ponto_acesso).to eq(@ponto_anterior)
end
