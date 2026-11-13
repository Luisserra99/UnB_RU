# Passos de features/relatorio_global_acesso.feature (F09) — responsável: Tarsila.
# Os helpers `rg_*` ficam em features/support/relatorio_global.rb.
# Reaproveitados de outros arquivos: "deve ser exibida a mensagem {string}" (F08) e "clico em {string}" (F11).

RG_HOJE = [ 2025, 10, 24, 15, 0 ].freeze

# --- Contexto ---

# É o primeiro passo do contexto: fixa o relógio em 24/10/2025, a data dos cenários.
Dado(/^que a tarifa fixa universitária é R\$ (.+) por refeição de almoço e janta, e (.+) para café da manhã$/) do |almoco, cafe|
  travel_to Time.zone.local(*RG_HOJE)
  @rg_tarifas = { "Café da Manhã" => reais(cafe), "Almoço" => reais(almoco), "Jantar" => reais(almoco) }
end

Dado("que o {string} possui {int} restaurantes e {int} catracas cadastradas, todas online") do |unidade, restaurantes, catracas|
  expect(unidade).to eq(RelatorioGlobal::UNIDADE)
  rg_criar_restaurantes(restaurantes)
  expect(rg_catracas_online).to eq(catracas)
end

Dado("que em {string} foram registrados os seguintes acessos por restaurante:") do |_data, tabela|
  @rg_por_restaurante = tabela.hashes.to_h { |linha| [ linha["restaurante"], linha["acessos"].to_i ] }
end

Dado("que em {string} foram registrados os seguintes acessos por turno:") do |_data, tabela|
  @rg_por_turno = tabela.hashes.to_h { |linha| [ linha["turno"], linha["acessos"].to_i ] }
end

Dado("que em {string} todos os acessos de {string} e de {string} ocorreram no {string}") do |_data, turno_a, turno_b, restaurante|
  @rg_concentrados = { turnos: [ turno_a, turno_b ], restaurante: restaurante }
end

# Último passo do contexto: com tudo declarado, grava os acessos do dia.
Dado("que a arrecadação de {string} foi liquidada nos seguintes métodos:") do |data, tabela|
  valores = tabela.hashes.to_h { |linha| [ RelatorioGlobal::METODOS.fetch(linha["metodo"]), reais(linha["valor"].delete("R$ ")) ] }
  total = valores.values.sum
  participacoes = valores.transform_values { |valor| valor / total }
  dia = rg_data(data)
  concentrados = @rg_concentrados[:turnos]

  @rg_por_restaurante.each do |nome, acessos|
    restaurante = rg_restaurante(nome)
    por_turno = nome == @rg_concentrados[:restaurante] ? @rg_por_turno.slice(*concentrados) : {}
    por_turno["Almoço"] = acessos - por_turno.values.sum
    por_turno.each do |turno, quantidade|
      rg_registrar_acessos(restaurante: restaurante, turno: turno, data: dia, quantidade: quantidade,
                           valor: @rg_tarifas.fetch(turno), participacoes: participacoes)
    end
  end

  # Confere se os números do contexto fecham entre si antes de testar a tela.
  expect(RegistroAcesso.count).to eq(@rg_por_turno.values.sum)
  expect(-MovimentacaoSaldo.debitos.sum(:valor)).to eq(total)
end

# --- Dado ---

Dado("que sou um administrador autenticado") do
  rg_login_administrador
end

Dado("que a data atual é {string}") do |data|
  expect(Date.current).to eq(rg_data(data))
end

Dado(/^que em "([^"]+)" o campus teve ([\d.]+) acessos$/) do |data, acessos|
  rg_registrar_acessos(restaurante: rg_restaurante("Restaurante 1"), turno: "Almoço", data: rg_data(data),
                       quantidade: rg_inteiro(acessos), valor: @rg_tarifas.fetch("Almoço"),
                       participacoes: { pix: 1 })
end

