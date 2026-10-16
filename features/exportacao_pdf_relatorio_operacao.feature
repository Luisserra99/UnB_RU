# language: pt
# Issue: https://github.com/neatzzy/UnB_RU/issues/12

Funcionalidade: Exportação em PDF do Relatório de Operação
  Como administrador geral do sistema
  Quero exportar o Relatório Global de Operação em PDF
  Para realizar auditorias internas dos acessos aos restaurantes

  Contexto:
    Dado que estou autenticado como administrador geral "Daniel Dezan Baby"
    E estou na página "Relatório Global de Operação"
    E existem os seguintes acessos registrados:
      | acesso | data_hora        | matricula | restaurante      | catraca    | refeicao      | valor_debitado |
      | A001   | 14/10/2026 07:30 | 232046097 | RU Darcy Ribeiro | Catraca 01 | Café da Manhã | 4,50           |
      | A002   | 15/10/2026 12:10 | 222005448 | RU Darcy Ribeiro | Catraca 01 | Almoço        | 4,50           |
      | A003   | 15/10/2026 12:20 | 251033574 | RU Darcy Ribeiro | Catraca 02 | Almoço        | 4,50           |
      | A004   | 15/10/2026 19:10 | 242012029 | RU Gama          | Catraca 01 | Jantar        | 4,50           |
      | A005   | 16/10/2026 12:00 | 222014133 | RU Gama          | Catraca 01 | Almoço        | 4,50           |

  # Caminhos felizes
  Cenário: Exportar o relatório de todos os restaurantes no período selecionado
    Dado que filtrei o período de "14/10/2026" a "15/10/2026"
    E selecionei todos os restaurantes e todas as catracas
    Quando solicito a exportação em PDF
    Então deve ser baixado um arquivo PDF válido
    E o PDF deve conter os acessos "A001, A002, A003, A004"
    E o PDF não deve conter o acesso "A005"
    E cada acesso deve apresentar data e hora, matrícula, restaurante, catraca, refeição e valor debitado
    E o PDF deve apresentar 4 acessos e o total debitado de R$ 18,00

  Cenário: Identificar a emissão e os critérios usados na auditoria
    Dado que a data e hora da emissão é "16/10/2026 20:00"
    E filtrei o período de "14/10/2026" a "15/10/2026"
    E filtrei o restaurante "RU Darcy Ribeiro" e a catraca "Catraca 01"
    E agrupei o relatório por restaurante e catraca
    Quando solicito a exportação em PDF
    Então o PDF deve identificar o administrador "Daniel Dezan Baby"
    E deve apresentar a data e hora da emissão "16/10/2026 20:00"
    E deve apresentar o período de "14/10/2026" a "15/10/2026"
    E deve apresentar o restaurante "RU Darcy Ribeiro", a catraca "Catraca 01" e o agrupamento aplicado

  Esquema do Cenário: Exportar somente os acessos que correspondem aos filtros
    Dado que filtrei o período de "<inicio>" a "<fim>"
    E filtrei o restaurante "<restaurante>" e a catraca "<catraca>"
    Quando solicito a exportação em PDF
    Então o PDF deve conter somente os acessos "<acessos>"
    E deve apresentar <quantidade> acessos e o total debitado de R$ <total>

    Exemplos:
      | inicio     | fim        | restaurante      | catraca    | acessos                      | quantidade | total |
      | 14/10/2026 | 16/10/2026 | Todos            | Todas      | A001, A002, A003, A004, A005 | 5          | 22,50 |
      | 14/10/2026 | 15/10/2026 | RU Darcy Ribeiro | Todas      | A001, A002, A003             | 3          | 13,50 |
      | 14/10/2026 | 15/10/2026 | RU Darcy Ribeiro | Catraca 01 | A001, A002                   | 2          | 9,00  |
      | 15/10/2026 | 15/10/2026 | RU Darcy Ribeiro | Catraca 01 | A002                         | 1          | 4,50  |
      | 14/10/2026 | 15/10/2026 | RU Gama          | Catraca 01 | A004                         | 1          | 4,50  |

  Cenário: Preservar os agrupamentos de catracas por restaurante
    Dado que filtrei o período de "14/10/2026" a "15/10/2026"
    E selecionei todos os restaurantes e todas as catracas
    E agrupei o relatório por restaurante e catraca
    Quando solicito a exportação em PDF
    Então o PDF deve apresentar os seguintes subtotais separados:
      | restaurante      | catraca    | quantidade | total_debitado |
      | RU Darcy Ribeiro | Catraca 01 | 2          | 9,00           |
      | RU Darcy Ribeiro | Catraca 02 | 1          | 4,50           |
      | RU Gama          | Catraca 01 | 1          | 4,50           |
    E deve apresentar 3 acessos e R$ 13,50 para o restaurante "RU Darcy Ribeiro"
    E deve apresentar 1 acesso e R$ 4,50 para o restaurante "RU Gama"
    E deve apresentar o total geral de 4 acessos e R$ 18,00

  Cenário: Exportar todos os resultados mesmo com listagem paginada
    Dado que filtrei o período de "14/10/2026" a "15/10/2026"
    E selecionei todos os restaurantes e todas as catracas
    E a listagem exibe apenas 2 acessos por página
    E estou visualizando a primeira página
    Quando solicito a exportação em PDF
    Então o PDF deve conter os acessos "A001, A002, A003, A004"
    E deve apresentar 4 acessos e o total debitado de R$ 18,00

  # Caminhos tristes
  Cenário: Tentar exportar um período sem acessos
    Dado que filtrei o período de "01/10/2026" a "02/10/2026"
    E selecionei todos os restaurantes e todas as catracas
    Quando solicito a exportação em PDF
    Então deve ser exibida a mensagem "Não há acessos para os filtros selecionados"
    E nenhum arquivo deve ser baixado

  Cenário: Tentar exportar com período invertido
    Quando informo o período de "16/10/2026" a "14/10/2026" para a exportação
    Então deve ser exibida a mensagem "A data inicial deve ser anterior ou igual à data final"
    E nenhum arquivo deve ser gerado

  Esquema do Cenário: Impedir exportação por um perfil sem permissão
    Dado que encerrei a sessão de administrador geral
    E estou autenticado apenas como "<perfil>"
    Quando tento acessar diretamente a exportação em PDF do relatório de operação
    Então o acesso deve ser negado por falta de permissão
    E nenhum arquivo deve ser gerado

    Exemplos:
      | perfil      |
      | funcionário |
      | estudante   |

  Esquema do Cenário: Exigir uma sessão válida para exportar
    Dado que minha sessão está "<estado>"
    Quando tento acessar diretamente a exportação em PDF do relatório de operação
    Então devo ser direcionado ao login
    E nenhum arquivo deve ser gerado

    Exemplos:
      | estado    |
      | encerrada |
      | expirada  |

  Cenário: Tratar falha na geração do arquivo
    Dado que filtrei o período de "14/10/2026" a "15/10/2026"
    E selecionei todos os restaurantes e todas as catracas
    E ocorre uma falha no serviço de geração de PDF
    Quando solicito a exportação em PDF
    Então deve ser exibida a mensagem "Não foi possível gerar o PDF. Tente novamente"
    E nenhum arquivo incompleto deve ser disponibilizado
    E devo poder tentar a exportação novamente
    E os acessos registrados e seus valores devem permanecer inalterados
