# language: pt

Funcionalidade: Cardápio da Refeição Atual
  Como estudante
  Eu quero ver o cardápio da refeição que está sendo servida agora
  Para que eu saiba as opções disponíveis antes de ir ao RU

  Cenário: Consulta do cardápio durante uma refeição em andamento
    Dado que o horário atual corresponde a uma refeição em andamento (café, almoço ou jantar)
    E há itens cadastrados para as opções padrão, ovolactovegetariano e vegetariano estrito
    Quando o usuário consulta o cardápio atual
    Então o sistema exibe os itens das três opções: padrão, ovolactovegetariano e vegetariano estrito

  Cenário: Consulta do cardápio fora do horário de qualquer refeição
    Dado que o horário atual não corresponde a nenhuma refeição em andamento
    Quando o usuário consulta o cardápio atual
    Então o sistema informa que não há cardápio disponível no momento

  Cenário: Consulta do cardápio com uma opção de dieta sem itens cadastrados
    Dado que o horário atual corresponde a uma refeição em andamento
    E a opção vegetariano estrito não possui itens cadastrados
    Quando o usuário consulta o cardápio atual
    Então o sistema exibe as opções padrão e ovolactovegetariano normalmente
    E indica que a opção vegetariano estrito não está disponível
