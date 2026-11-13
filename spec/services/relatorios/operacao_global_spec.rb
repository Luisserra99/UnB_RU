require "rails_helper"

RSpec.describe Relatorios::OperacaoGlobal do
  let(:agora) { Time.zone.local(2025, 10, 24, 15, 0) }
  let(:hoje) { agora.to_date }
  let(:unidade) { create(:unidade_gestora, nome: "Campus Darcy Ribeiro") }
  let!(:restaurante_um) { restaurante_com_catraca(unidade, "Restaurante 1") }
  let!(:restaurante_dois) { restaurante_com_catraca(unidade, "Restaurante 2") }
  let(:estudante) { create(:usuario_estudante).estudante }
  let(:pix) { recarga_confirmada(estudante, :pix) }
  let(:cartao) { recarga_confirmada(estudante, :cartao) }

  def relatorio(filtros = {})
    described_class.new(filtros, agora: agora)
  end

  around { |exemplo| travel_to(agora) { exemplo.run } }

  context "com acessos no dia" do
    before do
      acesso_realizado(restaurante_um, turno: TipoRefeicao::CAFE_DA_MANHA, dia: hoje, recarga: pix, valor: "2.50")
      acesso_realizado(restaurante_um, turno: TipoRefeicao::ALMOCO, dia: hoje, recarga: pix)
      acesso_realizado(restaurante_um, turno: TipoRefeicao::ALMOCO, dia: hoje, recarga: cartao)
      acesso_realizado(restaurante_um, turno: TipoRefeicao::JANTAR, dia: hoje - 1, recarga: pix)
    end

    it "usa hoje, todos os turnos e a unidade padrão quando não há filtros (RN09.3)" do
      expect(relatorio.data_nome).to eq("Hoje (24/10/2025)")
      expect(relatorio.turno_nome).to eq("Todos os Turnos (Café, Almoço, Jantar)")
      expect(relatorio.unidade_nome).to eq("Campus Darcy Ribeiro")
    end

    it "lista um restaurante por linha, na ordem da numeração, inclusive os zerados (RN09.7 e RN09.8)" do
      linhas = relatorio.linhas

      expect(linhas.map { |linha| linha.restaurante.nome }).to eq([ "Restaurante 1", "Restaurante 2" ])
      expect(linhas.map(&:acessos)).to eq([ 3, 0 ])
      expect(linhas.map(&:arrecadacao)).to eq([ BigDecimal("11.50"), 0 ])
    end

    it "soma o valor realmente debitado, com o café da manhã a R$ 2,50" do
      expect(relatorio.total_acessos).to eq(3)
      expect(relatorio.arrecadacao_global).to eq(BigDecimal("11.50"))
      expect(relatorio(turno: TipoRefeicao::CAFE_DA_MANHA).arrecadacao_global).to eq(BigDecimal("2.50"))
    end

    it "mostra valor e percentual por método, somando a arrecadação global (RN09.10)" do
      pix_item, cartao_item = relatorio.liquidacoes

      expect(pix_item).to have_attributes(nome: "PIX Institucional Instantâneo", valor: BigDecimal("7.00"), percentual: 61)
      expect(cartao_item).to have_attributes(nome: "Cartão de Crédito / Débito", valor: BigDecimal("4.50"), percentual: 39)
      expect(relatorio.soma_liquidacoes).to eq(relatorio.arrecadacao_global)
      expect(relatorio.divergencia_contabil).to eq(0)
    end

    it "calcula ticket médio e transações validadas (RN09.11)" do
      expect(relatorio.ticket_medio).to eq(BigDecimal("3.83"))
      expect(relatorio.transacoes_validadas).to eq(3)
    end

    it "distribui os acessos por refeição" do
      distribuicao = relatorio.distribuicao_por_refeicao.to_h { |item| [ item.nome, [ item.acessos, item.arrecadacao ] ] }

      expect(distribuicao).to eq("Café da Manhã" => [ 1, BigDecimal("2.50") ], "Almoço" => [ 2, BigDecimal("9.00") ],
                                 "Jantar" => [ 0, 0 ])
    end

    it "informa o horário de cada refeição a partir dos serviços cadastrados" do
      horarios = relatorio.distribuicao_por_refeicao.to_h { |item| [ item.nome, item.horario ] }

      expect(horarios).to eq("Café da Manhã" => "06:30 – 09:00", "Almoço" => "11:00 – 14:30", "Jantar" => "17:00 – 20:00")
    end

    it "aplica o filtro de turno a todos os números (RN09.4)" do
      resultado = relatorio(turno: TipoRefeicao::ALMOCO)

      expect(resultado.total_acessos).to eq(2)
      expect(resultado.arrecadacao_global).to eq(BigDecimal("9.00"))
      expect(resultado.soma_liquidacoes).to eq(BigDecimal("9.00"))
      expect(resultado.distribuicao_por_refeicao.map(&:acessos)).to eq([ 0, 2, 0 ])
    end

    it "aplica o filtro de data contábil" do
      resultado = relatorio(data: "2025-10-23")

      expect(resultado.data_nome).to eq("23/10/2025")
      expect(resultado.total_acessos).to eq(1)
      expect(resultado.arrecadacao_global).to eq(BigDecimal("4.50"))
    end

    it "combina data e turno" do
      expect(relatorio(data: "2025-10-23", turno: TipoRefeicao::ALMOCO)).to be_vazio
      expect(relatorio(data: "2025-10-23", turno: TipoRefeicao::JANTAR).total_acessos).to eq(1)
    end

    it "considera só os restaurantes da unidade gestora escolhida" do
      outra = create(:unidade_gestora, nome: "Campus Gama")
      acesso_realizado(restaurante_com_catraca(outra, "RU Gama"), turno: TipoRefeicao::ALMOCO, dia: hoje, recarga: pix)

      expect(relatorio.total_acessos).to eq(3)
      expect(relatorio(unidade_id: outra.id).linhas.map { |linha| [ linha.restaurante.nome, linha.acessos ] })
        .to eq([ [ "RU Gama", 1 ] ])
    end

    it "não conta leituras recusadas, que não geram débito" do
      create(:registro_acesso, configuracao_ponto_acesso: ConfiguracaoPontoAcesso.first, estudante: estudante,
                               estado: "recusado", liberado_em: nil, passagem_em: nil, bloqueado_em: nil,
                               lido_em: agora - 1.hour)

      expect(relatorio.total_acessos).to eq(3)
    end
  end

  describe "catracas online (RN09.5)" do
    it "conta as catracas em operação sobre as cadastradas na unidade" do
      restaurante_com_catraca(unidade, "Restaurante 3", online: false)
      restaurante_com_catraca(create(:unidade_gestora, nome: "Campus Gama"), "RU Gama")

      expect([ relatorio.catracas_online, relatorio.catracas_cadastradas ]).to eq([ 2, 3 ])
    end

    it "deixa de contar a catraca quando o ponto de acesso é encerrado" do
      ConfiguracaoPontoAcesso.where(restaurante: restaurante_um).update_all(finalizada_em: Time.current)

      expect(relatorio.catracas_online).to eq(1)
    end

    it "deixa de contar a catraca quando a sessão do funcionário termina" do
      ConfiguracaoPontoAcesso.find_by!(restaurante: restaurante_um).sessao_autenticacao.encerrar!

      expect(relatorio.catracas_online).to eq(1)
    end

    it "não conta catraca desativada, mesmo com ponto de acesso aberto" do
      restaurante_um.catracas.update_all(ativa: false)

      expect(relatorio.catracas_online).to eq(1)
    end
  end

  describe "sem acessos para os filtros (RN09.14)" do
    it "fica vazio e com todos os totais zerados" do
      resultado = relatorio(data: "2025-01-01")

      expect(resultado).to be_vazio
      expect(resultado.arrecadacao_global).to eq(0)
      expect(resultado.liquidacoes.map(&:valor)).to eq([ 0, 0 ])
      expect(resultado.liquidacoes.map(&:percentual)).to eq([ 0, 0 ])
      expect(resultado.ticket_medio).to eq(0)
      expect(resultado.linhas.size).to eq(2)
    end

    it "deixa sem horário a refeição que não tem serviço cadastrado" do
      expect(relatorio.distribuicao_por_refeicao.map(&:horario)).to eq([ nil, nil, nil ])
    end
  end

  describe "parâmetros inválidos" do
    it "volta aos valores padrão" do
      resultado = relatorio(data: "31/02/2025", turno: "ceia", unidade_id: "999999")

      expect(resultado.data).to eq(hoje)
      expect(resultado.turno).to eq("todos")
      expect(resultado.unidade).to eq(unidade)
    end
  end
end
