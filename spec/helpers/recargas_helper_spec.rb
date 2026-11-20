require "rails_helper"

RSpec.describe RecargasHelper, type: :helper do
  describe "#moeda" do
    it "formata o valor em reais" do
      expect(helper.moeda(BigDecimal("22.5"))).to eq("R$ 22,50")
    end

    it "mostra valor ausente como zero" do
      expect(helper.moeda(nil)).to eq("R$ 0,00")
    end
  end

  describe "#qr_code_pix_svg" do
    let(:svg) { helper.qr_code_pix_svg("00020126codigo") }

    it "gera um SVG seguro, sempre igual para o mesmo conteúdo" do
      expect(svg).to be_html_safe
      expect(svg).to start_with('<svg id="qr-code-pix"')
      expect(svg).to include('viewBox="0 0 37 37"')
      expect(helper.qr_code_pix_svg("00020126codigo")).to eq(svg)
    end

    it "desenha os três padrões de localização nos cantos" do
      # Módulo (0, 0) do QR, deslocado pela margem de 4: canto de cada padrão escuro.
      [ [ 4, 4 ], [ 26, 4 ], [ 4, 26 ] ].each do |x, y|
        expect(svg).to include(%(<rect x="#{x}" y="#{y}" width="1" height="1"/>))
      end
    end

    it "gera desenhos diferentes para conteúdos diferentes" do
      expect(helper.qr_code_pix_svg("outro codigo")).not_to eq(svg)
    end

    it "não desenha nada na borda branca em volta dos padrões" do
      # Linha 7 do QR (a borda abaixo do padrão do canto superior esquerdo), colunas 0 a 7.
      (0..7).each { |coluna| expect(svg).not_to include(%(<rect x="#{coluna + 4}" y="11" width="1" height="1"/>)) }
    end
  end

  describe "#rotulo_status_recarga" do
    let(:estudante) { create(:estudante) }
    let(:recarga) { create(:recarga, estudante: estudante) }

    it "mostra Confirmada para recarga confirmada" do
      confirmada = create(:recarga, :confirmada, estudante: estudante)
      expect(helper.rotulo_status_recarga(confirmada, confirmada.pagamento_atual)).to eq("Confirmada")
    end

    it "mostra Expirada para recarga ou pagamento expirado" do
      expect(helper.rotulo_status_recarga(recarga, build(:pagamento, recarga: recarga, status: "expirado")))
        .to eq("Expirada")
      recarga.status = "expirada"
      expect(helper.rotulo_status_recarga(recarga, nil)).to eq("Expirada")
    end

    it "mostra Pagamento recusado depois de uma recusa" do
      expect(helper.rotulo_status_recarga(recarga, build(:pagamento, recarga: recarga, status: "recusado")))
        .to eq("Pagamento recusado")
    end

    it "mostra Aguardando pagamento para recarga pendente, com ou sem pagamento" do
      expect(helper.rotulo_status_recarga(recarga, build(:pagamento, recarga: recarga))).to eq("Aguardando pagamento")
      expect(helper.rotulo_status_recarga(recarga, nil)).to eq("Aguardando pagamento")
    end
  end
end
