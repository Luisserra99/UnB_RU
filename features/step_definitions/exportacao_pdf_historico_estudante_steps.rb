# Passos de features/exportacao_PDF_historico_estudante.feature (F11) — responsável: Tarsila.
# Os helpers `extrato_*` ficam em features/support/extrato_exportacao.rb.
# O passo "deve ser exibida a mensagem {string}" já existe em gestao_restaurante_catracas_steps.rb.

# Os lançamentos dos cenários são de maio de 2024, então o relógio é fixado nessa data.
EXTRATO_AGORA_PADRAO = [ 2024, 5, 14, 20, 0 ].freeze

Dado("que estou logado como estudante com matrícula {string}") do |matricula|
  travel_to Time.zone.local(*EXTRATO_AGORA_PADRAO)
  usuario = create(:usuario_estudante, identificacao: matricula, nome: "Ana Beatriz Silva",
                                       password: AutenticacaoEstudanteSteps::SENHA_ESTUDANTE_TESTE)
  @estudante_usuario = login_estudante(usuario)
end

Dado("abri a página {string}") do |titulo|
  visit extrato_pagina(titulo)
  expect(page).to have_css("h1", text: titulo)
end

Dado("o valor da refeição é R$ {dinheiro}") do |valor|
  @extrato_valor_refeicao = valor
end

Dado("meu saldo atual é R$ {dinheiro}") do |saldo|
  @extrato_saldo_esperado = saldo
end

Dado("possuo os seguintes lançamentos nos últimos 30 dias:") do |tabela|
  estudante = @estudante_usuario.estudante
  @extrato_lancamentos = tabela.hashes
  @extrato_lancamentos.each do |linha|
    momento = extrato_momento(linha["data_hora"])
    if linha["evento"] == "Recarga de Saldo"
      extrato_registrar_recarga(estudante, em: momento, valor: reais(linha["valor"].delete("+")))
    else
      extrato_registrar_refeicao(estudante, evento: linha["evento"], em: momento, catraca: linha["catraca"],
                                            valor: @extrato_valor_refeicao)
    end
  end
  extrato_ajustar_saldo(estudante, @extrato_saldo_esperado)
  expect(estudante.saldo).to eq(@extrato_saldo_esperado)
  visit extrato_path # recarrega a página, agora com os lançamentos
end

Dado("que os filtros estão com os valores padrão") do
  expect(page).to have_select("Período de referência", selected: "Últimos 30 dias")
  expect(page).to have_select("Tipo de refeição", selected: "Todas as Refeições")
  expect(page).to have_select("Catraca", selected: "Todas as 6 Catracas")
end

Dado("que o estudante de matrícula {string} possui um {string} em {string}") do |matricula, evento, data_hora|
  outro = create(:usuario_estudante, identificacao: matricula).estudante
  extrato_registrar_refeicao(outro, evento: evento, em: extrato_momento(data_hora))
end

Dado("que minha sessão expirou") do
  @estudante_usuario.sessoes.update_all(expira_em: 1.minute.ago)
end

Dado("que não possuo nenhum lançamento") do
  MovimentacaoSaldo.where(estudante: @estudante_usuario.estudante).delete_all
end

Dado("que hoje é {string}") do |data|
  dia = Date.strptime(data, "%d/%m/%Y")
  travel_to Time.zone.local(dia.year, dia.month, dia.day, *EXTRATO_AGORA_PADRAO.last(2))
end

Quando("acesso a página {string}") do |titulo|
  visit extrato_pagina(titulo)
end

Quando("(eu )filtro o tipo de refeição por {string}") do |tipo|
  select tipo, from: "Tipo de refeição"
  click_button "Filtrar"
end

# "Todas as 6 Catracas" é a primeira opção; as demais são "Catraca NN · Restaurante".
Quando("filtro o restaurante pela {string}") do |catraca|
  opcao = catraca.start_with?("Todas") ? catraca : "#{catraca} · #{ExtratoExportacao::RESTAURANTE}"
  select opcao, from: "Catraca"
  click_button "Filtrar"
end

Quando("eu seleciono o período de referência {string}") do |periodo|
  select periodo, from: "Período de referência"
  click_button "Filtrar"
end

Quando("(eu )clico em {string}") do |rotulo|
  @extrato_texto_pdf = nil
  click_button rotulo
end

