# language: pt
Funcionalidade: Exportação em PDF do histórico do estudante
  Como estudante
  Quero poder exportar meu Extrato e Histórico de Refeições como PDF
  Para poder controlar melhor as minhas finanças.

  Contexto:
    Dado que estou logado como estudante com matrícula "221045999"
    E estou na página "Extrato e Histórico de Refeições"
    E o valor da refeição é R$ 4,50
    E meu saldo atual é R$ 18,00
    E possuo os seguintes lançamentos nos últimos 30 dias:
      | data_hora        | evento            | local                     | catraca    | metodo_acesso     | valor  |
      | 09/05/2024 12:40 | Almoço            | RU Darcy Ribeiro - Piso 3 | Catraca 05 | QR Code App       | -4,50  |
      | 10/05/2024 14:00 | Recarga de Saldo  | Pagamento Instantâneo PIX |            | Saldo em Carteira | +45,00 |
      | 13/05/2024 07:45 | Café da Manhã     | RU Darcy Ribeiro - Piso 1 | Catraca 02 | QR Code App       | -4,50  |
      | 13/05/2024 19:10 | Jantar            | RU Darcy Ribeiro - Piso 1 | Catraca 01 | QR Code App       | -4,50  |
      | 14/05/2024 12:20 | Almoço            | RU Darcy Ribeiro - Piso 2 | Catraca 04 | QR Code App       | -4,50  |

  # --- Caminho feliz ---
  Cenário: Exportação do extrato completo com os filtros padrão
    Dado que os filtros estão com os valores padrão
    Quando eu clico em "Exportar PDF"
    Então deve ser baixado um arquivo PDF do extrato
    E o PDF deve conter os 5 lançamentos listados
    E o PDF deve exibir o total gasto de R$ 18,00
    E o PDF deve exibir 4 refeições realizadas
    E o PDF deve exibir o total recarregado de R$ 45,00
    E o PDF deve exibir o saldo atual de R$ 18,00

  Cenário: PDF contém a identificação da estudante e os filtros aplicados
    Quando eu clico em "Exportar PDF"
    Então o PDF deve exibir o nome "Ana Beatriz Silva" e a matrícula "221045999"
    E o PDF deve exibir o período de referência "Últimos 30 dias"
    E o PDF deve exibir a data de emissão
    E o PDF deve exibir a indicação "Registros auditáveis assinados digitalmente"

  Cenário: PDF respeita os filtros aplicados na tela
    Quando eu filtro o tipo de refeição por "Almoço"
    E clico em "Exportar PDF"
    Então o PDF deve conter apenas os 2 lançamentos de "Almoço"
    E o PDF não deve conter o lançamento "Recarga de Saldo"
    E o PDF deve exibir o total gasto de R$ 9,00

  Cenário: PDF contém apenas os lançamentos da própria estudante
    Dado que o estudante de matrícula "231012345" possui um "Almoço" em "13/05/2024 12:00"
    Quando eu clico em "Exportar PDF"
    Então o PDF não deve conter lançamentos do estudante "231012345"

  # --- Caminhos tristes ---
  Cenário: Exportação com filtros que não retornam lançamentos
    Quando eu filtro o tipo de refeição por "Jantar"
    E filtro o restaurante pela "Catraca 05"
    E clico em "Exportar PDF"
    Então deve ser exibida a mensagem "Não há lançamentos para os filtros selecionados"
    E nenhum arquivo deve ser baixado

  Cenário: Exportação com a sessão expirada
    Dado que minha sessão expirou
    Quando eu clico em "Exportar PDF"
    Então devo ser redirecionado para a página de login
    E deve ser exibida a mensagem "Sua sessão expirou. Faça login novamente"
    E nenhum arquivo deve ser baixado

 Cenário: Estudante sem nenhum lançamento registrado
    Dado que não possuo nenhum lançamento
    Quando acesso a página "Extrato e Histórico de Refeições"
    Então o botão "Exportar PDF" deve estar desabilitado
    E deve ser exibida a mensagem "Você ainda não possui lançamentos"


  # --- Esquemas de teste ---
  Esquema do Cenário: Totais do PDF conforme os filtros aplicados
    Quando eu filtro o tipo de refeição por "<tipo>"
    E filtro o restaurante pela "<catraca>"
    E clico em "Exportar PDF"
    Então o PDF deve conter <qtd_lancamentos> lançamento(s)
    E o PDF deve exibir o total gasto de R$ <gasto>
    E o PDF deve exibir o total recarregado de R$ <recarregado>

    Exemplos:
      | tipo                | catraca               | qtd_lancamentos | gasto | recarregado |
      | Todas as Refeições  | Todas as 6 Catracas   | 5               | 18,00 | 45,00       |
      | Almoço              | Todas as 6 Catracas   | 2               | 9,00  | 0,00        |
      | Café da Manhã       | Todas as 6 Catracas   | 1               | 4,50  | 0,00        |
      | Jantar              | Todas as 6 Catracas   | 1               | 4,50  | 0,00        |
      | Recarga de Saldo    | Todas as 6 Catracas   | 1               | 0,00  | 45,00       |
      | Todas as Refeições  | Catraca 01            | 1               | 4,50  | 0,00        |
      | Almoço              | Catraca 04            | 1               | 4,50  | 0,00        |

  Esquema do Cenário: Exportação conforme o período de referência
    Dado que hoje é "14/05/2024"
    Quando eu seleciono o período de referência "<periodo>"
    E clico em "Exportar PDF"
    Então o PDF deve conter <qtd_lancamentos> lançamento(s)
    E o PDF deve exibir o período de referência "<periodo>"

    Exemplos:
      | periodo         | qtd_lancamentos |
      | Últimos 30 dias | 5               |
      | Últimos 7 dias  | 5               |
      | Hoje            | 1               |
