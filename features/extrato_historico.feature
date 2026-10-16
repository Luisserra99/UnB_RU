# language: pt

Funcionalidade: Extrato e Histórico
  Como estudante
  Eu quero consultar meu extrato e histórico de refeições
  Para que eu possa acompanhar meu saldo e meus acessos ao RU

  Cenário: Consulta de extrato com histórico existente
    Dado que o usuário está autenticado
    E possui movimentações e refeições registradas
    Quando ele acessa seu extrato e histórico
    Então o sistema exibe o saldo atual, as movimentações e os acessos registrados

  Cenário: Consulta de histórico sem registros
    Dado que o usuário está autenticado
    E não possui nenhuma movimentação ou refeição registrada
    Quando ele acessa seu extrato e histórico
    Então o sistema exibe uma mensagem informando que não há histórico disponível

  Cenário: Tentativa de acesso ao extrato de outro usuário
    Dado que o usuário está autenticado
    Quando ele tenta acessar o extrato e histórico de outro usuário
    Então o sistema nega o acesso e exibe uma mensagem de erro
