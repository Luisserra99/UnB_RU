require "rails_helper"
require "tmpdir"
require Rails.root.join("lib/tasks/qualidade/cobertura_arquivos")

RSpec.describe Qualidade::CoberturaArquivos do
  let(:relatorio) do
    {
      "total" => { "lines" => { "percent" => 95.456 } },
      "coverage" => {
        "app/models/b.rb" => { "lines_covered_percent" => 90.0, "covered_lines" => 9, "total_lines" => 10 },
        "app/models/a.rb" => { "lines_covered_percent" => 100.0, "covered_lines" => 4, "total_lines" => 4 },
        "app/services/c.rb" => { "lines_covered_percent" => 50.0, "covered_lines" => 1, "total_lines" => 2 }
      }
    }
  end

  around do |exemplo|
    Dir.mktmpdir do |pasta|
      @caminho = File.join(pasta, "coverage.json")
      File.write(@caminho, relatorio.to_json)
      exemplo.run
    end
  end

  it "lista a cobertura dos arquivos dos prefixos pedidos, em ordem alfabética" do
    arquivos = described_class.new(@caminho).arquivos([ "app/models" ])

    expect(arquivos.map(&:caminho)).to eq(%w[app/models/a.rb app/models/b.rb])
    expect(arquivos.last).to have_attributes(percentual: 90.0, cobertas: 9, total: 10)
  end

  it "informa a cobertura total arredondada" do
    expect(described_class.new(@caminho).total).to eq(95.46)
  end

  it "devolve lista vazia quando nenhum arquivo casa com os prefixos" do
    expect(described_class.new(@caminho).arquivos([ "app/controllers" ])).to eq([])
  end

  it "falha quando o relatório do SimpleCov ainda não foi gerado" do
    expect { described_class.new(File.join(File.dirname(@caminho), "nao_existe.json")) }
      .to raise_error(Errno::ENOENT)
  end
end
