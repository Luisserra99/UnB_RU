# Passos de features/recarga_saldo.feature (F02) — responsável: Luis.
# Helpers globais com prefixo `recarga_` para não colidir com os passos de outras features.

World(ActiveSupport::Testing::TimeHelpers)
After { travel_back }

RECARGA_CAMPOS = {
  "Cafés da Manhã" => "Cafés da Manhã",
  "Almoços/Jantares" => "Almoços/Jantares"
}.freeze

RECARGA_PAGINAS = { "Recarga de Saldo" => :new_recarga_path }.freeze

# "Almoço/Jantar" vale para almoço e jantar (a interface agrupa os dois).
RECARGA_TIPOS_POR_PRECO = {
  "Almoço/Jantar" => [ TipoRefeicao::ALMOCO, TipoRefeicao::JANTAR ],
  "Café da Manhã" => [ TipoRefeicao::CAFE_DA_MANHA ]
}.freeze

RECARGA_IDS_SUBTOTAL = { "Cafés da Manhã" => "#subtotal-cafe", "Almoços/Jantares" => "#subtotal-almoco" }.freeze

def recarga_definir_tarifa(codigo, valor)
  tipo = TipoRefeicao.find_or_create_by!(codigo: codigo) { |t| t.nome = codigo.humanize }
  tarifa = TarifaRefeicao.find_or_initialize_by(tipo_refeicao: tipo, vigente_ate: nil)
  tarifa.vigente_desde ||= Time.zone.local(2000, 1, 1)
  tarifa.update!(valor: valor)
end

def recarga_estudante
  @estudante_usuario.estudante.reload
end

def recarga_preencher_quantidades(quantidades)
  visit new_recarga_path unless page.has_css?("h1", text: "Recarga de Saldo", wait: 0)
  quantidades.each { |campo, qtd| fill_in RECARGA_CAMPOS.fetch(campo), with: qtd }
  click_button "Calcular total"
end

def recarga_clicar_confirmar
  if page.has_button?("Confirmar", disabled: true, wait: 0)
    # O botão está desabilitado na tela; envia o formulário direto para conferir a proteção do servidor.
    formulario = page.find_button("Confirmar", disabled: true).ancestor("form")
    dados = {
      "solicitacao_recarga[quantidade_cafes]" => formulario.find_field("Cafés da Manhã").value,
      "solicitacao_recarga[quantidade_almocos]" => formulario.find_field("Almoços/Jantares").value,
      "solicitacao_recarga[metodo]" => formulario.all(:radio_button, checked: true).first&.value,
      "acao" => "confirmar"
    }
    page.driver.submit :post, recargas_path, dados.compact
  else
    click_button "Confirmar"
  end
end

# Gera a cobrança pela tela, como o estudante faria. O valor é convertido em refeições pelas tarifas vigentes.
def recarga_gerar_cobranca(metodo, cafes: 0, almocos: 0)
  visit new_recarga_path
  recarga_preencher_quantidades("Cafés da Manhã" => cafes, "Almoços/Jantares" => almocos)
  choose metodo
  recarga_clicar_confirmar
  @recarga = recarga_estudante.recargas.recentes.first
  expect(@recarga).to be_present
  @pagamento = @recarga.pagamento_atual
end

def recarga_quantidades_para(valor)
  preco_almoco = TarifaRefeicao.vigente_para(TipoRefeicao::ALMOCO).valor
  preco_cafe = TarifaRefeicao.vigente_para(TipoRefeicao::CAFE_DA_MANHA).valor
  return { almocos: (valor / preco_almoco).to_i } if (valor % preco_almoco).zero?
  return { cafes: (valor / preco_cafe).to_i } if (valor % preco_cafe).zero?

  raise ArgumentError, "R$ #{valor} não corresponde a uma quantidade inteira de refeições"
end

def recarga_conferir_saldo(valor)
  expect(recarga_estudante.saldo).to eq(valor)
  visit new_recarga_path
  expect(page).to have_css("#saldo-atual", text: formatar_reais(valor))
end

# --- Contexto ---

Dado("que o estudante está logado no sistema do UnB RU") do
  @estudante_usuario = login_estudante
end

Dado(/^que o preço do (Almoço\/Jantar|Café da Manhã) é R\$ (\d{1,3}(?:\.\d{3})*,\d{2})$/) do |refeicao, valor|
  RECARGA_TIPOS_POR_PRECO.fetch(refeicao).each { |codigo| recarga_definir_tarifa(codigo, reais(valor)) }
end

Dado("que o saldo do estudante é R$ {dinheiro}") do |valor|
  SaldoInicialFactory.creditar(recarga_estudante, valor - recarga_estudante.saldo)
  expect(recarga_estudante.saldo).to eq(valor)
end

Dado("que o estudante acessa a página de {string}") do |nome_pagina|
  visit public_send(RECARGA_PAGINAS.fetch(nome_pagina))
  expect(page).to have_css("h1", text: nome_pagina)
end

Dado("que o estudante está na página de recarga de saldo") do
  visit new_recarga_path
  expect(page).to have_css("h1", text: "Recarga de Saldo")
end

# --- Seleção e cálculo ---

Dado("que o estudante seleciona a quantidade de {int} {string} e {int} {string}") do |qtd1, campo1, qtd2, campo2|
  recarga_preencher_quantidades(campo1 => qtd1, campo2 => qtd2)
end

Dado("que o estudante seleciona {int} {string} e {int} {string}") do |qtd1, campo1, qtd2, campo2|
  recarga_preencher_quantidades(campo1 => qtd1, campo2 => qtd2)
end

Quando("a quantidade de {string} for {int}") do |campo, quantidade|
  recarga_preencher_quantidades(campo => quantidade)
end

