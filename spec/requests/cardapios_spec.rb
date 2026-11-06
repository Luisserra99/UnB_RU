require "rails_helper"

RSpec.describe "Cardápio (F10)", type: :request do
  let(:restaurante) { create(:restaurante, nome: "RU Central") }
  let(:almoco) { create(:tipo_refeicao, codigo: TipoRefeicao::ALMOCO, nome: "Almoço") }
  let(:jantar) { create(:tipo_refeicao, codigo: TipoRefeicao::JANTAR, nome: "Jantar") }
  # 04/11/2026 é uma quarta-feira.
  let(:quarta) { Date.new(2026, 11, 4) }

  def criar_cardapio(restaurante:, tipo:, inicio:, fim:, data: quarta, pratos: {})
    servico = create(:servico_refeicao, restaurante: restaurante, tipo_refeicao: tipo, dia_semana: data.wday, inicio: inicio, fim: fim)
    cardapio = create(:cardapio, servico_refeicao: servico, data_referencia: data)
    pratos.each do |dieta, descricao|
      opcao = create(:opcao_cardapio, cardapio: cardapio, dieta: dieta)
      create(:item_cardapio, opcao_cardapio: opcao, categoria: "prato_principal", descricao: descricao, ordem: 1) if descricao
    end
    cardapio
  end

  it "é público e informa a ausência de cardápio quando não há restaurantes" do
    get cardapio_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Não há cardápio disponível no momento.")
  end

  context "com um almoço cadastrado" do
    before do
      criar_cardapio(restaurante: restaurante, tipo: almoco, inicio: "11:00", fim: "14:30",
                     pratos: { OpcaoCardapio::PADRAO => "Frango", OpcaoCardapio::OVOLACTOVEGETARIANA => "Quiche" })
    end

    it "mostra a refeição em andamento e a dieta ausente como indisponível" do
      travel_to Time.zone.local(2026, 11, 4, 12, 0) do
        get cardapio_path
        expect(response.body).to include("Frango", "Quiche", "Vegetariano estrito", "Esta opção não está disponível.")
      end
    end

    it "fora do horário informa que não há cardápio" do
      travel_to Time.zone.local(2026, 11, 4, 16, 0) do
        get cardapio_path
        expect(response.body).to include("Não há cardápio disponível no momento.")
        expect(response.body).not_to include("Frango")
      end
    end

    it "em horário de refeição sem cardápio publicado informa que não há cardápio" do
      travel_to Time.zone.local(2026, 11, 11, 12, 0) do
        get cardapio_path
        expect(response.body).to include("Não há cardápio disponível no momento.")
      end
    end

    it "consulta por data e refeição fora do horário" do
      travel_to Time.zone.local(2026, 11, 1, 8, 0) do
        get cardapio_path, params: { data: quarta.iso8601, refeicao: TipoRefeicao::ALMOCO }
        expect(response.body).to include("Frango")
      end
    end

    it "informa quando a consulta por data não encontra cardápio" do
      get cardapio_path, params: { data: "2026-11-11", refeicao: TipoRefeicao::ALMOCO }
      expect(response.body).to include("Não há cardápio cadastrado para esta data e refeição.")
    end

    it "pede a refeição ao consultar outra data sem informá-la" do
      travel_to Time.zone.local(2026, 11, 1, 12, 0) do
        get cardapio_path, params: { data: quarta.iso8601 }
        expect(response.body).to include("Selecione uma refeição")
        expect(response.body).not_to include("Frango")
      end
    end

    it "trata data inválida como hoje" do
      travel_to Time.zone.local(2026, 11, 4, 12, 0) do
        get cardapio_path, params: { data: "nao-e-data" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Frango")
      end
    end
  end

  it "trata opção cadastrada sem itens como indisponível" do
    criar_cardapio(restaurante: restaurante, tipo: almoco, inicio: "11:00", fim: "14:30",
                   pratos: { OpcaoCardapio::PADRAO => "Frango", OpcaoCardapio::VEGETARIANA_ESTRITA => nil })
    travel_to Time.zone.local(2026, 11, 4, 12, 0) do
      get cardapio_path
      expect(response.body).to include("Frango", "Esta opção não está disponível.")
    end
  end

  it "identifica a refeição certa de cada horário" do
    criar_cardapio(restaurante: restaurante, tipo: almoco, inicio: "11:00", fim: "14:30", pratos: { OpcaoCardapio::PADRAO => "Frango" })
    criar_cardapio(restaurante: restaurante, tipo: jantar, inicio: "17:00", fim: "19:30", pratos: { OpcaoCardapio::PADRAO => "Sopa" })
    travel_to Time.zone.local(2026, 11, 4, 18, 0) do
      get cardapio_path
      expect(response.body).to include("Sopa")
      expect(response.body).not_to include("Frango")
    end
  end

  describe "restaurante consultado" do
    let!(:primeiro) { create(:restaurante, nome: "RU Primeiro", unidade_gestora: unidade, numero: 1) }
    let!(:segundo) { create(:restaurante, nome: "RU Segundo", unidade_gestora: unidade, numero: 2) }
    let(:unidade) { create(:unidade_gestora) }

    before do
      criar_cardapio(restaurante: primeiro, tipo: almoco, inicio: "11:00", fim: "14:30", pratos: { OpcaoCardapio::PADRAO => "Frango" })
      criar_cardapio(restaurante: segundo, tipo: almoco, inicio: "11:00", fim: "14:30", pratos: { OpcaoCardapio::PADRAO => "Peixe" })
    end

    around { |exemplo| travel_to(Time.zone.local(2026, 11, 4, 12, 0)) { exemplo.run } }

    it "abre no restaurante ativo de menor número" do
      get cardapio_path
      expect(response.body).to include("Frango")
      expect(response.body).not_to include("Peixe")
    end

    it "respeita o restaurante escolhido" do
      get cardapio_path, params: { restaurante_id: segundo.id }
      expect(response.body).to include("Peixe")
      expect(response.body).not_to include("Frango")
    end

    it "ignora restaurante inativo" do
      primeiro.update!(ativo: false)
      get cardapio_path
      expect(response.body).to include("Peixe")
    end
  end
end
