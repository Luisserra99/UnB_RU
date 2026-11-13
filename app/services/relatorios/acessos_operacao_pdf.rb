require "prawn"
require "prawn/table"

Prawn::Fonts::AFM.hide_m17n_warning = true

# F12 — PDF de auditoria do Relatório de Operação (responsável: Tarsila).
# Traz todos os acessos do filtro, o emissor, a data e hora da emissão, os filtros e o
# agrupamento aplicados (RN12.3 e RN12.4), com subtotais quando agrupado (RN12.5).
module Relatorios
  class AcessosOperacaoPdf
    include Extratos::Formatacao

    TITULO = "Relatório Global de Operação".freeze
    SUBTITULO = "Acessos registrados — auditoria interna".freeze
    CABECALHO = [ "Acesso", "Data e hora", "Matrícula", "Restaurante", "Catraca", "Refeição", "Valor debitado" ].freeze
    COR_TITULO = "003366".freeze
    COR_CABECALHO = "E8EEF4".freeze

    def initialize(relatorio, emissor:, emitido_em:, numero_exportacao: nil)
      @relatorio = relatorio
      @emissor = emissor
      @emitido_em = emitido_em
      @numero_exportacao = numero_exportacao
    end

    def render
      documento = Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: 36,
                                      info: { Title: TITULO, Creator: "RU UnB Digital" })
      documento.font "Helvetica"
      cabecalho(documento)
      relatorio.agrupado? ? corpo_agrupado(documento) : tabela(documento, relatorio.acessos)
      totais(documento)
      documento.number_pages "Página <page> de <total>", at: [ documento.bounds.right - 120, -8 ], width: 120,
                                                         align: :right, size: 8
      documento.render
    end

    private

    attr_reader :relatorio, :emissor, :emitido_em, :numero_exportacao

    def cabecalho(documento)
      documento.text "RU UnB Digital", size: 10, color: "666666"
      documento.text TITULO, size: 18, style: :bold, color: COR_TITULO
      documento.text SUBTITULO, size: 10, color: "666666"
      documento.move_down 8
      documento.text "Emitido por: #{emissor.nome} (#{emissor.identificacao})"
      documento.text "Emitido em: #{data_hora(emitido_em)}"
      documento.text "Período: #{relatorio.periodo_nome}"
      documento.text "Restaurante: #{relatorio.restaurante_nome}"
      documento.text "Catraca: #{relatorio.catraca_nome}"
      documento.text "Agrupamento: #{relatorio.agrupamento_nome}"
      documento.text "Exportação nº #{numero_exportacao}" if numero_exportacao
      documento.move_down 12
    end

    def corpo_agrupado(documento)
      relatorio.grupos.each do |grupo|
        documento.text "Restaurante: #{grupo.restaurante}", size: 12, style: :bold, color: COR_TITULO
        documento.move_down 4
        grupo.catracas.each do |subtotal|
          documento.text "#{grupo.restaurante} · #{subtotal.catraca}", size: 10, style: :bold
          tabela(documento, subtotal.acessos)
          documento.text "Subtotal #{grupo.restaurante} · #{subtotal.catraca}: " \
                         "#{contagem(subtotal.quantidade)} · #{reais(subtotal.total)}", size: 10
          documento.move_down 10
        end
        documento.text "Total #{grupo.restaurante}: #{contagem(grupo.quantidade)} · #{reais(grupo.total)}",
                       size: 10, style: :bold
        documento.move_down 14
      end
    end

    def tabela(documento, acessos)
      linhas = acessos.map do |acesso|
        [ acesso.referencia, data_hora(acesso.momento), acesso.matricula.to_s, acesso.restaurante,
         acesso.catraca, acesso.refeicao, reais(acesso.valor) ]
      end
      documento.table([ CABECALHO ] + linhas, header: true, width: documento.bounds.width,
                                            cell_style: { size: 9, border_color: "CCCCCC" }) do
        row(0).font_style = :bold
        row(0).background_color = COR_CABECALHO
        column(6).align = :right
      end
      documento.move_down 6
    end

    def totais(documento)
      documento.move_down 6
      documento.text "Total geral: #{contagem(relatorio.quantidade)}", size: 11, style: :bold
      documento.text "Total debitado: #{reais(relatorio.total_debitado)}", size: 11, style: :bold
    end

    def contagem(quantidade)
      "#{quantidade} #{quantidade == 1 ? 'acesso' : 'acessos'}"
    end
  end
end
