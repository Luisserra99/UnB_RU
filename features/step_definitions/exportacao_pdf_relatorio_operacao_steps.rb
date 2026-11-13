# Passos de features/exportacao_pdf_relatorio_operacao.feature (F12) — responsável: Tarsila.
# Os helpers `aud_*` ficam em features/support/auditoria_acessos.rb.
# Reaproveitados: "abri a página {string}" e "nenhum arquivo deve ser baixado" (F11) e
# "deve ser exibida a mensagem {string}" (F08).
require "cucumber/rspec/doubles"

AUD_AGORA_PADRAO = [ 2026, 10, 16, 20, 0 ].freeze
AUD_SENHA = "senhaCorreta".freeze

# --- Contexto ---

# Primeiro passo do contexto: fixa o relógio logo após os acessos dos cenários.
Dado("que estou autenticado como administrador geral {string}") do |nome|
  travel_to Time.zone.local(*AUD_AGORA_PADRAO)
  @aud_administrador = create(:administrador, nome: nome, password: AUD_SENHA)
  fazer_login(@aud_administrador, AUD_SENHA)
end

Dado("existem os seguintes acessos registrados:") do |tabela|
  tabela.hashes.each { |linha| aud_registrar(linha) }
  @aud_retrato = aud_retrato_dos_acessos
  visit admin_acessos_relatorio_global_path # recarrega, agora com restaurantes e catracas nos filtros
end

# --- Dado ---

Dado("(que )filtrei o período de {string} a {string}") do |inicio, fim|
  fill_in "Data inicial", with: aud_data_iso(inicio)
  fill_in "Data final", with: aud_data_iso(fim)
  aud_aplicar_filtros
end

Dado("selecionei todos os restaurantes e todas as catracas") do
  select "Todos", from: "Restaurante"
  select "Todas", from: "Catraca"
  aud_aplicar_filtros
end

Dado("filtrei o restaurante {string} e a catraca {string}") do |restaurante, catraca|
  select restaurante, from: "Restaurante"
  select (catraca == "Todas" ? catraca : "#{catraca} · #{restaurante}"), from: "Catraca"
  aud_aplicar_filtros
end

Dado("agrupei o relatório por restaurante e catraca") do
  check "Agrupar por restaurante e catraca"
  aud_aplicar_filtros
end

Dado("que a data e hora da emissão é {string}") do |data_hora|
  travel_to aud_momento(data_hora)
end

Dado("a listagem exibe apenas {int} acessos por página") do |quantidade|
  visit "#{current_url}&por_pagina=#{quantidade}"
  expect(page).to have_css("#tabela-acessos tbody tr", count: quantidade)
end

Dado("estou visualizando a primeira página") do
  expect(page).to have_css("#pagina-atual", text: /\APágina 1 de [2-9]/)
end

Dado("que encerrei a sessão de administrador geral") do
  click_button "Sair"
end

Dado("estou autenticado apenas como {string}") do |perfil|
  case perfil
  when "funcionário" then fazer_login(create(:funcionario, password: AUD_SENHA), AUD_SENHA)
  when "estudante" then login_estudante
  else raise "Perfil desconhecido: #{perfil}"
  end
end

Dado("que minha sessão está {string}") do |estado|
  case estado
  when "encerrada" then click_button "Sair"
  when "expirada" then @aud_administrador.sessoes.update_all(expira_em: 1.minute.ago)
  else raise "Estado desconhecido: #{estado}"
  end
end

Dado("ocorre uma falha no serviço de geração de PDF") do
  allow(Relatorios::AcessosOperacaoPdf).to receive(:new).and_raise(StandardError, "falha simulada")
end

# --- Quando ---

Quando("solicito a exportação em PDF") do
  click_button "Exportar PDF"
end

Quando("informo o período de {string} a {string} para a exportação") do |inicio, fim|
  fill_in "Data inicial", with: aud_data_iso(inicio)
  fill_in "Data final", with: aud_data_iso(fim)
  aud_aplicar_filtros
  expect(page).to have_button("Exportar PDF", disabled: true)
  # Mesmo sem o botão, um pedido direto com esse período também é recusado.
  aud_exportar_diretamente(inicio: aud_data_iso(inicio), fim: aud_data_iso(fim))
end

Quando("tento acessar diretamente a exportação em PDF do relatório de operação") do
  aud_exportar_diretamente(inicio: "2026-10-14", fim: "2026-10-16")
end

# --- Então ---

Então("deve ser baixado um arquivo PDF válido") do
  expect(aud_baixou_pdf?).to be(true)
  expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename="relatorio-operacao-.+\.pdf"/)
  expect(page.source.b).to start_with("%PDF")
  expect(aud_paginas_pdf).not_to be_empty
