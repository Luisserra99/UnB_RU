require "rails_helper"

# F02 — Valores monetários devem ser BigDecimal exatos do cálculo até o saldo (o SQLite guarda
# decimal como REAL, então somas como 0,10 + 0,20 precisam continuar exatas depois da leitura).
RSpec.describe "Valores monetários da recarga (F02)", type: :model do
  let(:estudante) { create(:estudante) }

  context "com tarifas sem representação binária exata" do
    before do
      create(:tarifa_refeicao, :cafe, valor: BigDecimal("0.10"))
      create(:tarifa_refeicao, :almoco, valor: BigDecimal("3.33"))
    end

    it "calcula subtotais e total exatos em BigDecimal (RN02.5)" do
      s = SolicitacaoRecarga.new(estudante: estudante, quantidade_cafes: "3", quantidade_almocos: "3", metodo: "pix")
      expect(s.subtotal(:cafes)).to be_a(BigDecimal).and eq(BigDecimal("0.30"))
      expect(s.subtotal(:almocos)).to eq(BigDecimal("9.99"))
      expect(s.valor_total).to be_a(BigDecimal).and eq(BigDecimal("10.29"))
    end

    it "grava e relê o valor total sem erro de arredondamento" do
      s = SolicitacaoRecarga.new(estudante: estudante, quantidade_cafes: "7", quantidade_almocos: "11", metodo: "pix")
      expect(s.salvar).to be(true)
      recarga = Recarga.find(s.recarga.id)
      expect(recarga.valor_total).to eq(BigDecimal("37.33"))
      expect(recarga.pagamento_atual.valor_solicitado).to eq(BigDecimal("37.33"))
      expect(recarga).to be_valid
      expect(recarga.pagamento_atual.pix_copia_cola).to include("540537.33")
    end

    it "mantém o saldo exato após várias confirmações (0,10 + 0,20 = 0,30)" do
      [ 1, 2 ].each do |cafes|
        s = SolicitacaoRecarga.new(estudante: estudante, quantidade_cafes: cafes.to_s, quantidade_almocos: "0",
                                   metodo: "cartao_credito")
        s.salvar
        s.recarga.pagamento_atual.confirmar!
      end
      saldo = Estudante.find(estudante.id).saldo
      expect(saldo).to be_a(BigDecimal)
      expect(saldo).to eq(BigDecimal("0.30"))
      expect(saldo.to_s("F")).to eq("0.3")
    end
  end

  it "soma muitos créditos e débitos fracionados sem resíduo" do
    10.times { create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: BigDecimal("0.10")) }
    3.times { create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: BigDecimal("-0.10")) }
    expect(estudante.saldo).to eq(BigDecimal("0.70"))

    7.times { create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: BigDecimal("-0.10")) }
    expect(estudante.saldo).to be_zero
  end
end
