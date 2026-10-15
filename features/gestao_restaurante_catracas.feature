# language: pt
Funcionalidade: Gestão de restaurantes e catracas físicas
  Como administrador
  Quero cadastrar, editar e remover restaurantes e suas respectivas catracas físicas
  Para que os funcionários possam selecioná-las na aplicação de controle

  Contexto:
    Dado que estou logado como administrador
    E estou na página "Gestão de Restaurantes e Catracas Físicas"
    E o restaurante "RU Darcy Ribeiro" está cadastrado com 3 pisos e capacidade de 1200 refeições por hora
    E a catraca "Catraca 01" está associada ao "Piso 1" do restaurante "RU Darcy Ribeiro"

  # ===================== Restaurantes =====================

  # --- Caminho feliz ---
  Cenário: Cadastro de um novo restaurante
    Quando eu cadastro o restaurante "RU Faculdade do Gama" com 1 piso e capacidade de 400 refeições por hora
    Então deve ser exibida a mensagem "Restaurante cadastrado com sucesso"
    E o restaurante "RU Faculdade do Gama" deve aparecer na lista de unidades cadastradas
    E o total de restaurantes deve ser 2

  Cenário: Edição dos dados de um restaurante
    Quando eu altero a capacidade do restaurante "RU Darcy Ribeiro" para 1500 refeições por hora
    Então deve ser exibida a mensagem "Restaurante atualizado com sucesso"
    E o restaurante "RU Darcy Ribeiro" deve ter capacidade de 1500 refeições por hora

  Cenário: Remoção de um restaurante sem catracas associadas
    Dado que o restaurante "RU Faculdade do Gama" está cadastrado sem catracas associadas
    Quando eu removo o restaurante "RU Faculdade do Gama"
    E confirmo a remoção
    Então deve ser exibida a mensagem "Restaurante removido com sucesso"
    E o restaurante "RU Faculdade do Gama" não deve aparecer na lista de unidades cadastradas

  # --- Caminhos tristes ---
  Cenário: Cadastro de restaurante com nome já existente
    Quando eu cadastro o restaurante "RU Darcy Ribeiro" com 1 piso e capacidade de 400 refeições por hora
    Então deve ser exibida a mensagem "Já existe um restaurante com esse nome"
    E o total de restaurantes deve ser 1

  Cenário: Remoção de restaurante que possui catracas associadas
    Quando eu removo o restaurante "RU Darcy Ribeiro"
    E confirmo a remoção
    Então deve ser exibida a mensagem "Remova as catracas do restaurante antes de excluí-lo"
    E o restaurante "RU Darcy Ribeiro" deve continuar na lista de unidades cadastradas

  Cenário: Cancelamento da remoção de um restaurante
    Dado que o restaurante "RU Faculdade do Gama" está cadastrado sem catracas associadas
    Quando eu removo o restaurante "RU Faculdade do Gama"
    Mas cancelo a remoção
    Então o restaurante "RU Faculdade do Gama" deve continuar na lista de unidades cadastradas

  # ===================== Catracas =====================

  # --- Caminho feliz ---
  Cenário: Associação de uma nova catraca a um restaurante
    Quando eu associo a catraca "Catraca 02" ao "Piso 1" do restaurante "RU Darcy Ribeiro"
    Então deve ser exibida a mensagem "Catraca cadastrada com sucesso"
    E a catraca "Catraca 02" deve aparecer no "Piso 1" do restaurante "RU Darcy Ribeiro"
    E o total de catracas cadastradas deve ser 2

  Cenário: Catraca cadastrada fica disponível na aplicação de controle
    Dado que eu associei a catraca "Catraca 02" ao "Piso 1" do restaurante "RU Darcy Ribeiro"
    Quando um funcionário abre a lista de catracas do restaurante "RU Darcy Ribeiro" na aplicação de controle
    Então a catraca "Catraca 02" deve estar disponível para seleção

  Cenário: Catraca removida deixa de estar disponível na aplicação de controle
    Dado que eu removi a catraca "Catraca 01"
    Quando um funcionário abre a lista de catracas do restaurante "RU Darcy Ribeiro" na aplicação de controle
    Então a catraca "Catraca 01" não deve estar disponível para seleção

  # --- Caminhos tristes ---
  Cenário: Cadastro de catraca com identificação repetida no mesmo restaurante
    Quando eu associo a catraca "Catraca 01" ao "Piso 2" do restaurante "RU Darcy Ribeiro"
    Então deve ser exibida a mensagem "Já existe uma catraca com essa identificação neste restaurante"
    E o total de catracas cadastradas deve ser 1

  Cenário: Remoção de uma catraca em operação
    Dado que a catraca "Catraca 01" está selecionada por um funcionário na aplicação de controle
    Quando eu removo a catraca "Catraca 01"
    E confirmo a remoção
    Então deve ser exibida a mensagem "Não é possível remover uma catraca em operação"
    E a catraca "Catraca 01" deve continuar no "Piso 1" do restaurante "RU Darcy Ribeiro"

  # --- Esquemas de teste ---
  Esquema do Cenário: Validação dos dados no cadastro de restaurante
    Quando eu cadastro o restaurante "<nome>" com <pisos> piso(s) e capacidade de <capacidade> refeições por hora
    Então deve ser exibida a mensagem "<mensagem>"

    Exemplos:
      | nome                 | pisos | capacidade | mensagem                                 |
      | RU Faculdade do Gama | 1     | 400        | Restaurante cadastrado com sucesso       |
      |                      | 1     | 400        | Nome do restaurante é obrigatório        |
      | RU Darcy Ribeiro     | 1     | 400        | Já existe um restaurante com esse nome   |
      | RU Planaltina        | 0     | 400        | O restaurante deve ter ao menos 1 piso   |
      | RU Planaltina        | 1     | 0          | A capacidade deve ser maior que zero     |
      | RU Planaltina        | 1     | -10        | A capacidade deve ser maior que zero     |

  Esquema do Cenário: Validação dos dados no cadastro de catraca
    Quando eu associo a catraca "<catraca>" ao "<piso>" do restaurante "<restaurante>"
    Então deve ser exibida a mensagem "<mensagem>"

    Exemplos:
      | catraca    | piso   | restaurante      | mensagem                                                       |
      | Catraca 02 | Piso 1 | RU Darcy Ribeiro | Catraca cadastrada com sucesso                                 |
      |            | Piso 1 | RU Darcy Ribeiro | Identificação da catraca é obrigatória                         |
      | Catraca 01 | Piso 3 | RU Darcy Ribeiro | Já existe uma catraca com essa identificação neste restaurante |
      | Catraca 02 | Piso 4 | RU Darcy Ribeiro | Piso inexistente para este restaurante                         |
      | Catraca 02 | Piso 1 | RU Inexistente   | Restaurante não encontrado                                     |