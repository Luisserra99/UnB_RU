# Passos de features/cardapio_atual.feature (F10) — responsável: Leonardo.

World(ActiveSupport::Testing::TimeHelpers)

After { travel_back }

# 04/11/2026 é uma quarta-feira, dia_semana 3 do serviço criado abaixo.
QUARTA_FEIRA_AO_MEIO_DIA = [ 2026, 11, 4, 12, 0 ].freeze
QUARTA_FEIRA_FORA_DE_REFEICAO = [ 2026, 11, 4, 16, 0 ].freeze

PRATOS_POR_DIETA = {
  OpcaoCardapio::PADRAO => "Frango assado",
  OpcaoCardapio::OVOLACTOVEGETARIANA => "Quiche de legumes",
  OpcaoCardapio::VEGETARIANA_ESTRITA => "Refogado de lentilha"
}.freeze

def criar_cardapio_do_almoco
  servico = create(:servico_refeicao, dia_semana: 3, inicio: "11:00", fim: "14:30")
  create(:cardapio, servico_refeicao: servico, data_referencia: Date.new(2026, 11, 4))
end

def adicionar_prato(cardapio, dieta)
  opcao = create(:opcao_cardapio, cardapio: cardapio, dieta: dieta)
  create(:item_cardapio, opcao_cardapio: opcao, descricao: PRATOS_POR_DIETA.fetch(dieta), ordem: 1)
end

def esperar_opcao_com_prato(dieta)
  within("#opcao-#{dieta}") do
    expect(page).to have_content(OpcaoCardapio::DIETAS.fetch(dieta))
    expect(page).to have_content(PRATOS_POR_DIETA.fetch(dieta))
  end
end

# --- Dado ---

Dado("que o horário atual corresponde a uma refeição em andamento \\(café, almoço ou jantar)") do
  travel_to Time.zone.local(*QUARTA_FEIRA_AO_MEIO_DIA)
  @cardapio = criar_cardapio_do_almoco
end

Dado("que o horário atual corresponde a uma refeição em andamento") do
  travel_to Time.zone.local(*QUARTA_FEIRA_AO_MEIO_DIA)
  @cardapio = criar_cardapio_do_almoco
end

Dado("que o horário atual não corresponde a nenhuma refeição em andamento") do
  travel_to Time.zone.local(*QUARTA_FEIRA_FORA_DE_REFEICAO)
  @cardapio = criar_cardapio_do_almoco
  adicionar_prato(@cardapio, OpcaoCardapio::PADRAO)
end

Dado("há itens cadastrados para as opções padrão, ovolactovegetariano e vegetariano estrito") do
  OpcaoCardapio::DIETAS.each_key { |dieta| adicionar_prato(@cardapio, dieta) }
end

Dado("a opção vegetariano estrito não possui itens cadastrados") do
  adicionar_prato(@cardapio, OpcaoCardapio::PADRAO)
  adicionar_prato(@cardapio, OpcaoCardapio::OVOLACTOVEGETARIANA)
end

# --- Quando ---

Quando("o usuário consulta o cardápio atual") do
  visit cardapio_path
end

# --- Então ---

Então("o sistema exibe os itens das três opções: padrão, ovolactovegetariano e vegetariano estrito") do
  OpcaoCardapio::DIETAS.each_key { |dieta| esperar_opcao_com_prato(dieta) }
end

Então("o sistema informa que não há cardápio disponível no momento") do
  expect(page).to have_content("Não há cardápio disponível no momento.")
  expect(page).not_to have_css(".opcoes-cardapio")
end

Então("o sistema exibe as opções padrão e ovolactovegetariano normalmente") do
  esperar_opcao_com_prato(OpcaoCardapio::PADRAO)
  esperar_opcao_com_prato(OpcaoCardapio::OVOLACTOVEGETARIANA)
end

Então("indica que a opção vegetariano estrito não está disponível") do
  within("#opcao-#{OpcaoCardapio::VEGETARIANA_ESTRITA}") do
    expect(page).to have_content("Vegetariano estrito")
    expect(page).to have_content("Esta opção não está disponível.")
  end
end
