require "rails_helper"

RSpec.describe "Integridade da operação da catraca", type: :model do
  it "exige origem do mesmo estudante para débito" do
    debito = build(:movimentacao_saldo)
    debito.registro_acesso = nil
    expect(debito).not_to be_valid
    debito.registro_acesso = create(:registro_acesso, estudante: create(:estudante))
    expect(debito).not_to be_valid
  end

  it "o banco impede remover a origem de um débito" do
    debito = create(:movimentacao_saldo)
    expect { debito.update_column(:registro_acesso_id, nil) }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "não permite rateio de recarga de outro estudante" do
    debito = create(:movimentacao_saldo)
    recarga = create(:movimentacao_saldo, :credito_recarga).recarga
    rateio = RateioConsumo.new(movimentacao_saldo: debito, recarga: recarga, valor: 1)
    expect(rateio).not_to be_valid
  end

  it "não rateia além do valor do débito nem do crédito disponível" do
    aluno = create(:estudante)
    credito = create(:movimentacao_saldo, :credito_recarga, estudante: aluno, valor: 2)
    debito = create(:movimentacao_saldo, estudante: aluno, valor: -1)
    rateio = RateioConsumo.new(movimentacao_saldo: debito, recarga: credito.recarga, valor: 1.5)
    expect(rateio).not_to be_valid
    expect(rateio.errors[:valor]).to include("excede o débito")
    debito.update!(valor: -3)
    rateio.valor = 2.5
    expect(rateio).not_to be_valid
    expect(rateio.errors[:valor]).to include("excede o crédito disponível da recarga")
  end

  it "rejeita passagem anterior à liberação ou depois dos 5 segundos" do
    registro = build(:registro_acesso)
    registro.passagem_em = registro.liberado_em - 1.second
    expect(registro).not_to be_valid
    registro.passagem_em = registro.liberado_em + 6.seconds
    expect(registro).not_to be_valid
  end
end
