# language: pt

Funcionalidade: Cadastro de Usuário
  Como estudante
  Eu quero me cadastrar no sistema utilizando minha matrícula
  Para que eu possa acessar minha conta do RU

  Cenário: Cadastro com dados válidos
    Dado que o usuário informa uma matrícula válida de 9 números
    E um email com domínio da faculdade
    E uma senha com 8 caracteres ou mais
    Quando ele confirma o cadastro
    Então o sistema cria a conta com sucesso

  Cenário: Cadastro com matrícula em formato inválido
    Dado que o usuário informa uma matrícula com menos de 9 números
    E um email com domínio da faculdade
    E uma senha com 8 caracteres ou mais
    Quando ele confirma o cadastro
    Então o sistema exibe um erro de matrícula inválida e não cria a conta

  Cenário: Cadastro com email fora do domínio da faculdade
    Dado que o usuário informa uma matrícula válida de 9 números
    E um email que não é do domínio da faculdade
    E uma senha com 8 caracteres ou mais
    Quando ele confirma o cadastro
    Então o sistema exibe um erro de email inválido e não cria a conta

  Cenário: Cadastro com senha muito curta
    Dado que o usuário informa uma matrícula válida de 9 números
    E um email com domínio da faculdade
    E uma senha com menos de 8 caracteres
    Quando ele confirma o cadastro
    Então o sistema exibe um erro de senha inválida e não cria a conta
