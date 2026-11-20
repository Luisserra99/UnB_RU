require "rails_helper"

RSpec.describe MovimentacaoSaldo, type: :model do
  let(:estudante) { create(:estudante) }

  describe "crédito de recarga" do
    it "exige recarga confirmada do mesmo estudante" do
      pendente = create(:recarga, estudante: estudante)
      credito = described_class.new(estudante: estudante, recarga: pendente, natureza: "credito_recarga",
                                    valor: pendente.valor_total, ocorrida_em: Time.current)
      expect(credito).not_to be_valid
      expect(credito.errors[:recarga]).to include("deve estar confirmada")

      de_outro = create(:recarga, estudante: create(:estudante), status: "confirmada", confirmada_em: Time.current)
      credito.recarga = de_outro
      expect(credito).not_to be_valid
      expect(credito.errors[:recarga]).to include("deve ser do mesmo estudante")
    end

    it "é válido com recarga confirmada do mesmo estudante" do
      expect(build(:movimentacao_saldo, :credito_recarga, estudante: estudante)).to be_valid
    end

    it "exige a recarga e não aceita registro de acesso" do
      credito = build(:movimentacao_saldo, :credito_recarga, estudante: estudante, recarga: nil,
                                                             registro_acesso: create(:registro_acesso, estudante: estudante))
      expect(credito).not_to be_valid
      expect(credito.errors[:recarga]).to include("é obrigatória para crédito")
      expect(credito.errors[:registro_acesso_id]).to include("não se aplica a crédito")
    end

    it "descreve a recarga sem método quando não há pagamento confirmado" do
      credito = build(:movimentacao_saldo, :credito_recarga, estudante: estudante)
      expect(credito.descricao).to eq("Recarga de Saldo")
    end

    it "exige valor positivo" do
      credito = build(:movimentacao_saldo, :credito_recarga, estudante: estudante)
      credito.valor = -1
      expect(credito).not_to be_valid
    end

    it "descreve a recarga com o método de pagamento" do
      recarga = create(:recarga, :confirmada, estudante: estudante)
      expect(recarga.movimentacao_saldo.descricao).to eq("Recarga de Saldo (Cartão de Crédito)")
    end
  end

  describe "débito de refeição" do
    it "exige valor negativo e não aceita recarga" do
      debito = build(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: 4.5)
      expect(debito).not_to be_valid
      expect(debito.errors[:valor]).to include("do débito deve ser negativo")
    end

    it "é válido com passagem realizada pelo mesmo estudante" do
      expect(build(:movimentacao_saldo, :debito_refeicao, estudante: estudante)).to be_valid
    end

    it "exige o registro da passagem" do
      debito = build(:movimentacao_saldo, :debito_refeicao, estudante: estudante, registro_acesso: nil)
      expect(debito).not_to be_valid
      expect(debito.errors[:registro_acesso]).to include("é obrigatório para débito")
    end

    it "rejeita passagem de outro estudante ou não realizada" do
      mensagem = "deve ser uma passagem realizada pelo mesmo estudante"
      de_outro = build(:movimentacao_saldo, :debito_refeicao, estudante: estudante,
                                                              registro_acesso: create(:registro_acesso))
      expect(de_outro).not_to be_valid
      expect(de_outro.errors[:registro_acesso]).to include(mensagem)

      nao_realizada = build(:movimentacao_saldo, :debito_refeicao, estudante: estudante)
      allow(nao_realizada.registro_acesso).to receive(:realizado?).and_return(false)
      expect(nao_realizada).not_to be_valid
      expect(nao_realizada.errors[:registro_acesso]).to include(mensagem)
    end

    it "não aceita recarga" do
      debito = build(:movimentacao_saldo, :debito_refeicao, estudante: estudante,
                                                            recarga: create(:recarga, estudante: estudante))
      expect(debito).not_to be_valid
      expect(debito.errors[:recarga]).to include("não se aplica a débito")
    end

    it "é descrito como refeição" do
      expect(build(:movimentacao_saldo, :debito_refeicao).descricao).to eq("Refeição")
    end

    it "é descrito com o tipo da refeição quando o serviço é conhecido" do
      debito = build(:movimentacao_saldo, :debito_refeicao)
      allow(debito).to receive(:tipo_refeicao).and_return(build(:tipo_refeicao, nome: "Almoço"))
      expect(debito.descricao).to eq("Refeição: Almoço")
    end
  end

  it "o banco rejeita lançamento incoerente" do
    debito = create(:movimentacao_saldo, :debito_refeicao, estudante: estudante)
    expect { debito.update_column(:valor, 5) }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "lista os mais recentes primeiro" do
    antigo = create(:movimentacao_saldo, estudante: estudante, ocorrida_em: 2.days.ago)
    novo = create(:movimentacao_saldo, estudante: estudante, ocorrida_em: 1.day.ago)
    expect(estudante.movimentacoes_saldo.recentes).to eq([ novo, antigo ])
  end
end
