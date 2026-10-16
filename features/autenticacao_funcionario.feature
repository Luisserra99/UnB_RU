# language: pt
# Issue: https://github.com/neatzzy/UnB_RU/issues/4

Funcionalidade: Autenticação do Funcionário
  Como funcionário do restaurante
  Eu quero fazer login na aplicação de controle
  Para autenticar minha sessão e operar o sistema de forma segura

  # Caminhos felizes
  Cenário: Funcionário ativo faz login com credenciais válidas
    Dado que o funcionário "funcionario01" está cadastrado e ativo
    E que ele está na tela de login da aplicação de controle
    Quando ele informa sua identificação e a senha correta
    E confirma o login
    Então o sistema deve autenticar a sessão do funcionário
    E deve apresentar a escolha do restaurante e da catraca do ponto de acesso

  Cenário: Funcionário encerra a sessão
    Dado que o funcionário possui uma sessão autenticada
    Quando ele solicita sair da aplicação de controle
    Então o sistema deve encerrar a sessão
    E deve apresentar a tela de login
    E deve exigir novo login para acessar as funções de controle

  # Caminhos tristes
  Cenário: Senha incorreta
    Dado que o funcionário "funcionario01" está cadastrado e ativo
    E que ele está na tela de login da aplicação de controle
    Quando ele informa sua identificação e uma senha incorreta
    E confirma o login
    Então o sistema deve informar que não foi possível autenticar as credenciais
    E não deve criar uma sessão autenticada
    E deve manter a tela de login

  Cenário: Identificação não cadastrada
    Dado que a identificação "desconhecido" não está cadastrada
    E que a tela de login da aplicação de controle está aberta
    Quando o usuário informa a identificação "desconhecido" e uma senha
    E confirma o login
    Então o sistema deve informar que não foi possível autenticar as credenciais
    E não deve criar uma sessão autenticada
    E deve manter a tela de login

  Esquema do Cenário: Credenciais obrigatórias não preenchidas
    Dado que o funcionário "funcionario01" está cadastrado e ativo
    E que a senha correta desse funcionário é "senhaCorreta"
    E que ele está na tela de login da aplicação de controle
    Quando ele informa a identificação "<identificacao>" e a senha "<senha>"
    E confirma o login
    Então o sistema deve indicar os campos obrigatórios não preenchidos
    E não deve criar uma sessão autenticada
    E deve manter a tela de login

    Exemplos:
      | identificacao | senha        |
      |               | senhaCorreta |
      | funcionario01 |              |
      |               |              |

  Cenário: Funcionário inativo tenta fazer login
    Dado que o funcionário "funcionario01" está cadastrado e inativo
    E que ele está na tela de login da aplicação de controle
    Quando ele informa sua identificação e a senha correta
    E confirma o login
    Então o sistema deve informar que não foi possível autenticar as credenciais
    E não deve criar uma sessão autenticada
    E deve manter a tela de login

  Cenário: Estudante tenta acessar a aplicação de controle
    Dado que o usuário possui somente uma conta de estudante ativa
    E que ele está na tela de login da aplicação de controle
    Quando ele informa suas credenciais corretas de estudante
    E confirma o login
    Então o sistema deve negar o acesso à aplicação de controle
    E não deve criar uma sessão de funcionário
    E deve manter a tela de login

  Cenário: Acesso a uma função de controle sem autenticação
    Dado que o usuário não possui uma sessão autenticada de funcionário
    Quando ele tenta acessar diretamente uma função da aplicação de controle
    Então o sistema deve exigir login de funcionário
    E não deve executar a função solicitada

  Cenário: Sessão expirada ao acessar uma função de controle
    Dado que a sessão autenticada do funcionário expirou
    Quando ele tenta acessar uma função da aplicação de controle
    Então o sistema deve exigir novo login de funcionário
    E não deve executar a função solicitada
