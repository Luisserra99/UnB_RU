require "rails_helper"

RSpec.describe CardapiosHelper, type: :helper do
  describe "#rotulo_categoria" do
    it "usa o rótulo acentuado das categorias previstas" do
      expect(helper.rotulo_categoria("guarnicao")).to eq("Guarnição")
      expect(helper.rotulo_categoria("opcao_extra")).to eq("Opção extra")
    end

    it "humaniza a categoria que não está na lista de rótulos" do
      expect(helper.rotulo_categoria("prato_principal")).to eq("Prato principal")
    end
  end
end
