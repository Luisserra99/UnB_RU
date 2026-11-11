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
    expect(helper.hora_registro(nil)).to be_nil
    expect(helper.saldo_registro(nil)).to be_nil
  end

  it "descreve a situação de cada estado" do
    expect(helper.situacao_registro(build(:registro_acesso, estado: "realizado")).first).to eq("Liberado (passagem confirmada)")
    expect(helper.situacao_registro(build(:registro_acesso, estado: "cancelado")).first).to eq("Liberado sem passagem")
    expect(helper.situacao_registro(build(:registro_acesso, estado: "recusado", mensagem: "Saldo insuficiente")).first)
      .to eq("Bloqueado (Saldo insuficiente)")
  end
end
