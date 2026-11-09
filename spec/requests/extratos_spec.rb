require "rails_helper"

RSpec.describe "Extrato e Histórico de Refeições (F03)", type: :request do
  let!(:aluno) { create(:usuario_estudante, password: "senhaCorreta") }
  let(:estudante) { aluno.estudante }

  it "exige login de estudante" do
    get extrato_path
    expect(response).to redirect_to(login_estudante_path)
    get extrato_estudante_path(estudante)
    expect(response).to redirect_to(login_estudante_path)
  end

  context "com estudante logado" do
    before { login_estudante(aluno) }

    it "mostra a mensagem de ausência de histórico (RN03.4)" do
      get extrato_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Extrato e Histórico de Refeições")
      expect(response.body).to include("Não há histórico disponível. Você ainda não possui lançamentos.")
    end

    it "mostra saldo, movimentações e refeições do próprio estudante (RN03.2 e RN03.3)" do
      create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: BigDecimal("22.50"),
                                                    ocorrida_em: 2.days.ago)
      create(:movimentacao_saldo, :debito_refeicao, estudante: estudante, valor: BigDecimal("-4.50"),
                                                    ocorrida_em: Time.zone.local(2026, 11, 5, 12, 30))

      get extrato_path
      expect(response.body).to include("R$ 18,00")
      expect(response.body).to include("Recarga de Saldo")
      expect(response.body).to include("05/11/2026")
      expect(response.body).to include("12:30")
      expect(response.body).not_to include("Não há histórico disponível")
    end

    it "permite a rota com o próprio id" do
      get extrato_estudante_path(estudante)
      expect(response).to have_http_status(:ok)
    end

    it "nega o extrato de outro estudante com 403, sem expor os dados (RN03.1)" do
      outro = create(:estudante, saldo: 9)
      get extrato_estudante_path(outro)
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include(ExtratosController::MSG_ACESSO_NEGADO)
      expect(response.body).not_to include(outro.matricula)
      expect(response.body).not_to include("R$ 9,00")
    end

    it "nega id inexistente com 403" do
      get extrato_estudante_path(estudante_id: 0)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
