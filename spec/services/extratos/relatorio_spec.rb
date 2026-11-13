require "rails_helper"

RSpec.describe Extratos::Relatorio do
  let(:agora) { Time.zone.local(2024, 5, 14, 20, 0) }
  let(:estudante) { create(:usuario_estudante).estudante }
  let(:restaurante) { create(:restaurante, nome: "RU Darcy Ribeiro", quantidade_pisos: 2) }
  let(:catraca_um) { create(:catraca, piso: restaurante.pisos.find_by!(numero: 1), identificacao: "Catraca 01") }
  let(:catraca_dois) { create(:catraca, piso: restaurante.pisos.find_by!(numero: 2), identificacao: "Catraca 04") }
  let(:ponto_um) { create(:configuracao_ponto_acesso, catraca: catraca_um) }
  let(:ponto_dois) { create(:configuracao_ponto_acesso, catraca: catraca_dois) }
  let(:almoco) { tipo_refeicao_de(TipoRefeicao::ALMOCO, "Almoço") }
  let(:jantar) { tipo_refeicao_de(TipoRefeicao::JANTAR, "Jantar") }

  def relatorio(filtros = {})
    described_class.new(estudante, filtros, agora: agora)
  end

  around { |exemplo| travel_to(agora) { exemplo.run } }

  before do
    refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 9, 12, 40), ponto: ponto_dois, tipo: almoco)
    recarga_do_extrato(estudante, em: Time.zone.local(2024, 5, 10, 14, 0))
    refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 13, 19, 10), ponto: ponto_um, tipo: jantar)
    refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 14, 12, 20), ponto: ponto_dois, tipo: almoco)
  end

  describe "filtros padrão" do
    it "usa últimos 30 dias, todas as refeições e todas as catracas" do
      expect(relatorio.filtros).to eq("tipo" => "todas", "periodo" => "30_dias", "catraca_id" => nil)
      expect(relatorio.periodo_nome).to eq("Últimos 30 dias")
      expect(relatorio.tipo_nome).to eq("Todas as Refeições")
      expect(relatorio.catraca_nome).to eq("Todas as 2 Catracas")
    end

    it "lista todos os lançamentos, do mais recente para o mais antigo" do
      expect(relatorio.lancamentos.map(&:evento)).to eq([ "Almoço", "Jantar", "Recarga de Saldo", "Almoço" ])
    end

    it "calcula os totais" do
      expect(relatorio.total_gasto).to eq(BigDecimal("13.50"))
      expect(relatorio.total_recarregado).to eq(BigDecimal("45.00"))
      expect(relatorio.refeicoes_realizadas).to eq(3)
      expect(relatorio.saldo_atual).to eq(BigDecimal("31.50"))
    end

    it "descreve o local e a catraca de cada refeição" do
      refeicao = relatorio.lancamentos.first

      expect(refeicao.local).to eq("RU Darcy Ribeiro - Piso 2")
      expect(refeicao.catraca).to eq("Catraca 04")
      expect(refeicao.valor).to eq(BigDecimal("-4.50"))
    end
  end

  describe "filtro por tipo de refeição" do
    it "mantém só as refeições do tipo escolhido" do
      resultado = relatorio(tipo: TipoRefeicao::ALMOCO)

      expect(resultado.lancamentos.map(&:evento)).to eq(%w[Almoço Almoço])
      expect(resultado.total_gasto).to eq(BigDecimal("9.00"))
      expect(resultado.total_recarregado).to eq(0)
    end

    it "mantém só as recargas" do
      resultado = relatorio(tipo: "recarga")

      expect(resultado.lancamentos.map(&:evento)).to eq([ "Recarga de Saldo" ])
      expect(resultado.total_gasto).to eq(0)
      expect(resultado.refeicoes_realizadas).to eq(0)
    end

    it "volta ao padrão quando o tipo é desconhecido" do
      expect(relatorio(tipo: "sobremesa").tipo).to eq("todas")
    end
  end

  describe "filtro por catraca" do
    it "mantém só as refeições da catraca, sem as recargas" do
      resultado = relatorio(catraca_id: catraca_um.id.to_s)

      expect(resultado.lancamentos.map(&:catraca)).to eq([ "Catraca 01" ])
      expect(resultado.catraca_nome).to eq("Catraca 01 · RU Darcy Ribeiro")
    end

    it "ignora uma catraca inexistente" do
      expect(relatorio(catraca_id: "999999").catraca_id).to be_nil
    end

    it "combina com o filtro de tipo" do
      expect(relatorio(tipo: TipoRefeicao::JANTAR, catraca_id: catraca_dois.id)).to be_vazio
    end
  end

  describe "filtro por período" do
    it "considera só o dia atual em Hoje" do
      expect(relatorio(periodo: "hoje").lancamentos.size).to eq(1)
    end

    it "inclui o dia inteiro do início do período" do
      refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 7, 0, 5), ponto: ponto_um, tipo: almoco)
      refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 6, 23, 55), ponto: ponto_um, tipo: jantar)

      expect(relatorio(periodo: "7_dias").lancamentos.size).to eq(5)
    end

    it "deixa de fora o que é mais antigo que 30 dias" do
      refeicao_do_extrato(estudante, em: Time.zone.local(2024, 4, 1, 12, 0), ponto: ponto_um, tipo: almoco)

      expect(relatorio.lancamentos.size).to eq(4)
      expect(relatorio.saldo_atual).to eq(BigDecimal("27.00"))
    end

    it "volta ao padrão quando o período é desconhecido" do
      expect(relatorio(periodo: "sempre").periodo).to eq("30_dias")
    end
  end

  describe "resumo dos indicadores" do
    it "conta as refeições por tipo, na ordem do dia, e as recargas" do
      expect(relatorio.refeicoes_por_tipo).to eq("Almoço" => 2, "Jantar" => 1)
      expect(relatorio.quantidade_recargas).to eq(1)
    end

    it "sabe quando há filtro diferente do padrão" do
      expect(relatorio).not_to be_filtrado
      expect(relatorio(tipo: TipoRefeicao::ALMOCO)).to be_filtrado
      expect(relatorio(periodo: "hoje")).to be_filtrado
    end
  end

  describe "paginação da tela" do
    before do
      12.times { |indice| recarga_do_extrato(estudante, em: Time.zone.local(2024, 5, 12, 8, indice), valor: "1.00") }
    end

    it "mostra 10 lançamentos por página sem alterar os totais" do
      primeira = relatorio
      segunda = relatorio(pagina: "2")

      expect(primeira.lancamentos.size).to eq(16)
      expect(primeira.total_paginas).to eq(2)
      expect(primeira.lancamentos_da_pagina.size).to eq(10)
      expect(primeira.intervalo_da_pagina).to eq([ 1, 10 ])
      expect(segunda.lancamentos_da_pagina.size).to eq(6)
      expect(segunda.intervalo_da_pagina).to eq([ 11, 16 ])
      expect(segunda.total_recarregado).to eq(primeira.total_recarregado)
    end

    it "limita a página a valores existentes" do
      expect(relatorio(pagina: "99").pagina_atual).to eq(2)
      expect(relatorio(pagina: "-3").pagina_atual).to eq(1)
    end

    it "mostra só as páginas próximas quando há muitas" do
      60.times { |indice| recarga_do_extrato(estudante, em: Time.zone.local(2024, 5, 11, 8, indice), valor: "1.00") }

      expect(relatorio.paginas_visiveis).to eq([ 1, 2, nil, 8 ])
      expect(relatorio(pagina: "5").paginas_visiveis).to eq([ 1, nil, 4, 5, 6, nil, 8 ])
      expect(relatorio(pagina: "8").paginas_visiveis).to eq([ 1, nil, 7, 8 ])
    end

    it "não inclui a página nos filtros gravados na exportação" do
      expect(relatorio(pagina: "2").filtros.keys).to eq(%w[tipo periodo catraca_id])
    end
  end

  describe "isolamento entre estudantes" do
    it "nunca inclui lançamentos de outro estudante" do
      outro = create(:usuario_estudante).estudante
      refeicao_do_extrato(outro, em: Time.zone.local(2024, 5, 13, 12, 0), ponto: ponto_um, tipo: almoco)

      expect(relatorio.lancamentos.size).to eq(4)
    end
  end

  describe "estudante sem lançamentos" do
    let(:novato) { create(:usuario_estudante).estudante }

    it "fica vazio e com totais zerados" do
      resultado = described_class.new(novato, {}, agora: agora)

      expect(resultado).to be_vazio
      expect(resultado.possui_lancamentos?).to be(false)
      expect(resultado.total_gasto).to eq(0)
      expect(resultado.total_recarregado).to eq(0)
    end
  end

  it "trata como Refeição o débito sem tipo de serviço" do
    refeicao_do_extrato(estudante, em: Time.zone.local(2024, 5, 14, 13, 0), ponto: ponto_um)

    expect(relatorio.lancamentos.first.evento).to eq("Refeição")
    expect(relatorio(tipo: TipoRefeicao::ALMOCO).lancamentos.size).to eq(2)
  end
end
