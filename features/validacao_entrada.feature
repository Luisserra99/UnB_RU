# language: pt
Funcionalidade: Validação de entrada na catraca do RU
  Como aplicação de controle
  Eu quero ler a identificação do aluno, verificar se há saldo, liberar a catraca e debitar a refeição na passagem
  Para que apenas alunos com saldo entrem no RU e cada refeição seja cobrada uma única vez

  Contexto:
    Dado que o valor da refeição é R$ 2,50
    E que o aluno de matrícula "251033574" está cadastrado

  # --- Caminho feliz ---
  Cenário: Aluno com saldo suficiente passa pela catraca do RU
    Dado que o aluno "251033574" possui saldo de R$ 10,00
    Quando a identificação "251033574" é lida na catraca
    E é verificado que o aluno de identificação "251033574" possui saldo suficiente
    E a catraca é liberada
    E o aluno passa pela catraca em 2 segundos
    Então a catraca deve ser bloqueada
    E deve ser exibida a mensagem "Boa refeição" 
    E o saldo do aluno "251033574" deve ser R$ 7,50

  Cenário: Aluno com saldo exatamente igual ao valor da refeição
    Dado que o aluno "251033574" possui saldo de R$ 2,50
    Quando a identificação "251033574" é lida na catraca
    E é verificado que o aluno de identificação "251033574" possui saldo suficiente
    E a catraca é liberada
    E o aluno passa pela catraca em 2 segundos
    Então a catraca deve ser bloqueada
    E deve ser exibida a mensagem "Boa refeição" 
    E o saldo do aluno "251033574" deve ser R$ 0,00

  # --- Caminhos tristes ---
  Cenário: Aluno com saldo insuficiente
    Dado que o aluno "251033574" possui saldo de R$ 2,00
    Quando a identificação "251033574" é lida na catraca
    E é verificado que o aluno de identificação "251033574" não possui saldo suficiente
    Então a catraca não deve receber o comando de liberação
    E deve ser exibida a mensagem "Saldo insuficiente"
    E o saldo do aluno "251033574" deve ser R$ 2,00

  Cenário: Catraca liberada, mas o aluno não passa
    Dado que o aluno "251033574" possui saldo de R$ 10,00
    Quando a identificação "251033574" é lida na catraca
    E é verificado que o aluno de identificação "251033574" possui saldo suficiente
    E a catraca é liberada
    Mas o aluno não passa pela catraca em até 5 segundos
    Então a catraca deve ser bloqueada
    E deve ser exibida a mensagem "Acesso cancelado"
    E o saldo do aluno "251033574" deve ser R$ 10,00

  # --- Esquemas de teste ---
  Esquema do Cenário: Identificação inválida ou desconhecida
    Quando a identificação "<identificacao>" é lida na catraca
    Então a catraca não deve receber o comando de liberação
    E deve ser exibida a mensagem "<mensagem>"

    Exemplos:
      | identificacao | mensagem                   |
      |               | Identificação desconhecida |
      | abc123xyz     | Identificação desconhecida |
      | 12345         | Identificação desconhecida |
      | 25103357      | Identificação desconhecida |

  Esquema do Cenário: Passagem pela catraca conforme saldo e tempo de passagem
    Dado que o aluno "<identificacao>" possui saldo de R$ <saldo>
    Quando a identificação "<identificacao>" é lida na catraca
    E o aluno tenta passar pela catraca após <timer> segundos
    Então a catraca deve ser bloqueada
    E deve ser exibida a mensagem "<mensagem>"
    E o saldo do aluno "<identificacao>" deve ser R$ <saldo_final>

    Exemplos:
      | identificacao | saldo | timer | mensagem           | saldo_final |
      | 251033574     | 2,00  | 1     | Saldo insuficiente | 2,00        |
      | 251033574     | 2,50  | 2     | Boa refeição       | 0,00        |
      | 251033574     | 10,00 | 3     | Boa refeição       | 7,50        |
      | 251033574     | 10,00 | 5     | Boa refeição       | 7,50        |
      | 251033574     | 10,00 | 6     | Acesso cancelado   | 10,00       |