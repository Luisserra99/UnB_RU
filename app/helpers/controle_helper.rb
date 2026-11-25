# Menu e rótulos do layout da aplicação de controle.
module ControleHelper
  # Item do menu da aplicação de controle.
  # Vira link automaticamente quando a rota existir (ex.: quando a F06 criar `controle_terminal_path`);
  # até lá aparece desabilitado.
  #
  # Argumentos:: +rotulo+ (String): texto do item; +rota+ (Symbol): nome do helper de rota, ex.:
  #              +:controle_historico_path+.
  # Retorno:: ActiveSupport::SafeBuffer com um link (marcado como ativo quando é a página atual ou
  #           uma subpágina dela); com um +span+ desabilitado quando a rota não existe.
  # Efeitos colaterais:: nenhum.
  def item_nav_controle(rotulo, rota)
    return item_nav_desabilitado(rotulo) unless respond_to?(rota)

    caminho = public_send(rota)
    ativo = item_nav_ativo?(caminho)
    link_to rotulo, caminho, class: [ "nav-item", ("ativo" if ativo) ], "aria-current": (ativo ? "page" : nil)
  end

  # Nome do papel do usuário mostrado no cabeçalho do controle.
  #
  # Argumentos:: +usuario+ (Usuario): funcionário ou administrador logado.
  # Retorno:: "Administrador" ou "Funcionário".
  # Efeitos colaterais:: consulta os papéis do usuário no banco.
  def rotulo_papel(usuario)
    usuario.administrador? ? "Administrador" : "Funcionário"
  end

  private

  # Item do menu de uma função que ainda não existe.
  #
  # Argumentos:: +rotulo+ (String): texto do item.
  # Retorno:: ActiveSupport::SafeBuffer com um +span+ desabilitado e a dica "Disponível em breve".
  # Efeitos colaterais:: nenhum.
  def item_nav_desabilitado(rotulo)
    tag.span(rotulo, class: "nav-item desabilitado", "aria-disabled": "true", title: "Disponível em breve")
  end

  # Indica se o item do menu corresponde à página atual.
  # Também marca a página re-renderizada após POST (ex.: credencial inválida) e as subpáginas
  # de uma seção (ex.: /admin/relatorio-global/acessos). A raiz do controle só vale com caminho exato.
  #
  # Argumentos:: +caminho+ (String): caminho do item, ex.: "/controle/historico".
  # Retorno:: true ou false.
  # Efeitos colaterais:: nenhum.
  def item_nav_ativo?(caminho)
    atual = request.path
    atual == caminho || (caminho != controle_root_path && atual.start_with?("#{caminho}/"))
  end
end
