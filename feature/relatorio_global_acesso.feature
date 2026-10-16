Funcionalidade: Relatório Global de Operação
  Como administrador
  Eu quero visualizar o relatório global de operação dos restaurantes do campus, filtrando por data, turno e unidade
  Para ter uma visão gerencial consolidada de acessos, arrecadação e liquidação

  Contexto:
    Dado que a tarifa fixa universitária é R$ 4,50 por refeição de almoço e janta, e 2,50 para café da manhã
    E que o "Campus Darcy Ribeiro" possui 6 restaurantes e 6 catracas cadastradas, todas online
    E que em "24/10/2025" foram registrados os seguintes acessos por restaurante:
      | restaurante   | acessos |
      | Restaurante 1 | 2100    |
      | Restaurante 2 | 720     |
      | Restaurante 3 | 710     |
      | Restaurante 4 | 480     |
      | Restaurante 5 | 460     |
      | Restaurante 6 | 350     |
    E que em "24/10/2025" foram registrados os seguintes acessos por turno:
      | turno         | acessos |
      | Café da Manhã | 650     |
      | Almoço        | 2980    |
      | Jantar        | 1190    |
    E que a arrecadação de "24/10/2025" foi liquidada nos seguintes métodos:
      | metodo                        | valor       |
      | PIX Institucional Instantâneo | R$ 15616,80 |
      | Cartão de Crédito / Débito    | R$ 6073,20  |

  # --- Caminho feliz ---
  Cenário: Administrador abre o relatório com os filtros padrão
    Dado que sou um administrador autenticado
    E que a data atual é "24/10/2025"
    Quando acesso o Relatório Global de Operação
    Então o filtro de data contábil deve exibir "Hoje (24/10/2025)"
    E o filtro de janela de serviço deve exibir "Todos os Turnos (Café, Almoço, Jantar)"
    E o filtro de unidade gestora deve exibir "Campus Darcy Ribeiro"

  Cenário: Indicador de catracas online
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então o indicador de catracas online deve exibir "6/6"

  Cenário: Card de arrecadação global exibe a soma de todos os restaurantes
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então o card "Arrecadação Global" deve exibir "R$ 21.690,00"

  Cenário: Tabela de consolidação exibe uma linha por restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então a tabela de consolidação deve exibir as seguintes linhas, nesta ordem:
      | restaurante   | acessos | arrecadacao_bruta |
      | Restaurante 1 | 2.100   | R$ 9.450,00       |
      | Restaurante 2 | 720     | R$ 3.240,00       |
      | Restaurante 3 | 710     | R$ 3.195,00       |
      | Restaurante 4 | 480     | R$ 2.160,00       |
      | Restaurante 5 | 460     | R$ 2.070,00       |
      | Restaurante 6 | 350     | R$ 1.575,00       |

  Cenário: Linha de total consolidado
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então a linha "Total Consolidado" deve exibir 4.820 acessos
    E a linha "Total Consolidado" deve exibir arrecadação de "R$ 21.690,00"

  Cenário: Painel de métodos de liquidação
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então o método "PIX Institucional Instantâneo" deve exibir "72%" e "R$ 15.616,80"
    E o método "Cartão de Crédito / Débito" deve exibir "28%" e "R$ 6.073,20"
    E a soma dos métodos de liquidação deve ser igual a "R$ 21.690,00"

  Cenário: Filtrar por janela de serviço recalcula todo o relatório
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    E seleciono a janela de serviço "Almoço"
    Então o card "Arrecadação Global" deve exibir "R$ 13.410,00"
    E a linha "Total Consolidado" deve exibir 2.980 acessos
    E a soma dos métodos de liquidação deve ser igual a "R$ 13.410,00"
    E as transações validadas devem ser 2.980 operações

  Cenário: Filtrar por uma data contábil anterior
    Dado que sou um administrador autenticado
    E que em "23/10/2025" o campus teve 4.000 acessos
    Quando acesso o Relatório Global de Operação
    E seleciono a data contábil "23/10/2025"
    Então o card "Arrecadação Global" deve exibir "R$ 18.000,00"
    E a linha "Total Consolidado" deve exibir 4.000 acessos

  Cenário: Filtros de data e turno atuam em conjunto
    Dado que sou um administrador autenticado
    E que em "23/10/2025" o campus teve 2.000 acessos no turno "Almoço"
    E que em "23/10/2025" o campus teve 1.500 acessos nos demais turnos
    Quando acesso o Relatório Global de Operação
    E seleciono a data contábil "23/10/2025"
    E seleciono a janela de serviço "Almoço"
    Então o card "Arrecadação Global" deve exibir "R$ 9.000,00"
    E a linha "Total Consolidado" deve exibir 2.000 acessos

  Cenário: Restaurante sem acessos no filtro continua listado com valores zerados
    Dado que sou um administrador autenticado
    E que no turno "Jantar" de "24/10/2025" somente o "Restaurante 1" teve acessos
    Quando acesso o Relatório Global de Operação
    E seleciono a janela de serviço "Jantar"
    Então a tabela de consolidação deve exibir 6 restaurantes
    E o "Restaurante 1" deve exibir 1.190 acessos e arrecadação bruta de "R$ 5.355,00"
    E o "Restaurante 2" deve exibir 0 acessos e arrecadação bruta de "R$ 0,00"
    E o "Restaurante 6" deve exibir 0 acessos e arrecadação bruta de "R$ 0,00"

  Cenário: Exportar o relatório em CSV respeitando os filtros
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    E seleciono a janela de serviço "Almoço"
    E clico em "Exportar CSV"
    Então deve ser gerado um arquivo CSV com os dados do relatório
    E o arquivo deve conter somente os dados do turno "Almoço"

  Cenário: Exportar o relatório em PDF oficial
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    E clico em "Exportar PDF Oficial"
    Então deve ser gerado um documento PDF com os mesmos dados exibidos no relatório
    E o documento deve conter os filtros aplicados, a data e hora de emissão e o usuário emissor

  # --- Caminhos tristes ---
  Cenário: Usuário sem perfil de administrador tenta acessar o relatório
    Dado que sou um usuário autenticado com perfil de aluno
    Quando tento acessar o Relatório Global de Operação
    Então o acesso deve ser negado
    E deve ser exibida a mensagem "Acesso não autorizado"
    E nenhum dado operacional deve ser exibido

  Cenário: Nenhum acesso corresponde aos filtros aplicados
    Dado que sou um administrador autenticado
    E que não há acessos registrados em "01/01/2025"
    Quando acesso o Relatório Global de Operação
    E seleciono a data contábil "01/01/2025"
    Então deve ser exibida a mensagem "Nenhum acesso encontrado"
    E o card "Arrecadação Global" deve exibir "R$ 0,00"
    E a linha "Total Consolidado" deve exibir 0 acessos
    E a linha "Total Consolidado" deve exibir arrecadação de "R$ 0,00"
    E os métodos de liquidação devem exibir "R$ 0,00"

  Cenário: Catraca offline é refletida no indicador de catracas online
    Dado que sou um administrador autenticado
    E que 1 das 6 catracas cadastradas está offline
    Quando acesso o Relatório Global de Operação
    Então o indicador de catracas online deve exibir "5/6"

  Cenário: Relatório é somente leitura
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então não deve existir nenhuma opção para editar ou excluir dados operacionais

  # --- Esquemas de teste ---
  Esquema do Cenário: Arrecadação bruta por restaurante
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    Então o "<restaurante>" deve exibir <acessos> acessos e arrecadação bruta de "R$ <arrecadacao>"

    Exemplos:
      | restaurante   | acessos | arrecadacao |
      | Restaurante 1 | 2.100   | 9.450,00    |
      | Restaurante 2 | 720     | 3.240,00    |
      | Restaurante 3 | 710     | 3.195,00    |
      | Restaurante 4 | 480     | 2.160,00    |
      | Restaurante 5 | 460     | 2.070,00    |
      | Restaurante 6 | 350     | 1.575,00    |

  Esquema do Cenário: Filtro de janela de serviço
    Dado que sou um administrador autenticado
    Quando acesso o Relatório Global de Operação
    E seleciono a janela de serviço "<turno>"
    Então o card "Arrecadação Global" deve exibir "R$ <arrecadacao>"
    E a linha "Total Consolidado" deve exibir <acessos> acessos

    Exemplos:
      | turno                                  | acessos | arrecadacao |
      | Todos os Turnos (Café, Almoço, Jantar) | 4.820   | 21.690,00   |
      | Café da Manhã                          | 650     | 2.925,00    |
      | Almoço                                 | 2.980   | 13.410,00   |
      | Jantar                                 | 1.190   | 5.355,00    |