# Passos de features/gestao_restaurante_catracas.feature (F08) — responsável: Leonardo.
require "cucumber/rspec/doubles"

def cadastrar_restaurante_existente(nome, pisos:, capacidade:)
  unidade = UnidadeGestora.find_or_create_by!(nome: UnidadeGestora::NOME_PADRAO)
  Restaurante.criar_com_pisos!(unidade_gestora: unidade, nome: nome, quantidade_pisos: pisos,
                               capacidade_refeicoes_hora: capacidade)
end

def linha_do_restaurante(nome)
  within("#lista-restaurantes") { find("tr", text: nome) }
end

def linha_da_catraca(identificacao)
  within("#lista-catracas") { find("tr", text: identificacao) }
end

def numero_do_piso(nome_piso)
  nome_piso.delete_prefix("Piso ")
end

def associar_catraca(identificacao, nome_piso, nome_restaurante)
  restaurante = Restaurante.find_by(nome: nome_restaurante)
  if restaurante
    visit new_admin_catraca_path
    select nome_restaurante, from: "Restaurante"
    fill_in "Número do piso", with: numero_do_piso(nome_piso)
    fill_in "Identificação da catraca", with: identificacao
    click_button "Salvar"
  else
    # O select só oferece restaurantes existentes; aqui é testada a proteção do servidor.
    page.driver.submit :post, admin_catracas_path,
                       catraca: { identificacao: identificacao, piso_numero: numero_do_piso(nome_piso), restaurante_id: 0 }
  end
end

def abrir_remocao_da_catraca(identificacao)
  visit admin_restaurantes_path
  linha_da_catraca(identificacao).click_link("Remover")
end

# --- Dado ---

Dado("que estou logado como administrador") do
  administrador = create(:administrador, password: "senhaCorreta")
  fazer_login(administrador, "senhaCorreta")
end

Dado("estou na página {string}") do |titulo|
  visit admin_restaurantes_path
  expect(page).to have_css("h1", text: titulo)
end

Dado("o restaurante {string} está cadastrado com {int} pisos e capacidade de {int} refeições por hora") do |nome, pisos, capacidade|
  cadastrar_restaurante_existente(nome, pisos: pisos, capacidade: capacidade)
end

Dado("a catraca {string} está associada ao {string} do restaurante {string}") do |identificacao, nome_piso, nome_restaurante|
  piso = Restaurante.find_by!(nome: nome_restaurante).pisos.find_by!(numero: numero_do_piso(nome_piso))
  piso.catracas.create!(identificacao: identificacao)
end

Dado("que o restaurante {string} está cadastrado sem catracas associadas") do |nome|
  cadastrar_restaurante_existente(nome, pisos: 1, capacidade: 400)
end

Dado("que eu associei a catraca {string} ao {string} do restaurante {string}") do |identificacao, nome_piso, nome_restaurante|
  associar_catraca(identificacao, nome_piso, nome_restaurante)
  expect(page).to have_content("Catraca cadastrada com sucesso")
end

Dado("que eu removi a catraca {string}") do |identificacao|
  abrir_remocao_da_catraca(identificacao)
  click_button "Confirmar remoção"
  expect(page).to have_content("Catraca removida com sucesso")
end

# Configuração persistida, usando a integração real da F05.
Dado("que a catraca {string} está selecionada por um funcionário na aplicação de controle") do |identificacao|
  catraca = Catraca.find_by!(identificacao: identificacao)
  sessao, = SessaoAutenticacao.iniciar!(create(:funcionario))
  PontosAcesso::Configurar.call(sessao: sessao, restaurante_id: catraca.restaurante.id, catraca_id: catraca.id)
end

# --- Quando ---

Quando(/^eu cadastro o restaurante "([^"]*)" com (-?\d+) piso(?:s|\(s\))? e capacidade de (-?\d+) refeições por hora$/) do |nome, pisos, capacidade|
  visit new_admin_restaurante_path
  fill_in "Nome do restaurante", with: nome
  fill_in "Quantidade de pisos", with: pisos
  fill_in "Capacidade (refeições por hora)", with: capacidade
  click_button "Salvar"
