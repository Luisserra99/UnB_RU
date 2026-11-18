# Sprint 3 — ferramentas de qualidade (critérios C1, C2 e C4). Uso:
#
#   bin/rails "qualidade:metodos[15,app/forms app/models]"  # Flog e ABC por método, nota >= 15
#   bundle exec rspec && bin/rails qualidade:cobertura       # cobertura por controller e model
#   bin/rails qualidade:rdoc                                 # itens sem comentário RDoc em app/
#   bin/rails documentacao                                   # gera o HTML do RDoc em doc/app
#   bundle exec rubycritic                                   # relatório completo (tmp/rubycritic)
require "rdoc/task"

RDoc::Task.new(:documentacao) do |rdoc|
  rdoc.rdoc_dir = "doc/app"
  rdoc.title = "UnB RU — documentação do código"
  rdoc.main = "README.MD"
  rdoc.rdoc_files.include("README.MD", "app/**/*.rb")
  rdoc.options << "--all" << "--encoding=UTF-8"
end

namespace :qualidade do
  desc "Flog (RubyCritic) e ABC (RuboCop) por método. Args: limite (padrão 15) e caminhos (padrão app)"
  task :metodos, [ :limite, :caminhos ] do |_tarefa, args|
    require_relative "qualidade/metricas_metodos"

    limite = (args[:limite] || 15).to_f
    arquivos = (args[:caminhos] || "app").split.flat_map do |caminho|
      File.directory?(caminho) ? Dir.glob("#{caminho}/**/*.rb") : [ caminho ]
    end
    metodos = Qualidade::MetricasMetodos.new(arquivos.sort).metodos.select { |metodo| metodo.maior >= limite }

    puts "| Arquivo:linha | Método | Flog (RubyCritic) | ABC (RuboCop) |", "|---|---|---|---|"
    metodos.each do |metodo|
      puts "| `#{metodo.local}` | `#{metodo.nome}` | #{metodo.flog || '—'} | #{metodo.abc} #{metodo.vetor} |"
    end
    puts "", "#{metodos.size} método(s) com nota >= #{limite} em #{arquivos.size} arquivo(s)."
  end

  desc "Cobertura de linhas por arquivo, lida do último bundle exec rspec. Arg: prefixos (padrão controllers e models)"
  task :cobertura, [ :prefixos ] do |_tarefa, args|
    require_relative "qualidade/cobertura_arquivos"

    prefixos = (args[:prefixos] || "app/controllers app/models").split
    cobertura = Qualidade::CoberturaArquivos.new

    puts "| Arquivo | Cobertura | Linhas cobertas |", "|---|---|---|"
    cobertura.arquivos(prefixos).each do |arquivo|
      puts "| `#{arquivo.caminho}` | #{format('%.2f', arquivo.percentual)}% | #{arquivo.cobertas}/#{arquivo.total} |"
    end
    puts "", "Cobertura total: #{format('%.2f', cobertura.total)}%"
  end

  desc "Lista classes, constantes e métodos (inclusive privados) sem comentário RDoc. Arg: caminhos (padrão app)"
  task :rdoc, [ :caminhos ] do |_tarefa, args|
    system("rdoc", "--coverage-report", "--all", "--quiet", *(args[:caminhos] || "app").split)
  end
end
