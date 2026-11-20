require "rails_helper"
require "tmpdir"
require Rails.root.join("lib/tasks/qualidade/metricas_metodos")

RSpec.describe Qualidade::MetricasMetodos do
  def arquivo_com(codigo)
    caminho = File.join(@pasta, "exemplo.rb")
    File.write(caminho, codigo)
    caminho
  end

  around do |exemplo|
    Dir.mktmpdir do |pasta|
      @pasta = pasta
      exemplo.run
    end
  end

  it "mede Flog e ABC de cada método, do mais complexo para o menos complexo" do
    caminho = arquivo_com(<<~RUBY)
      class Exemplo
        def simples
          1
        end

        def complexo(valor)
          total = 0
          total += valor if valor.positive? && valor.even?
          total.to_s.strip
        end
      end
    RUBY

    metodos = described_class.new([ caminho ]).metodos

    expect(metodos.map(&:nome)).to eq(%w[Exemplo#complexo Exemplo#simples])
    complexo = metodos.first
    expect(complexo.local).to eq("#{caminho}:6")
    expect(complexo.flog).to be > 0
    expect(complexo.vetor).to match(/\A<\d+, \d+, \d+>\z/)
    expect(complexo.maior).to eq([ complexo.flog, complexo.abc ].max)
  end

  it "devolve lista vazia para um arquivo sem métodos" do
    caminho = arquivo_com("VALOR = 1\n")

    expect(described_class.new([ caminho ]).metodos).to eq([])
  end
end
