require "rails_helper"

RSpec.describe RegistroAcesso, type: :model do
  it "aceita a passagem no instante da liberação e no limite exato" do
    registro = build(:registro_acesso)
    [ registro.liberado_em, registro.limite_em ].each do |instante|
      registro.passagem_em = instante
      expect(registro).to be_valid
    end
    expect(registro).to be_catraca_liberada
    expect(registro).to be_acesso_realizado
  end

  it "representa uma leitura recusada sem estudante nem liberação" do
    registro = build(:registro_acesso, estado: :recusado, estudante: nil, identificacao_lida: "",
      liberado_em: nil, passagem_em: nil, bloqueado_em: nil)
    expect(registro).to be_valid
    expect(registro.limite_em).to be_nil
    expect(registro).not_to be_catraca_liberada
    expect(registro).not_to be_acesso_realizado
  end

  %i[estudante liberado_em passagem_em bloqueado_em].each do |atributo|
    it "recusa acesso realizado sem #{atributo}" do
      registro = build(:registro_acesso)
      registro.public_send("#{atributo}=", nil)
      expect(registro).not_to be_valid
      expect(registro.errors[:base]).to include("Passagem exige estudante, liberação e bloqueio")
    end
  end

  it "recusa horário de passagem sem liberação mesmo em outro estado" do
    registro = build(:registro_acesso, estado: :cancelado, liberado_em: nil)
    expect(registro).not_to be_valid
    expect(registro.errors[:passagem_em]).to include("deve ocorrer em até 5 segundos após a liberação")
  end
end
