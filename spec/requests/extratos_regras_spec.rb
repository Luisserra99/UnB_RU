require "rails_helper"

# F03 — Extrato ligado ao fluxo real da recarga e casos de RN03.1/RN03.3/RN03.4 não cobertos antes.
RSpec.describe "Extrato e Histórico (F03) — regras", type: :request do
  let!(:aluno) { create(:usuario_estudante, password: "senhaCorreta") }
  let(:estudante) { aluno.estudante }

  before do
    create(:tarifa_refeicao, :cafe, valor: 2.5)
    create(:tarifa_refeicao, :almoco, valor: 4.5)
    login_estudante(aluno)
  end

  def solicitar_pix(almocos)
    post recargas_path, params: {
      acao: "confirmar",
      solicitacao_recarga: { quantidade_cafes: "0", quantidade_almocos: almocos.to_s, metodo: "pix" }
    }
    estudante.recargas.last
  end

  it "mostra a recarga PIX confirmada pelo fluxo real, com saldo e método (RN03.3)" do
    recarga = solicitar_pix(5)
    post simular_confirmacao_recarga_path(recarga)

    get extrato_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("R$ 22,50")
    expect(response.body).to include("Recarga de Saldo (PIX)")
    expect(response.body).not_to include("Não há histórico disponível")
  end

  it "recarga pendente ou expirada não aparece e não tira a mensagem de ausência (RN02.2/RN03.4)" do
    expirada = solicitar_pix(1)
    travel_to(expirada.pagamento_atual.expira_em) { get recarga_path(expirada) }
    solicitar_pix(2)

    get extrato_path
    expect(response.body).to include("Não há histórico disponível. Você ainda não possui lançamentos.")
    expect(response.body).not_to include("Recarga de Saldo (PIX)")
  end

  it "nega o extrato de outro estudante que tem lançamentos, sem vazar saldo nem movimentações (RN03.1)" do
    outro = create(:usuario_estudante, saldo: 37)
    create(:movimentacao_saldo, :debito_refeicao, estudante: outro.estudante, valor: BigDecimal("-4.50"),
                                                  ocorrida_em: Time.zone.local(2026, 10, 1, 11, 47))

    get extrato_estudante_path(outro.estudante)
    expect(response).to have_http_status(:forbidden)
    expect(response.body).not_to include("R$ 32,50")
    expect(response.body).not_to include("11:47")
    expect(response.body).not_to include(outro.nome)
  end

  it "/extrato sempre mostra o estudante logado, mesmo com estudante_id na query string" do
    outro = create(:estudante, saldo: 37)
    get extrato_path, params: { estudante_id: outro.id }
    expect(response).to have_http_status(:forbidden)
    expect(response.body).not_to include("R$ 37,00")
  end

  it "após logout, o extrato volta a exigir login" do
    delete logout_estudante_path
    get extrato_path
    expect(response).to redirect_to(login_estudante_path)
  end
end

RSpec.describe Extratos::Consulta, "limite de recargas (RN03.3)" do
  include ActiveSupport::Testing::TimeHelpers

  it "traz só as 10 recargas confirmadas mais recentes" do
    estudante = create(:estudante)
    recargas = Array.new(12) do |i|
      travel_to(Time.zone.local(2026, 11, 1, 8) + i.hours) { create(:recarga, :confirmada, estudante: estudante) }
    end

    ultimas = described_class.new(estudante).ultimas_recargas
    expect(ultimas.size).to eq(Extratos::Consulta::LIMITE_RECARGAS)
    expect(ultimas).to eq(recargas.last(10).reverse)
    expect(described_class.new(estudante).movimentacoes.size).to eq(12)
  end
end
