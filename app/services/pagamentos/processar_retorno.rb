module Pagamentos
  # Única porta de entrada para o retorno do gateway (F02). Recebe o status da transação
  # como o gateway o informa e aplica a transição correspondente no pagamento.
  class ProcessarRetorno
    # Método de Pagamento chamado para cada status de transação do gateway.
    ACOES = {
      "Confirmada" => :confirmar!,
      "Recusada" => :recusar!,
      "Expirada" => :expirar!,
      "Pendente" => :expirar_se_vencido!
    }.freeze

    # Aplica no pagamento o status informado pelo gateway.
    #
    # Argumentos:: +pagamento+ (Pagamento). +status_transacao+ (String): uma chave de ACOES.
    #              +em+ (Time): momento do retorno; padrão Time.current.
    # Retorno:: o próprio +pagamento+, já atualizado.
    # Efeitos colaterais:: os da transição chamada (Pagamento#confirmar!, #recusar!, #expirar! ou
    #                      #expirar_se_vencido!), que gravam no banco; levanta ArgumentError para
    #                      status desconhecido, sem alterar nada.
    def self.call(pagamento, status_transacao, em: Time.current)
      acao = ACOES.fetch(status_transacao) { raise ArgumentError, "Status de transação desconhecido: #{status_transacao}" }
      pagamento.public_send(acao, em: em)
    end
  end
end
