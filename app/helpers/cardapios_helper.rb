# Formatação usada na tela do cardápio (F10).
module CardapiosHelper
  # Categorias do cardápio cujo nome precisa de acento; as demais usam `humanize`.
  ROTULOS_CATEGORIA = {
    "guarnicao" => "Guarnição",
    "panificacao" => "Panificação",
    "opcao_extra" => "Opção extra"
  }.freeze

  # Converte a categoria de um item do cardápio no rótulo exibido.
  #
  # Argumentos:: +categoria+ (String): categoria gravada no item (ex.: "prato_principal").
  # Retorno:: String com o rótulo de ROTULOS_CATEGORIA, quando a categoria precisa de acento;
  #           caso contrário, a categoria com +humanize+ (ex.: "Prato principal").
  # Efeitos colaterais:: nenhum.
  def rotulo_categoria(categoria)
    ROTULOS_CATEGORIA.fetch(categoria) { categoria.humanize }
  end
end
