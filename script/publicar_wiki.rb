# encoding: utf-8
# frozen_string_literal: true

# Copia as páginas de wiki/ para um clone do GitHub Wiki, ajustando os links:
#   [F01](F01.md#secao)        -> [F01](F01#secao)          (página da wiki)
#   [x](../features/a.feature) -> link para o arquivo na branch de entrega
# e gera a barra lateral (_Sidebar.md).
#
# Uso:
#   git clone https://github.com/Luisserra99/UnB_RU.wiki.git ../UnB_RU.wiki
#   ruby script/publicar_wiki.rb ../UnB_RU.wiki

REPOSITORIO = "https://github.com/Luisserra99/UnB_RU"
BRANCH = "sprint-2"

destino = ARGV.fetch(0) { abort "Uso: ruby script/publicar_wiki.rb <pasta do clone do wiki>" }
abort "#{destino} não parece um clone do wiki (falta .git)" unless File.directory?(File.join(destino, ".git"))

origem = File.expand_path("../wiki", __dir__)

def converter(texto)
  texto
    .gsub("\r\n", "\n")
    .gsub(%r{\]\(\.\./([^)\s]+)\)}) { "](#{REPOSITORIO}/blob/#{BRANCH}/#{Regexp.last_match(1)})" }
    .gsub(%r{\]\(([\w.-]+)\.md(#[^)]*)?\)}) { "](#{Regexp.last_match(1)}#{Regexp.last_match(2)})" }
end

paginas = Dir[File.join(origem, "*.md")].sort
paginas.each do |caminho|
  conteudo = converter(File.read(caminho, encoding: "utf-8"))
  File.write(File.join(destino, File.basename(caminho)), conteudo, encoding: "utf-8")
  puts "copiada: #{File.basename(caminho)}"
end

titulos = paginas.to_h do |caminho|
  [ File.basename(caminho, ".md"), File.foreach(caminho, encoding: "utf-8").first.sub(/^#\s*/, "").strip ]
end

funcionalidades = titulos.keys.grep(/\AF\d{2}\z/).map { |pagina| "- [#{titulos[pagina]}](#{pagina})" }
barra = <<~MD
  **[Home](Home)**

  **Sprint 2**

  #{funcionalidades.join("\n")}
  - [Identidade e Acesso](Sprint-2-Identidade-e-Acesso)

  **Sprint 1**

  - [Especificação e cenários BDD](Sprint-1)

  **Repositório**

  - [Código (branch #{BRANCH})](#{REPOSITORIO}/tree/#{BRANCH})
  - [Kanban](https://github.com/users/Luisserra99/projects/1)
MD
File.write(File.join(destino, "_Sidebar.md"), barra, encoding: "utf-8")
puts "gerada: _Sidebar.md"