end

Então("o PDF deve conter os acessos {string}") do |acessos|
  expect(aud_referencias_pdf).to include(*aud_lista(acessos))
end

Então("o PDF não deve conter o acesso {string}") do |acesso|
  expect(aud_referencias_pdf).not_to include(acesso)
end

Então("o PDF deve conter somente os acessos {string}") do |acessos|
  expect(aud_referencias_pdf).to match_array(aud_lista(acessos))
end

Então("cada acesso deve apresentar data e hora, matrícula, restaurante, catraca, refeição e valor debitado") do
  formato = %r{\AA\d{3} \d{2}/\d{2}/\d{4} \d{2}:\d{2} \d{9} RU .+ Catraca \d{2} (Café da Manhã|Almoço|Jantar) R\$ \d+,\d{2}\z}
  expect(aud_linhas_pdf).not_to be_empty
  aud_linhas_pdf.each { |linha| expect(linha).to match(formato) }
end

Então("(o PDF )deve apresentar {int} acesso(s) e o total debitado de R$ {dinheiro}") do |quantidade, total|
  expect(aud_linhas_pdf.size).to eq(quantidade)
  expect(aud_texto_pdf).to include("Total geral: #{quantidade} #{quantidade == 1 ? 'acesso' : 'acessos'}",
                                   "Total debitado: #{formatar_reais(total)}")
end

Então("o PDF deve identificar o administrador {string}") do |nome|
  expect(aud_texto_pdf).to include("Emitido por: #{nome} (#{@aud_administrador.identificacao})")
end

Então("deve apresentar a data e hora da emissão {string}") do |data_hora|
  expect(aud_texto_pdf).to include("Emitido em: #{data_hora}")
end

Então("deve apresentar o período de {string} a {string}") do |inicio, fim|
  expect(aud_texto_pdf).to include("Período: #{inicio} a #{fim}")
end

Então("deve apresentar o restaurante {string}, a catraca {string} e o agrupamento aplicado") do |restaurante, catraca|
  expect(aud_texto_pdf).to include("Restaurante: #{restaurante}", "Catraca: #{catraca}",
                                   "Agrupamento: Restaurante e catraca")
end

Então("o PDF deve apresentar os seguintes subtotais separados:") do |tabela|
  tabela.hashes.each do |linha|
    quantidade = linha["quantidade"].to_i
    expect(aud_texto_pdf).to include(
      "Subtotal #{linha['restaurante']} · #{linha['catraca']}: " \
      "#{quantidade} #{quantidade == 1 ? 'acesso' : 'acessos'} · #{formatar_reais(reais(linha['total_debitado']))}"
    )
  end
  expect(aud_texto_pdf.scan("Subtotal ").size).to eq(tabela.hashes.size)
end

Então("deve apresentar {int} acesso(s) e R$ {dinheiro} para o restaurante {string}") do |quantidade, total, restaurante|
  expect(aud_texto_pdf).to include(
    "Total #{restaurante}: #{quantidade} #{quantidade == 1 ? 'acesso' : 'acessos'} · #{formatar_reais(total)}"
  )
end

Então("deve apresentar o total geral de {int} acessos e R$ {dinheiro}") do |quantidade, total|
  expect(aud_texto_pdf).to include("Total geral: #{quantidade} acessos", "Total debitado: #{formatar_reais(total)}")
end

Então("nenhum arquivo deve ser gerado") do
  expect(aud_baixou_pdf?).to be(false)
  expect(ExportacaoRelatorio.concluida).to be_empty
end

Então("o acesso deve ser negado por falta de permissão") do
  expect(page.status_code).to eq(403)
  expect(page).to have_content("Acesso não autorizado")
end

Então("devo ser direcionado ao login") do
  expect(page).to have_current_path(controle_login_path)
end

Então("nenhum arquivo incompleto deve ser disponibilizado") do
  expect(aud_baixou_pdf?).to be(false)
  exportacao = ExportacaoRelatorio.last
  expect(exportacao).to be_falhou
  expect(exportacao.arquivo_chave).to be_nil
  expect(exportacao.arquivo_sha256).to be_nil
end

Então("devo poder tentar a exportação novamente") do
  allow(Relatorios::AcessosOperacaoPdf).to receive(:new).and_call_original
  click_button "Exportar PDF"
  expect(aud_baixou_pdf?).to be(true)
  expect(ExportacaoRelatorio.last).to be_concluida
end

Então("os acessos registrados e seus valores devem permanecer inalterados") do
  expect(aud_retrato_dos_acessos).to eq(@aud_retrato)
end
