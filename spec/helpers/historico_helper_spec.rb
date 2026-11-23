require "rails_helper"

RSpec.describe HistoricoHelper, type: :helper do
  let(:momento) { Time.zone.local(2026, 10, 14, 11, 30, 1) }

  it "formata no padrão dos cenários: data, hora, saldo e S/N" do
    expect(helper.data_registro(momento)).to eq("14/10/2026")
    expect(helper.hora_registro(momento)).to eq("11:30:01")
    expect(helper.saldo_registro(BigDecimal("10"))).to eq("10,00")
    expect(helper.sim_nao(true)).to eq("S")
    expect(helper.sim_nao(false)).to eq("N")
  end

  it "deixa vazios os campos sem valor" do
    expect(helper.data_registro(nil)).to be_nil
    expect(helper.hora_registro(nil)).to be_nil
    expect(helper.saldo_registro(nil)).to be_nil
    expect(helper.sim_nao(nil)).to eq("N")
  end

  it "usa ponto como separador de milhar no saldo" do
    expect(helper.saldo_registro(BigDecimal("1234.5"))).to eq("1.234,50")
  end

  it "descreve a situação de cada estado" do
    expect(helper.situacao_registro(build(:registro_acesso, estado: "realizado")).first).to eq("Liberado (passagem confirmada)")
    expect(helper.situacao_registro(build(:registro_acesso, estado: "cancelado")).first).to eq("Liberado sem passagem")
    expect(helper.situacao_registro(build(:registro_acesso, estado: "liberado")))
      .to eq([ "Aguardando passagem", "situacao-info" ])
    expect(helper.situacao_registro(build(:registro_acesso, estado: "recusado", mensagem: "Saldo insuficiente")))
      .to eq([ "Bloqueado (Saldo insuficiente)", "situacao-erro" ])
  end

  describe "#linha_bloqueada?" do
    it "destaca as leituras recusadas e as liberadas sem passagem" do
      expect(helper.linha_bloqueada?(build(:registro_acesso, estado: "recusado"))).to be(true)
      expect(helper.linha_bloqueada?(build(:registro_acesso, estado: "cancelado"))).to be(true)
    end

    it "não destaca as passagens realizadas nem as que aguardam passagem" do
      expect(helper.linha_bloqueada?(build(:registro_acesso, estado: "realizado"))).to be(false)
      expect(helper.linha_bloqueada?(build(:registro_acesso, estado: "liberado"))).to be(false)
    end
  end
end
