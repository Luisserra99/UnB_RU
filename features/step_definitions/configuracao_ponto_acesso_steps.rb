# F05 — Daniel Dezan Baby, 232046097. Fluxos via HTTP/Capybara e persistência real.
def sessao_ponto
  @usuario.sessoes.order(:id).last
end

def enviar_ponto(nome, identificacao)
  r = Restaurante.find_by(nome: nome)
  c = Catraca.find_by(identificacao: identificacao)
  page.driver.submit :post, controle_ponto_acesso_path,
    restaurante_id: (nome.blank? ? "" : r&.id || 0), catraca_id: (identificacao.blank? ? "" : c&.id || 0)
end

Dado("que o funcionário de identificação {string} está cadastrado") do |identificacao|
  @usuario = create(:funcionario, identificacao: identificacao)
end
Dado("que os restaurantes {string} e {string} estão cadastrados e ativos") do |a, b|
  [ a, b ].each { |nome| create(:restaurante, nome: nome) }
end
Dado("que a catraca {string} está cadastrada e ativa no restaurante {string}") do |identificacao, nome|
  create(:catraca, piso: Restaurante.find_by!(nome: nome).pisos.first, identificacao: identificacao)
end
Quando("o funcionário {string} realiza o login com sucesso") do |identificacao|
  fazer_login(Usuario.find_by!(identificacao: identificacao), "senhaCorreta")
end
Dado("que o funcionário {string} possui uma sessão autenticada ativa") do |identificacao|
  step "o funcionário \"#{identificacao}\" realiza o login com sucesso"
end
Quando("o funcionário realiza um novo login com sucesso") do
  fazer_login(@usuario, "senhaCorreta")
end
Então("o sistema deve solicitar a seleção de um restaurante e de uma catraca") do
  expect(page).to have_content("Escolha do restaurante e da catraca")
end
Então("deve apresentar os restaurantes cadastrados e ativos") do
  Restaurante.ativos.each { |r| expect(page).to have_select("Restaurante", with_options: [ r.nome ]) }
end
Então("o funcionário ainda não deve possuir um ponto de acesso configurado na sessão") do
  expect(sessao_ponto.ponto_acesso_atual).to be_nil
end
Então("as operações que dependem do ponto de acesso devem permanecer indisponíveis") do
  expect(sessao_ponto&.ponto_acesso_atual&.disponivel?).to be_falsey
end
Quando("seleciona o restaurante {string}") do |nome|
  select nome, from: "Restaurante"
  click_button "Selecionar restaurante"
end
Dado("selecionou o restaurante {string}") { |nome| step "seleciona o restaurante \"#{nome}\"" }
Dado("selecionou a catraca {string}") do |identificacao|
  select find("#catraca_id option", text: identificacao).text, from: "Catraca"
end
Quando("confirma o ponto de acesso") { click_button "Confirmar ponto de acesso" }
Quando("confirma o ponto de acesso em {string} às {string}") do |data, hora|
  # Cria o login nesse mesmo relógio: não se retrocede uma sessão já autenticada.
  momento = Time.zone.strptime("#{data} #{hora}", "%d/%m/%Y %H:%M:%S")
  sessao_ponto.update!(autenticada_em: momento, expira_em: momento + 8.hours)
  travel_to(momento)
  click_button "Confirmar ponto de acesso"
end
Então("a sessão deve ter como ponto de acesso o restaurante {string} e a catraca {string}") do |nome, identificacao|
  ponto = sessao_ponto.ponto_acesso_atual
  expect(ponto.restaurante.nome).to eq(nome)
  expect(ponto.catraca.identificacao).to eq(identificacao)
end
Então("as operações de controle devem utilizar as regras do restaurante {string}") do |nome|
  expect(sessao_ponto.configuracoes_ponto_acesso.abertas.last.restaurante.nome).to eq(nome)
end
Então("deve ser registrado o evento de configuração do ponto de acesso com:") do |tabela|
  ponto = sessao_ponto.configuracoes_ponto_acesso.last
  esperado = tabela.hashes.first
  expect(ponto.usuario.identificacao).to eq(esperado["funcionario"])
  expect(ponto.restaurante.nome).to eq(esperado["restaurante"])
  expect(ponto.catraca.identificacao).to eq(esperado["catraca"])
  expect(ponto.confirmada_em.strftime("%d/%m/%Y %H:%M:%S")).to eq("#{esperado['data']} #{esperado['hora']}")
end
Dado("configurou o restaurante {string} e a catraca {string} como ponto de acesso") do |nome, identificacao|
  enviar_ponto(nome, identificacao)
  @ponto_anterior = sessao_ponto.ponto_acesso_atual
end
Dado("iniciou a alteração do ponto de acesso") do
  @registro_anterior = Catracas::Operar.new(sessao_ponto.ponto_acesso_atual).ler(identificacao: "desconhecido", referencia: SecureRandom.uuid)
  click_button "Alterar ponto de acesso"
end
Então("a seleção da catraca {string} deve ser removida do formulário de alteração") do |identificacao|
  expect(find("#catraca_id").value).to eq("")
