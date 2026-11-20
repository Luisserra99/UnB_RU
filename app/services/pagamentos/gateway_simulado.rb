# Pagamentos da recarga de saldo (F02).
module Pagamentos
  # Gateway de pagamento simulado (ambiente acadêmico, F02): não há integração com banco ou operadora.
  # - PIX: gera referência, validade de 10 minutos e um código Copia e Cola no formato BR Code (EMV).
  # - Cartão: aprova qualquer cartão válido, exceto o cartão de teste CARTAO_RECUSADO.
  module GatewaySimulado
    # Cartão de teste sempre aprovado.
    CARTAO_APROVADO = "4111111111111111".freeze
    # Cartão de teste sempre recusado.
    CARTAO_RECUSADO = "4000000000000002".freeze
    # Chave PIX do recebedor que vai no BR Code.
    CHAVE_PIX = "pagamentos.ru@unb.br".freeze
    # Nome do recebedor no BR Code (campo 59, até 25 caracteres).
    RECEBEDOR = "RESTAURANTE UNIV UNB".freeze
    # Cidade do recebedor no BR Code (campo 60).
    CIDADE = "BRASILIA".freeze
    # Tamanho máximo do identificador da transação no BR Code (campo 62-05).
    TAMANHO_TXID = 25

    module_function

    # Prepara um pagamento PIX: referência no provedor, validade de 10 minutos e código Copia e Cola.
    #
    # Argumentos:: +pagamento+ (Pagamento): pagamento PIX ainda não gravado.
    #              +agora+ (Time): início da validade; padrão Time.current.
    # Retorno:: o próprio +pagamento+, com os campos preenchidos.
    # Efeitos colaterais:: altera os atributos do +pagamento+ em memória (não grava no banco). Uma
    #                      referência já existente é mantida.
    def emitir_pix(pagamento, agora = Time.current)
      pagamento.referencia_provedor ||= "PIXSIM-#{SecureRandom.hex(8).upcase}"
      pagamento.expira_em = agora + Pagamento::VALIDADE_PIX
      pagamento.pix_copia_cola = copia_e_cola(valor: pagamento.valor_solicitado, txid: pagamento.referencia_provedor)
      pagamento
    end

    # Simula a autorização de um cartão na operadora.
    #
    # Argumentos:: +dados_cartao+ (DadosCartao): dados já validados.
    # Retorno:: String no vocabulário de Pagamentos::ProcessarRetorno: "Recusada" para o
    #           CARTAO_RECUSADO e "Confirmada" para qualquer outro cartão.
    # Efeitos colaterais:: nenhum.
    def autorizar_cartao(dados_cartao)
      dados_cartao.numero_normalizado == CARTAO_RECUSADO ? "Recusada" : "Confirmada"
    end

    # Monta o código PIX Copia e Cola (BR Code, padrão EMV) de uma cobrança.
    #
    # Argumentos:: +valor+ (BigDecimal): valor da cobrança. +txid+ (String): referência da transação.
    # Retorno:: String com os campos EMV seguidos do CRC16 (4 dígitos hexadecimais).
    # Efeitos colaterais:: nenhum.
    def copia_e_cola(valor:, txid:)
      payload = campos_br_code(valor, txid).map { |id, conteudo| campo(id, conteudo) }.join + "6304"
      payload + crc16(payload)
    end

    # Lista os campos do BR Code na ordem exigida pelo padrão, sem o CRC.
    #
    # Argumentos:: +valor+ (BigDecimal): valor da cobrança. +txid+ (String): referência da transação.
    # Retorno:: Array de pares [id, conteúdo] (Strings).
    # Efeitos colaterais:: nenhum.
    def campos_br_code(valor, txid)
      [
        [ "00", "01" ], [ "26", conta_pix ], [ "52", "0000" ], [ "53", "986" ],
        [ "54", format("%.2f", valor) ], [ "58", "BR" ], [ "59", RECEBEDOR ], [ "60", CIDADE ],
        [ "62", campo("05", txid_emv(txid)) ]
      ]
    end

    # Monta o campo 26 do BR Code: domínio do arranjo PIX e chave do recebedor.
    #
    # Argumentos:: nenhum.
    # Retorno:: String com os dois subcampos EMV.
    # Efeitos colaterais:: nenhum.
    def conta_pix
      campo("00", "br.gov.bcb.pix") + campo("01", CHAVE_PIX)
    end

    # Adapta a referência da transação ao BR Code: só letras e dígitos, até TAMANHO_TXID caracteres.
    #
    # Argumentos:: +txid+ (String ou nil): referência da transação.
    # Retorno:: String, possivelmente vazia.
    # Efeitos colaterais:: nenhum.
    def txid_emv(txid)
      txid.to_s.gsub(/[^A-Za-z0-9]/, "").first(TAMANHO_TXID)
    end

    # Formata um campo EMV: id, tamanho do conteúdo com 2 dígitos e conteúdo.
    #
    # Argumentos:: +id+ (String): identificador do campo. +valor+ (Object): conteúdo, convertido com to_s.
    # Retorno:: String, ex.: campo("58", "BR") devolve "5802BR".
    # Efeitos colaterais:: nenhum.
    def campo(id, valor)
      "#{id}#{valor.to_s.length.to_s.rjust(2, '0')}#{valor}"
    end

    # Calcula o CRC16-CCITT (polinômio 0x1021, valor inicial 0xFFFF), exigido pelo BR Code.
    #
    # Argumentos:: +texto+ (String): conteúdo a verificar.
    # Retorno:: String com 4 dígitos hexadecimais maiúsculos, ex.: crc16("123456789") devolve "29B1".
    # Efeitos colaterais:: nenhum.
    def crc16(texto)
      crc = texto.each_byte.reduce(0xFFFF) { |acumulado, byte| crc16_byte(acumulado, byte) }
      crc.to_s(16).upcase.rjust(4, "0")
    end

    # Processa um byte no cálculo do CRC16.
    #
    # Argumentos:: +crc+ (Integer): CRC acumulado. +byte+ (Integer): próximo byte do texto.
    # Retorno:: Integer de 16 bits com o novo CRC acumulado.
    # Efeitos colaterais:: nenhum.
    def crc16_byte(crc, byte)
      crc ^= byte << 8
      8.times { crc = crc16_bit(crc) }
      crc & 0xFFFF
    end

    # Desloca o CRC um bit à esquerda, aplicando o polinômio 0x1021 quando o bit 15 está ligado.
    #
    # Argumentos:: +crc+ (Integer): CRC acumulado.
    # Retorno:: Integer com o CRC deslocado (pode passar de 16 bits; crc16_byte aplica a máscara).
    # Efeitos colaterais:: nenhum.
    def crc16_bit(crc)
      (crc & 0x8000).zero? ? crc << 1 : (crc << 1) ^ 0x1021
    end
  end
end
