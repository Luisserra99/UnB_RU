require "rails_helper"
require "pdf-reader"

# Sprint 3 — blocos comuns aos PDFs de relatório (F09, F11 e F12).
RSpec.describe Extratos::ComposicaoPdf do
  let(:gerador) do
    Class.new do
      include Extratos::ComposicaoPdf

      def montar(linhas: [], tabela: nil, numero: nil, destacar_ultima: false)
        documento = novo_documento("Documento de teste", margin: 40)
        secao(documento, "Seção de teste")
        escrever_linhas(documento, linhas)
        desenhar_tabela(documento, tabela, colunas_a_direita: 1, destacar_ultima: destacar_ultima) if tabela
        documento.text "Fim.#{registro_da_exportacao(numero)}"
        documento.render
      end
    end.new
  end

  def leitor(conteudo)
    PDF::Reader.new(StringIO.new(conteudo))
  end

  def texto(conteudo)
    leitor(conteudo).pages.map(&:text).join("\n").squish
  end

  it "abre um documento A4 com o título e o sistema nos metadados" do
    pdf = leitor(gerador.montar)

    expect(pdf.info).to include(Title: "Documento de teste", Creator: "RU UnB Digital")
    expect(pdf.page_count).to eq(1)
  end

  it "escreve linhas simples e linhas com estilo, na ordem recebida" do
    conteudo = gerador.montar(linhas: [ "Primeira linha", [ "Segunda linha", { size: 14, style: :bold } ] ])

    expect(texto(conteudo)).to include("Seção de teste Primeira linha Segunda linha")
  end

  it "desenha a tabela com o cabeçalho e as linhas de dados" do
    conteudo = gerador.montar(tabela: [ %w[Item Valor], [ "Almoço", "R$ 4,50" ], [ "Total", "R$ 4,50" ] ],
                              destacar_ultima: true)

    expect(texto(conteudo)).to include("Item Valor", "Almoço R$ 4,50", "Total R$ 4,50")
  end

  it "desenha só o cabeçalho quando não há linhas de dados" do
    conteudo = gerador.montar(tabela: [ %w[Item Valor] ])

    expect(texto(conteudo)).to include("Item Valor Fim.")
  end

  it "inclui o número da exportação no rodapé quando ele existe" do
    expect(texto(gerador.montar(numero: 7))).to include("Fim. Exportação nº 7.")
  end

  it "não escreve número de exportação quando ele não existe" do
    expect(texto(gerador.montar)).not_to include("Exportação nº")
  end
end
