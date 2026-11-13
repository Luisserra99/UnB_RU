require "rails_helper"

RSpec.describe ExtratosHelper, type: :helper do
  let(:hoje) { Date.new(2024, 5, 14) }

  describe "#momento_do_lancamento" do
    it "usa Hoje e Ontem para os dois dias mais recentes" do
      expect(helper.momento_do_lancamento(Time.zone.local(2024, 5, 14, 12, 20), hoje: hoje)).to eq("Hoje, 12:20")
      expect(helper.momento_do_lancamento(Time.zone.local(2024, 5, 13, 19, 10), hoje: hoje)).to eq("Ontem, 19:10")
    end

    it "usa a data completa para os dias anteriores" do
      expect(helper.momento_do_lancamento(Time.zone.local(2024, 5, 10, 14, 0), hoje: hoje)).to eq("10/05/2024, 14:00")
    end
  end

  describe "#resumo_das_refeicoes" do
    it "junta as quantidades por tipo, com plural" do
      expect(helper.resumo_das_refeicoes("Café da Manhã" => 1, "Almoço" => 2, "Jantar" => 4))
        .to eq("1 café da manhã · 2 almoços · 4 jantares")
    end

    it "avisa quando não há refeições" do
      expect(helper.resumo_das_refeicoes({})).to eq("Nenhuma refeição no período")
    end
  end

  describe "#classe_do_evento" do
    it "escolhe a etiqueta pelo tipo do lançamento" do
      recarga = Extratos::Relatorio::Lancamento.new(tipo: "recarga")
      sem_tipo = Extratos::Relatorio::Lancamento.new(tipo: nil)

      expect(helper.classe_do_evento(recarga)).to eq("evento-recarga")
      expect(helper.classe_do_evento(sem_tipo)).to eq("evento-refeicao")
    end
  end
end
