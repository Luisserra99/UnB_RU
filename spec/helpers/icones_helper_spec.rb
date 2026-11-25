require "rails_helper"

RSpec.describe IconesHelper, type: :helper do
  describe "#icone" do
    it "desenha o SVG decorativo com o tamanho e a classe padrão" do
      svg = Capybara.string(helper.icone(:usuario)).find("svg", visible: :all)

      expect(svg[:class]).to eq("icone")
      expect(svg[:width]).to eq("20")
      expect(svg[:height]).to eq("20")
      expect(svg[:"aria-hidden"]).to eq("true")
      expect(svg).to have_css("circle", visible: :all)
    end

    it "aceita tamanho e classe personalizados" do
      svg = Capybara.string(helper.icone(:cadeado, tamanho: 18, classe: "icone-campo")).find("svg", visible: :all)
      expect(svg[:class]).to eq("icone-campo")
      expect(svg[:width]).to eq("18")
    end

    it "desenha todos os ícones cadastrados" do
      IconesHelper::ICONES.each_key do |nome|
        expect(helper.icone(nome)).to start_with("<svg")
      end
    end

    it "lança KeyError para ícone desconhecido" do
      expect { helper.icone(:nao_existe) }.to raise_error(KeyError)
    end
  end
end
