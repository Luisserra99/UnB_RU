# Ícones SVG inline (traço), no estilo das telas do Figma.
# Uso: <%= icone(:usuario) %>  ou  <%= icone(:cadeado, tamanho: 18, classe: "icone-campo") %>
module IconesHelper
  ICONES = {
    usuario: '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.6-6.5 8-6.5s8 2.5 8 6.5"/>',
    cadeado: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/><path d="M12 15v2"/>',
    olho: '<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
    entrar: '<path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><path d="M10 17l5-5-5-5"/><path d="M15 12H3"/>',
    cracha: '<rect x="3" y="6" width="18" height="15" rx="2"/><path d="M9 6V3h6v3"/><circle cx="9" cy="13" r="2"/><path d="M6 18c.6-1.3 1.7-2 3-2s2.4.7 3 2"/><path d="M14 12h4"/><path d="M14 15h3"/>',
    email: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>',
    qr: '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3h-3z"/><path d="M20 14v.01"/><path d="M14 20h.01"/><path d="M17 20h4v-3"/>',
    ajustes: '<path d="M4 6h10"/><path d="M18 6h2"/><circle cx="16" cy="6" r="2"/><path d="M4 12h4"/><path d="M12 12h8"/><circle cx="10" cy="12" r="2"/><path d="M4 18h12"/><path d="M20 18h0"/><circle cx="18" cy="18" r="2"/>',
    historico: '<path d="M3 12a9 9 0 1 0 3-6.7"/><path d="M3 4v5h5"/><path d="M12 7v5l3 2"/>',
    passagem: '<circle cx="13" cy="4" r="2"/><path d="M8 21l3-7 3 3v4"/><path d="M7 12l3-4 4 2 3 2"/><path d="M10 8l1 6"/>',
    dinheiro: '<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/><path d="M6 10v4"/><path d="M18 10v4"/>',
    atualizar: '<path d="M21 12a9 9 0 1 1-2.6-6.4"/><path d="M21 4v5h-5"/>',
    voltar: '<path d="M19 12H5"/><path d="M11 18l-6-6 6-6"/>',
    sair: '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/>',
    confirmar: '<circle cx="12" cy="12" r="9"/><path d="M8 12l3 3 5-6"/>',
    info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5"/><path d="M12 8h.01"/>',
    alerta: '<circle cx="12" cy="12" r="9"/><path d="M12 7v6"/><path d="M12 16h.01"/>',
    talheres: '<path d="M7 3v8"/><path d="M4 3v5a3 3 0 0 0 6 0V3"/><path d="M7 11v10"/><path d="M17 21V3c-2.2 1.4-3 4-3 7v3h3"/>',
    # F09/F11/F12 (Tarsila)
    imprimir: '<path d="M7 9V3h10v6"/><rect x="3" y="9" width="18" height="9" rx="2"/><rect x="7" y="14" width="10" height="7"/>',
    documento: '<path d="M6 3h8l4 4v14H6z"/><path d="M14 3v4h4"/><path d="M9 13h6"/><path d="M9 17h6"/>',
    filtro: '<path d="M3 5h18l-7 8v6l-4-2v-4z"/>',
    carteira: '<rect x="3" y="6" width="18" height="13" rx="2"/><path d="M3 10h18"/><path d="M16 14.5h2"/>'
  }.freeze

  def icone(nome, tamanho: 20, classe: "icone")
    tag.svg(
      ICONES.fetch(nome).html_safe,
      "class" => classe,
      "width" => tamanho,
      "height" => tamanho,
      "viewBox" => "0 0 24 24",
      "fill" => "none",
      "stroke" => "currentColor",
      "stroke-width" => "2",
      "stroke-linecap" => "round",
      "stroke-linejoin" => "round",
      "aria-hidden" => "true",
      "focusable" => "false"
    )
  end
end
