require "rails_helper"

RSpec.describe "Relatório Global de Operação (F09)", type: :request do
  let(:unidade) { create(:unidade_gestora, nome: "Campus Darcy Ribeiro") }
  let!(:restaurante) { restaurante_com_catraca(unidade, "Restaurante 1") }
  let(:administrador) { create(:administrador, password: "senhaCorreta") }

  def entrar_no_controle(usuario)
    post controle_login_path, params: { identificacao: usuario.identificacao, senha: "senhaCorreta" }
  end

  describe "controle de acesso (RN09.1)" do
    it "manda para o login quem não tem sessão" do
      get admin_relatorio_global_path

      expect(response).to redirect_to(controle_login_path)
    end

    it "não mostra o item de menu para funcionário comum" do
      entrar_no_controle(create(:funcionario, password: "senhaCorreta"))
      get controle_root_path

      expect(response.body).not_to include(admin_relatorio_global_path)
    end

    it "nega o funcionário que não é administrador, sem mostrar dados" do
      entrar_no_controle(create(:funcionario, password: "senhaCorreta"))
      get admin_relatorio_global_path

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Acesso não autorizado")
      expect(response.body).not_to include("Arrecadação Global", "Restaurante 1")
    end

    it "nega o estudante logado, sem mostrar dados" do
      aluno = create(:usuario_estudante, password: "senhaCorreta")
      login_estudante(aluno)
      get admin_relatorio_global_path

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Acesso não autorizado")
      expect(response.body).not_to include("Arrecadação Global")
    end

    it "nega também a exportação para quem não é administrador" do
      entrar_no_controle(create(:funcionario, password: "senhaCorreta"))
      post exportar_admin_relatorio_global_path, params: { formato: "pdf" }

      expect(response).to have_http_status(:forbidden)
      expect(ExportacaoRelatorio.count).to eq(0)
    end
  end

  context "com administrador logado" do
    before { entrar_no_controle(administrador) }

    it "mostra o relatório zerado quando não há acessos (RN09.14)" do
      get admin_relatorio_global_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Relatório Global de Operação", "Nenhum acesso encontrado",
                                       "Total Consolidado", "Restaurante 1", "Campus Darcy Ribeiro")
    end

    it "mostra os números do dia e os botões de exportação" do
      estudante = create(:usuario_estudante).estudante
      acesso_realizado(restaurante, turno: TipoRefeicao::ALMOCO, dia: Date.current,
                                    recarga: recarga_confirmada(estudante, :pix))
      get admin_relatorio_global_path

      expect(response.body).to include("R$ 4,50", "Exportar CSV", "Exportar PDF Oficial", "1/1")
      expect(response.body).not_to include("Nenhum acesso encontrado")
    end

    it "aparece no menu da aplicação de controle" do
      get controle_root_path

      expect(response.body).to include(%(href="#{admin_relatorio_global_path}"), "Relatório Global")
    end

    it "não oferece rotas de alteração (RN09.2)" do
      rotas = Rails.application.routes.routes.select { |rota| rota.defaults[:controller] == "admin/relatorios_globais" }

      expect(rotas.map { |rota| rota.defaults[:action] }).to contain_exactly("show", "exportar")
    end

    it "baixa o CSV respeitando os filtros (RN09.12)" do
      estudante = create(:usuario_estudante).estudante
      pix = recarga_confirmada(estudante, :pix)
      acesso_realizado(restaurante, turno: TipoRefeicao::ALMOCO, dia: Date.current, recarga: pix)
      acesso_realizado(restaurante, turno: TipoRefeicao::JANTAR, dia: Date.current, recarga: pix)

      post exportar_admin_relatorio_global_path, params: { formato: "csv", turno: TipoRefeicao::ALMOCO }

      corpo = response.body.force_encoding("UTF-8")
      expect(response.media_type).to eq("text/csv")
      expect(corpo).to include(";Almoço;Campus Darcy Ribeiro;Total Consolidado;1;4,50")
      expect(corpo).not_to include("Jantar")
    end

    it "baixa o PDF oficial (RN09.13)" do
      estudante = create(:usuario_estudante).estudante
      acesso_realizado(restaurante, turno: TipoRefeicao::ALMOCO, dia: Date.current,
                                    recarga: recarga_confirmada(estudante, :pix))

      post exportar_admin_relatorio_global_path, params: { formato: "pdf" }

      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("attachment", "relatorio-global-")
      expect(ExportacaoRelatorio.last).to have_attributes(usuario: administrador, tipo: "operacao_global")
    end

    it "volta ao relatório com a mensagem quando não há o que exportar" do
      post exportar_admin_relatorio_global_path, params: { formato: "pdf", data: "2025-01-01" }

      expect(response).to redirect_to(admin_relatorio_global_path(data: "2025-01-01", turno: "todos", unidade_id: unidade.id))
      expect(flash[:alert]).to eq("Nenhum acesso encontrado")
    end
  end
end
