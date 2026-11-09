require "rails_helper"

RSpec.describe Pagamentos::GatewaySimulado do
  describe ".copia_e_cola" do
    it "gera um BR Code com valor e CRC16 válido" do
      codigo = described_class.copia_e_cola(valor: BigDecimal("57.5"), txid: "PIXSIM-ABC123")
      expect(codigo).to start_with("000201")
      expect(codigo).to include("br.gov.bcb.pix")
      expect(codigo).to include("540557.50")
      expect(codigo).to include("5303986")
      expect(codigo[-4..]).to eq(described_class.crc16(codigo[0...-4]))
    end
  end

  it "calcula o CRC16-CCITT de referência" do
    expect(described_class.crc16("123456789")).to eq("29B1")
  end

  describe ".emitir_pix" do
    it "preenche referência, código e validade de 10 minutos" do
      pagamento = Pagamento.new(metodo: "pix", valor_solicitado: 22.5)
      agora = Time.current
      described_class.emitir_pix(pagamento, agora)
      expect(pagamento.referencia_provedor).to start_with("PIXSIM-")
      expect(pagamento.expira_em).to be_within(1.second).of(agora + 10.minutes)
      expect(pagamento.pix_copia_cola).to be_present
    end
  end

  describe ".autorizar_cartao" do
    it "recusa o cartão de teste de recusa e aprova os demais" do
      expect(described_class.autorizar_cartao(DadosCartao.new(numero: described_class::CARTAO_RECUSADO))).to eq("Recusada")
      expect(described_class.autorizar_cartao(DadosCartao.new(numero: described_class::CARTAO_APROVADO))).to eq("Confirmada")
    end
  end
end
