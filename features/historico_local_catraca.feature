# language: pt
Funcionalidade: Histórico local de acessos da catraca
  Como funcionário
  Eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento
  Para que eu possa realizar auditorias ou conferências locais de fluxo

  Contexto:
    Dado que o valor da refeição é R$ 2,50
    E que o aluno de matrícula "251033574" está cadastrado
    E que o funcionário de matrícula "100200300" e senha "Senha@123" está cadastrado
    E que o funcionário de matrícula "100200301" e senha "Senha@456" está cadastrado
    E que o funcionário "100200300" está gerenciando a catraca "CAT-01"
    E que o funcionário "100200301" está gerenciando a catraca "CAT-02"

  # --- Visualização do histórico: caminho feliz ---
  Cenário: Funcionário com credencial válida visualiza apenas o histórico da sua catraca
    Dado que existem os seguintes registros no histórico:
      | catraca | identificacao | data       | hora     | saldo_lido | catraca_liberada | acesso_realizado | timestamp_liberacao | timestamp_bloqueio |
      | CAT-01  | 251033574     | 14/10/2026 | 11:30:00 | 10,00      | S                | S                | 11:30:01            | 11:30:03           |
      | CAT-01  | 251033574     | 14/10/2026 | 18:00:00 | 2,00       | N                | N                |                     |                    |
      | CAT-02  | 251033574     | 14/10/2026 | 12:15:00 | 7,50       | S                | S                | 12:15:01            | 12:15:04           |
    Quando o funcionário informa a matrícula "100200300" e a senha "Senha@123" na catraca "CAT-01"
    E solicita a visualização do histórico de acessos
    Então a credencial do funcionário deve ser validada
    E devem ser exibidos os seguintes registros:
      | identificacao | data       | hora     | saldo_lido | catraca_liberada | acesso_realizado | timestamp_liberacao | timestamp_bloqueio |
      | 251033574     | 14/10/2026 | 11:30:00 | 10,00      | S                | S                | 11:30:01            | 11:30:03           |
      | 251033574     | 14/10/2026 | 18:00:00 | 2,00       | N                | N                |                     |                    |
    Mas não devem ser exibidos registros da catraca "CAT-02"

  Cenário: Funcionário visualiza o histórico de uma catraca sem acessos registrados
    Dado que não existem registros no histórico da catraca "CAT-01"
    Quando o funcionário informa a matrícula "100200300" e a senha "Senha@123" na catraca "CAT-01"
    E solicita a visualização do histórico de acessos
    Então a credencial do funcionário deve ser validada
    E deve ser exibida a mensagem "Nenhum acesso registrado nesta catraca"

  # --- Visualização do histórico: caminhos tristes ---
  Esquema do Cenário: Credencial inválida ou sem permissão para a catraca
    Quando o funcionário informa a matrícula "<matricula>" e a senha "<senha>" na catraca "CAT-01"
    E solicita a visualização do histórico de acessos
    Então o histórico de acessos não deve ser exibido
    E deve ser exibida a mensagem "<mensagem>"

    Exemplos:
      | matricula | senha       | mensagem                                     |
      |           | Senha@123   | Credencial inválida                          |
      | 100200300 |             | Credencial inválida                          |
      | 100200300 | SenhaErrada | Credencial inválida                          |
      | abc123xyz | Senha@123   | Credencial inválida                          |
      | 999999999 | Senha@123   | Credencial inválida                          |
      | 100200301 | Senha@456   | Credencial inválida                          |

  # --- Registro no histórico ---
  Cenário: Registro de acesso realizado com sucesso
    Dado que o aluno "251033574" possui saldo de R$ 10,00
    Quando a identificação "251033574" é lida na catraca "CAT-01" em "14/10/2026" às "11:30:00"
    E a catraca é liberada às "11:30:01"
    E o aluno passa pela catraca às "11:30:03"
    Então a catraca deve ser bloqueada às "11:30:03"
    E deve ser registrado no histórico da catraca "CAT-01":
      | identificacao | data       | hora     | saldo_lido | catraca_liberada | acesso_realizado | timestamp_liberacao | timestamp_bloqueio |
      | 251033574     | 14/10/2026 | 11:30:00 | 10,00      | S                | S                | 11:30:01            | 11:30:03           |

  Cenário: Registro de acesso negado por saldo insuficiente
    Dado que o aluno "251033574" possui saldo de R$ 2,00
    Quando a identificação "251033574" é lida na catraca "CAT-01" em "14/10/2026" às "18:00:00"
    Então deve ser registrado no histórico da catraca "CAT-01":
      | identificacao | data       | hora     | saldo_lido | catraca_liberada | acesso_realizado | timestamp_liberacao | timestamp_bloqueio |
      | 251033574     | 14/10/2026 | 18:00:00 | 2,00       | N                | N                |                     |                    |

  Cenário: Registro de catraca liberada sem passagem do aluno
    Dado que o aluno "251033574" possui saldo de R$ 10,00
    Quando a identificação "251033574" é lida na catraca "CAT-01" em "14/10/2026" às "12:00:00"
    E a catraca é liberada às "12:00:01"
    Mas o aluno não passa pela catraca em até 5 segundos
    Então a catraca é bloqueada às "12:00:06"
    E deve ser registrado no histórico da catraca "CAT-01":
      | identificacao | data       | hora     | saldo_lido | catraca_liberada | acesso_realizado | timestamp_liberacao | timestamp_bloqueio |
      | 251033574     | 14/10/2026 | 12:00:00 | 10,00      | S                | N                | 12:00:01            | 12:00:06           |

  Esquema do Cenário: Registro de leitura de identificação inválida ou desconhecida
    Quando a identificação "<identificacao>" é lida na catraca "CAT-01" em "14/10/2026" às "13:00:00"
    Então deve ser registrado no histórico da catraca "CAT-01":
      | identificacao   | data       | hora     | saldo_lido | catraca_liberada | acesso_realizado | timestamp_liberacao | timestamp_bloqueio |
      | <identificacao> | 14/10/2026 | 13:00:00 |            | N                | N                |                     |                    |

    Exemplos:
      | identificacao |
      | abc123xyz     |
      | 12345         |
      | 25103357      |
