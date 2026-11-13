require "rails_helper"

RSpec.describe Cardapios::ImportadorJson do
  let!(:restaurante) { create(:restaurante) }
  # 04/11/2026 é uma quarta-feira; a semana começa na segunda, 02/11/2026.
  let(:semana) { Date.new(2026, 11, 4) }

  before do
    horarios = {
      TipoRefeicao::CAFE_DA_MANHA => %w[07:00 09:00],
      TipoRefeicao::ALMOCO => %w[11:00 14:30],
      TipoRefeicao::JANTAR => %w[17:00 19:30]
    }
    horarios.each do |codigo, (inicio, fim)|
      tipo = create(:tipo_refeicao, codigo: codigo, nome: codigo)
      ServicoRefeicao::DIAS_SEMANA.each do |dia|
        create(:servico_refeicao, restaurante: restaurante, tipo_refeicao: tipo, dia_semana: dia, inicio: inicio, fim: fim)
      end
    end
  end

  def importar_json(dados)
    Tempfile.create([ "cardapio", ".json" ]) do |arquivo|
      arquivo.write(dados.to_json)
      arquivo.close
      Cardapios::ImportadorJson.new(semana: semana, caminho: arquivo.path).importar
    end
  end

  def cardapio_de(data, codigo)
    Cardapio.joins(servico_refeicao: :tipo_refeicao)
            .find_by!(data_referencia: data, tipo_refeicoes: { codigo: codigo })
  end

  context "com o cardapio.json do projeto" do
    before { @resultado = Cardapios::ImportadorJson.new(semana: semana).importar }

    it "gera 7 dias com 3 refeições cada, datados na semana escolhida" do
      expect(@resultado.cardapios).to eq(21)
      expect(@resultado.servicos_ausentes).to eq(0)
      expect(Cardapio.pluck(:data_referencia).uniq).to match_array(Date.new(2026, 11, 2)..Date.new(2026, 11, 8))
    end

    it "faz o dia do JSON cair na data certa" do
      opcao = cardapio_de(Date.new(2026, 11, 2), TipoRefeicao::ALMOCO).opcao_de(OpcaoCardapio::PADRAO)
      expect(opcao.itens.map(&:descricao)).to include("Frango assado com manjericão")
    end

    it "não transforma null em item" do
      segunda = cardapio_de(Date.new(2026, 11, 2), TipoRefeicao::CAFE_DA_MANHA).opcao_de(OpcaoCardapio::PADRAO)
      terca = cardapio_de(Date.new(2026, 11, 3), TipoRefeicao::CAFE_DA_MANHA).opcao_de(OpcaoCardapio::PADRAO)
      expect(segunda.itens.map(&:categoria)).not_to include("opcao_extra")
      expect(terca.itens.map(&:categoria)).to include("opcao_extra")
    end

    it "é idempotente" do
      contagens = -> { [ Cardapio.count, OpcaoCardapio.count, ItemCardapio.count ] }
      antes = contagens.call
      Cardapios::ImportadorJson.new(semana: semana).importar
      expect(contagens.call).to eq(antes)
    end
  end

  context "com um JSON controlado" do
    let(:campos) do
      {
        salada_1: "Alface",
        molho_para_salada: %w[Ácido Limão],
        prato_principal_padrao: "Frango",
        prato_principal_ovolactovegetariano: "Quiche",
        prato_principal_vegetariano_estrito: "Lentilha",
        sobremesa: nil,
        acompanhamentos: []
      }
    end

    it "separa os pratos por dieta e copia os itens comuns, com ordem e categoria" do
      importar_json("quarta-feira" => { almoco: campos })
      opcao = cardapio_de(semana, TipoRefeicao::ALMOCO).opcao_de(OpcaoCardapio::OVOLACTOVEGETARIANA)

      expect(opcao.itens.map { |item| [ item.ordem, item.categoria, item.descricao ] }).to eq([
        [ 1, "salada_1", "Alface" ],
        [ 2, "molho_para_salada", "Ácido" ],
        [ 3, "molho_para_salada", "Limão" ],
        [ 4, "prato_principal", "Quiche" ]
      ])
    end

    it "não cria a opção da dieta sem item próprio, mesmo havendo itens comuns" do
      importar_json("quarta-feira" => { almoco: campos.merge(prato_principal_vegetariano_estrito: nil) })
      cardapio = cardapio_de(semana, TipoRefeicao::ALMOCO)

      expect(cardapio.opcao_de(OpcaoCardapio::VEGETARIANA_ESTRITA)).to be_nil
      expect(cardapio.opcao_de(OpcaoCardapio::PADRAO)).to be_present
    end

    it "conta os serviços que não existem, sem criar cardápio" do
      ServicoRefeicao.where(dia_semana: 3).destroy_all
      resultado = importar_json("quarta-feira" => { almoco: campos })

      expect(resultado.servicos_ausentes).to eq(1)
      expect(Cardapio.count).to eq(0)
    end

    it "rejeita um dia desconhecido sem gravar nada" do
      expect { importar_json("quarta-feira" => { almoco: campos }, "feriado" => { almoco: campos }) }
        .to raise_error(ArgumentError, /feriado/)
      expect(Cardapio.count).to eq(0)
    end

    it "importa para todos os restaurantes ativos e ignora os inativos" do
      outro = create(:restaurante)
      inativo = create(:restaurante, ativo: false)
      almoco = TipoRefeicao.find_by!(codigo: TipoRefeicao::ALMOCO)
      [ outro, inativo ].each { |r| create(:servico_refeicao, restaurante: r, tipo_refeicao: almoco, dia_semana: 3) }

      importar_json("quarta-feira" => { almoco: campos })

      expect(Cardapio.joins(:servico_refeicao).distinct.pluck("servico_refeicoes.restaurante_id"))
        .to contain_exactly(restaurante.id, outro.id)
    end
  end
end
