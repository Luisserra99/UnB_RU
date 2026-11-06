class Catraca < ApplicationRecord
  MSG_IDENTIFICACAO_OBRIGATORIA = "Identificação da catraca é obrigatória".freeze
  MSG_IDENTIFICACAO_REPETIDA = "Já existe uma catraca com essa identificação neste restaurante".freeze
  MSG_PISO_INEXISTENTE = "Piso inexistente para este restaurante".freeze
  MSG_EM_OPERACAO = "Não é possível remover uma catraca em operação".freeze

  belongs_to :piso, optional: true
  has_one :restaurante, through: :piso

  normalizes :identificacao, with: ->(valor) { valor.squish }

  before_destroy :impedir_remocao_em_operacao

  validates :identificacao, presence: { message: MSG_IDENTIFICACAO_OBRIGATORIA }
  validates :piso, presence: { message: MSG_PISO_INEXISTENTE }
  validate :identificacao_unica_no_restaurante

  scope :disponiveis, -> { where(ativa: true) }

  # Ponto preparado para a F05: deve retornar true quando houver uma
  # ConfiguracaoPontoAcesso vigente (finalizada_em nula) de uma sessão válida com esta catraca.
  # Enquanto a F05 não existir, nenhuma catraca é considerada em operação.
  def em_operacao?
    false
  end

  private

  # Um índice não alcança o restaurante através do piso, por isso a regra fica aqui.
  def identificacao_unica_no_restaurante
    return if piso.nil? || identificacao.blank?

    repetida = Catraca.joins(:piso)
                      .where(pisos: { restaurante_id: piso.restaurante_id }, identificacao: identificacao)
                      .where.not(id: id)
                      .exists?
    errors.add(:identificacao, MSG_IDENTIFICACAO_REPETIDA) if repetida
  end

  def impedir_remocao_em_operacao
    return unless em_operacao?

    errors.add(:base, MSG_EM_OPERACAO)
    throw :abort
  end
end