Dado(/^que em "([^"]+)" o campus teve ([\d.]+) acessos no turno "([^"]+)"$/) do |data, acessos, turno|
  rg_registrar_acessos(restaurante: rg_restaurante("Restaurante 1"), turno: turno, data: rg_data(data),
                       quantidade: rg_inteiro(acessos), valor: @rg_tarifas.fetch(turno), participacoes: { pix: 1 })
end

Dado(/^que em "([^"]+)" o campus teve ([\d.]+) acessos nos demais turnos$/) do |data, acessos|
  rg_registrar_acessos(restaurante: rg_restaurante("Restaurante 2"), turno: "Jantar", data: rg_data(data),
                       quantidade: rg_inteiro(acessos), valor: @rg_tarifas.fetch("Jantar"), participacoes: { pix: 1 })
end

# O contexto já concentra o jantar no restaurante citado; aqui só se confirma.
Dado("que no turno {string} de {string} somente o {string} teve acessos") do |turno, data, restaurante|
  dia = rg_data(data).in_time_zone.all_day
  servicos = ServicoRefeicao.joins(:tipo_refeicao).where(tipo_refeicoes: { nome: turno })
  restaurantes = RegistroAcesso.where(passagem_em: dia, servico_refeicao: servicos)
                               .joins(:configuracao_ponto_acesso).distinct
                               .pluck("configuracao_ponto_acessos.restaurante_id")
  expect(restaurantes).to eq([ rg_restaurante(restaurante).id ])
end

Dado("que não há acessos registrados em {string}") do |data|
  expect(RegistroAcesso.where(passagem_em: rg_data(data).in_time_zone.all_day)).to be_empty
end

Dado("que {int} das {int} catracas cadastradas está offline") do |offline, total|
  expect(Catraca.count).to eq(total)
  rg_desligar_catracas(offline)
  expect(rg_catracas_online).to eq(total - offline)
end

Dado("que sou um usuário autenticado com perfil de aluno") do
  @estudante_usuario = login_estudante
end

# --- Quando ---

Quando("acesso o Relatório Global de Operação") do
  rg_abrir_relatorio
  expect(page).to have_css("h1", text: "Relatório Global de Operação")
end

Quando("tento acessar o Relatório Global de Operação") do
  rg_abrir_relatorio
end

Quando("seleciono a janela de serviço {string}") do |turno|
  select turno, from: "Janela de serviço"
  click_button "Aplicar filtros"
end

Quando("seleciono a data contábil {string}") do |data|
  fill_in "Data contábil", with: rg_data(data).iso8601
  click_button "Aplicar filtros"
end

# --- Então ---

Então("o filtro de data contábil deve exibir {string}") do |texto|
  expect(page).to have_css("#filtro-data-contabil", text: texto, exact_text: true)
end

Então("o filtro de janela de serviço deve exibir {string}") do |texto|
  expect(page).to have_select("Janela de serviço", selected: texto)
end

Então("o filtro de unidade gestora deve exibir {string}") do |texto|
  expect(page).to have_select("Unidade gestora", selected: texto)
end

Então("o indicador de catracas online deve exibir {string}") do |texto|
  expect(page).to have_css("#catracas-online", text: texto, exact_text: true)
end

Então("o card {string} deve exibir {string}") do |titulo, valor|
  card = find(".relatorio-indicador", text: titulo)
  expect(card).to have_css("strong", text: valor, exact_text: true)
end

Então("a tabela de consolidação deve exibir as seguintes linhas, nesta ordem:") do |tabela|
  linhas = page.all("#tabela-consolidacao tbody tr").map { |linha| rg_celulas(linha) }
  expect(linhas).to eq(tabela.hashes.map { |linha| linha.values_at("restaurante", "acessos", "arrecadacao_bruta") })
end

Então("a tabela de consolidação deve exibir {int} restaurantes") do |quantidade|
  expect(page).to have_css("#tabela-consolidacao tbody tr", count: quantidade)
end

Então(/^a linha "Total Consolidado" deve exibir ([\d.]+) acessos$/) do |acessos|
  expect(rg_celulas(find("#total-consolidado"))[1]).to eq(acessos)
