require "rails_helper"

RSpec.describe Pagamento, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:estudante) { create(:estudante) }
  let(:recarga) { create(:recarga, estudante: estudante, quantidade: 5) }

  describe "PIX" do
    let(:pagamento) { create(:pagamento, :pix, recarga: recarga) }

    it "tem código Copia e Cola e validade de 10 minutos" do
      expect(pagamento.pix_copia_cola).to start_with("000201")
      expect(pagamento.expira_em - pagamento.created_at).to be_within(1.second).of(10.minutes)
    end

    it "exige código e validade" do
      pix = build(:pagamento, recarga: recarga, metodo: "pix")
      expect(pix).not_to be_valid
      expect(pix.errors[:expira_em]).to be_present
      expect(pix.errors[:pix_copia_cola]).to be_present
    end

    it "vence aos 10 minutos exatos" do
      expect(pagamento.vencido?(pagamento.expira_em - 1.second)).to be(false)
      expect(pagamento.vencido?(pagamento.expira_em)).to be(true)
    end

    it "não credita confirmação que chega depois do vencimento" do
      pagamento.confirmar!(em: pagamento.expira_em + 1.minute)
      expect(pagamento.reload).to be_expirado
      expect(recarga.reload).to be_expirada
      expect(estudante.saldo).to eq(0)
    end

    it "expira a recarga junto com o código" do
      travel_to(pagamento.expira_em + 1.second) { pagamento.expirar_se_vencido! }
      expect(pagamento.reload).to be_expirado
      expect(recarga.reload).to be_expirada
    end

    it "não expira antes do prazo" do
      pagamento.expirar_se_vencido!(em: pagamento.expira_em - 1.minute)
      expect(pagamento.reload).to be_pendente
    end
  end

  describe "#confirmar!" do
    let(:pagamento) { create(:pagamento, :cartao, recarga: recarga) }

    it "confirma o pagamento e a recarga e credita o saldo" do
      pagamento.confirmar!
      expect(pagamento.reload).to be_confirmado
      expect(pagamento.valor_confirmado).to eq(BigDecimal("22.50"))
      expect(recarga.reload).to be_confirmada
      expect(estudante.saldo).to eq(BigDecimal("22.50"))
    end

    it "é idempotente: não credita duas vezes" do
      pagamento.confirmar!
      expect { pagamento.confirmar! }.not_to change(MovimentacaoSaldo, :count)
      expect(estudante.saldo).to eq(BigDecimal("22.50"))
    end

    it "não confirma pagamento recusado" do
      pagamento.recusar!
      pagamento.confirmar!
      expect(pagamento.reload).to be_recusado
      expect(estudante.saldo).to eq(0)
    end

    it "o banco impede dois pagamentos confirmados na mesma recarga" do
      pagamento.confirmar!
      outro = create(:pagamento, :cartao, recarga: recarga)
      expect do
        outro.update_columns(status: "confirmado", confirmado_em: Time.current, valor_confirmado: outro.valor_solicitado)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "#recusar!" do
    it "recusa sem alterar o saldo e mantém a recarga pendente" do
      pagamento = create(:pagamento, :cartao, recarga: recarga)
      pagamento.recusar!
      expect(pagamento.reload).to be_recusado
      expect(recarga.reload).to be_pendente
      expect(estudante.saldo).to eq(0)
    end
  end

  it "traduz o nome do método" do
    expect(described_class.nome_metodo("pix")).to eq("PIX")
    expect(described_class.nome_metodo(:cartao_credito)).to eq("Cartão de Crédito")
  end
end
