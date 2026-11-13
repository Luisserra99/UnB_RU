require "rails_helper"

RSpec.describe Pagamentos::ProcessarRetorno do
  let(:estudante) { create(:estudante) }
  let(:recarga) { create(:recarga, estudante: estudante, quantidade: 5) }
  let(:pix) { create(:pagamento, :pix, recarga: recarga) }

  {
    [ "Confirmada", 2 ] => [ :confirmado, BigDecimal("22.50") ],
    [ "Pendente", 9 ] => [ :pendente, 0 ],
    [ "Pendente", 11 ] => [ :expirado, 0 ],
    [ "Expirada", 11 ] => [ :expirado, 0 ],
    [ "Confirmada", 11 ] => [ :expirado, 0 ],
    [ "Recusada", 1 ] => [ :recusado, 0 ]
  }.each do |(status, minutos), (esperado, saldo)|
    it "PIX com status #{status} após #{minutos} minutos fica #{esperado} e saldo #{saldo.to_f}" do
      described_class.call(pix, status, em: pix.created_at + minutos.minutes)
      expect(pix.reload.status).to eq(esperado.to_s)
      expect(estudante.saldo).to eq(saldo)
    end
  end

  it "rejeita status desconhecido" do
    expect { described_class.call(pix, "Paga") }.to raise_error(ArgumentError)
  end
end
