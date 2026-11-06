module CardapiosHelper
  # Categorias do cardápio cujo nome precisa de acento; as demais usam `humanize`.
  ROTULOS_CATEGORIA = {
    "guarnicao" => "Guarnição",
    "panificacao" => "Panificação",
    "opcao_extra" => "Opção extra"
  }.freeze

  def rotulo_categoria(categoria)
    ROTULOS_CATEGORIA.fetch(categoria) { categoria.humanize }
  end
end
