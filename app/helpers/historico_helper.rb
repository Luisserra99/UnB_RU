# Formatação das linhas do histórico local da catraca (F07), no formato dos cenários BDD:
# data dd/mm/aaaa, horas HH:MM:SS, saldo "10,00" e S/N para liberação e passagem.
module HistoricoHelper
  SITUACOES = {
    "realizado" => [ "Liberado (passagem confirmada)", "situacao-ok" ],
    "cancelado" => [ "Liberado sem passagem", "situacao-aviso" ],
    "liberado" => [ "Aguardando passagem", "situacao-info" ]
  }.freeze

  def sim_nao(valor)
    valor ? "S" : "N"
  end

  def data_registro(momento)
    momento && l(momento.to_date)
  end

  def hora_registro(momento)
    momento && l(momento, format: :hora)
  end

  def saldo_registro(valor)
    valor && number_with_precision(valor, precision: 2, separator: ",", delimiter: ".")
  end

  # [texto, classe CSS] da situação; recusas mostram o motivo gravado na leitura.
  def situacao_registro(registro)
    SITUACOES.fetch(registro.estado) { [ "Bloqueado (#{registro.mensagem})", "situacao-erro" ] }
  end

  def linha_bloqueada?(registro)
    registro.recusado? || registro.cancelado?
  end
end