end
Então("o ponto de acesso confirmado deve continuar sendo o restaurante {string} e a catraca {string} até uma nova confirmação válida") do |nome, identificacao|
  step "a sessão deve ter como ponto de acesso o restaurante \"#{nome}\" e a catraca \"#{identificacao}\""
end
Então("as operações que dependem do ponto de acesso devem permanecer indisponíveis enquanto a reconfiguração estiver pendente") do
  expect(sessao_ponto).to be_ponto_acesso_pendente
  expect(sessao_ponto.ponto_acesso_atual).not_to be_disponivel
end
Quando("seleciona a catraca {string} e confirma o ponto de acesso") do |identificacao|
  step "selecionou a catraca \"#{identificacao}\""
  click_button "Confirmar ponto de acesso"
end
Então("a reconfiguração deve ser concluída e as operações do novo ponto de acesso devem ficar disponíveis") do
  expect(sessao_ponto).not_to be_ponto_acesso_pendente
  expect(sessao_ponto.ponto_acesso_atual).to be_disponivel
end
Dado("ainda não configurou um ponto de acesso") { expect(sessao_ponto.ponto_acesso_atual).to be_nil }
Quando("tenta confirmar o restaurante {string} e a catraca {string}") { |r, c| enviar_ponto(r, c) }
Então("nenhum ponto de acesso deve ser configurado na sessão") { expect(sessao_ponto&.ponto_acesso_atual).to be_nil }
Quando("tenta confirmar a catraca {string}") do |c|
  enviar_ponto("RU Darcy Ribeiro", c)
end
Dado("o cadastro {string} está {string}") do |nome, situacao|
  if situacao == "inativo"
    if nome.start_with?("CAT-")
      c = Catraca.find_by(identificacao: nome) || create(:catraca, identificacao: nome, piso: Restaurante.find_by!(nome: "RU Darcy Ribeiro").pisos.first)
      c.update!(ativa: false)
    else
      Restaurante.find_by!(nome: nome).update!(ativo: false)
    end
  end
end
Quando("tenta confirmar o restaurante {string} e a catraca {string} como novo ponto de acesso") { |r, c| enviar_ponto(r, c) }
Então("o ponto de acesso confirmado da sessão deve continuar sendo o restaurante {string} e a catraca {string}") do |r, c|
  step "a sessão deve ter como ponto de acesso o restaurante \"#{r}\" e a catraca \"#{c}\""
end
Então("a reconfiguração deve permanecer pendente") { expect(sessao_ponto).to be_ponto_acesso_pendente }
Então("as operações que dependem do ponto de acesso devem permanecer indisponíveis até uma nova confirmação válida") do
  expect(sessao_ponto.ponto_acesso_atual).not_to be_disponivel
end
Então("a tentativa não deve ser registrada como uma configuração concluída") do
  expect(sessao_ponto.configuracoes_ponto_acesso.count).to eq(1)
end
Dado("a catraca {string} deixou de estar disponível após a seleção") { |c| Catraca.find_by!(identificacao: c).update!(ativa: false) }
Dado("todos os restaurantes cadastrados foram desativados") { Restaurante.update_all(ativo: false) }
Quando("acessa a seleção de ponto de acesso") { visit controle_root_path }
Dado("todas as catracas do restaurante {string} foram desativadas") { |r| Restaurante.find_by!(nome: r).catracas.update_all(ativa: false) }
Então("a confirmação do ponto de acesso deve permanecer indisponível") { expect(page).to have_button("Confirmar ponto de acesso", disabled: true) }
Dado("que o funcionário {string} não possui uma sessão autenticada ativa") { |_i| expect(SessaoAutenticacao.ativas).to be_empty }
Quando("tenta configurar o restaurante {string} e a catraca {string}") { |r, c| enviar_ponto(r, c) }
Então("o sistema deve solicitar o login do funcionário") { esperar_tela_de_login }
Então("nenhum ponto de acesso deve ser configurado") { expect(ConfiguracaoPontoAcesso.count).to eq(0) }
Quando("a sessão é encerrada por {string}") do |motivo|
  if motivo == "logout"
    click_button "Sair"
  else
    sessao_ponto.update!(expira_em: 1.second.ago)
    visit controle_root_path
  end
end
Então("o ponto de acesso deve ser removido da sessão") { expect(sessao_ponto.ponto_acesso_atual).to be_nil }
Então("o sistema deve exigir autenticação para realizar operações de controle") { esperar_tela_de_login }
Então("o sistema deve solicitar novamente a seleção de restaurante e catraca") do
  expect(page).to have_content("Escolha do restaurante e da catraca")
end
Então("as operações que dependem do ponto de acesso devem permanecer indisponíveis até a nova confirmação") do
  expect(sessao_ponto.ponto_acesso_atual).to be_nil
end

Dado("selecionou o restaurante {string} e a catraca {string}") do |r, c|
  step %(seleciona o restaurante "#{r}")
  step %(selecionou a catraca "#{c}")
end
After { travel_back }
