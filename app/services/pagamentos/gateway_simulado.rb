# Gateway de pagamento simulado (ambiente acadêmico, F02): não há integração com banco ou operadora.
# - PIX: gera referência, validade de 10 minutos e um código Copia e Cola no formato BR Code (EMV).
# - Cartão: aprova qualquer cartão válido, exceto o cartão de teste CARTAO_RECUSADO.
module Pagamentos
  module GatewaySimulado
    CARTAO_APROVADO = "4111111111111111".freeze
    CARTAO_RECUSADO = "4000000000000002".freeze
    CHAVE_PIX = "pagamentos.ru@unb.br".freeze
    RECEBEDOR = "RESTAURANTE UNIV UNB".freeze
    CIDADE = "BRASILIA".freeze

    module_function

    def emitir_pix(pagamento, agora = Time.current)
      pagamento.referencia_provedor ||= "PIXSIM-#{SecureRandom.hex(8).upcase}"
      pagamento.expira_em = agora + Pagamento::VALIDADE_PIX
      pagamento.pix_copia_cola = copia_e_cola(valor: pagamento.valor_solicitado, txid: pagamento.referencia_provedor)
      pagamento
    end

    # Devolve o status da transação no vocabulário de Pagamentos::ProcessarRetorno.
    def autorizar_cartao(dados_cartao)
      dados_cartao.numero_normalizado == CARTAO_RECUSADO ? "Recusada" : "Confirmada"
    end

    def copia_e_cola(valor:, txid:)
      conta = campo("00", "br.gov.bcb.pix") + campo("01", CHAVE_PIX)
      txid_emv = txid.to_s.gsub(/[^A-Za-z0-9]/, "").first(25)
      payload = campo("00", "01") +
                campo("26", conta) +
                campo("52", "0000") +
                campo("53", "986") +
                campo("54", format("%.2f", valor)) +
                campo("58", "BR") +
                campo("59", RECEBEDOR) +
                campo("60", CIDADE) +
                campo("62", campo("05", txid_emv)) +
                "6304"
      payload + crc16(payload)
    end

    def campo(id, valor)
      "#{id}#{valor.to_s.length.to_s.rjust(2, '0')}#{valor}"
    end

    # CRC16-CCITT (polinômio 0x1021, valor inicial 0xFFFF), exigido pelo BR Code.
    def crc16(texto)
      crc = 0xFFFF
      texto.each_byte do |byte|
        crc ^= byte << 8
        8.times { crc = (crc & 0x8000).zero? ? (crc << 1) : ((crc << 1) ^ 0x1021) }
        crc &= 0xFFFF
      end
      crc.to_s(16).upcase.rjust(4, "0")
    end
  end
end
