require "rails_helper"

RSpec.describe Restaurante, type: :model do
  let(:unidade) { create(:unidade_gestora) }

  def atributos(sobrescritos = {})
    { unidade_gestora: unidade, nome: "RU Gama", quantidade_pisos: 2, capacidade_refeicoes_hora: 400 }.merge(sobrescritos)
  end

  describe ".criar_com_pisos!" do
    it "cria o restaurante e os pisos numerados a partir de 1" do
      restaurante = Restaurante.criar_com_pisos!(atributos)
      expect(restaurante.pisos.ordenados.pluck(:numero)).to eq([ 1, 2 ])
    end

    it "numera os restaurantes por unidade gestora" do
      primeiro = Restaurante.criar_com_pisos!(atributos)
      segundo = Restaurante.criar_com_pisos!(atributos(nome: "RU Planaltina"))
      outra_unidade = Restaurante.criar_com_pisos!(atributos(nome: "RU Ceilândia", unidade_gestora: create(:unidade_gestora)))

      expect([ primeiro.numero, segundo.numero, outra_unidade.numero ]).to eq([ 1, 2, 1 ])
    end

    it "não grava o restaurante se a criação de um piso falhar" do
      allow_any_instance_of(Piso).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Piso.new))

      expect { Restaurante.criar_com_pisos!(atributos) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Restaurante.count).to eq(0)
      expect(Piso.count).to eq(0)
    end
  end

  describe "validações" do
    it "exige nome, com a mensagem do cenário" do
      restaurante = Restaurante.new(atributos(nome: "  "))
      expect(restaurante).not_to be_valid
      expect(restaurante.errors[:nome]).to include("Nome do restaurante é obrigatório")
    end

    it "rejeita nome repetido, mesmo em outra unidade" do
      Restaurante.criar_com_pisos!(atributos)
      repetido = Restaurante.new(atributos(unidade_gestora: create(:unidade_gestora)))
      expect(repetido).not_to be_valid
      expect(repetido.errors[:nome]).to include("Já existe um restaurante com esse nome")
    end

    it "rejeita nome repetido com outra combinação de maiúsculas e minúsculas" do
      Restaurante.criar_com_pisos!(atributos(nome: "RU Gama"))
      repetido = Restaurante.new(atributos(nome: "ru GAMA"))
      expect(repetido).not_to be_valid
      expect(repetido.errors[:nome]).to include("Já existe um restaurante com esse nome")
    end

    it "rejeita número repetido na mesma unidade" do
      Restaurante.criar_com_pisos!(atributos(numero: 7))
      expect(Restaurante.new(atributos(nome: "Outro", numero: 7))).not_to be_valid
    end

    it "exige ao menos 1 piso no cadastro" do
      restaurante = Restaurante.new(atributos(quantidade_pisos: 0))
      expect(restaurante).not_to be_valid
      expect(restaurante.errors[:quantidade_pisos]).to include("O restaurante deve ter ao menos 1 piso")
    end

    it "exige capacidade positiva" do
      [ 0, -10, nil ].each do |capacidade|
        restaurante = Restaurante.new(atributos(capacidade_refeicoes_hora: capacidade))
        expect(restaurante).not_to be_valid
        expect(restaurante.errors[:capacidade_refeicoes_hora]).to include("A capacidade deve ser maior que zero")
      end
    end

    it "permite editar sem informar a quantidade de pisos" do
      restaurante = Restaurante.find(Restaurante.criar_com_pisos!(atributos).id)
      expect(restaurante.update(capacidade_refeicoes_hora: 500)).to be(true)
    end
  end

  describe "#atualizar_com_pisos" do
    let!(:restaurante) { Restaurante.find(Restaurante.criar_com_pisos!(atributos).id) }

    it "informa a quantidade atual de pisos quando nada foi digitado" do
      expect(restaurante.quantidade_pisos).to eq(2)
    end

    it "acrescenta os pisos que faltam, numerados em sequência" do
      expect(restaurante.atualizar_com_pisos(quantidade_pisos: "4")).to be(true)
      expect(restaurante.pisos.order(:numero).pluck(:numero)).to eq([ 1, 2, 3, 4 ])
    end

    it "mantém os pisos quando a quantidade não muda" do
      expect { restaurante.atualizar_com_pisos(quantidade_pisos: "2", capacidade_refeicoes_hora: 900) }
        .not_to change(Piso, :count)
      expect(restaurante.reload.capacidade_refeicoes_hora).to eq(900)
    end

    it "não deixa remover pisos e não grava as outras alterações" do
      expect(restaurante.atualizar_com_pisos(quantidade_pisos: "1", capacidade_refeicoes_hora: 900)).to be(false)
      expect(restaurante.errors[:quantidade_pisos]).to include("Não é possível remover pisos: informe 2 ou mais")
      expect(restaurante.reload.pisos.count).to eq(2)
      expect(restaurante.capacidade_refeicoes_hora).to eq(400)
    end

    it "rejeita quantidade que não é número inteiro" do
      expect(restaurante.atualizar_com_pisos(quantidade_pisos: "abc")).to be(false)
      expect(restaurante.errors[:quantidade_pisos]).to include("O restaurante deve ter ao menos 1 piso")
    end
  end

  describe "remoção" do
    it "remove junto os pisos e os serviços quando não há catracas" do
      restaurante = create(:restaurante)
      create(:servico_refeicao, restaurante: restaurante)

      expect(restaurante.destroy).to be_truthy
      expect(Piso.count).to eq(0)
      expect(ServicoRefeicao.count).to eq(0)
    end

    it "é impedida quando há catracas e preserva os pisos" do
      restaurante = create(:restaurante)
      create(:catraca, piso: restaurante.pisos.first)

      expect(restaurante.destroy).to be(false)
      expect(restaurante.errors.full_messages).to include("Remova as catracas do restaurante antes de excluí-lo")
      expect(restaurante.reload.pisos.count).to eq(1)
    end
  end

  it "ordena pela numeração" do
    unidade_atual = create(:unidade_gestora)
    segundo = create(:restaurante, unidade_gestora: unidade_atual, numero: 2)
    primeiro = create(:restaurante, unidade_gestora: unidade_atual, numero: 1)
    expect(Restaurante.ordenados).to eq([ primeiro, segundo ])
  end
end
