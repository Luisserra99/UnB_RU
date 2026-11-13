require "rails_helper"

RSpec.describe "Gestão de restaurantes (F08)", type: :request do
  let!(:unidade) { create(:unidade_gestora, nome: UnidadeGestora::NOME_PADRAO) }
  let(:administrador) { create(:administrador) }
  let(:dados_validos) do
    { unidade_gestora_id: unidade.id, nome: "RU Gama", quantidade_pisos: 2, capacidade_refeicoes_hora: 400 }
  end

  describe "autorização" do
    it "exige login" do
      get admin_restaurantes_path
      expect(response).to redirect_to(controle_login_path)
    end

    it "nega funcionário sem papel de administrador, inclusive para gravar" do
      login_controle(create(:funcionario))

      get admin_restaurantes_path
      expect(response).to redirect_to(controle_root_path)
      follow_redirect!
      expect(response.body).to include(Admin::BaseController::MSG_SOMENTE_ADMINISTRADORES)

      expect { post admin_restaurantes_path, params: { restaurante: dados_validos } }.not_to change(Restaurante, :count)
      expect(response).to redirect_to(controle_root_path)
    end
  end

  context "como administrador" do
    before { login_controle(administrador) }

    it "mostra o link da gestão no menu só para o administrador" do
      get controle_root_path
      expect(response.body).to include(admin_restaurantes_path)
    end

    it "lista restaurantes e totais" do
      create(:restaurante, nome: "RU Listado")
      get admin_restaurantes_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("RU Listado", "Total de restaurantes: 1")
    end

    it "liga cada restaurante ativo às suas catracas disponíveis" do
      ativo = create(:restaurante)
      inativo = create(:restaurante, ativo: false)

      get admin_restaurantes_path
      expect(response.body).to include(controle_restaurante_catracas_path(ativo))
      expect(response.body).not_to include(controle_restaurante_catracas_path(inativo))
    end

    it "pré-seleciona a unidade padrão no cadastro" do
      get new_admin_restaurante_path
      expect(response.body).to match(/selected="selected" value="#{unidade.id}"/)
    end

    it "cria o restaurante com os pisos" do
      expect { post admin_restaurantes_path, params: { restaurante: dados_validos } }
        .to change(Restaurante, :count).by(1).and change(Piso, :count).by(2)
      expect(response).to redirect_to(admin_restaurantes_path)
      expect(flash[:notice]).to eq("Restaurante cadastrado com sucesso")
    end

    it "rejeita dados inválidos sem gravar nada" do
      expect { post admin_restaurantes_path, params: { restaurante: dados_validos.merge(quantidade_pisos: 0) } }
        .not_to change(Restaurante, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("O restaurante deve ter ao menos 1 piso")
    end

    it "atualiza a capacidade" do
      restaurante = create(:restaurante)
      patch admin_restaurante_path(restaurante), params: { restaurante: { capacidade_refeicoes_hora: 1500 } }
      expect(response).to redirect_to(admin_restaurantes_path)
      expect(restaurante.reload.capacidade_refeicoes_hora).to eq(1500)
    end

    it "acrescenta pisos na edição" do
      restaurante = create(:restaurante)
      expect { patch admin_restaurante_path(restaurante), params: { restaurante: { quantidade_pisos: 3 } } }
        .to change { restaurante.pisos.count }.from(1).to(3)
      expect(response).to redirect_to(admin_restaurantes_path)
    end

    it "não remove pisos na edição" do
      restaurante = create(:restaurante, quantidade_pisos: 2)
      expect { patch admin_restaurante_path(restaurante), params: { restaurante: { quantidade_pisos: 1 } } }
        .not_to change(Piso, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Não é possível remover pisos: informe 2 ou mais")
    end

    it "rejeita edição inválida" do
      restaurante = create(:restaurante)
      patch admin_restaurante_path(restaurante), params: { restaurante: { capacidade_refeicoes_hora: 0 } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "pede confirmação sem remover" do
      restaurante = create(:restaurante)
      get remover_admin_restaurante_path(restaurante)
      expect(response.body).to include("Confirmar remoção", "Cancelar")
      expect(Restaurante.exists?(restaurante.id)).to be(true)
    end

    it "remove restaurante sem catracas" do
      restaurante = create(:restaurante)
      delete admin_restaurante_path(restaurante)
      expect(flash[:notice]).to eq("Restaurante removido com sucesso")
      expect(Restaurante.exists?(restaurante.id)).to be(false)
    end

    it "não remove restaurante com catracas" do
      catraca = create(:catraca, piso: create(:restaurante).pisos.first)
      restaurante = catraca.piso.restaurante
      delete admin_restaurante_path(restaurante)
      expect(flash[:alert]).to eq("Remova as catracas do restaurante antes de excluí-lo")
      expect(Restaurante.exists?(restaurante.id)).to be(true)
    end
  end
end
