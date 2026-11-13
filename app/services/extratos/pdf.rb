require "prawn"
require "prawn/table"

# As fontes embutidas do PDF cobrem os acentos do português; o aviso do Prawn não se aplica.
Prawn::Fonts::AFM.hide_m17n_warning = true

# F11 — Documento PDF do extrato (responsável: Tarsila).
# Recebe um Extratos::Relatorio já filtrado e devolve os bytes do PDF. Não consulta o banco.
module Extratos
  class Pdf
    include Formatacao

    TITULO = "Extrato e Histórico de Refeições".freeze
    CABECALHO_TABELA = [ "Data e hora", "Evento", "Local", "Catraca", "Valor" ].freeze
    INDICACAO_AUDITORIA = "Registros auditáveis".freeze
    COR_TITULO = "003366".freeze
    COR_CABECALHO = "E8EEF4".freeze

    def initialize(relatorio, emitido_em:, numero_exportacao: nil)
      @relatorio = relatorio
      @emitido_em = emitido_em
      @numero_exportacao = numero_exportacao
    end

    def render
      documento = Prawn::Document.new(page_size: "A4", margin: 40,
                                      info: { Title: TITULO, Creator: "RU UnB Digital" })
      documento.font "Helvetica"
      cabecalho(documento)
      resumo(documento)
      tabela(documento)
      rodape(documento)
      documento.render
    end

    private

    attr_reader :relatorio, :emitido_em, :numero_exportacao

    def cabecalho(documento)
      estudante = relatorio.estudante
      documento.text "RU UnB Digital", size: 10, color: "666666"
      documento.text TITULO, size: 18, style: :bold, color: COR_TITULO
      documento.move_down 8
      documento.text "Estudante: #{estudante.nome}"
      documento.text "Matrícula: #{estudante.matricula}"
      documento.text "Período de referência: #{relatorio.periodo_nome}"
      documento.text "Tipo de refeição: #{relatorio.tipo_nome}"
      documento.text "Catraca: #{relatorio.catraca_nome}"
      documento.text "Data de emissão: #{data_hora(emitido_em)}"
      documento.move_down 14
    end

    def resumo(documento)
      documento.text "Resumo", size: 12, style: :bold, color: COR_TITULO
      documento.move_down 4
      documento.text "Saldo atual: #{reais(relatorio.saldo_atual)}"
      documento.text "Total gasto: #{reais(relatorio.total_gasto)}"
      documento.text "Refeições realizadas: #{relatorio.refeicoes_realizadas}"
      documento.text "Total recarregado: #{reais(relatorio.total_recarregado)}"
      documento.text "Lançamentos: #{relatorio.lancamentos.size}"
      documento.move_down 14
    end

    def tabela(documento)
      linhas = relatorio.lancamentos.map do |lancamento|
        [ data_hora(lancamento.momento), lancamento.descricao, lancamento.local.to_s,
         lancamento.catraca.to_s, valor_com_sinal(lancamento.valor) ]
      end
      documento.table([ CABECALHO_TABELA ] + linhas, header: true, width: documento.bounds.width,
                                                   cell_style: { size: 9, border_color: "CCCCCC" }) do
        row(0).font_style = :bold
        row(0).background_color = COR_CABECALHO
        column(4).align = :right
      end
    end

    def rodape(documento)
      registro = numero_exportacao ? " Exportação nº #{numero_exportacao}." : ""
      documento.move_down 14
      documento.text "#{INDICACAO_AUDITORIA}.#{registro}", size: 8, color: "666666"
    end
  end
end
