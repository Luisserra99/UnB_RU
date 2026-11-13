require "rails_helper"

RSpec.describe "Exportação do extrato do estudante (F11)", type: :request do
  let!(:aluno) { create(:usuario_estudante, password: "senhaCorreta") }
  let(:estudante) { aluno.estudante }
  let(:ponto) { create(:configuracao_ponto_acesso) }
  let(:almoco) { tipo_refeicao_de(TipoRefeicao::ALMOCO, "Almoço") }

  it "exige login de estudante" do
    post exportacoes_extrato_path, params: { formato: "pdf" }

    expect(response).to redirect_to(login_estudante_path)
    expect(ExportacaoRelatorio.count).to eq(0)
  end

  context "com estudante logado e lançamentos" do
    before do
      recarga_do_extrato(estudante, em: 3.days.ago)
      refeicao_do_extrato(estudante, em: 1.day.ago, ponto: ponto, tipo: almoco)
      login_estudante(aluno)
    end

    it "baixa o PDF do extrato" do
      post exportacoes_extrato_path, params: { formato: "pdf" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("attachment", "extrato-#{estudante.matricula}-")
      expect(response.body).to start_with("%PDF")
    end

    it "baixa o CSV do extrato" do
      post exportacoes_extrato_path, params: { formato: "csv" }

      expect(response.media_type).to eq("text/csv")
      expect(response.body.force_encoding("UTF-8")).to include("data_hora;evento;local;catraca;valor", "Almoço")
    end

    it "respeita os filtros enviados" do
      post exportacoes_extrato_path, params: { formato: "csv", tipo: "recarga" }

      corpo = response.body.force_encoding("UTF-8")
      expect(corpo).to include("Recarga de Saldo")
      expect(corpo).not_to include("Almoço")
      expect(ExportacaoRelatorio.last.filtros).to include("tipo" => "recarga")
    end

    it "volta ao extrato com a mensagem quando os filtros não retornam lançamentos" do
      post exportacoes_extrato_path, params: { formato: "pdf", tipo: TipoRefeicao::JANTAR }

      expect(response).to redirect_to(extrato_path(tipo: TipoRefeicao::JANTAR, periodo: "30_dias"))
      follow_redirect!
      expect(response.body).to include("Não há lançamentos para os filtros selecionados")
      expect(ExportacaoRelatorio.last).to be_sem_dados
    end

    it "nunca exporta lançamentos de outro estudante, mesmo recebendo o id dele" do
      outro = create(:usuario_estudante).estudante
      refeicao_do_extrato(outro, em: 2.hours.ago, ponto: ponto, tipo: almoco)

      post exportacoes_extrato_path, params: { formato: "csv", estudante_id: outro.id }

      expect(response.body.lines.size).to eq(3) # cabeçalho + 2 lançamentos do próprio estudante
      expect(ExportacaoRelatorio.last.usuario).to eq(aluno)
    end

    it "mostra indicadores, contador, botão de imprimir e etiquetas por evento" do
      get extrato_path

      expect(response.body).to include("Refeições realizadas", "2 totais", "Imprimir", "Registros auditáveis",
                                       "evento-almoco", "evento-recarga", "Exibindo", "1 almoço")
      expect(response.body).not_to include("Limpar Filtros")
    end

    it "oferece limpar filtros quando algum filtro está aplicado" do
      get extrato_path, params: { tipo: "recarga" }

      expect(response.body).to include("Limpar Filtros", "1 totais")
      expect(response.body).not_to include("evento-almoco")
    end

    it "pagina os lançamentos e exporta todos, independentemente da página" do
      12.times { |indice| recarga_do_extrato(estudante, em: 5.days.ago + indice.minutes, valor: "1.00") }

      get extrato_path, params: { pagina: 2 }
      expect(response.body).to include("14 totais").and match(/Exibindo <b>11–14<\/b>/)

      post exportacoes_extrato_path, params: { formato: "csv", pagina: 2 }
      expect(response.body.lines.size).to eq(15) # cabeçalho + 14 lançamentos
    end

    it "mostra filtros, totais e botões de exportação na tela do extrato" do
      get extrato_path

      expect(response.body).to include("Período de referência", "Tipo de refeição", "Total gasto",
                                       "Total recarregado", "Exportar PDF", "Exportar CSV")
    end
  end

  context "com estudante logado e sem lançamentos" do
    before { login_estudante(aluno) }

    it "mostra o botão de exportação desabilitado" do
      get extrato_path

      expect(response.body).to match(/<button[^>]*disabled[^>]*>Exportar PDF/)
    end
  end

  context "com a sessão expirada" do
    it "redireciona ao login e não gera arquivo" do
      login_estudante(aluno)
      aluno.sessoes.update_all(expira_em: 1.minute.ago)

      post exportacoes_extrato_path, params: { formato: "pdf" }

      expect(response).to redirect_to(login_estudante_path)
      expect(flash[:alert]).to include("Sua sessão expirou")
      expect(ExportacaoRelatorio.count).to eq(0)
    end
  end
end