Quando(/^(?:ele )?escolhe "([^"]*)" como método de pagamento$/) do |metodo|
  choose metodo
end

Quando("confirma a solicitação de recarga") do
  recarga_clicar_confirmar
end

Quando("solicita a geração da cobrança") do
  @pagamentos_antes = Pagamento.count
  recarga_clicar_confirmar
end

Então(/^o sistema deve calcular o subtotal de (Cafés da Manhã|Almoços\/Jantares) como R\$ (\d{1,3}(?:\.\d{3})*,\d{2})$/) do |categoria, valor|
  expect(page).to have_css(RECARGA_IDS_SUBTOTAL.fetch(categoria), text: formatar_reais(reais(valor)))
end

Então("o valor total da recarga deve ser R$ {dinheiro}") do |valor|
  expect(page).to have_css("#valor-total", text: formatar_reais(valor))
end

Então("o sistema deve gerar e exibir um QR Code e um código {string}") do |rotulo|
  pagamento = recarga_estudante.recargas.recentes.first.pagamento_atual
  expect(pagamento).to be_pix
  expect(page).to have_css("svg#qr-code-pix[aria-label='QR Code PIX']")
  expect(page).to have_field("Código PIX #{rotulo}", with: pagamento.pix_copia_cola, readonly: true)
end

Então("a cobrança deve exibir que o prazo de validade para pagamento é de {int} minutos") do |minutos|
  expect(page).to have_content("Prazo de validade para pagamento: #{minutos} minutos")
  pagamento = recarga_estudante.recargas.recentes.first.pagamento_atual
  expect(pagamento.expira_em - pagamento.created_at).to be_within(1.second).of(minutos.minutes)
end

Então("o botão {string} deve permanecer desabilitado") do |rotulo|
  expect(page).to have_button(rotulo, disabled: true)
end

Então("o sistema deve exibir a mensagem {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end

Então("o sistema não deve gerar nenhum código de pagamento") do
  expect(Pagamento.count).to eq(0)
  expect(Recarga.count).to eq(0)
  expect(page).to have_no_css("#qr-code-pix")
end

Então(/^a cobrança (deve ser gerada|não deve ser gerada)$/) do |resultado|
  if resultado == "deve ser gerada"
    expect(Pagamento.count).to eq(@pagamentos_antes + 1)
    expect(page).to have_css("#status-recarga", text: "Aguardando pagamento")
  else
    expect(Pagamento.count).to eq(@pagamentos_antes)
    expect(page).to have_no_css("#status-recarga")
  end
end

# --- Cartão de crédito ---

Quando("ele insere os dados válidos do cartão e finaliza o pagamento") do
  recarga_clicar_confirmar
  fill_in "Número do cartão", with: "4111 1111 1111 1111"
  fill_in "Nome impresso no cartão", with: "ESTUDANTE TESTE"
  fill_in "Validade (MM/AA)", with: 2.years.from_now.strftime("%m/%y")
  fill_in "CVV", with: "123"
  click_button "Finalizar pagamento"
end

Quando("o sistema recebe a confirmação da transação de pagamento") do
  pagamento = recarga_estudante.recargas.recentes.first.pagamento_atual
  expect(pagamento.reload).to be_confirmado
  expect(page).to have_content(RecargasController::MSG_PAGAMENTO_CONFIRMADO)
end

Então("o saldo da conta do estudante deve ser atualizado para R$ {dinheiro}") do |valor|
  recarga_conferir_saldo(valor)
end

# --- Cobranças geradas e retorno do pagamento ---

Dado("que o estudante gerou uma cobrança via {string}") do |metodo|
  recarga_gerar_cobranca(metodo, almocos: 5)
end

Dado("que o estudante gerou uma cobrança via {string} de R$ {dinheiro}") do |metodo, valor|
  recarga_gerar_cobranca(metodo, **recarga_quantidades_para(valor))
  expect(@pagamento.valor_solicitado).to eq(valor)
end

Dado("que o estudante gerou uma cobrança via {string} para recarregar {int} {string}") do |metodo, quantidade, campo|
  quantidades = campo == "Cafés da Manhã" ? { cafes: quantidade } : { almocos: quantidade }
  recarga_gerar_cobranca(metodo, **quantidades)
end

Dado("que o valor da cobrança é R$ {dinheiro}") do |valor|
  expect(@pagamento.valor_solicitado).to eq(valor)
  expect(page).to have_css("#valor-total", text: formatar_reais(valor))
end

Dado("o saldo do estudante ainda não foi atualizado") do
  expect(recarga_estudante.saldo).to eq(0)
end

Quando("o pagamento ainda não foi confirmado") do
  expect(@pagamento.reload).to be_pendente
end

Quando("se passam {int} minutos sem a confirmação da transação de pagamento") do |minutos|
  travel_to @pagamento.created_at + minutos.minutes, with_usec: true
  visit recarga_path(@recarga)
end

Quando("o status da transação após {int} minutos é {string}") do |minutos, status|
  travel_to @pagamento.created_at + minutos.minutes, with_usec: true
  Pagamentos::ProcessarRetorno.call(@pagamento.reload, status)
end

Então("o sistema deve expirar o código PIX gerado") do
  expect(@pagamento.reload).to be_expirado
  expect(@recarga.reload).to be_expirada
  expect(page).to have_content("Código PIX expirado")
  expect(page).to have_no_css("#qr-code-pix")
end

Então("o saldo da conta do estudante deve continuar R$ {dinheiro}") do |valor|
  recarga_conferir_saldo(valor)
end

Então("o saldo da conta do estudante não deve ser atualizado") do
  recarga_conferir_saldo(BigDecimal("0"))
end

Então("o saldo do estudante deve ser R$ {dinheiro}") do |valor|
  recarga_conferir_saldo(valor)
end
