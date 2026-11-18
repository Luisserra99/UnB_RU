require "rubycritic/analysers/helpers/flog"
require "rubocop"

module Qualidade
  # Mede a complexidade de cada método de um conjunto de arquivos Ruby (critério C1 da Sprint 3:
  # ABC < 20 por método).
  #
  # Junta duas medidas por método, casadas pelo arquivo e pela linha do +def+:
  # - *Flog*, calculado pelo mesmo analisador que o RubyCritic usa (RubyCritic::Flog). É uma
  #   variação ponderada do ABC e costuma dar valores maiores.
  # - *ABC* exato, calculado como no cop Metrics/AbcSize do RuboCop, com o vetor
  #   <Assignments, Branches, Conditions>.
  class MetricasMetodos
    # Medidas de um método. +local+ é "arquivo:linha", +nome+ segue o padrão do Flog
    # (Classe#metodo ou Classe::metodo_de_classe), +abc+ é a nota e +vetor+ é "<A, B, C>".
    Metodo = Struct.new(:local, :nome, :flog, :abc, :vetor, keyword_init: true) do
      # Devolve a maior das duas medidas (Float), usada para ordenar e filtrar.
      def maior
        [ flog, abc ].compact.max
      end
    end

    # Recebe +arquivos+, uma lista de caminhos de arquivos .rb. Não lê nada até #metodos ser chamado.
    def initialize(arquivos)
      @arquivos = arquivos
    end

    # Devolve um Array de Metodo, um por +def+ encontrado, do mais complexo para o menos complexo.
    # Arquivos sem nenhum método resultam em lista vazia. Não tem efeitos colaterais.
    def metodos
      flog = notas_flog
      definicoes.map { |definicao| medir(definicao, flog) }.sort_by { |metodo| -metodo.maior }
    end

    private

    # Devolve um Hash "arquivo:linha" => [nome, nota] com a nota Flog de cada método. O Flog
    # informa o local como "arquivo:início-fim"; só a linha de início é usada.
    def notas_flog
      analisador = RubyCritic::Flog.new
      analisador.flog(*@arquivos)
      notas = {}
      analisador.each_by_score do |nome, nota|
        local = analisador.method_locations[nome]
        notas[local.sub(/-\d+\z/, "")] = [ nome, nota.round(2) ] if local
      end
      notas
    end

    # Devolve uma lista de pares [arquivo, nó def/defs] com todos os métodos dos arquivos.
    def definicoes
      @arquivos.flat_map do |arquivo|
        fonte = RuboCop::AST::ProcessedSource.new(File.read(arquivo), RUBY_VERSION.to_f, arquivo)
        fonte.ast ? fonte.ast.each_node(:def, :defs).map { |no| [ arquivo, no ] } : []
      end
    end

    # Monta o Metodo de uma definição, completando com a nota Flog do mesmo arquivo e linha.
    def medir((arquivo, no), flog)
      local = "#{arquivo}:#{no.first_line}"
      nome, nota_flog = flog.fetch(local, [ no.method_name.to_s, nil ])
      abc, vetor = RuboCop::Cop::Metrics::Utils::AbcSizeCalculator.calculate(no)
      Metodo.new(local: local, nome: nome, flog: nota_flog, abc: abc, vetor: vetor)
    end
  end
end