Então("deve ser baixado um arquivo PDF do extrato") do
  expect(extrato_baixou?("application/pdf")).to be(true)
  expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename="extrato-221045999-.+\.pdf"/)
  expect(page.source.b).to start_with("%PDF")
end

Então("o PDF deve conter os {int} lançamentos listados") do |quantidade|
  expect(extrato_linhas_pdf.size).to eq(quantidade)
  @extrato_lancamentos.each do |linha|
    expect(extrato_texto_pdf).to include("#{linha['data_hora']} #{linha['evento']}")
  end
end

Então(/^o PDF deve conter (\d+) lançamento\(s\)$/) do |quantidade|
  expect(extrato_linhas_pdf.size).to eq(quantidade.to_i)
end

Então("o PDF deve conter apenas os {int} lançamentos de {string}") do |quantidade, evento|
  expect(extrato_linhas_pdf.size).to eq(quantidade)
  expect(extrato_linhas_pdf.reject { |linha| linha.include?(evento) }).to be_empty
end

Então("o PDF não deve conter o lançamento {string}") do |evento|
  expect(extrato_linhas_pdf.grep(/#{Regexp.escape(evento)}/)).to be_empty
end

Então("o PDF não deve conter lançamentos do estudante {string}") do |matricula|
  expect(extrato_texto_pdf).not_to include(matricula)
  expect(extrato_linhas_pdf.size).to eq(@extrato_lancamentos.size)
  expect(extrato_texto_pdf).not_to include("13/05/2024 12:00")
end

Então("o PDF deve exibir o total gasto de R$ {dinheiro}") do |valor|
  expect(extrato_texto_pdf).to include("Total gasto: #{formatar_reais(valor)}")
end

Então("o PDF deve exibir o total recarregado de R$ {dinheiro}") do |valor|
  expect(extrato_texto_pdf).to include("Total recarregado: #{formatar_reais(valor)}")
end

Então("o PDF deve exibir o saldo atual de R$ {dinheiro}") do |valor|
  expect(extrato_texto_pdf).to include("Saldo atual: #{formatar_reais(valor)}")
end

Então("o PDF deve exibir {int} refeições realizadas") do |quantidade|
  expect(extrato_texto_pdf).to include("Refeições realizadas: #{quantidade}")
end

Então("o PDF deve exibir o nome {string} e a matrícula {string}") do |nome, matricula|
  expect(extrato_texto_pdf).to include("Estudante: #{nome}")
  expect(extrato_texto_pdf).to include("Matrícula: #{matricula}")
end

Então("o PDF deve exibir o período de referência {string}") do |periodo|
  expect(extrato_texto_pdf).to include("Período de referência: #{periodo}")
end

Então("o PDF deve exibir a data de emissão") do
  expect(extrato_texto_pdf).to include("Data de emissão: #{Time.current.strftime('%d/%m/%Y %H:%M')}")
end

Então("o PDF deve exibir a indicação {string}") do |indicacao|
  expect(extrato_texto_pdf).to include(indicacao)
end

Então("nenhum arquivo deve ser baixado") do
  expect(extrato_baixou?("text/html")).to be(true)
  expect(page.response_headers["Content-Disposition"].to_s).not_to include("attachment")
end

Então("devo ser redirecionado para a página de login") do
  expect(page).to have_current_path(login_estudante_path)
end

Então("o botão {string} deve estar desabilitado") do |rotulo|
  expect(page).to have_button(rotulo, disabled: true)
end

Então("deve ser baixado um arquivo CSV do extrato") do
  expect(extrato_baixou?("text/csv")).to be(true)
  expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename="extrato-221045999-.+\.csv"/)
end

Então(/^o CSV deve conter (\d+) lançamento\(s\)$/) do |quantidade|
  expect(extrato_linhas_csv.size).to eq(quantidade.to_i)
end

Então("o CSV não deve conter o lançamento {string}") do |evento|
  expect(extrato_linhas_csv.grep(/#{Regexp.escape(evento)}/)).to be_empty
end

Então("deve existir {int} exportação concluída do meu extrato em {string} com {int} registros") do |total, formato, registros|
  exportacoes = ExportacaoRelatorio.where(usuario: @estudante_usuario, tipo: "extrato_estudante", formato: formato)
  expect(exportacoes.concluida.count).to eq(total)
  exportacao = exportacoes.concluida.last
  expect(exportacao.quantidade_registros).to eq(registros)
  expect(exportacao.arquivo_sha256).to eq(Digest::SHA256.hexdigest(page.source.b))
end
