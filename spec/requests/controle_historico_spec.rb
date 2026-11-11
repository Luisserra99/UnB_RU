require "rails_helper"

RSpec.describe "Histórico local da catraca (F07)", type: :request do
  let(:funcionario) { create(:funcionario, password: "senhaCorreta") }
  let(:catraca) { create(:catraca, identificacao: "CAT-01") }
  let(:momento) { Time.zone.local(2026, 10, 14, 11, 30) }

  def configurar(usuario = funcionario, catraca_alvo = catraca)
    login_controle(usuario)
    post controle_ponto_acesso_path, params: { restaurante_id: catraca_alvo.restaurante.id, catraca_id: catraca_alvo.id }
  end

  def ponto_atual
    ConfiguracaoPontoAcesso.where(catraca: catraca).order(:id).last
  end

  def liberar_historico(matricula: funcionario.identificacao, senha: "senhaCorreta")
    post controle_historico_path, params: { matricula: matricula, senha: senha }
  end

  def registrar(configuracao: ponto_atual, em: momento, **atributos)
    create(:registro_acesso, configuracao_ponto_acesso: configuracao, lido_em: em, liberado_em: em + 1.second,
                             passagem_em: em + 3.seconds, bloqueado_em: em + 3.seconds, **atributos)
  end

  describe "acesso" do
    it "exige login de funcionário" do
      get controle_historico_path
      expect(response).to redirect_to(controle_login_path)
    end

    it "exige ponto de acesso confirmado" do
      login_controle(funcionario)
      get controle_historico_path
      expect(response).to redirect_to(controle_root_path)
    end

    it "pede a credencial antes de mostrar o histórico" do
      configurar
      registrar
      get controle_historico_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Histórico Local da CAT-01", "Confirme sua credencial")
      expect(response.body).not_to include('id="historico-acessos"')
    end

    it "mostra o item 'Histórico Local' como link no menu" do
      configurar
      get controle_root_path
      expect(response.body).to include(%(href="#{controle_historico_path}"))
    end
  end

  describe "credencial (RN07.1)" do
    before { configurar }

    it "libera o histórico com a credencial do funcionário que gerencia a catraca" do
      liberar_historico
      expect(response).to redirect_to(controle_historico_path)

      follow_redirect!
      expect(response.body).to include("Credencial validada", 'id="historico"')
    end

    {
      "matrícula vazia" => { matricula: "" },
      "senha vazia" => { senha: "" },
      "senha incorreta" => { senha: "SenhaErrada" },
      "matrícula com letras" => { matricula: "abc123xyz" },
      "matrícula não cadastrada" => { matricula: "999999999" }
    }.each do |caso, credencial|
      it "recusa #{caso} com 'Credencial inválida'" do
        liberar_historico(**credencial)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Credencial inválida")
        expect(response.body).not_to include('id="historico"')
      end
    end

    it "recusa o funcionário que gerencia outra catraca" do
      outro = create(:funcionario, password: "senhaOutra1")
      outra_catraca = create(:catraca, identificacao: "CAT-02")
      PontosAcesso::Configurar.call(
        sessao: SessaoAutenticacao.iniciar!(outro).first, restaurante_id: outra_catraca.restaurante.id, catraca_id: outra_catraca.id
      )

      liberar_historico(matricula: outro.identificacao, senha: "senhaOutra1")
      expect(response.body).to include("Credencial inválida")
    end

    it "não revela o histórico depois de uma tentativa inválida" do
      liberar_historico
      liberar_historico(senha: "SenhaErrada")
      get controle_historico_path
      expect(response.body).not_to include('id="historico"')
    end
  end

  describe "listagem (RN07.2 e RN07.3)" do
    before do
      configurar
      liberar_historico
    end

    it "mostra só os registros da catraca gerenciada" do
      registrar(identificacao_lida: "251033574")
      outra = create(:configuracao_ponto_acesso, catraca: create(:catraca, identificacao: "CAT-02"))
      registrar(configuracao: outra, identificacao_lida: "202033481", em: momento + 45.minutes)

      get controle_historico_path
      expect(response.body).to include("251033574")
      expect(response.body).not_to include("202033481")
    end

    it "mostra os campos de cada leitura (RN07.4)" do
      registrar(saldo_lido: 10)
      get controle_historico_path

      expect(response.body).to include("14/10/2026", "11:30:00", "10,00", "11:30:01", "11:30:03")
      expect(response.body).to include("Liberado (passagem confirmada)")
    end

    it "informa quando a catraca não tem acessos" do
      get controle_historico_path
      expect(response.body).to include("Nenhum acesso registrado nesta catraca")
      expect(response.body).not_to include('id="historico-acessos"')
    end

    it "pagina o histórico" do
      (HistoricoCatraca::Consulta::POR_PAGINA + 1).times { |i| registrar(em: momento + i.minutes) }

      get controle_historico_path
      expect(response.body).to include("Página 1 de 2")
      get controle_historico_path(pagina: 2)
      expect(response.body).to include("Página 2 de 2")
    end
  end

  describe "validade da liberação" do
    before do
      configurar
      liberar_historico
    end

    it "pede a credencial de novo depois de #{Controle::HistoricoController::VALIDADE.inspect}" do
      travel(Controle::HistoricoController::VALIDADE + 1.second) do
        get controle_historico_path
        expect(response.body).to include("Confirme sua credencial")
      end
    end

    it "pede a credencial de novo quando o ponto de acesso muda" do
      outra_catraca = create(:catraca, identificacao: "CAT-09", piso: catraca.piso)
      post reconfigurar_controle_ponto_acesso_path
      post controle_ponto_acesso_path, params: { restaurante_id: catraca.restaurante.id, catraca_id: outra_catraca.id }

      get controle_historico_path
      expect(response.body).to include("Histórico Local da CAT-09", "Confirme sua credencial")
    end

    it "bloqueia o histórico pelo botão 'Bloquear histórico'" do
      delete controle_historico_path
      expect(response).to redirect_to(controle_historico_path)

      follow_redirect!
      expect(response.body).to include("Confirme sua credencial")
    end

    it "encerra com o logout" do
      delete controle_logout_path
      configurar
      get controle_historico_path
      expect(response.body).to include("Confirme sua credencial")
    end
  end
end
