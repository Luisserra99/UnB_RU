# Catraca instalada num piso de um restaurante (F08). A identificação é única dentro do restaurante,
# e a catraca não pode ser removida enquanto houver um ponto de acesso operando nela.
class Catraca < ApplicationRecord
  # Erro quando a identificação fica em branco.
  MSG_IDENTIFICACAO_OBRIGATORIA = "Identificação da catraca é obrigatória".freeze
  # Erro quando outra catraca do mesmo restaurante já usa a identificação.
  MSG_IDENTIFICACAO_REPETIDA = "Já existe uma catraca com essa identificação neste restaurante".freeze
  # Erro quando o piso informado não existe no restaurante.
  MSG_PISO_INEXISTENTE = "Piso inexistente para este restaurante".freeze
  # Erro ao tentar remover uma catraca com ponto de acesso em sessão válida.
  MSG_EM_OPERACAO = "Não é possível remover uma catraca em operação".freeze

  has_many :configuracoes_ponto_acesso, class_name: "ConfiguracaoPontoAcesso", dependent: :restrict_with_error

  belongs_to :piso, optional: true
  has_one :restaurante, through: :piso

  normalizes :identificacao, with: ->(valor) { valor.squish }

  before_destroy :impedir_remocao_em_operacao, prepend: true

  validates :identificacao, presence: { message: MSG_IDENTIFICACAO_OBRIGATORIA }
  validates :piso, presence: { message: MSG_PISO_INEXISTENTE }
  validate :identificacao_unica_no_restaurante

  # Catracas ativas, que podem ser selecionadas como ponto de acesso.
  scope :disponiveis, -> { where(ativa: true) }
  # Catracas instaladas em qualquer piso do restaurante +restaurante_id+.
  scope :do_restaurante, ->(restaurante_id) { joins(:piso).where(pisos: { restaurante_id: restaurante_id }) }

  # Indica se há um ponto de acesso em sessão válida usando a catraca. Mesmo durante a
  # reconfiguração, o ponto antigo é preservado até a nova confirmação.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se a catraca está em operação; false caso contrário.
  # Efeitos colaterais:: consulta o banco.
  def em_operacao?
    configuracoes_ponto_acesso.em_sessoes_validas.exists?
  end

  private

  # Valida que nenhuma outra catraca do restaurante usa a mesma identificação, em qualquer piso.
  # Um índice não alcança o restaurante através do piso, por isso a regra fica aqui.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta o banco; adiciona erro em +identificacao+ quando ela se repete.
  #                      Não valida sem piso ou sem identificação (já validados por presença).
  def identificacao_unica_no_restaurante
    return if piso.nil? || identificacao.blank?

    errors.add(:identificacao, MSG_IDENTIFICACAO_REPETIDA) if identificacao_repetida?
  end

  # Indica se outra catraca do mesmo restaurante já tem esta identificação.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se existe outra catraca com a identificação; false caso contrário.
  # Efeitos colaterais:: consulta o banco.
  def identificacao_repetida?
    Catraca.do_restaurante(piso.restaurante_id).where(identificacao: identificacao).where.not(id: id).exists?
  end

  # Callback +before_destroy+ que impede remover a catraca em operação.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: quando em operação, adiciona erro em +base+ e interrompe a remoção (+throw :abort+).
  def impedir_remocao_em_operacao
    return unless em_operacao?

    errors.add(:base, MSG_EM_OPERACAO)
    throw :abort
  end
end
