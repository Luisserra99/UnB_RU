require "rails_helper"

# F02 — Regras de segurança e de negócio da recarga que os specs principais não cobriam
# (confirmação dupla, prazo exato do PIX, acesso a recarga de outro estudante, dados do cartão).
RSpec.describe "Recarga de Saldo (F02) — regras e segurança", type: :request do
  let!(:aluno) { create(:usuario_estudante, password: "senhaCorreta") }
  let(:estudante) { aluno.estudante }

  before do
    create(:tarifa_refeicao, :cafe, valor: 2.5)
    create(:tarifa_refeicao, :almoco, valor: 4.5)
  end

  def solicitar(cafes:, almocos:, metodo: "pix")
    post recargas_path, params: {
      acao: "confirmar",
      solicitacao_recarga: { quantidade_cafes: cafes, quantidade_almocos: almocos, metodo: metodo }
    }
  end

  def dados_cartao(numero: Pagamentos::GatewaySimulado::CARTAO_APROVADO, nome: "Fulana", cvv: "123")
    { dados_cartao: { numero: numero, nome: nome, validade: 2.years.from_now.strftime("%m/%y"), cvv: cvv } }
  end

  it "sem login, não confirma nem paga e redireciona ao login" do
    recarga = create(:recarga, estudante: estudante)
    create(:pagamento, :pix, recarga: recarga)

    post simular_confirmacao_recarga_path(recarga)
    expect(response).to redirect_to(login_estudante_path)
    post pagar_cartao_recarga_path(recarga), params: dados_cartao
    expect(response).to redirect_to(login_estudante_path)
    expect(estudante.saldo).to eq(0)
  end

  it "funcionário logado na aplicação de controle não entra no portal do estudante" do
    funcionario = create(:funcionario)
    login_controle(funcionario)
    get new_recarga_path
    expect(response).to redirect_to(login_estudante_path)
    get extrato_path
    expect(response).to redirect_to(login_estudante_path)
  end

  context "com estudante logado" do
    before { login_estudante(aluno) }

    describe "cobrança enviada direto ao servidor (RN02.6)" do
      it "rejeita cobrança zerada com cartão" do
        expect { solicitar(cafes: 0, almocos: 0, metodo: "cartao_credito") }
          .not_to change(Recarga, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Não é possível gerar uma cobrança zerada")
        expect(Pagamento.count).to eq(0)
      end

      it "rejeita quantidades em branco, negativas ou fracionadas" do
        [ [ "", "" ], [ "-5", "2" ], [ "0", "-1" ], [ "1.5", "0" ] ].each do |cafes, almocos|
          solicitar(cafes: cafes, almocos: almocos)
          expect(response).to have_http_status(:unprocessable_content), "esperava 422 para #{cafes.inspect}/#{almocos.inspect}"
        end
        expect(Recarga.count).to eq(0)
      end

      it "rejeita método de pagamento desconhecido" do
        solicitar(cafes: 1, almocos: 0, metodo: "boleto")
        expect(response).to have_http_status(:unprocessable_content)
        expect(Recarga.count).to eq(0)
      end

      it "não aceita o total enviado pelo cliente: recalcula pelas tarifas" do
        post recargas_path, params: {
          acao: "confirmar",
          solicitacao_recarga: { quantidade_cafes: "0", quantidade_almocos: "1", metodo: "pix", valor_total: "0.01" }
        }
        expect(estudante.recargas.last.valor_total).to eq(BigDecimal("4.50"))
      end

      it "responde 4xx (não 500) quando os parâmetros vêm malformados" do
        post recargas_path, params: { acao: "confirmar", solicitacao_recarga: "abc" }
        expect(response.status).to be_between(400, 499)
      end
    end

    describe "confirmação do PIX (RN02.2 e RN02.4)" do
      # Gera o PIX num segundo inteiro: travel_to descarta microssegundos, e sem isso
      # "aos 10 minutos exatos" cairia uma fração de segundo antes do vencimento.
      let(:inicio) { Time.current.change(usec: 0) + 1.second }
      before { travel_to(inicio) { solicitar(cafes: 0, almocos: 5) } }

      let(:recarga) { estudante.recargas.last }
      let(:pagamento) { recarga.pagamento_atual }

      it "confirmação dupla credita uma única vez" do
        post simular_confirmacao_recarga_path(recarga)
        expect { post simular_confirmacao_recarga_path(recarga) }.not_to change(MovimentacaoSaldo, :count)
        expect(estudante.saldo).to eq(BigDecimal("22.50"))
        expect(recarga.pagamentos.confirmado.count).to eq(1)
      end

      it "credita se a confirmação chega 1 segundo antes dos 10 minutos" do
        travel_to(pagamento.expira_em - 1.second) { post simular_confirmacao_recarga_path(recarga) }
        expect(pagamento.reload).to be_confirmado
        expect(estudante.saldo).to eq(BigDecimal("22.50"))
      end

      it "recusa e expira a confirmação que chega aos 10 minutos exatos" do
        expect(pagamento.expira_em).to eq(inicio + 10.minutes)
        travel_to(pagamento.expira_em) { post simular_confirmacao_recarga_path(recarga) }
        expect(response).to redirect_to(recarga_path(recarga))
        expect(flash[:alert]).to include("não está mais pendente")
        expect(pagamento.reload).to be_expirado
        expect(recarga.reload).to be_expirada
        expect(estudante.saldo).to eq(0)
      end

      it "não aceita pagamento com cartão numa cobrança PIX" do
        post pagar_cartao_recarga_path(recarga), params: dados_cartao
        expect(flash[:alert]).to eq(RecargasController::MSG_COBRANCA_SEM_CARTAO)
        expect(pagamento.reload).to be_pendente
        expect(estudante.saldo).to eq(0)
      end

      it "simular_confirmacao não existe fora de desenvolvimento e teste" do
        allow(Rails.env).to receive(:local?).and_return(false)
        post simular_confirmacao_recarga_path(recarga)
        expect(response).to have_http_status(:not_found)
        expect(pagamento.reload).to be_pendente
        expect(estudante.saldo).to eq(0)
      end
    end

    it "simular_confirmacao não confirma cobrança de cartão" do
      solicitar(cafes: 1, almocos: 0, metodo: "cartao_credito")
      recarga = estudante.recargas.last
      post simular_confirmacao_recarga_path(recarga)
      expect(recarga.pagamento_atual.reload).to be_pendente
      expect(estudante.saldo).to eq(0)
    end

    describe "recarga de outro estudante" do
      let(:outro) { create(:estudante) }
      let(:recarga_alheia) { create(:recarga, estudante: outro, quantidade: 5) }

      it "não confirma o PIX de outra pessoa (404)" do
        pix = create(:pagamento, :pix, recarga: recarga_alheia)
        post simular_confirmacao_recarga_path(recarga_alheia)
        expect(response).to have_http_status(:not_found)
        expect(pix.reload).to be_pendente
        expect(outro.saldo).to eq(0)
      end

      it "não paga com cartão a cobrança de outra pessoa (404)" do
        cartao = create(:pagamento, :cartao, recarga: recarga_alheia)
        post pagar_cartao_recarga_path(recarga_alheia), params: dados_cartao
        expect(response).to have_http_status(:not_found)
        expect(cartao.reload).to be_pendente
        expect(outro.saldo).to eq(0)
      end
    end

    describe "dados do cartão" do
      let(:numero) { "4111 1111 1111 1111" }
      let(:nome) { "Titular Secreto Da Silva" }

      before do
        solicitar(cafes: 2, almocos: 4, metodo: "cartao_credito")
        post pagar_cartao_recarga_path(estudante.recargas.last), params: dados_cartao(numero: numero, nome: nome, cvv: "987")
      end

      it "nunca são gravados no banco" do
        expect(estudante.saldo).to eq(BigDecimal("23.00"))
        conexao = ActiveRecord::Base.connection
        conexao.tables.each do |tabela|
          colunas = conexao.columns(tabela).select { |c| %i[string text].include?(c.type) }
          next if colunas.empty?

          conexao.select_rows("SELECT #{colunas.map { |c| conexao.quote_column_name(c.name) }.join(', ')} " \
                              "FROM #{conexao.quote_table_name(tabela)}").flatten.compact.each do |valor|
            expect(valor).not_to include("4111111111111111", numero, nome), "dado do cartão gravado em #{tabela}"
          end
        end
      end

      it "não aparecem na página após o pagamento" do
        follow_redirect!
        expect(response.body).not_to include("4111111111111111")
        expect(response.body).not_to include(numero)
        expect(response.body).not_to include("987")
      end

      it "são filtrados do log de parâmetros" do
        filtro = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
        filtrado = filtro.filter("dados_cartao" => { "numero" => numero, "nome" => nome, "validade" => "12/30",
                                                     "cvv" => "987" })
        expect(filtrado["dados_cartao"].values).to all(eq("[FILTERED]"))
      end
    end
  end
end
