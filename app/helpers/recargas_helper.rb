require "digest"

module RecargasHelper
  QR_MODULOS = 29
  QR_MARGEM = 4

  def moeda(valor)
    number_to_currency(valor || 0)
  end

  # QR Code ilustrativo em SVG, sem dependências: tem os três padrões de localização e os
  # demais módulos derivados do SHA-256 do conteúdo. Não é decodificável por leitores reais;
  # o pagamento simulado usa o código Copia e Cola. Para um QR real, use a gem rqrcode.
  def qr_code_pix_svg(conteudo)
    lado = QR_MODULOS + (2 * QR_MARGEM)
    retangulos = qr_modulos(conteudo).map do |(linha, coluna)|
      %(<rect x="#{coluna + QR_MARGEM}" y="#{linha + QR_MARGEM}" width="1" height="1"/>)
    end
    svg = %(<svg id="qr-code-pix" class="qr-code" role="img" aria-label="QR Code PIX" ) +
          %(xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{lado} #{lado}" shape-rendering="crispEdges">) +
          %(<rect width="#{lado}" height="#{lado}" fill="#fff"/><g fill="#1b1b1c">#{retangulos.join}</g></svg>)
    svg.html_safe # conteúdo gerado aqui: só números e atributos fixos
  end

  def rotulo_status_recarga(recarga, pagamento)
    return "Confirmada" if recarga.confirmada?
    return "Expirada" if recarga.expirada? || pagamento&.expirado?
    return "Pagamento recusado" if pagamento&.recusado?

    "Aguardando pagamento"
  end

  private

  def qr_modulos(conteudo)
    bits = qr_bits(conteudo, QR_MODULOS * QR_MODULOS)
    (0...QR_MODULOS).to_a.product((0...QR_MODULOS).to_a).select do |linha, coluna|
      padrao = qr_padrao_localizacao(linha, coluna)
      padrao.nil? ? bits[(linha * QR_MODULOS) + coluna] : padrao
    end
  end

  def qr_bits(conteudo, quantidade)
    bits = []
    bloco = Digest::SHA256.digest(conteudo.to_s)
    while bits.size < quantidade
      bits.concat(bloco.unpack1("B*").chars.map { |bit| bit == "1" })
      bloco = Digest::SHA256.digest(bloco)
    end
    bits
  end

  # true/false dentro de um padrão de localização (com a borda branca), nil fora deles.
  def qr_padrao_localizacao(linha, coluna)
    [ [ 0, 0 ], [ 0, QR_MODULOS - 7 ], [ QR_MODULOS - 7, 0 ] ].each do |topo, esquerda|
      l = linha - topo
      c = coluna - esquerda
      next unless l.between?(-1, 7) && c.between?(-1, 7)
      return false if [ l, c ].any? { |v| v == -1 || v == 7 }

      borda = [ l, c ].any? { |v| [ 0, 6 ].include?(v) }
      miolo = l.between?(2, 4) && c.between?(2, 4)
      return borda || miolo
    end
    nil
  end
end
