module ControleHelper
  # Item do menu da aplicação de controle.
  # Vira link automaticamente quando a rota existir (ex.: quando a F06 criar `controle_terminal_path`);
  # até lá aparece desabilitado.
  def item_nav_controle(rotulo, rota)
    unless respond_to?(rota)
      return tag.span(rotulo, class: "nav-item desabilitado", "aria-disabled": "true", title: "Disponível em breve")
    end

    caminho = public_send(rota)
    ativo = request.path == caminho # também marca a página re-renderizada após POST (ex.: credencial inválida)
    link_to rotulo, caminho, class: ["nav-item", ("ativo" if ativo)], "aria-current": (ativo ? "page" : nil)
  end

  def rotulo_papel(usuario)
    usuario.administrador? ? "Administrador" : "Funcionário"
  end
end
