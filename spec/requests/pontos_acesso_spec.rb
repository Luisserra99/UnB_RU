require "rails_helper"

RSpec.describe "Configuração do ponto de acesso (F05)", type: :request do
  let!(:funcionario) { create(:funcionario) }
  let!(:catraca) { create(:catraca) }
  let(:restaurante) { catraca.restaurante }

  def confirmar(c = catraca, r = c.restaurante)
    post controle_ponto_acesso_path, params: { restaurante_id: r.id, catraca_id: c.id }
  end

  it "exige autenticação também no POST" do
    confirmar
    expect(response).to redirect_to(controle_login_path)
    expect(ConfiguracaoPontoAcesso.count).to eq(0)
  end

  it "confirma e preserva os pontos antigos ao reconfigurar" do
    login_controle(funcionario)
    confirmar
    primeiro = ConfiguracaoPontoAcesso.last
    expect(primeiro).to be_disponivel
    expect(catraca).to be_em_operacao
    post reconfigurar_controle_ponto_acesso_path
    expect(primeiro.reload).not_to be_disponivel
    nova = create(:catraca)
    confirmar(nova)
    expect(primeiro.reload.finalizada_em).to be_present
    expect(primeiro.restaurante).to eq(restaurante)
    expect(SessaoAutenticacao.last.ponto_acesso_atual.catraca).to eq(nova)
    expect(catraca).not_to be_em_operacao
  end

  it "rejeita catraca de outro restaurante sem perder o ponto confirmado" do
    login_controle(funcionario)
    confirmar
    primeiro = ConfiguracaoPontoAcesso.last
    outra = create(:catraca)
    confirmar(outra, restaurante)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("A catraca não pertence ao restaurante selecionado")
    expect(ConfiguracaoPontoAcesso.count).to eq(1)
    expect(primeiro.reload.finalizada_em).to be_nil
    expect(primeiro).not_to be_disponivel
  end

  it "revalida disponibilidade no servidor" do
    login_controle(funcionario)
    catraca.update!(ativa: false)
    confirmar
    expect(response.body).to include("Catraca indisponível")
    expect(ConfiguracaoPontoAcesso.count).to eq(0)
  end

  it "encerra o ponto no logout e impede remoção somente durante uso" do
    login_controle(funcionario)
    confirmar
    expect(catraca.destroy).to be_falsey
    delete controle_logout_path
    expect(ConfiguracaoPontoAcesso.last.finalizada_em).to be_present
    expect(catraca).not_to be_em_operacao
    # O histórico continua protegido pela FK/associação, mesmo sem sessão vigente.
  end

  it "uma sessão expirada ou usuário desativado não mantém a catraca em operação" do
    login_controle(funcionario)
    confirmar
    travel 9.hours do
      expect(catraca).not_to be_em_operacao
      get controle_root_path
      expect(response).to redirect_to(controle_login_path)
      expect(ConfiguracaoPontoAcesso.last.finalizada_em).to be_present
    end
  end
end

RSpec.describe "Vigência do ponto de acesso", type: :request do
  it "libera a catraca quando o operador é desativado" do
    funcionario = create(:funcionario)
    catraca = create(:catraca)
    login_controle(funcionario)
    post controle_ponto_acesso_path, params: { restaurante_id: catraca.restaurante.id, catraca_id: catraca.id }
    funcionario.update!(ativo: false)
    expect(catraca).not_to be_em_operacao
    get controle_root_path
    expect(response).to redirect_to(controle_login_path)
    expect(ConfiguracaoPontoAcesso.last.finalizada_em).to be_present
  end
end
