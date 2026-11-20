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

  describe ".txid_emv" do
    it "mantém só letras e dígitos, até 25 caracteres" do
      expect(described_class.txid_emv("PIXSIM-ABC123")).to eq("PIXSIMABC123")
      expect(described_class.txid_emv("A" * 30)).to eq("A" * 25)
    end

    it "devolve texto vazio para referência ausente" do
      expect(described_class.txid_emv(nil)).to eq("")
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

    it "mantém a referência que o pagamento já tinha" do
      pagamento = Pagamento.new(metodo: "pix", valor_solicitado: 4.5, referencia_provedor: "PIXSIM-EXISTENTE")
      described_class.emitir_pix(pagamento)
      expect(pagamento.referencia_provedor).to eq("PIXSIM-EXISTENTE")
      expect(pagamento.pix_copia_cola).to include("PIXSIMEXISTENTE")
    end
  end

  describe ".autorizar_cartao" do
    it "recusa o cartão de teste de recusa e aprova os demais" do
      expect(described_class.autorizar_cartao(DadosCartao.new(numero: described_class::CARTAO_RECUSADO))).to eq("Recusada")
      expect(described_class.autorizar_cartao(DadosCartao.new(numero: described_class::CARTAO_APROVADO))).to eq("Confirmada")
    end
  end
end
