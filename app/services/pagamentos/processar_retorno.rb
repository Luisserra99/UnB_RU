# Única porta de entrada para o retorno do gateway (F02). Recebe o status da transação
# como o gateway o informa e aplica a transição correspondente no pagamento.
module Pagamentos
  class ProcessarRetorno
    ACOES = {
      "Confirmada" => :confirmar!,
      "Recusada" => :recusar!,
      "Expirada" => :expirar!,
      "Pendente" => :expirar_se_vencido!
    }.freeze

    def self.call(pagamento, status_transacao, em: Time.current)
      acao = ACOES.fetch(status_transacao) { raise ArgumentError, "Status de transação desconhecido: #{status_transacao}" }
      pagamento.public_send(acao, em: em)
    end
  end
end
