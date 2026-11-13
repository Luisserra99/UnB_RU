# encoding: utf-8
# frozen_string_literal: true

# Publica no GitHub Wiki as páginas das funcionalidades (wiki/F01.md … wiki/F12.md) e a de
# Identidade e Acesso, sem tocar na Home nem nas páginas "Sprint - 1" e "Sprint - 2",
# que são mantidas direto no Wiki pela PO. Ajusta os links:
#   [F01](F01.md#secao)        -> [F01](F01#secao)                (página do Wiki)
#   [x](Sprint-1.md)           -> [x](Sprint-‐-1)                 (página mantida no Wiki)
#   [x](../features/a.feature) -> link para o arquivo na branch de entrega
# e gera a barra lateral (_Sidebar.md).
#
# Uso:
#   git clone https://github.com/Luisserra99/UnB_RU.wiki.git ../UnB_RU.wiki
#   ruby script/publicar_wiki.rb ../UnB_RU.wiki

REPOSITORIO = "https://github.com/Luisserra99/UnB_RU"
BRANCH = "sprint-2"

# Páginas do repositório que, no Wiki, já existem com outro nome. O hífen é o U+2010 que o
# GitHub usa ao criar páginas com " - " no título.
PAGINAS_DO_WIKI = { "Home" => "Sprint-‐-2", "Sprint-1" => "Sprint-‐-1" }.freeze

destino = ARGV.fetch(0) { abort "Uso: ruby script/publicar_wiki.rb <pasta do clone do wiki>" }
abort "#{destino} não parece um clone do wiki (falta .git)" unless File.directory?(File.join(destino, ".git"))

origem = File.expand_path("../wiki", __dir__)

def converter(texto)
  texto
    .gsub("\r\n", "\n")
    .gsub(%r{\]\(\.\./([^)\s]+)\)}) { "](#{REPOSITORIO}/blob/#{BRANCH}/#{Regexp.last_match(1)})" }
    .gsub(%r{\]\(([\w.-]+)\.md(#[^)]*)?\)}) do
      pagina = Regexp.last_match(1)
      "](#{PAGINAS_DO_WIKI.fetch(pagina, pagina)}#{Regexp.last_match(2)})"
    end
end

paginas = Dir[File.join(origem, "F[0-9][0-9].md")].sort + [ File.join(origem, "Sprint-2-Identidade-e-Acesso.md") ]
paginas.each do |caminho|
  conteudo = converter(File.read(caminho, encoding: "utf-8"))
  File.write(File.join(destino, File.basename(caminho)), conteudo, encoding: "utf-8")
  puts "copiada: #{File.basename(caminho)}"
end

funcionalidades = paginas.grep(/F\d{2}\.md\z/).map do |caminho|
  titulo = File.foreach(caminho, encoding: "utf-8").first.sub(/^#\s*/, "").strip
  "- [#{titulo}](#{File.basename(caminho, '.md')})"
end

barra = <<~MD
  **[Home](Home)**

  **Sprint 2**

  - [Visão geral da Sprint 2](Sprint-‐-2)
  #{funcionalidades.join("\n")}
  - [Identidade e Acesso](Sprint-2-Identidade-e-Acesso)

  **Sprint 1**

  - [Especificação e cenários BDD](Sprint-‐-1)

  **Repositório**

  - [Código (branch #{BRANCH})](#{REPOSITORIO}/tree/#{BRANCH})
  - [Kanban](https://github.com/users/Luisserra99/projects/1)
MD
File.write(File.join(destino, "_Sidebar.md"), barra, encoding: "utf-8")
puts "gerada: _Sidebar.md"
