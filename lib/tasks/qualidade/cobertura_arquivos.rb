require "json"

module Qualidade
  # Lê o relatório do SimpleCov (coverage/coverage.json, gerado por +bundle exec rspec+) e
  # devolve a cobertura de linhas de cada arquivo (critério C2 da Sprint 3: > 90% por
  # controller e model).
  class CoberturaArquivos
    CAMINHO_PADRAO = "coverage/coverage.json".freeze

    # Cobertura de um arquivo: +percentual+ (Float, 0 a 100), linhas +cobertas+ e +total+ de
    # linhas relevantes.
    Arquivo = Struct.new(:caminho, :percentual, :cobertas, :total, keyword_init: true)

    # Recebe o +caminho+ do coverage.json. Levanta Errno::ENOENT se o arquivo não existir
    # (o RSpec ainda não foi rodado).
    def initialize(caminho = CAMINHO_PADRAO)
      @relatorio = JSON.parse(File.read(caminho))
    end

    # Devolve um Array de Arquivo, em ordem alfabética, só com os arquivos cujo caminho começa
    # com um dos +prefixos+ (ex.: "app/models"). Não tem efeitos colaterais.
    def arquivos(prefixos)
      @relatorio.fetch("coverage")
                .select { |caminho, _| prefixos.any? { |prefixo| caminho.start_with?(prefixo) } }
                .map { |caminho, dados| montar(caminho, dados) }
                .sort_by(&:caminho)
    end

    # Devolve a cobertura total de linhas (Float, 0 a 100) do relatório.
    def total
      @relatorio.dig("total", "lines", "percent").to_f.round(2)
    end

    private

    # Converte os dados de um arquivo do JSON num Arquivo.
    def montar(caminho, dados)
      Arquivo.new(caminho: caminho, percentual: dados["lines_covered_percent"].to_f.round(2),
                  cobertas: dados["covered_lines"], total: dados["total_lines"])
    end
  end
end
