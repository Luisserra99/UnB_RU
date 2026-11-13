# F11 — Apresentação dos lançamentos do extrato (responsável: Tarsila).
module ExtratosHelper
  CLASSES_DE_EVENTO = {
    TipoRefeicao::CAFE_DA_MANHA => "evento-cafe",
    TipoRefeicao::ALMOCO => "evento-almoco",
    TipoRefeicao::JANTAR => "evento-jantar",
    Extratos::Relatorio::TIPO_RECARGA => "evento-recarga"
  }.freeze

  PLURAIS = {
    "Café da Manhã" => [ "café da manhã", "cafés da manhã" ],
    "Almoço" => %w[almoço almoços],
    "Jantar" => %w[jantar jantares],
    "Refeição" => %w[refeição refeições]
  }.freeze

  # "Hoje, 12:20", "Ontem, 19:10" ou "10/05/2024, 14:00".
  def momento_do_lancamento(momento, hoje: Date.current)
    dia = case momento.to_date
    when hoje then "Hoje"
    when hoje - 1 then "Ontem"
    else momento.strftime("%d/%m/%Y")
    end
    "#{dia}, #{momento.strftime('%H:%M')}"
  end

  def classe_do_evento(lancamento)
    CLASSES_DE_EVENTO.fetch(lancamento.tipo, "evento-refeicao")
  end

  # "1 café da manhã · 2 almoços · 4 jantares"
  def resumo_das_refeicoes(por_tipo)
    return "Nenhuma refeição no período" if por_tipo.empty?

    por_tipo.map do |nome, quantidade|
      singular, plural = PLURAIS.fetch(nome, [ nome.downcase, nome.downcase ])
      "#{quantidade} #{quantidade == 1 ? singular : plural}"
    end.join(" · ")
  end
end
