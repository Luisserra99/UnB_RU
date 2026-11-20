# Preço de uma refeição (F02). Uma tarifa vale de `vigente_desde` até `vigente_ate` (aberta se nulo),
# e as vigências de um mesmo tipo de refeição não se sobrepõem.
class TarifaRefeicao < ApplicationRecord
  # Erro quando a vigência cruza a de outra tarifa do mesmo tipo.
  MSG_SOBREPOSICAO = "Já existe uma tarifa vigente para este tipo de refeição nesse período".freeze

  belongs_to :tipo_refeicao

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :vigente_desde, presence: true
  validate :vigente_ate_posterior_ao_inicio
  validate :sem_sobreposicao_de_vigencia

  # Tarifas que ainda não tinham terminado em +momento+ (sem fim ou com fim depois dele).
  scope :nao_encerradas_em, ->(momento) { where("vigente_ate IS NULL OR vigente_ate > ?", momento) }
  # Tarifas que começam antes de +momento+; com +momento+ nil, todas.
  scope :iniciadas_antes_de, ->(momento) { momento ? where(vigente_desde: ...momento) : all }
  # Tarifas válidas em +momento+.
  scope :vigentes_em, ->(momento) { where(vigente_desde: ..momento).nao_encerradas_em(momento) }

  # Busca a tarifa vigente de um tipo de refeição.
  #
  # Argumentos:: +tipo+ (TipoRefeicao ou String): o tipo ou o seu código (ex.: TipoRefeicao::ALMOCO).
  #              +momento+ (Time): instante da consulta; padrão Time.current.
  # Retorno:: a TarifaRefeicao vigente mais recente, ou nil se o tipo não existe ou não há tarifa.
  # Efeitos colaterais:: consulta o banco.
  def self.vigente_para(tipo, momento = Time.current)
    tipo = TipoRefeicao.find_by(codigo: tipo) unless tipo.is_a?(TipoRefeicao)
    return nil if tipo.nil?

    where(tipo_refeicao: tipo).vigentes_em(momento).order(vigente_desde: :desc).first
  end

  # Indica se a tarifa vale num instante.
  #
  # Argumentos:: +momento+ (Time).
  # Retorno:: true se +momento+ está entre o início (inclusive) e o fim (exclusive); false caso contrário.
  # Efeitos colaterais:: nenhum.
  def vigente_em?(momento)
    vigente_desde <= momento && (vigente_ate.nil? || vigente_ate > momento)
  end

  private

  # Validação: o fim da vigência, quando informado, deve ser posterior ao início.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +vigente_ate+ quando inválido.
  def vigente_ate_posterior_ao_inicio
    return if vigente_ate.nil? || vigente_desde.nil? || vigente_ate > vigente_desde

    errors.add(:vigente_ate, "deve ser posterior ao início da vigência")
  end

  # Validação: não pode haver outra tarifa do mesmo tipo com vigência que cruze a desta.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta o banco; adiciona MSG_SOBREPOSICAO em +base+ quando há cruzamento.
  def sem_sobreposicao_de_vigencia
    return if tipo_refeicao_id.nil? || vigente_desde.nil?

    errors.add(:base, MSG_SOBREPOSICAO) if tarifas_sobrepostas.exists?
  end

  # Monta a consulta das outras tarifas do mesmo tipo cuja vigência cruza a desta.
  #
  # Argumentos:: nenhum.
  # Retorno:: ActiveRecord::Relation de TarifaRefeicao (não executada).
  # Efeitos colaterais:: nenhum.
  def tarifas_sobrepostas
    TarifaRefeicao.where(tipo_refeicao_id: tipo_refeicao_id).where.not(id: id)
                  .nao_encerradas_em(vigente_desde).iniciadas_antes_de(vigente_ate)
  end
end
