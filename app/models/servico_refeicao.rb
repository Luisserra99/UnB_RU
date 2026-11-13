class ServicoRefeicao < ApplicationRecord
  # dia_semana segue Date#wday: domingo = 0 ... sábado = 6.
  DIAS_SEMANA = (0..6)
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

  scope :ativos, -> { where(ativo: true) }

  # Serviço ativo em andamento no momento informado, entre os do escopo atual.
  def self.em_andamento(momento)
    ativos.where(dia_semana: momento.wday).find { |servico| servico.abrange?(momento) }
  end

  # O início é inclusivo e o fim é exclusivo.
  def abrange?(momento)
    hora = momento.strftime(FORMATO_HORA)
    inicio.strftime(FORMATO_HORA) <= hora && hora < fim.strftime(FORMATO_HORA)
  end

  private

  def inicio_antes_do_fim
    return if inicio.blank? || fim.blank? || inicio < fim

    errors.add(:inicio, "deve ser anterior ao fim")
  end

  def sem_sobreposicao_de_horario
    return if inicio.blank? || fim.blank? || restaurante_id.blank?

    outros = self.class.where(restaurante_id: restaurante_id, dia_semana: dia_semana).where.not(id: id)
    return unless outros.any? { |outro| outro.inicio < fim && inicio < outro.fim }

    errors.add(:inicio, "sobrepõe outro serviço do restaurante neste dia")
  end
end
