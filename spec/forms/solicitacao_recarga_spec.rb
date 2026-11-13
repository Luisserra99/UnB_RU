require "rails_helper"

RSpec.describe SolicitacaoRecarga do
  let(:estudante) { create(:estudante) }

  before do
    create(:tarifa_refeicao, :cafe, valor: 2.5)
    create(:tarifa_refeicao, :almoco, valor: 4.5)
  end

  def solicitacao(**atributos)
    described_class.new(estudante: estudante, **atributos)
  end

  it "calcula subtotais e total pelas tarifas vigentes" do
    s = solicitacao(quantidade_cafes: "5", quantidade_almocos: "10", metodo: "pix")
    expect(s.subtotal(:cafes)).to eq(BigDecimal("12.50"))
    expect(s.subtotal(:almocos)).to eq(BigDecimal("45.00"))
    expect(s.valor_total).to eq(BigDecimal("57.50"))
  end

  it "trata quantidade em branco como zero" do
    expect(solicitacao(quantidade_cafes: "", quantidade_almocos: nil).valor_total).to eq(0)
  end

  it "rejeita cobrança zerada sem gravar nada" do
    s = solicitacao(quantidade_cafes: "0", quantidade_almocos: "0", metodo: "pix")
    expect { expect(s.salvar).to be(false) }.not_to change(Recarga, :count)
    expect(s.errors[:base]).to include("Não é possível gerar uma cobrança zerada")
  end

  it "rejeita quantidades negativas, não numéricas ou acima do limite" do
    %w[-1 abc 2.5 101].each do |valor|
      s = solicitacao(quantidade_cafes: valor, quantidade_almocos: "1", metodo: "pix")
      expect(s).not_to be_valid, "esperava rejeitar #{valor.inspect}"
      expect(s.errors[:quantidade_cafes]).to be_present
    end
  end

  it "exige o método de pagamento" do
    s = solicitacao(quantidade_almocos: "1")
    expect(s).not_to be_valid
    expect(s.errors[:metodo]).to include("Selecione o método de pagamento")
  end

  it "exige tarifas cadastradas" do
    TarifaRefeicao.delete_all
    s = solicitacao(quantidade_almocos: "1", metodo: "pix")
    expect(s).not_to be_valid
    expect(s.errors[:base]).to include("As tarifas das refeições não estão cadastradas")
  end

  it "cria recarga, itens e PIX pendente" do
    s = solicitacao(quantidade_cafes: "5", quantidade_almocos: "10", metodo: "pix")
    expect(s.salvar).to be(true)

    recarga = s.recarga.reload
    expect(recarga).to be_pendente
    expect(recarga.valor_total).to eq(BigDecimal("57.50"))
    expect(recarga.itens.map { |i| [ i.tipo_refeicao.codigo, i.quantidade ] })
      .to contain_exactly([ TipoRefeicao::CAFE_DA_MANHA, 5 ], [ TipoRefeicao::ALMOCO, 10 ])
    expect(recarga.pagamento_atual).to be_pix
    expect(recarga.pagamento_atual).to be_pendente
    expect(s.mensagem_sucesso).to eq("Código PIX gerado. Válido por 10 minutos.")
    expect(estudante.saldo).to eq(0)
  end

  it "cria só o item da categoria escolhida e um pagamento com cartão" do
    s = solicitacao(quantidade_cafes: "5", quantidade_almocos: "0", metodo: "cartao_credito")
    expect(s.salvar).to be(true)
    expect(s.recarga.itens.size).to eq(1)
    expect(s.recarga.pagamento_atual).to be_cartao_credito
    expect(s.mensagem_sucesso).to eq("Cobrança gerada com sucesso")
  end
end