end

Então("a linha {string} deve exibir arrecadação de {string}") do |_linha, valor|
  expect(rg_celulas(find("#total-consolidado"))[2]).to eq(valor)
end

Então(/^o "([^"]+)" deve exibir ([\d.]+) acessos e arrecadação bruta de "([^"]+)"$/) do |restaurante, acessos, valor|
  expect(rg_celulas(rg_linha_restaurante(restaurante))).to eq([ restaurante, acessos, valor ])
end

Então("o método {string} deve exibir {string} e {string}") do |metodo, percentual, valor|
  expect(rg_celulas(find("#tabela-liquidacao tbody tr", text: metodo))).to eq([ metodo, percentual, valor ])
end

Então("a soma dos métodos de liquidação deve ser igual a {string}") do |valor|
  expect(page).to have_css("#liquidacao-total", text: valor, exact_text: true)
  expect(page).to have_css("#divergencias-contabeis", text: "R$ 0,00", exact_text: true)
end

Então("os métodos de liquidação devem exibir {string}") do |valor|
  page.all("#tabela-liquidacao tbody tr").each { |linha| expect(rg_celulas(linha).last).to eq(valor) }
  expect(page).to have_css("#liquidacao-total", text: valor, exact_text: true)
end

Então(/^as transações validadas devem ser ([\d.]+) operações$/) do |quantidade|
  expect(page).to have_css("#transacoes-validadas", text: "#{quantidade} operações", exact_text: true)
end

Então("deve ser gerado um arquivo CSV com os dados do relatório") do
  linhas = rg_linhas_csv
  expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename="relatorio-global-2025-10-24-\d+\.csv"/)
  expect(linhas.size).to eq(Restaurante.count + 1)
  expect(linhas.last.values_at(3, 4, 5)).to eq([ "Total Consolidado", "2980", "13410,00" ])
end

Então("o arquivo deve conter somente os dados do turno {string}") do |turno|
  expect(rg_linhas_csv.map { |linha| linha[1] }.uniq).to eq([ turno ])
end

Então("deve ser gerado um documento PDF com os mesmos dados exibidos no relatório") do
  texto = rg_texto_pdf
  expect(page.source.b).to start_with("%PDF")
  expect(texto).to include("Arrecadação global: R$ 20.390,00", "Catracas online: 6/6",
                           "Restaurante 1 2100 R$ 8.150,00", "Restaurante 6 350 R$ 1.575,00",
                           "Total Consolidado 4820 R$ 20.390,00", "PIX Institucional Instantâneo 72% R$ 14.680,80",
                           "Cartão de Crédito / Débito 28% R$ 5.709,20")
end

Então("o documento deve conter os filtros aplicados, a data e hora de emissão e o usuário emissor") do
  expect(rg_texto_pdf).to include("Data contábil: 24/10/2025",
                                  "Janela de serviço: Todos os Turnos (Café, Almoço, Jantar)",
                                  "Unidade gestora: Campus Darcy Ribeiro", "Emitido em: 24/10/2025 15:00",
                                  "Emitido por: #{@rg_administrador.nome} (#{@rg_administrador.identificacao})")
end

Então("o acesso deve ser negado") do
  expect(page.status_code).to eq(403)
end

Então("nenhum dado operacional deve ser exibido") do
  expect(page).to have_no_css("#tabela-consolidacao, #relatorio-indicadores, #tabela-liquidacao")
  expect(page).to have_no_content("Arrecadação")
end

Então("não deve existir nenhuma opção para editar ou excluir dados operacionais") do
  within("main") do
    expect(page).to have_no_link(text: /editar|excluir|remover/i)
    expect(page).to have_no_button(text: /editar|excluir|remover|salvar/i)
    expect(page.all("form").map { |formulario| formulario[:action] }.uniq)
      .to contain_exactly(admin_relatorio_global_path, exportar_admin_relatorio_global_path)
  end
end
