require "digest"

# Formatação das telas de recarga (F02): valores em reais, QR Code ilustrativo do PIX e status.
module RecargasHelper
  # Lado do QR Code, em módulos (versão 3 do padrão).
  QR_MODULOS = 29
  # Borda branca em volta do QR Code, em módulos.
  QR_MARGEM = 4
  # Lado de um padrão de localização (os três quadrados dos cantos), em módulos.
  QR_LOCALIZADOR = 7
  # Canto superior esquerdo [linha, coluna] de cada padrão de localização.
  QR_LOCALIZADORES = [ [ 0, 0 ], [ 0, QR_MODULOS - QR_LOCALIZADOR ], [ QR_MODULOS - QR_LOCALIZADOR, 0 ] ].freeze

  # Formata um valor em reais.
  #
  # Argumentos:: +valor+ (Numeric ou nil).
  # Retorno:: String, ex.: "R$ 22,50"; nil é exibido como "R$ 0,00".
  # Efeitos colaterais:: nenhum.
  def moeda(valor)
    number_to_currency(valor || 0)
  end

  # Desenha um QR Code ilustrativo em SVG, sem dependências: tem os três padrões de localização e os
  # demais módulos derivados do SHA-256 do conteúdo. Não é decodificável por leitores reais; o
  # pagamento simulado usa o código Copia e Cola. Para um QR real, use a gem rqrcode.
  #
  # Argumentos:: +conteudo+ (String): código Copia e Cola.
  # Retorno:: ActiveSupport::SafeBuffer com o SVG; o mesmo conteúdo sempre gera o mesmo desenho.
  # Efeitos colaterais:: nenhum.
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

  # Traduz a situação da recarga e do seu pagamento atual para o texto da tela.
  #
  # Argumentos:: +recarga+ (Recarga). +pagamento+ (Pagamento ou nil): pagamento atual.
  # Retorno:: "Confirmada", "Expirada", "Pagamento recusado" ou "Aguardando pagamento".
  # Efeitos colaterais:: nenhum.
  def rotulo_status_recarga(recarga, pagamento)
    return "Confirmada" if recarga.confirmada?
    return "Expirada" if recarga.expirada? || pagamento&.expirado?
    return "Pagamento recusado" if pagamento&.recusado?

    "Aguardando pagamento"
  end

  private

  # Lista os módulos escuros do QR Code.
  #
  # Argumentos:: +conteudo+ (String): código Copia e Cola.
  # Retorno:: Array de pares [linha, coluna] (0 a QR_MODULOS - 1).
  # Efeitos colaterais:: nenhum.
  def qr_modulos(conteudo)
    bits = qr_bits(conteudo, QR_MODULOS * QR_MODULOS)
    (0...QR_MODULOS).to_a.product((0...QR_MODULOS).to_a).select do |linha, coluna|
      padrao = qr_padrao_localizacao(linha, coluna)
      padrao.nil? ? bits[(linha * QR_MODULOS) + coluna] : padrao
    end
  end

  # Gera bits pseudoaleatórios e determinísticos a partir do conteúdo (SHA-256 encadeado).
  #
  # Argumentos:: +conteudo+ (String). +quantidade+ (Integer): mínimo de bits desejado.
  # Retorno:: Array de true/false com pelo menos +quantidade+ elementos.
  # Efeitos colaterais:: nenhum.
  def qr_bits(conteudo, quantidade)
    bits = []
    bloco = Digest::SHA256.digest(conteudo.to_s)
    while bits.size < quantidade
      bits.concat(bloco.unpack1("B*").chars.map { |bit| bit == "1" })
      bloco = Digest::SHA256.digest(bloco)
    end
    bits
  end

  # Diz se um módulo pertence a um padrão de localização (incluindo a borda branca em volta).
  #
  # Argumentos:: +linha+ e +coluna+ (Integer): posição do módulo no QR Code.
  # Retorno:: true (escuro) ou false (claro) dentro de um padrão de localização; nil fora deles.
  # Efeitos colaterais:: nenhum.
  def qr_padrao_localizacao(linha, coluna)
    QR_LOCALIZADORES.each do |topo, esquerda|
      l = linha - topo
      c = coluna - esquerda
      return qr_modulo_do_localizador(l, c) if l.between?(-1, QR_LOCALIZADOR) && c.between?(-1, QR_LOCALIZADOR)
    end
    nil
  end

  # Desenha um padrão de localização: borda branca, anel escuro, anel claro e miolo escuro 3×3.
  #
  # Argumentos:: +l+ e +c+ (Integer): posição relativa ao canto do padrão, de -1 a QR_LOCALIZADOR.
  # Retorno:: true para módulo escuro; false para módulo claro.
  # Efeitos colaterais:: nenhum.
  def qr_modulo_do_localizador(l, c)
    posicoes = [ l, c ]
    return false if posicoes.any? { |v| [ -1, QR_LOCALIZADOR ].include?(v) }

    posicoes.any? { |v| [ 0, QR_LOCALIZADOR - 1 ].include?(v) } || (l.between?(2, 4) && c.between?(2, 4))
  end
end
