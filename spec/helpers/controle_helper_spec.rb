require "rails_helper"

RSpec.describe ControleHelper, type: :helper do
  describe "#item_nav_controle" do
    def item(rota = :controle_historico_path, rotulo: "Histórico Local", na_pagina: "/controle")
      allow(helper.request).to receive(:path).and_return(na_pagina)
      Capybara.string(helper.item_nav_controle(rotulo, rota))
    end

    it "vira link para a rota quando ela existe" do
      html = item
      expect(html).to have_link("Histórico Local", href: "/controle/historico", class: "nav-item")
      expect(html).not_to have_css("a.ativo")
    end

    it "marca como ativo o item da página atual" do
      expect(item(na_pagina: "/controle/historico")).to have_css('a.nav-item.ativo[aria-current="page"]')
    end

    it "marca como ativo o item de uma subpágina da seção" do
      expect(item(na_pagina: "/controle/historico/qualquer")).to have_css("a.ativo")
    end

    it "só marca a raiz do controle com o caminho exato" do
      expect(item(:controle_root_path, rotulo: "Painel", na_pagina: "/controle")).to have_css("a.ativo")
      expect(item(:controle_root_path, rotulo: "Painel", na_pagina: "/controle/historico")).not_to have_css("a.ativo")
    end

    it "não marca como ativo um caminho que só começa igual" do
      expect(item(na_pagina: "/controle/historicos")).not_to have_css("a.ativo")
    end

    it "aparece desabilitado quando a rota ainda não existe" do
      html = item(:rota_que_nao_existe_path, rotulo: "Em breve")
      expect(html).to have_css('span.nav-item.desabilitado[aria-disabled="true"][title="Disponível em breve"]', text: "Em breve")
      expect(html).not_to have_link("Em breve")
    end
  end

  describe "#rotulo_papel" do
    it "mostra 'Administrador' para administrador" do
      expect(helper.rotulo_papel(create(:administrador))).to eq("Administrador")
    end

    it "mostra 'Funcionário' para quem não é administrador" do
      expect(helper.rotulo_papel(create(:funcionario))).to eq("Funcionário")
    end
  end
end
