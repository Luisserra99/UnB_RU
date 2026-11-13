# Passos de features/historico_local_catraca.feature (F07) — Weldo Gonçalves da Silva Junior, 222014133.
#
# Cada catraca tem o seu terminal: uma sessão do Capybara logada (F04) pelo funcionário que a gerencia,
# com o ponto de acesso confirmado (F05). As leituras passam pelo terminal real da F06.
#
# Passos reaproveitados de outros arquivos (não redefinir aqui, senão o Cucumber acusa ambiguidade):
#   validacao_entrada_steps.rb (F06): "que o valor da refeição é R$ ...", "que o aluno de matrícula ... está cadastrado",
#     "que o aluno ... possui saldo de R$ ...", "o aluno não passa pela catraca em até ... segundos"
#   gestao_restaurante_catracas_steps.rb (F08): "deve ser exibida a mensagem ..."

After { Capybara.session_name = :default }

def historico_colunas
  %w[identificacao data hora saldo_lido catraca_liberada acesso_realizado timestamp_liberacao timestamp_bloqueio]
end

def historico_restaurante
  @historico_restaurante ||= create(:restaurante, nome: "RU Darcy Ribeiro", quantidade_pisos: 1)
end

def historico_catraca(identificacao)
  historico_restaurante.catracas.find_by(identificacao: identificacao) ||
    historico_restaurante.pisos.first.catracas.create!(identificacao: identificacao)
end

def historico_momento(data, hora)
  Time.zone.strptime("#{data} #{hora}", "%d/%m/%Y %H:%M:%S")
end

# Troca o navegador de teste para o terminal da catraca.
def historico_terminal(identificacao_catraca)
  Capybara.session_name = "terminal #{identificacao_catraca}"
end

def historico_ponto_da_catraca(catraca)
  ConfiguracaoPontoAcesso.em_sessoes_validas.find_by!(catraca_id: catraca.id)
end

# Deixa a sessão e o ponto de acesso começando antes da leitura, para a linha do tempo ficar coerente.
def historico_alinhar_ponto(catraca, momento)
  ponto = historico_ponto_da_catraca(catraca)
  ponto.sessao_autenticacao.update!(autenticada_em: momento - 1.hour, expira_em: momento + 8.hours)
  ponto.update!(confirmada_em: momento - 1.hour)
end

# Almoço e jantar no dia da semana da leitura, com a tarifa do Contexto ("valor da refeição").
def historico_preparar_refeicoes(momento)
  { TipoRefeicao::ALMOCO => [ "Almoço", "11:00", "14:30" ], TipoRefeicao::JANTAR => [ "Jantar", "17:30", "19:30" ] }
    .each do |codigo, (nome, inicio, fim)|
      tipo = create(:tipo_refeicao, codigo: codigo, nome: nome)
      ServicoRefeicao.find_or_create_by!(restaurante: historico_restaurante, tipo_refeicao: tipo, dia_semana: momento.wday) do |servico|
        servico.assign_attributes(inicio: inicio, fim: fim, ativo: true)
      end
      create(:tarifa_refeicao, tipo_refeicao: tipo, valor: @valor_refeicao)
    end
end

def historico_criar_registro(linha)
  ponto = historico_ponto_da_catraca(historico_catraca(linha["catraca"]))
  horario = ->(coluna) { linha[coluna].presence && historico_momento(linha["data"], linha[coluna]) }
  liberada = linha["catraca_liberada"] == "S"
  realizado = linha["acesso_realizado"] == "S"
  estado = if realizado then "realizado" elsif liberada then "cancelado" else "recusado" end
  estudante = Estudante.find_by(matricula: linha["identificacao"])
  saldo = linha["saldo_lido"].presence && reais(linha["saldo_lido"])
  mensagem = { "realizado" => "Boa refeição", "cancelado" => "Acesso cancelado" }.fetch(estado) do
    estudante ? "Saldo insuficiente" : "Identificação desconhecida"
  end

  RegistroAcesso.create!(
    configuracao_ponto_acesso: ponto, estudante: estudante, referencia_evento: SecureRandom.uuid,
    identificacao_lida: linha["identificacao"], saldo_lido: saldo, valor_previsto: (@valor_refeicao if estudante),
    estado: estado, mensagem: mensagem, lido_em: horario.call("hora"), liberado_em: horario.call("timestamp_liberacao"),
    passagem_em: (horario.call("timestamp_bloqueio") if realizado), bloqueado_em: horario.call("timestamp_bloqueio")
  )
end

def historico_informar_credencial(catraca, matricula, senha)
  historico_terminal(catraca)
  visit controle_historico_path
  fill_in "matricula", with: matricula
  fill_in "senha", with: senha
end

