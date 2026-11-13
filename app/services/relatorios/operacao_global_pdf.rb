require "prawn"
require "prawn/table"

Prawn::Fonts::AFM.hide_m17n_warning = true

# F09 — PDF oficial do Relatório Global de Operação (responsável: Tarsila).
# Mostra os mesmos dados da tela, mais os filtros, a data e hora de emissão e o emissor (RN09.13).
module Relatorios
  class OperacaoGlobalPdf
    include Extratos::Formatacao

    TITULO = "Relatório Global de Operação".freeze
    COR_TITULO = "003366".freeze
    COR_CABECALHO = "E8EEF4".freeze

    def initialize(relatorio, emissor:, emitido_em:, numero_exportacao: nil)
      @relatorio = relatorio
      @emissor = emissor
      @emitido_em = emitido_em
      @numero_exportacao = numero_exportacao
    end

    def render
      documento = Prawn::Document.new(page_size: "A4", margin: 40, info: { Title: TITULO, Creator: "RU UnB Digital" })
      documento.font "Helvetica"
      cabecalho(documento)
      indicadores(documento)
      consolidacao(documento)
      liquidacao(documento)
      distribuicao(documento)
      rodape(documento)
      documento.render
    end

    private

    attr_reader :relatorio, :emissor, :emitido_em, :numero_exportacao

    def cabecalho(documento)
      documento.text "RU UnB Digital", size: 10, color: "666666"
      documento.text TITULO, size: 18, style: :bold, color: COR_TITULO
      documento.move_down 8
      documento.text "Data contábil: #{relatorio.data.strftime(OperacaoGlobal::FORMATO_DATA)}"
      documento.text "Janela de serviço: #{relatorio.turno_nome}"
      documento.text "Unidade gestora: #{relatorio.unidade_nome}"
      documento.text "Emitido em: #{data_hora(emitido_em)}"
      documento.text "Emitido por: #{emissor.nome} (#{emissor.identificacao})"
      documento.move_down 14
    end

    def indicadores(documento)
      secao(documento, "Indicadores")
      documento.text "Catracas online: #{relatorio.catracas_online}/#{relatorio.catracas_cadastradas}"
      documento.text "Arrecadação global: #{reais(relatorio.arrecadacao_global)}"
      documento.text "Refeições servidas: #{relatorio.total_acessos}"
      documento.text "Ticket médio por estudante: #{reais(relatorio.ticket_medio)}"
      documento.text "Transações validadas: #{relatorio.transacoes_validadas}"
      documento.text "Divergências contábeis: #{reais(relatorio.divergencia_contabil)}"
      documento.move_down 14
    end

    def consolidacao(documento)
      secao(documento, "Consolidação operacional dos restaurantes")
      linhas = relatorio.linhas.map { |linha| [ linha.restaurante.nome, linha.acessos.to_s, reais(linha.arrecadacao) ] }
      linhas << [ "Total Consolidado", relatorio.total_acessos.to_s, reais(relatorio.arrecadacao_global) ]
      tabela(documento, [ "Restaurante", "Acessos", "Arrecadação bruta" ], linhas, destacar_ultima: true)
    end

    def liquidacao(documento)
      secao(documento, "Métodos de liquidação")
      linhas = relatorio.liquidacoes.map { |item| [ item.nome, "#{item.percentual}%", reais(item.valor) ] }
      linhas << [ "Total liquidado", "", reais(relatorio.soma_liquidacoes) ]
      tabela(documento, [ "Método", "Participação", "Valor liquidado" ], linhas, destacar_ultima: true)
    end

    def distribuicao(documento)
      secao(documento, "Distribuição por refeição")
      linhas = relatorio.distribuicao_por_refeicao.map { |item| [ item.nome, item.acessos.to_s, reais(item.arrecadacao) ] }
      tabela(documento, [ "Refeição", "Acessos", "Arrecadação" ], linhas)
    end

    def secao(documento, titulo)
      documento.text titulo, size: 12, style: :bold, color: COR_TITULO
      documento.move_down 4
    end

    def tabela(documento, cabecalho, linhas, destacar_ultima: false)
      ultima = linhas.size
      documento.table([ cabecalho ] + linhas, header: true, width: documento.bounds.width,
                                            cell_style: { size: 9, border_color: "CCCCCC" }) do
        row(0).font_style = :bold
        row(0).background_color = COR_CABECALHO
        row(ultima).font_style = :bold if destacar_ultima
        columns(1..2).align = :right
      end
      documento.move_down 14
    end

    def rodape(documento)
      registro = numero_exportacao ? " Exportação nº #{numero_exportacao}." : ""
      documento.text "Documento somente leitura, gerado a partir dos acessos registrados.#{registro}",
                     size: 8, color: "666666"
    end
  end
end
