# Passos de features/cadastro_usuario.feature (F01) — responsável: Weldo.

Before do
  Papel.find_or_create_by!(codigo: Papel::ESTUDANTE) { |papel| papel.descricao = "Estudante" }
end

def abrir_cadastro
  visit novo_cadastro_path
  fill_in "Nome completo", with: "Estudante de Teste"
end

Dado("que o usuário informa uma matrícula válida de {int} números") do |digitos|
  abrir_cadastro
  fill_in "Matrícula", with: "2" * digitos
end

Dado("que o usuário informa uma matrícula com menos de {int} números") do |digitos|
  abrir_cadastro
  fill_in "Matrícula", with: "2" * (digitos - 1)
end

Dado("um email com domínio da faculdade") do
  fill_in "Email institucional", with: "estudante@aluno.unb.br"
end

Dado("um email que não é do domínio da faculdade") do
  fill_in "Email institucional", with: "estudante@gmail.com"
end

Dado("uma senha com {int} caracteres ou mais") do |tamanho|
  fill_in "Senha", with: "s" * tamanho
end

Dado("uma senha com menos de {int} caracteres") do |tamanho|
  fill_in "Senha", with: "s" * (tamanho - 1)
end

Quando("ele confirma o cadastro") do
  click_button "Cadastrar"
end

Então("o sistema cria a conta com sucesso") do
  expect(page).to have_content("Conta criada com sucesso")
  expect(Estudante.count).to eq(1)
  expect(Usuario.last).to be_estudante
end

def esperar_erro_sem_conta(mensagem)
  expect(page).to have_content(mensagem)
  expect(Usuario.count).to eq(0)
  expect(Estudante.count).to eq(0)
end

Então("o sistema exibe um erro de matrícula inválida e não cria a conta") do
  esperar_erro_sem_conta(CadastroEstudante::MSG_MATRICULA)
end

Então("o sistema exibe um erro de email inválido e não cria a conta") do
  esperar_erro_sem_conta(CadastroEstudante::MSG_EMAIL)
end

Então("o sistema exibe um erro de senha inválida e não cria a conta") do
  esperar_erro_sem_conta(CadastroEstudante::MSG_SENHA)
end
