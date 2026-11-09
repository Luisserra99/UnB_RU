# Preço de uma refeição (F02). Uma tarifa vale de `vigente_desde` até `vigente_ate` (aberta se nulo),
# e as vigências de um mesmo tipo de refeição não se sobrepõem.
class TarifaRefeicao < ApplicationRecord
  belongs_to :tipo_refeicao

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :vigente_desde, presence: true
  validate :vigente_ate_posterior_ao_inicio
  validate :sem_sobreposicao_de_vigencia

  scope :vigentes_em, lambda { |momento|
    where(vigente_desde: ..momento).where("vigente_ate IS NULL OR vigente_ate > ?", momento)
  }

  # Aceita um TipoRefeicao ou o código (ex.: TipoRefeicao::ALMOCO).
  def self.vigente_para(tipo, momento = Time.current)
    tipo = TipoRefeicao.find_by(codigo: tipo) unless tipo.is_a?(TipoRefeicao)
    return nil if tipo.nil?

    where(tipo_refeicao: tipo).vigentes_em(momento).order(vigente_desde: :desc).first
  end

  def vigente_em?(momento)
    vigente_desde <= momento && (vigente_ate.nil? || vigente_ate > momento)
  end

  private

  def vigente_ate_posterior_ao_inicio
    return if vigente_ate.nil? || vigente_desde.nil? || vigente_ate > vigente_desde

    errors.add(:vigente_ate, "deve ser posterior ao início da vigência")
  end

  def sem_sobreposicao_de_vigencia
    return if tipo_refeicao_id.nil? || vigente_desde.nil?

    outras = TarifaRefeicao.where(tipo_refeicao_id: tipo_refeicao_id).where.not(id: id)
                           .where("vigente_ate IS NULL OR vigente_ate > ?", vigente_desde)
    outras = outras.where(vigente_desde: ...vigente_ate) if vigente_ate
    errors.add(:base, "Já existe uma tarifa vigente para este tipo de refeição nesse período") if outras.exists?
  end
end
