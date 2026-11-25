# F11 — Apresentação dos lançamentos do extrato (responsável: Tarsila).
module ExtratosHelper
  # Classe CSS de cada tipo de lançamento, que define a cor do evento na tela.
  CLASSES_DE_EVENTO = {
    TipoRefeicao::CAFE_DA_MANHA => "evento-cafe",
    TipoRefeicao::ALMOCO => "evento-almoco",
    TipoRefeicao::JANTAR => "evento-jantar",
    Extratos::Relatorio::TIPO_RECARGA => "evento-recarga"
  }.freeze

  # Singular e plural, em minúsculas, do nome de cada refeição.
  PLURAIS = {
    "Café da Manhã" => [ "café da manhã", "cafés da manhã" ],
    "Almoço" => %w[almoço almoços],
    "Jantar" => %w[jantar jantares],
    "Refeição" => %w[refeição refeições]
  }.freeze

  # Escreve a data e a hora de um lançamento, trocando a data por "Hoje" ou "Ontem" quando couber.
  #
  # Argumentos:: +momento+ (Time): quando o lançamento aconteceu;
  #              +hoje+ (Date): data de referência (por padrão, a data atual).
  # Retorno:: String, como "Hoje, 12:20", "Ontem, 19:10" ou "10/05/2024, 14:00".
  # Efeitos colaterais:: nenhum.
  def momento_do_lancamento(momento, hoje: Date.current)
    dia = case momento.to_date
    when hoje then "Hoje"
    when hoje - 1 then "Ontem"
    else momento.strftime("%d/%m/%Y")
    end
    "#{dia}, #{momento.strftime('%H:%M')}"
  end

  # Escolhe a classe CSS do evento de um lançamento.
  #
  # Argumentos:: +lancamento+ (Extratos::Relatorio::Lancamento): lançamento exibido.
  # Retorno:: String de CLASSES_DE_EVENTO; "evento-refeicao" para refeição sem tipo conhecido.
  # Efeitos colaterais:: nenhum.
  def classe_do_evento(lancamento)
    CLASSES_DE_EVENTO.fetch(lancamento.tipo, "evento-refeicao")
  end

  # Resume as refeições do período numa frase, com o plural correto de cada tipo.
  #
  # Argumentos:: +por_tipo+ (Hash): nome da refeição => quantidade, como em
  #              Extratos::Relatorio#refeicoes_por_tipo.
  # Retorno:: String, como "1 café da manhã · 2 almoços · 4 jantares"; "Nenhuma refeição no
  #           período" para Hash vazio.
  # Efeitos colaterais:: nenhum.
  def resumo_das_refeicoes(por_tipo)
    return "Nenhuma refeição no período" if por_tipo.empty?

    por_tipo.map do |nome, quantidade|
      singular, plural = PLURAIS.fetch(nome, [ nome.downcase, nome.downcase ])
      "#{quantidade} #{quantidade == 1 ? singular : plural}"
    end.join(" · ")
  end
end