def historico_linhas_exibidas
  all("#historico-acessos tbody tr").map do |linha|
    historico_colunas.to_h { |coluna| [ coluna, linha.find("td[data-coluna='#{coluna}']").text.strip ] }
  end
end

def historico_ordenar(linhas)
  linhas.sort_by { |linha| historico_momento(linha["data"], linha["hora"]) }
end

# --- Contexto ---

Dado("que o funcionário de matrícula {string} e senha {string} está cadastrado") do |matricula, senha|
  (@historico_senhas ||= {})[matricula] = senha
  create(:funcionario, identificacao: matricula, password: senha)
end

Dado("que o funcionário {string} está gerenciando a catraca {string}") do |matricula, identificacao|
  catraca = historico_catraca(identificacao)
  usuario = Usuario.find_by!(identificacao: matricula)
  (@historico_gerentes ||= {})[identificacao] = matricula

  historico_terminal(identificacao)
  fazer_login(usuario, @historico_senhas.fetch(matricula))
  page.driver.submit :post, controle_ponto_acesso_path, restaurante_id: historico_restaurante.id, catraca_id: catraca.id
  expect(historico_ponto_da_catraca(catraca).funcionario).to eq(usuario)
  Capybara.session_name = :default
end

# --- Visualização do histórico ---

Dado("que existem os seguintes registros no histórico:") do |tabela|
  tabela.hashes.each { |linha| historico_criar_registro(linha) }
end

Dado("que não existem registros no histórico da catraca {string}") do |identificacao|
  expect(HistoricoCatraca::Consulta.new(historico_catraca(identificacao)).total).to eq(0)
end

Quando("o funcionário informa a matrícula {string} e a senha {string} na catraca {string}") do |matricula, senha, catraca|
  historico_informar_credencial(catraca, matricula, senha)
end

Quando("solicita a visualização do histórico de acessos") do
  click_button "Ver histórico"
end

Então("a credencial do funcionário deve ser validada") do
  expect(page).to have_content("Credencial validada")
  expect(page).to have_current_path(controle_historico_path)
  expect(page).to have_css("#historico")
end

Então("devem ser exibidos os seguintes registros:") do |tabela|
  expect(historico_ordenar(historico_linhas_exibidas)).to eq(historico_ordenar(tabela.hashes))
end

Então("não devem ser exibidos registros da catraca {string}") do |identificacao|
  da_outra = HistoricoCatraca::Consulta.new(historico_catraca(identificacao)).registros
                                        .map { |registro| registro.lido_em.strftime("%d/%m/%Y %H:%M:%S") }
  exibidos = historico_linhas_exibidas.map { |linha| "#{linha["data"]} #{linha["hora"]}" }

  expect(da_outra).not_to be_empty
  expect(exibidos & da_outra).to be_empty
end

Então("o histórico de acessos não deve ser exibido") do
  expect(page).not_to have_css("#historico")
  expect(page).not_to have_css("#historico-acessos")
  expect(page).to have_css("#credencial-historico")
end

# --- Registro no histórico (leituras feitas no terminal da F06) ---

Quando("a identificação {string} é lida na catraca {string} em {string} às {string}") do |identificacao, catraca, data, hora|
  momento = historico_momento(data, hora)
  historico_alinhar_ponto(historico_catraca(catraca), momento)
  historico_preparar_refeicoes(momento)
  @historico_data = data

  travel_to momento
  historico_terminal(catraca)
  visit controle_terminal_path
  fill_in "Matrícula do estudante", with: identificacao
  click_button "Ler identificação"
  @leitura = RegistroAcesso.order(:id).last
  expect(@leitura.lido_em).to eq(momento)
end

Quando("a catraca é liberada às {string}") do |hora|
  travel_to historico_momento(@historico_data, hora)
  @leitura = Catracas::Operar.new(@leitura.configuracao_ponto_acesso).confirmar_liberacao(@leitura)
  expect(@leitura).to be_liberado
  visit controle_terminal_path(registro_id: @leitura.id)
end

Quando("o aluno passa pela catraca às {string}") do |hora|
  travel_to historico_momento(@historico_data, hora)
  click_button "Simular passagem"
end

Então(/^a catraca (?:deve ser|é) bloqueada às "([^"]*)"$/) do |hora|
  expect(@leitura.reload.bloqueado_em&.strftime("%H:%M:%S")).to eq(hora)
end

Então("deve ser registrado no histórico da catraca {string}:") do |catraca, tabela|
  gerente = @historico_gerentes.fetch(catraca)
  historico_informar_credencial(catraca, gerente, @historico_senhas.fetch(gerente))
  click_button "Ver histórico"
  expect(page).to have_content("Credencial validada")
  expect(historico_linhas_exibidas).to eq(tabela.hashes)
end
