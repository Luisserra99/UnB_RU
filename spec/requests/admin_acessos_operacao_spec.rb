require "rails_helper"

RSpec.describe "Acessos do Relatório de Operação e exportação em PDF (F12)", type: :request do
  let(:administrador) { create(:administrador, password: "senhaCorreta") }
  let(:darcy) { create(:restaurante, nome: "RU Darcy Ribeiro", quantidade_pisos: 1) }
  let!(:catraca) { create(:catraca, piso: darcy.pisos.first, identificacao: "Catraca 01") }
  let(:periodo) { { inicio: 2.days.ago.to_date.iso8601, fim: Date.current.iso8601 } }

  def entrar_no_controle(usuario)
    post controle_login_path, params: { identificacao: usuario.identificacao, senha: "senhaCorreta" }
  end

  describe "controle de acesso (RN12.1)" do
    it "manda para o login quem não tem sessão, na tela e na exportação" do
      get admin_acessos_relatorio_global_path
      expect(response).to redirect_to(controle_login_path)

      post exportar_admin_acessos_relatorio_global_path, params: periodo
      expect(response).to redirect_to(controle_login_path)
      expect(ExportacaoRelatorio.count).to eq(0)
    end

    it "nega a exportação direta para funcionário comum" do
      entrar_no_controle(create(:funcionario, password: "senhaCorreta"))
      post exportar_admin_acessos_relatorio_global_path, params: periodo

      expect(response).to have_http_status(:forbidden)
      expect(response.media_type).to eq("text/html")
      expect(ExportacaoRelatorio.count).to eq(0)
    end

    it "nega a exportação direta para estudante" do
      login_estudante(create(:usuario_estudante, password: "senhaCorreta"))
      post exportar_admin_acessos_relatorio_global_path, params: periodo

      expect(response).to have_http_status(:forbidden)
      expect(ExportacaoRelatorio.count).to eq(0)
    end

    it "manda para o login quando a sessão do administrador expirou" do
      entrar_no_controle(administrador)
      administrador.sessoes.update_all(expira_em: 1.minute.ago)
      post exportar_admin_acessos_relatorio_global_path, params: periodo

      expect(response).to redirect_to(controle_login_path)
      expect(flash[:alert]).to include("Sua sessão expirou")
    end
  end

  context "com administrador logado" do
    before { entrar_no_controle(administrador) }

    it "lista os acessos do período com totais e paginação" do
      3.times { |indice| acesso_na_catraca(catraca, em: 1.day.ago + indice.minutes, referencia: "R00#{indice}") }
      get admin_acessos_relatorio_global_path, params: periodo.merge(por_pagina: 2)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Relatório Global de Operação", "R000", "R001", "Página 1 de 2",
                                       "R$ 13,50", "Exportar PDF")
      expect(response.body).not_to include("R002")
    end

    it "exporta todos os acessos do filtro, mesmo com a listagem paginada (RN12.2)" do
      3.times { |indice| acesso_na_catraca(catraca, em: 1.day.ago + indice.minutes, referencia: "R00#{indice}") }
      post exportar_admin_acessos_relatorio_global_path, params: periodo.merge(por_pagina: 2, pagina: 1)

      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("attachment", "relatorio-operacao-")
      expect(texto_de_pdf(response.body)).to include("R000", "R001", "R002", "Total geral: 3 acessos")
    end

    it "avisa quando não há acessos e não baixa arquivo (RN12.6)" do
      post exportar_admin_acessos_relatorio_global_path, params: periodo

      expect(response).to redirect_to(admin_acessos_relatorio_global_path(periodo))
      follow_redirect!
      expect(response.body).to include("Não há acessos para os filtros selecionados")
    end

    it "rejeita o período invertido na tela e na exportação (RN12.7)" do
      invertido = { inicio: "2026-10-16", fim: "2026-10-14" }

      get admin_acessos_relatorio_global_path, params: invertido
      expect(response.body).to include("A data inicial deve ser anterior ou igual à data final")

      post exportar_admin_acessos_relatorio_global_path, params: invertido
      expect(response).to redirect_to(admin_acessos_relatorio_global_path(invertido))
      expect(ExportacaoRelatorio.count).to eq(0)
    end
  end
end
