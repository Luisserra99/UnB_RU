require "rails_helper"

RSpec.describe "Recarga de Saldo (F02)", type: :request do
  let!(:aluno) { create(:usuario_estudante, password: "senhaCorreta") }
  let(:estudante) { aluno.estudante }

  before do
    create(:tarifa_refeicao, :cafe, valor: 2.5)
    create(:tarifa_refeicao, :almoco, valor: 4.5)
  end

  def solicitar(cafes:, almocos:, metodo: "pix", acao: "confirmar")
    post recargas_path, params: {
      acao: acao,
      solicitacao_recarga: { quantidade_cafes: cafes, quantidade_almocos: almocos, metodo: metodo }
    }
  end

  def cartao(numero = Pagamentos::GatewaySimulado::CARTAO_APROVADO)
    { dados_cartao: { numero: numero, nome: "Fulana", validade: 2.years.from_now.strftime("%m/%y"), cvv: "123" } }
  end

  it "exige login de estudante" do
    get new_recarga_path
    expect(response).to redirect_to(login_estudante_path)
    solicitar(cafes: 1, almocos: 0)
    expect(response).to redirect_to(login_estudante_path)
    expect(Recarga.count).to eq(0)
  end

  context "com estudante logado" do
    before { login_estudante(aluno) }

    it "mostra o formulário com total zerado e o Confirmar desabilitado" do
      get new_recarga_path
      expect(response.body).to include("Recarga de Saldo")
      expect(response.body).to include("Não é possível gerar uma cobrança zerada")
      expect(response.body).to match(/<button[^>]*disabled[^>]*>Confirmar|<button[^>]*value="confirmar"[^>]*disabled/)
    end

    it "calcula o total sem gerar cobrança" do
      solicitar(cafes: 5, almocos: 10, acao: "calcular")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("R$ 57,50")
      expect(Recarga.count).to eq(0)
    end

    it "recusa cobrança zerada no servidor" do
      solicitar(cafes: 0, almocos: 0)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Não é possível gerar uma cobrança zerada")
      expect(Pagamento.count).to eq(0)
    end

    it "gera PIX com QR Code, Copia e Cola e prazo" do
      solicitar(cafes: 5, almocos: 10)
      recarga = estudante.recargas.last
      expect(response).to redirect_to(recarga_path(recarga))
      follow_redirect!
      expect(response.body).to include("Código PIX gerado. Válido por 10 minutos.")
      expect(response.body).to include('id="qr-code-pix"')
      expect(response.body).to include(recarga.pagamento_atual.pix_copia_cola)
      expect(response.body).to include("10 minutos")
      expect(estudante.saldo).to eq(0)
    end

    it "mostra o PIX expirado depois de 10 minutos" do
      solicitar(cafes: 0, almocos: 1)
      recarga = estudante.recargas.last
      travel_to(recarga.pagamento_atual.expira_em + 1.second) do
        get recarga_path(recarga)
        expect(response.body).to include("Código PIX expirado")
        expect(recarga.reload).to be_expirada
      end
    end

    it "simula a confirmação do PIX em ambiente de teste" do
      solicitar(cafes: 0, almocos: 5)
      recarga = estudante.recargas.last
      post simular_confirmacao_recarga_path(recarga)
      expect(response).to redirect_to(recarga_path(recarga))
      expect(estudante.saldo).to eq(BigDecimal("22.50"))
    end

    describe "cartão de crédito" do
      before { solicitar(cafes: 2, almocos: 4, metodo: "cartao_credito") }

      let(:recarga) { estudante.recargas.last }

      it "gera a cobrança e pede os dados do cartão" do
        follow_redirect!
        expect(response.body).to include("Cobrança gerada com sucesso")
        expect(response.body).to include("Finalizar pagamento")
      end

      it "confirma com cartão válido e atualiza o saldo" do
        post pagar_cartao_recarga_path(recarga), params: cartao
        expect(response).to redirect_to(recarga_path(recarga))
        expect(estudante.saldo).to eq(BigDecimal("23.00"))
        expect(recarga.reload).to be_confirmada
      end

      it "rejeita dados inválidos sem chamar o gateway" do
        post pagar_cartao_recarga_path(recarga), params: cartao("1234")
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Dados do cartão inválidos")
        expect(recarga.pagamento_atual.reload).to be_pendente
      end

      it "registra recusa e permite nova tentativa" do
        post pagar_cartao_recarga_path(recarga), params: cartao(Pagamentos::GatewaySimulado::CARTAO_RECUSADO)
        expect(recarga.pagamento_atual).to be_recusado
        expect(estudante.saldo).to eq(0)

        post pagar_cartao_recarga_path(recarga), params: cartao
        expect(recarga.pagamentos.count).to eq(2)
        expect(estudante.saldo).to eq(BigDecimal("23.00"))
      end

      it "não aceita pagar de novo uma recarga confirmada" do
        post pagar_cartao_recarga_path(recarga), params: cartao
        post pagar_cartao_recarga_path(recarga), params: cartao
        expect(flash[:alert]).to eq(RecargasController::MSG_COBRANCA_SEM_CARTAO)
        expect(estudante.saldo).to eq(BigDecimal("23.00"))
      end
    end

    it "não mostra recarga de outro estudante" do
      outra = create(:recarga, estudante: create(:estudante))
      get recarga_path(outra)
      expect(response).to have_http_status(:not_found)
    end
  end
end
