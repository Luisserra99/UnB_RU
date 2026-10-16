Funcionalidade: Relatório Global de Acessos
  Como administrador
  Eu quero visualizar o histórico completo de todos os acessos do campus, podendo filtrar e agrupar por restaurante e por catraca
  Para ter uma visão gerencial de toda a operação

  Contexto:
    Dado que o valor da refeição é R$ 2,50 para café da manhâ e 4,50 para almoço e jantar
    E que existem os seguintes restaurantes e catracas:
      | restaurante | catraca    |
      | RU Central  | Catraca 01 |
      | RU Central  | Catraca 02 |
      | RU Setorial | Catraca 01 |
    E que existem os seguintes acessos registrados:
      | data_hora        | restaurante | catraca    | matricula | resultado               | valor_debitado |
      | 14/10/2026 11:30 | RU Central  | Catraca 01 | 251033574 | Acesso liberado         | 2,50           |
      | 14/10/2026 11:45 | RU Central  | Catraca 02 | 251033575 | Saldo insuficiente      | 0,00           |
      | 14/10/2026 12:00 | RU Setorial | Catraca 01 | 251033576 | Acesso liberado         | 2,50           |
      | 14/10/2026 12:10 | RU Setorial | Catraca 01 | 251033577 | Acesso cancelado        | 0,00           |
      | 15/10/2026 11:35 | RU Central  | Catraca 01 | 251033578 | Acesso liberado         | 2,50           |
      | 15/10/2026 11:50 | RU Central  | Catraca 02 | abc123xyz | Identificação desconhecida | 0,00        |

  # --- Caminho feliz ---
  Cenário: Administrador visualiza o histórico completo sem filtros
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    Então devem ser exibidos 6 acessos
    E o primeiro acesso exibido deve ser o de "15/10/2026 11:50"
    E o último acesso exibido deve ser o de "14/10/2026 11:30"
    E cada registro deve exibir data e hora, restaurante, catraca, matrícula, resultado e valor debitado

  Cenário: Relatório inclui acessos liberados e negados
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    Então devem constar acessos com o resultado "Acesso liberado"
    E devem constar acessos com o resultado "Saldo insuficiente"
    E devem constar acessos com o resultado "Acesso cancelado"
    E devem constar acessos com o resultado "Identificação desconhecida"

  Cenário: Filtrar acessos por restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo restaurante "RU Central"
    Então devem ser exibidos 4 acessos
    E todos os acessos exibidos devem pertencer ao restaurante "RU Central"

  Cenário: Filtrar acessos por catraca específica de um restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo restaurante "RU Central"
    E filtro pela catraca "Catraca 01"
    Então devem ser exibidos 2 acessos
    E todos os acessos exibidos devem pertencer à catraca "Catraca 01" do restaurante "RU Central"

  Cenário: Filtrar acessos por período
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo período de "15/10/2026" até "15/10/2026"
    Então devem ser exibidos 2 acessos
    E todos os acessos exibidos devem ser do dia "15/10/2026"

  Cenário: Combinar filtros de restaurante e período
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo restaurante "RU Setorial"
    E filtro pelo período de "14/10/2026" até "14/10/2026"
    Então devem ser exibidos 2 acessos

  Cenário: Agrupar acessos por restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E agrupo os dados por restaurante
    Então devem ser exibidos os seguintes grupos:
      | restaurante | total_acessos | liberados | negados | valor_arrecadado |
      | RU Central  | 4             | 2         | 2       | R$ 5,00          |
      | RU Setorial | 2             | 1         | 1       | R$ 2,50          |

  Cenário: Agrupar acessos por catraca
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E agrupo os dados por catraca
    Então devem ser exibidos os seguintes grupos:
      | restaurante | catraca    | total_acessos | liberados | negados | valor_arrecadado |
      | RU Central  | Catraca 01 | 2             | 2         | 0       | R$ 5,00          |
      | RU Central  | Catraca 02 | 2             | 0         | 2       | R$ 0,00          |
      | RU Setorial | Catraca 01 | 2             | 1         | 1       | R$ 2,50          |

  Cenário: Catracas com o mesmo nome em restaurantes diferentes são agrupadas separadamente
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E agrupo os dados por catraca
    Então deve existir um grupo para "Catraca 01" do restaurante "RU Central"
    E deve existir um grupo para "Catraca 01" do restaurante "RU Setorial"
    E os dois grupos não devem ser somados

  Cenário: Agrupamento combinado com filtro de restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo restaurante "RU Central"
    E agrupo os dados por catraca
    Então devem ser exibidos apenas os grupos "Catraca 01" e "Catraca 02" do restaurante "RU Central"

  Cenário: Valor debitado apenas em acessos liberados
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    Então os acessos com resultado "Acesso liberado" devem exibir valor debitado de R$ 2,50
    E os acessos com qualquer outro resultado devem exibir valor debitado de R$ 0,00

  # --- Caminhos tristes ---
  Cenário: Usuário sem perfil de administrador tenta acessar o relatório
    Dado que sou um usuário autenticado com perfil de aluno
    Quando tento acessar o Relatório Global de Acessos
    Então o acesso deve ser negado
    E deve ser exibida a mensagem "Acesso não autorizado"
    E nenhum dado de acesso deve ser exibido

  Cenário: Usuário não autenticado tenta acessar o relatório
    Dado que não estou autenticado
    Quando tento acessar o Relatório Global de Acessos
    Então devo ser redirecionado para a tela de login
    E nenhum dado de acesso deve ser exibido

  Cenário: Filtro sem nenhum acesso correspondente
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo período de "01/01/2026" até "31/01/2026"
    Então deve ser exibida a mensagem "Nenhum acesso encontrado"
    E o total de acessos deve ser 0
    E o valor total arrecadado deve ser R$ 0,00

  Cenário: Data inicial posterior à data final
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo período de "15/10/2026" até "14/10/2026"
    Então deve ser exibida a mensagem "Período inválido"
    E o relatório não deve ser gerado

  Cenário: Filtrar por catraca sem selecionar o restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    Então o filtro de catraca deve estar desabilitado até que um restaurante seja selecionado

  Cenário: Relatório é somente leitura
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    Então não deve existir nenhuma opção para editar ou excluir um registro de acesso

  # --- Esquemas de teste ---
  Esquema do Cenário: Filtro por restaurante e catraca
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo restaurante "<restaurante>"
    E filtro pela catraca "<catraca>"
    Então devem ser exibidos <quantidade> acessos

    Exemplos:
      | restaurante | catraca    | quantidade |
      | RU Central  | Catraca 01 | 2          |
      | RU Central  | Catraca 02 | 2          |
      | RU Setorial | Catraca 01 | 2          |

  Esquema do Cenário: Filtro por período
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E filtro pelo período de "<data_inicial>" até "<data_final>"
    Então <resultado>

    Exemplos:
      | data_inicial | data_final | resultado                                   |
      | 14/10/2026   | 14/10/2026 | devem ser exibidos 4 acessos                |
      | 15/10/2026   | 15/10/2026 | devem ser exibidos 2 acessos                |
      | 14/10/2026   | 15/10/2026 | devem ser exibidos 6 acessos                |
      | 16/10/2026   | 17/10/2026 | deve ser exibida a mensagem "Nenhum acesso encontrado" |
      | 15/10/2026   | 14/10/2026 | deve ser exibida a mensagem "Período inválido"         |

  Esquema do Cenário: Totais do agrupamento por restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Acessos
    E agrupo os dados por restaurante
    Então o grupo "<restaurante>" deve exibir <total> acessos, sendo <liberados> liberados e <negados> negados
    E o valor arrecadado do grupo "<restaurante>" deve ser R$ <valor>

    Exemplos:
      | restaurante | total | liberados | negados | valor |
      | RU Central  | 4     | 2         | 2       | 5,00  |
      | RU Setorial | 2     | 1         | 1       | 2,50  |