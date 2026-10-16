# language: pt
# Issue: https://github.com/neatzzy/UnB_RU/issues/5
Funcionalidade: Configuração de ponto de acesso
  Como funcionário do restaurante
  Eu quero selecionar em qual restaurante e catraca vou gerenciar logo após o login
  Para que o sistema direcione as regras e registre os logs no ponto de acesso correto

  Contexto:
    Dado que o funcionário de identificação "100200300" está cadastrado
    E que os restaurantes "RU Darcy Ribeiro" e "RU Faculdade do Gama" estão cadastrados e ativos
    E que a catraca "CAT-01" está cadastrada e ativa no restaurante "RU Darcy Ribeiro"
    E que a catraca "CAT-02" está cadastrada e ativa no restaurante "RU Faculdade do Gama"

  # --- Configuração do ponto de acesso: caminhos felizes ---
  Cenário: Solicitar a seleção de ponto de acesso logo após o login
    Quando o funcionário "100200300" realiza o login com sucesso
    Então o sistema deve solicitar a seleção de um restaurante e de uma catraca
    E deve apresentar os restaurantes cadastrados e ativos
    E o funcionário ainda não deve possuir um ponto de acesso configurado na sessão
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis

  Cenário: Listar somente as catracas do restaurante selecionado
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    Quando seleciona o restaurante "RU Darcy Ribeiro"
    Então a catraca "CAT-01" deve estar disponível para seleção
    Mas a catraca "CAT-02" não deve estar disponível para seleção

  Cenário: Confirmar um ponto de acesso válido
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E selecionou o restaurante "RU Darcy Ribeiro"
    E selecionou a catraca "CAT-01"
    Quando confirma o ponto de acesso em "15/10/2026" às "11:00:00"
    Então a sessão deve ter como ponto de acesso o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01"
    E as operações de controle devem utilizar as regras do restaurante "RU Darcy Ribeiro"
    E deve ser registrado o evento de configuração do ponto de acesso com:
      | funcionario | restaurante      | catraca | data       | hora     |
      | 100200300   | RU Darcy Ribeiro | CAT-01  | 15/10/2026 | 11:00:00 |

  Cenário: Associar os registros de operação ao ponto de acesso da sessão
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E configurou o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01" como ponto de acesso
    Quando realiza uma operação de controle registrada em "15/10/2026" às "11:30:00"
    Então o registro da operação deve identificar o funcionário "100200300"
    E deve identificar o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01"
    E deve identificar a data "15/10/2026" e a hora "11:30:00"

  Cenário: Trocar de restaurante e configurar uma nova catraca
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E configurou o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01" como ponto de acesso
    E iniciou a alteração do ponto de acesso
    Quando seleciona o restaurante "RU Faculdade do Gama"
    Então a seleção da catraca "CAT-01" deve ser removida do formulário de alteração
    E o ponto de acesso confirmado deve continuar sendo o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01" até uma nova confirmação válida
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis enquanto a reconfiguração estiver pendente
    Quando seleciona a catraca "CAT-02" e confirma o ponto de acesso
    Então a sessão deve ter como ponto de acesso o restaurante "RU Faculdade do Gama" e a catraca "CAT-02"
    E a reconfiguração deve ser concluída e as operações do novo ponto de acesso devem ficar disponíveis
    E os novos registros de operação devem utilizar o novo ponto de acesso
    E os registros anteriores devem manter o ponto de acesso em que foram gerados

  # --- Configuração do ponto de acesso: caminhos tristes ---
  Esquema do Cenário: Não confirmar um ponto de acesso incompleto
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E ainda não configurou um ponto de acesso
    Quando tenta confirmar o restaurante "<restaurante>" e a catraca "<catraca>"
    Então deve ser exibida a mensagem "<mensagem>"
    E nenhum ponto de acesso deve ser configurado na sessão
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis

    Exemplos:
      | restaurante      | catraca | mensagem                           |
      |                  |         | Selecione um restaurante            |
      | RU Darcy Ribeiro |         | Selecione uma catraca do restaurante |

  Cenário: Rejeitar uma catraca que pertence a outro restaurante
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E selecionou o restaurante "RU Darcy Ribeiro"
    Quando tenta confirmar a catraca "CAT-02"
    Então deve ser exibida a mensagem "A catraca não pertence ao restaurante selecionado"
    E nenhum ponto de acesso deve ser configurado na sessão
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis

  Esquema do Cenário: Rejeitar restaurante ou catraca indisponível sem alterar o ponto de acesso atual
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E configurou o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01" como ponto de acesso
    E iniciou a alteração do ponto de acesso
    E o cadastro "<cadastro>" está "<situacao>"
    Quando tenta confirmar o restaurante "<restaurante>" e a catraca "<catraca>" como novo ponto de acesso
    Então deve ser exibida a mensagem "<mensagem>"
    E o ponto de acesso confirmado da sessão deve continuar sendo o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01"
    E a reconfiguração deve permanecer pendente
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis até uma nova confirmação válida
    E a tentativa não deve ser registrada como uma configuração concluída

    Exemplos:
      | cadastro             | situacao    | restaurante          | catraca | mensagem                  |
      | RU Inexistente       | inexistente | RU Inexistente       | CAT-02  | Restaurante indisponível  |
      | RU Faculdade do Gama | inativo     | RU Faculdade do Gama | CAT-02  | Restaurante indisponível  |
      | CAT-99               | inexistente | RU Darcy Ribeiro     | CAT-99  | Catraca indisponível      |
      | CAT-03               | inativo     | RU Darcy Ribeiro     | CAT-03  | Catraca indisponível      |

  Cenário: Revalidar a disponibilidade ao confirmar a seleção
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E selecionou o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01"
    E a catraca "CAT-01" deixou de estar disponível após a seleção
    Quando confirma o ponto de acesso
    Então deve ser exibida a mensagem "Catraca indisponível"
    E nenhum ponto de acesso deve ser configurado na sessão
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis

  Cenário: Não existem restaurantes disponíveis para seleção
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E todos os restaurantes cadastrados foram desativados
    Quando acessa a seleção de ponto de acesso
    Então deve ser exibida a mensagem "Nenhum restaurante disponível"
    E nenhum ponto de acesso deve ser configurado na sessão
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis

  Cenário: O restaurante selecionado não possui catracas disponíveis
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E todas as catracas do restaurante "RU Darcy Ribeiro" foram desativadas
    Quando seleciona o restaurante "RU Darcy Ribeiro"
    Então deve ser exibida a mensagem "Nenhuma catraca disponível neste restaurante"
    E a confirmação do ponto de acesso deve permanecer indisponível
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis

  Cenário: Impedir a configuração sem autenticação
    Dado que o funcionário "100200300" não possui uma sessão autenticada ativa
    Quando tenta configurar o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01"
    Então o sistema deve solicitar o login do funcionário
    E nenhum ponto de acesso deve ser configurado

  Esquema do Cenário: Não reutilizar o ponto de acesso após o encerramento da sessão
    Dado que o funcionário "100200300" possui uma sessão autenticada ativa
    E configurou o restaurante "RU Darcy Ribeiro" e a catraca "CAT-01" como ponto de acesso
    Quando a sessão é encerrada por "<motivo>"
    Então o ponto de acesso deve ser removido da sessão
    E o sistema deve exigir autenticação para realizar operações de controle
    Quando o funcionário realiza um novo login com sucesso
    Então o sistema deve solicitar novamente a seleção de restaurante e catraca
    E as operações que dependem do ponto de acesso devem permanecer indisponíveis até a nova confirmação

    Exemplos:
      | motivo    |
      | logout    |
      | expiração |
