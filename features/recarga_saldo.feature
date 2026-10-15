Funcionalidade: Recarga de Saldo
  Como estudante da UnB
  Quero comprar créditos para Café da Manhã e Almoço/Jantar
  Para que eu tenha saldo para acessar os restaurantes.

Contexto:
    Dado que o estudante está logado no sistema do UnB RU
    E acessa a página de "Recarga de Saldo"
    E o preço do almoço e da janta é 4,50
    E o preço do café da Manhã é 2,50

  # Caminho Feliz:
  
  Cenário: Gerar cobrança válida de recarga via PIX
    Dado que o estudante seleciona a quantidade de 5 "Cafés da Manhã" e 10 "Almoços/Jantares"
    Quando ele escolhe "PIX" como método de pagamento
    E confirma a solicitação de recarga
    Então o sistema deve calcular o valor total de 57,50, somando o subtotal de Cafés da Manhã com o subtotal de Almoços/Jantares
    E o sistema deve gerar e exibir um QR Code e um código "Copia e Cola"
    E a cobrança deve exibir que o prazo de validade para pagamento é de 10 minutos

  Cenário: Atualização de saldo após pagamento confirmado no Cartão de Crédito
    Dado que o estudante selecionou refeições e escolheu "Cartão de Crédito" como método de pagamento
    Quando ele insere os dados válidos do cartão e finaliza o pagamento
    E o sistema recebe a confirmação da transação de pagamento
    Então o saldo da conta do estudante deve ser efetivamente atualizado com as novas quantidades

  # Caminho Triste:

  Cenário: Tentativa de avançar sem selecionar nenhuma refeição
    Dado que estou na página de recarga de saldo
    Quando a quantidade de Almoço/Jantar for "0"
    E a quantidade de Café da Manhã for "0"
    Então o valor total da recarga deve ser "R$ 0,00"
    E o botão "Confirmar" deve permanecer desabilitado
    E o sistema não deve gerar nenhum código de pagamento

  Cenário: Expiração do pagamento via PIX sem confirmação
    Dado que o estudante gerou uma cobrança via PIX
    E o saldo do estudante ainda não foi atualizado
    Quando se passam 10 minutos sem a confirmação da transação de pagamento
    Então o sistema deve expirar o código PIX gerado
    E o saldo da conta do estudante não deve ser atualizado sob nenhuma circunstância

  # Esquemas de teste 

  Esquema do Cenário: Tentativa de recarga com diferentes quantidades e métodos
    Dado que o estudante seleciona <qtd_cafe> "Cafés da Manhã" e <qtd_almoco> "Almoços/Jantares"
    Quando ele escolhe "<metodo>" como método de pagamento e tenta gerar a cobrança
    Então a cobrança <status_cobranca>
    E o sistema deve exibir a mensagem "<mensagem>"

    Exemplos:
      | qtd_cafe | qtd_almoco | metodo            | status_cobranca     | mensagem                                    |
      | 0        | 0          | PIX               | não deve ser gerada | Não é possível gerar uma cobrança zerada    |
      | 5        | 0          | Cartão de Crédito | deve ser gerada     | Cobrança gerada com sucesso                 |
      | 0        | 10         | PIX               | deve ser gerada     | Código PIX gerado. Válido por 10 minutos.   |
      | -1       | 5          | Cartão de Crédito | não deve ser gerada | Quantidade inválida                         |
    

  Esquema do Cenário: Efetivação do saldo baseado no status e tempo de pagamento
    Dado que o estudante possui um saldo anterior de 0 refeições
    E gerou uma cobrança via "<metodo>" para recarregar 5 refeições
    Quando o status da transação após <tempo_decorrido> minutos é "<status_transacao>"
    Então o saldo de refeições do estudante deve ser <saldo_final>

    Exemplos:
      | metodo            | tempo_decorrido | status_transacao | saldo_final |
      | PIX               | 2               | Confirmada       | 13,5        |
      | PIX               | 9               | Pendente         | 0           |
      | PIX               | 11              | Expirada         | 0           |
      | Cartão de Crédito | 1               | Confirmada       | 13,5        |
      | Cartão de Crédito | 1               | Recusada         | 0           |