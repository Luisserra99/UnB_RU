# Formatação das linhas do histórico local da catraca (F07), no formato dos cenários BDD:
# data dd/mm/aaaa, horas HH:MM:SS, saldo "10,00" e S/N para liberação e passagem.
module HistoricoHelper
  # Texto e classe CSS da coluna "Situação" para cada estado de RegistroAcesso que não é recusa.
  SITUACOES = {
    "realizado" => [ "Liberado (passagem confirmada)", "situacao-ok" ],
    "cancelado" => [ "Liberado sem passagem", "situacao-aviso" ],
    "liberado" => [ "Aguardando passagem", "situacao-info" ]
  }.freeze

  # Converte um booleano para as colunas S/N (RN07.4).
  #
  # Argumentos:: +valor+ (Object): valor verdadeiro ou falso.
  # Retorno:: "S" para valor verdadeiro; "N" para false ou nil.
  # Efeitos colaterais:: nenhum.
  def sim_nao(valor)
    valor ? "S" : "N"
  end

  # Data do registro no formato dd/mm/aaaa.
  #
  # Argumentos:: +momento+ (Time ou nil).
  # Retorno:: String com a data; nil quando +momento+ é nil.
  # Efeitos colaterais:: nenhum.
  def data_registro(momento)
    momento && l(momento.to_date)
  end

  # Hora do registro no formato HH:MM:SS.
  #
  # Argumentos:: +momento+ (Time ou nil).
  # Retorno:: String com a hora; nil quando +momento+ é nil (ex.: leitura recusada não tem horário
  #           de liberação).
  # Efeitos colaterais:: nenhum.
  def hora_registro(momento)
    momento && l(momento, format: :hora)
  end

  # Saldo lido na catraca, com duas casas e vírgula decimal (ex.: "10,00").
  #
  # Argumentos:: +valor+ (Numeric ou nil).
  # Retorno:: String com o saldo; nil quando +valor+ é nil (ex.: identificação inválida, RN07.7).
  # Efeitos colaterais:: nenhum.
  def saldo_registro(valor)
    valor && number_with_precision(valor, precision: 2, separator: ",", delimiter: ".")
  end

  # Texto e classe CSS da coluna "Situação"; recusas mostram o motivo gravado na leitura.
  #
  # Argumentos:: +registro+ (RegistroAcesso).
  # Retorno:: Array <tt>[texto, classe_css]</tt>: o par de SITUACOES para o estado do registro;
  #           <tt>["Bloqueado (<motivo>)", "situacao-erro"]</tt> para os demais (recusas).
  # Efeitos colaterais:: nenhum.
  def situacao_registro(registro)
    SITUACOES.fetch(registro.estado) { [ "Bloqueado (#{registro.mensagem})", "situacao-erro" ] }
  end

  # Indica se a linha do histórico deve aparecer destacada como bloqueada.
  #
  # Argumentos:: +registro+ (RegistroAcesso).
  # Retorno:: true se o acesso foi recusado ou liberado sem passagem; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def linha_bloqueada?(registro)
    registro.recusado? || registro.cancelado?
  end
end
