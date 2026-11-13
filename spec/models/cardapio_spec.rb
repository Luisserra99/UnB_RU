require "rails_helper"

RSpec.describe TipoRefeicao, type: :model do
  it "aceita só os códigos previstos, sem repetição" do
    create(:tipo_refeicao, codigo: TipoRefeicao::ALMOCO)
    expect(TipoRefeicao.new(codigo: TipoRefeicao::ALMOCO, nome: "x")).not_to be_valid
    expect(TipoRefeicao.new(codigo: "lanche", nome: "Lanche")).not_to be_valid
    expect(TipoRefeicao.new(codigo: TipoRefeicao::JANTAR, nome: "")).not_to be_valid
  end

  it "ordena na sequência do dia" do
    [ TipoRefeicao::JANTAR, TipoRefeicao::CAFE_DA_MANHA, TipoRefeicao::ALMOCO ].each { |codigo| create(:tipo_refeicao, codigo: codigo) }
    expect(TipoRefeicao.ordenados.pluck(:codigo)).to eq(TipoRefeicao::CODIGOS)
  end
end

RSpec.describe ServicoRefeicao, type: :model do
  let(:restaurante) { create(:restaurante) }
  let(:almoco) { create(:tipo_refeicao, codigo: TipoRefeicao::ALMOCO) }
  let(:jantar) { create(:tipo_refeicao, codigo: TipoRefeicao::JANTAR, nome: "Jantar") }

  def servico(atributos = {})
    build(:servico_refeicao, { restaurante: restaurante, tipo_refeicao: almoco }.merge(atributos))
  end

  it "exige dia da semana entre 0 e 6" do
    expect(servico(dia_semana: 0)).to be_valid
    expect(servico(dia_semana: 6)).to be_valid
    expect(servico(dia_semana: 7)).not_to be_valid
    expect(servico(dia_semana: -1)).not_to be_valid
  end

  it "exige início anterior ao fim" do
    expect(servico(inicio: "14:00", fim: "11:00")).not_to be_valid
    expect(servico(inicio: "11:00", fim: "11:00")).not_to be_valid
  end

  it "é único por restaurante, tipo e dia" do
    servico.save!
    expect(servico).not_to be_valid
    expect(servico(dia_semana: 4)).to be_valid
  end

  it "não aceita horário sobreposto no mesmo restaurante e dia" do
    servico(inicio: "11:00", fim: "14:30").save!
    expect(servico(tipo_refeicao: jantar, inicio: "14:00", fim: "19:00")).not_to be_valid
  end

  it "aceita horário encostado, em outro dia ou em outro restaurante" do
    servico(inicio: "11:00", fim: "14:30").save!
    expect(servico(tipo_refeicao: jantar, inicio: "14:30", fim: "19:00")).to be_valid
    expect(servico(tipo_refeicao: jantar, dia_semana: 4, inicio: "14:00", fim: "19:00")).to be_valid
    expect(servico(tipo_refeicao: jantar, restaurante: create(:restaurante), inicio: "14:00", fim: "19:00")).to be_valid
  end

  describe ".em_andamento" do
    let!(:em_quarta) { create(:servico_refeicao, restaurante: restaurante, tipo_refeicao: almoco, dia_semana: 3) }

    it "usa início inclusivo e fim exclusivo, no fuso da aplicação" do
      expect(restaurante.servicos_refeicao.em_andamento(Time.zone.local(2026, 11, 4, 11, 0))).to eq(em_quarta)
      expect(restaurante.servicos_refeicao.em_andamento(Time.zone.local(2026, 11, 4, 14, 29, 59))).to eq(em_quarta)
      expect(restaurante.servicos_refeicao.em_andamento(Time.zone.local(2026, 11, 4, 14, 30))).to be_nil
      expect(restaurante.servicos_refeicao.em_andamento(Time.zone.local(2026, 11, 4, 10, 59))).to be_nil
    end

    it "ignora outros dias e serviços inativos" do
      expect(restaurante.servicos_refeicao.em_andamento(Time.zone.local(2026, 11, 5, 12, 0))).to be_nil
      em_quarta.update!(ativo: false)
      expect(restaurante.servicos_refeicao.em_andamento(Time.zone.local(2026, 11, 4, 12, 0))).to be_nil
    end
  end
end

RSpec.describe Cardapio, type: :model do
  let(:servico) { create(:servico_refeicao, dia_semana: 3) }

  it "exige data no dia da semana do serviço" do
    expect(Cardapio.new(servico_refeicao: servico, data_referencia: Date.new(2026, 11, 4))).to be_valid
    expect(Cardapio.new(servico_refeicao: servico, data_referencia: Date.new(2026, 11, 5))).not_to be_valid
  end

  it "é único por serviço e data" do
    Cardapio.create!(servico_refeicao: servico, data_referencia: Date.new(2026, 11, 4))
    expect(Cardapio.new(servico_refeicao: servico, data_referencia: Date.new(2026, 11, 4))).not_to be_valid
  end
end

RSpec.describe OpcaoCardapio, type: :model do
  let(:cardapio) { create(:cardapio) }

  it "aceita só as dietas previstas" do
    expect(OpcaoCardapio.new(cardapio: cardapio, dieta: OpcaoCardapio::VEGETARIANA_ESTRITA)).to be_valid
    expect(OpcaoCardapio.new(cardapio: cardapio, dieta: "vegana")).not_to be_valid
  end

  it "é única por cardápio e dieta" do
    OpcaoCardapio.create!(cardapio: cardapio, dieta: OpcaoCardapio::PADRAO)
    expect(OpcaoCardapio.new(cardapio: cardapio, dieta: OpcaoCardapio::PADRAO)).not_to be_valid
  end
end

RSpec.describe ItemCardapio, type: :model do
  let(:opcao) { create(:opcao_cardapio) }

  it "exige descrição não vazia e categoria" do
    expect(ItemCardapio.new(opcao_cardapio: opcao, categoria: "salada", descricao: "  ", ordem: 1)).not_to be_valid
    expect(ItemCardapio.new(opcao_cardapio: opcao, categoria: "", descricao: "Alface", ordem: 1)).not_to be_valid
  end

  it "exige ordem positiva e única na opção" do
    ItemCardapio.create!(opcao_cardapio: opcao, categoria: "salada", descricao: "Alface", ordem: 1)
    expect(ItemCardapio.new(opcao_cardapio: opcao, categoria: "salada", descricao: "Tomate", ordem: 1)).not_to be_valid
    expect(ItemCardapio.new(opcao_cardapio: opcao, categoria: "salada", descricao: "Tomate", ordem: 0)).not_to be_valid
  end

  it "é listado pela ordem" do
    segundo = ItemCardapio.create!(opcao_cardapio: opcao, categoria: "salada", descricao: "Tomate", ordem: 2)
    primeiro = ItemCardapio.create!(opcao_cardapio: opcao, categoria: "salada", descricao: "Alface", ordem: 1)
    expect(opcao.itens.to_a).to eq([ primeiro, segundo ])
  end
end
