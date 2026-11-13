require "rails_helper"

RSpec.describe "Gestão de catracas (F08)", type: :request do
  let!(:restaurante) { create(:restaurante, quantidade_pisos: 2) }
  let(:piso_1) { restaurante.pisos.find_by!(numero: 1) }

  def dados(sobrescritos = {})
    { identificacao: "Catraca 01", restaurante_id: restaurante.id, piso_numero: 1 }.merge(sobrescritos)
  end

  it "nega funcionário sem papel de administrador" do
    login_controle(create(:funcionario))
    expect { post admin_catracas_path, params: { catraca: dados } }.not_to change(Catraca, :count)
    expect(response).to redirect_to(controle_root_path)
  end

  context "como administrador" do
    before { login_controle(create(:administrador)) }

    it "limita o campo de piso ao maior piso do restaurante" do
      outro = create(:restaurante, quantidade_pisos: 5)

      get new_admin_catraca_path, params: {}
      expect(response.body).to include(%(data-maximo-piso="2"), %(data-maximo-piso="5"))
      expect(response.body).to match(/<input[^>]*max="2"[^>]*name="catraca\[piso_numero\]"/)
      expect(response.body).to include("Maior piso deste restaurante: 2")

      catraca = outro.pisos.find_by!(numero: 5).catracas.create!(identificacao: "Catraca 05")
      get edit_admin_catraca_path(catraca)
      expect(response.body).to match(/<input[^>]*max="5"[^>]*name="catraca\[piso_numero\]"/)
    end

    it "cria a catraca no piso do restaurante" do
      expect { post admin_catracas_path, params: { catraca: dados } }.to change(piso_1.catracas, :count).by(1)
      expect(flash[:notice]).to eq("Catraca cadastrada com sucesso")
    end

    {
      "identificação vazia" => [ { identificacao: "" }, "Identificação da catraca é obrigatória" ],
      "piso inexistente" => [ { piso_numero: 4 }, "Piso inexistente para este restaurante" ],
      "restaurante inexistente" => [ { restaurante_id: 0 }, "Restaurante não encontrado" ]
    }.each do |caso, (dados_invalidos, mensagem)|
      it "rejeita #{caso}" do
        expect { post admin_catracas_path, params: { catraca: dados(dados_invalidos) } }.not_to change(Catraca, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(mensagem)
      end
    end

    it "rejeita identificação repetida em outro piso do restaurante" do
      piso_1.catracas.create!(identificacao: "Catraca 01")
      expect { post admin_catracas_path, params: { catraca: dados(piso_numero: 2) } }.not_to change(Catraca, :count)
      expect(response.body).to include("Já existe uma catraca com essa identificação neste restaurante")
    end

    it "não aceita piso de outro restaurante" do
      outro = create(:restaurante, quantidade_pisos: 3)
      post admin_catracas_path, params: { catraca: dados(restaurante_id: restaurante.id, piso_numero: outro.pisos.maximum(:numero)) }
      expect(response.body).to include("Piso inexistente para este restaurante")
    end

    it "edita a catraca" do
      catraca = piso_1.catracas.create!(identificacao: "Catraca 01")
      get edit_admin_catraca_path(catraca)
      expect(response).to have_http_status(:ok)

      patch admin_catraca_path(catraca), params: { catraca: dados(identificacao: "Catraca 09", piso_numero: 2, ativa: "0") }
      catraca.reload
      expect(flash[:notice]).to eq("Catraca atualizada com sucesso")
      expect([ catraca.identificacao, catraca.piso.numero, catraca.ativa ]).to eq([ "Catraca 09", 2, false ])
    end

    it "pede confirmação e remove a catraca" do
      catraca = piso_1.catracas.create!(identificacao: "Catraca 01")
      get remover_admin_catraca_path(catraca)
      expect(response.body).to include("Confirmar remoção")

      delete admin_catraca_path(catraca)
      expect(flash[:notice]).to eq("Catraca removida com sucesso")
      expect(Catraca.exists?(catraca.id)).to be(false)
    end

    it "não remove catraca em operação" do
      catraca = piso_1.catracas.create!(identificacao: "Catraca 01")
      allow_any_instance_of(Catraca).to receive(:em_operacao?).and_return(true)

      delete admin_catraca_path(catraca)
      expect(flash[:alert]).to eq("Não é possível remover uma catraca em operação")
      expect(Catraca.exists?(catraca.id)).to be(true)
    end
  end
end

RSpec.describe "Catracas disponíveis na aplicação de controle (F08)", type: :request do
  let(:restaurante) { create(:restaurante) }
  let(:piso) { restaurante.pisos.first }

  it "exige login" do
    get controle_restaurante_catracas_path(restaurante)
    expect(response).to redirect_to(controle_login_path)
  end

  context "como funcionário" do
    before { login_controle(create(:funcionario)) }

    it "chega à lista pelo painel, só com restaurantes ativos, e volta por ele" do
      ativo = restaurante
      inativo = create(:restaurante, ativo: false)

      get controle_root_path
      expect(response.body).to include(controle_restaurante_catracas_path(ativo))
      expect(response.body).not_to include(controle_restaurante_catracas_path(inativo))

      get controle_restaurante_catracas_path(restaurante)
      expect(response.body).to include("Voltar ao painel")
    end

    it "lista só as catracas ativas do restaurante" do
      piso.catracas.create!(identificacao: "Disponível")
      piso.catracas.create!(identificacao: "Desativada", ativa: false)
      create(:catraca, identificacao: "De outro restaurante", piso: create(:restaurante).pisos.first)

      get controle_restaurante_catracas_path(restaurante)

      expect(response.body).to include("Disponível")
      expect(response.body).not_to include("Desativada", "De outro restaurante")
    end

    it "avisa quando não há catracas" do
      get controle_restaurante_catracas_path(restaurante)
      expect(response.body).to include("Nenhuma catraca disponível")
    end

    it "não abre restaurante inativo" do
      restaurante.update!(ativo: false)
      get controle_restaurante_catracas_path(restaurante)
      expect(response).to have_http_status(:not_found)
    end
  end
end
