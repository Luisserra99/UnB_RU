require "rails_helper"

RSpec.describe HistoricoCatraca::Credencial do
  let(:ponto) { create(:configuracao_ponto_acesso) }
  let(:catraca) { ponto.catraca }
  let(:funcionario) { ponto.funcionario }

  def valida?(matricula: funcionario.identificacao, senha: "senhaCorreta", catraca: self.catraca)
    described_class.valida?(matricula: matricula, senha: senha, catraca: catraca)
  end

  it "aceita o funcionário que gerencia a catraca, com a senha correta" do
    expect(valida?).to be(true)
  end

  it "ignora espaços em volta da matrícula" do
    expect(valida?(matricula: " #{funcionario.identificacao} ")).to be(true)
  end

  it "recusa matrícula ou senha vazias" do
    expect(valida?(matricula: "")).to be(false)
    expect(valida?(senha: "")).to be(false)
  end

  it "recusa senha incorreta e matrícula não cadastrada" do
    expect(valida?(senha: "senhaErrada")).to be(false)
    expect(valida?(matricula: "999999999")).to be(false)
  end

  it "recusa funcionário que gerencia outra catraca" do
    outro_ponto = create(:configuracao_ponto_acesso)
    expect(valida?(matricula: outro_ponto.funcionario.identificacao)).to be(false)
  end

  it "recusa funcionário inativo" do
    funcionario.update!(ativo: false)
    expect(valida?).to be(false)
  end

  it "recusa quando a sessão do funcionário foi encerrada" do
    ponto.sessao_autenticacao.encerrar!
    expect(valida?).to be(false)
  end

  it "recusa durante a reconfiguração do ponto de acesso" do
    ponto.sessao_autenticacao.update!(ponto_acesso_pendente: true)
    expect(valida?).to be(false)
  end

  it "recusa estudante, mesmo com a senha correta" do
    estudante = create(:usuario_estudante, password: "senhaCorreta")
    expect(valida?(matricula: estudante.identificacao)).to be(false)
  end
end