end

Quando("eu altero a capacidade do restaurante {string} para {int} refeições por hora") do |nome, capacidade|
  visit admin_restaurantes_path
  linha_do_restaurante(nome).click_link("Editar")
  fill_in "Capacidade (refeições por hora)", with: capacidade
  click_button "Salvar"
end

Quando("eu removo o restaurante {string}") do |nome|
  visit admin_restaurantes_path
  linha_do_restaurante(nome).click_link("Remover")
end

Quando("eu removo a catraca {string}") do |identificacao|
  abrir_remocao_da_catraca(identificacao)
end

Quando("confirmo a remoção") do
  click_button "Confirmar remoção"
end

Quando("cancelo a remoção") do
  click_link "Cancelar"
end

Quando("eu associo a catraca {string} ao {string} do restaurante {string}") do |identificacao, nome_piso, nome_restaurante|
  associar_catraca(identificacao, nome_piso, nome_restaurante)
end

Quando("um funcionário abre a lista de catracas do restaurante {string} na aplicação de controle") do |nome|
  click_button "Sair"
  fazer_login(create(:funcionario, password: "senhaCorreta"), "senhaCorreta")
  within("#restaurantes-disponiveis") { find("tr", text: nome).click_link("Ver catracas") }
end

# --- Então ---

Então("deve ser exibida a mensagem {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end

Então("o restaurante {string} deve aparecer na lista de unidades cadastradas") do |nome|
  visit admin_restaurantes_path
  within("#lista-restaurantes") { expect(page).to have_css("tr", text: nome) }
end

Então("o restaurante {string} deve continuar na lista de unidades cadastradas") do |nome|
  visit admin_restaurantes_path
  within("#lista-restaurantes") { expect(page).to have_css("tr", text: nome) }
end

Então("o restaurante {string} não deve aparecer na lista de unidades cadastradas") do |nome|
  visit admin_restaurantes_path
  within("#lista-restaurantes") { expect(page).not_to have_css("tr", text: nome) }
end

Então("o total de restaurantes deve ser {int}") do |total|
  visit admin_restaurantes_path
  expect(page).to have_css("#total-restaurantes", exact_text: "Total de restaurantes: #{total}")
end

Então("o restaurante {string} deve ter capacidade de {int} refeições por hora") do |nome, capacidade|
  # A tabela formata com separador de milhar: 1500 aparece como "1.500".
  expect(linha_do_restaurante(nome)).to have_css("td", exact_text: ActiveSupport::NumberHelper.number_to_delimited(capacidade, delimiter: "."))
end

Então("a catraca {string} deve aparecer no {string} do restaurante {string}") do |identificacao, nome_piso, nome_restaurante|
  visit admin_restaurantes_path
  linha = linha_da_catraca(identificacao)
  expect(linha).to have_css("td", exact_text: nome_piso)
  expect(linha).to have_css("td", exact_text: nome_restaurante)
end

Então("a catraca {string} deve continuar no {string} do restaurante {string}") do |identificacao, nome_piso, nome_restaurante|
  visit admin_restaurantes_path
  linha = linha_da_catraca(identificacao)
  expect(linha).to have_css("td", exact_text: nome_piso)
  expect(linha).to have_css("td", exact_text: nome_restaurante)
end

Então("o total de catracas cadastradas deve ser {int}") do |total|
  visit admin_restaurantes_path
  expect(page).to have_css("#total-catracas", exact_text: "Total de catracas cadastradas: #{total}")
end

Então("a catraca {string} deve estar disponível para seleção") do |identificacao|
  within("#catracas-disponiveis") { expect(page).to have_content(identificacao) }
end

Então("a catraca {string} não deve estar disponível para seleção") do |identificacao|
  within("#catracas-disponiveis") { expect(page).not_to have_content(identificacao) }
end
