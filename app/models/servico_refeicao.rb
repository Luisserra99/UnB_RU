# Horário semanal de uma refeição num restaurante (F08, F10): o café, o almoço ou o jantar de um
# dia da semana, com início e fim. Os serviços de um mesmo restaurante e dia não se sobrepõem.
class ServicoRefeicao < ApplicationRecord
  # Dias aceitos em +dia_semana+, no padrão de Date#wday: domingo = 0 ... sábado = 6.
  DIAS_SEMANA = (0..6)
  # Formato usado para comparar horários sem data e sem fuso.
  FORMATO_HORA = "%H:%M:%S".freeze

  # Horários são de relógio local (sem data), então não passam por conversão de fuso.
  self.skip_time_zone_conversion_for_attributes = %i[inicio fim]

  belongs_to :restaurante
  belongs_to :tipo_refeicao
  has_many :cardapios, dependent: :destroy

  validates :dia_semana, inclusion: { in: DIAS_SEMANA, message: "deve estar entre 0 (domingo) e 6 (sábado)" }
  validates :dia_semana, uniqueness: { scope: [ :restaurante_id, :tipo_refeicao_id ], message: "já possui este serviço no restaurante" }
  validates :inicio, :fim, presence: true
  validate :inicio_antes_do_fim
  validate :sem_sobreposicao_de_horario

  # Serviços em funcionamento (os inativos não aparecem no cardápio).
  scope :ativos, -> { where(ativo: true) }

  # Busca o serviço ativo em andamento num instante, entre os do escopo atual.
  #
  # Argumentos:: +momento+ (Time): instante da consulta.
  # Retorno:: o ServicoRefeicao do dia de +momento+ cujo horário o abrange; nil se não há nenhum.
  # Efeitos colaterais:: consulta o banco.
  def self.em_andamento(momento)
    ativos.where(dia_semana: momento.wday).find { |servico| servico.abrange?(momento) }
  end

  # Indica se o horário do serviço abrange a hora de um instante (início inclusivo, fim exclusivo).
  #
  # Argumentos:: +momento+ (Time): instante comparado; só a hora conta, não a data.
  # Retorno:: true se a hora está entre +inicio+ (inclusive) e +fim+ (exclusive); false caso contrário.
  # Efeitos colaterais:: nenhum.
  def abrange?(momento)
    hora = momento.strftime(FORMATO_HORA)
    inicio.strftime(FORMATO_HORA) <= hora && hora < fim.strftime(FORMATO_HORA)
  end

  private

  # Valida que o serviço começa antes de terminar.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +inicio+ quando ele não é anterior a +fim+; não valida
  #                      se algum dos dois está em branco (a presença já é validada).
  def inicio_antes_do_fim
    return if !horario_completo? || inicio < fim

    errors.add(:inicio, "deve ser anterior ao fim")
  end

  # Valida que o horário não cruza o de outro serviço do mesmo restaurante e dia.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta os outros serviços; adiciona erro em +inicio+ quando há sobreposição.
  def sem_sobreposicao_de_horario
    return if !horario_completo? || restaurante_id.blank?
    return unless servicos_do_mesmo_dia.any? { |outro| sobrepoe?(outro) }

    errors.add(:inicio, "sobrepõe outro serviço do restaurante neste dia")
  end

  # Indica se início e fim foram informados.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se os dois estão preenchidos; false se algum está em branco.
  # Efeitos colaterais:: nenhum.
  def horario_completo?
    inicio.present? && fim.present?
  end

  # Lista os outros serviços do mesmo restaurante no mesmo dia da semana.
  #
  # Argumentos:: nenhum.
  # Retorno:: ActiveRecord::Relation de ServicoRefeicao, sem o próprio registro.
  # Efeitos colaterais:: nenhum (a consulta só roda quando a relação é percorrida).
  def servicos_do_mesmo_dia
    self.class.where(restaurante_id: restaurante_id, dia_semana: dia_semana).where.not(id: id)
  end

  # Indica se os horários de dois serviços se cruzam; horários só encostados não se cruzam.
  #
  # Argumentos:: +outro+ (ServicoRefeicao): serviço comparado.
  # Retorno:: true se os intervalos têm algum trecho em comum; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def sobrepoe?(outro)
    outro.inicio < fim && inicio < outro.fim
  end
end
