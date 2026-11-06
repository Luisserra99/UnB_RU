class Restaurante < ApplicationRecord
  MSG_NOME_OBRIGATORIO = "Nome do restaurante é obrigatório".freeze
  MSG_NOME_REPETIDO = "Já existe um restaurante com esse nome".freeze
  MSG_UNIDADE_OBRIGATORIA = "Unidade gestora é obrigatória".freeze
  MSG_PISOS = "O restaurante deve ter ao menos 1 piso".freeze
  MSG_CAPACIDADE = "A capacidade deve ser maior que zero".freeze
  MSG_POSSUI_CATRACAS = "Remova as catracas do restaurante antes de excluí-lo".freeze

  # Informado só no cadastro; depois a quantidade é obtida pelos registros de Piso.
  attr_accessor :quantidade_pisos

  # Precisa vir antes de `has_many :pisos`, senão os pisos são removidos antes da checagem.
  before_destroy :impedir_remocao_com_catracas

  belongs_to :unidade_gestora, optional: true
  has_many :pisos, dependent: :destroy
  has_many :catracas, through: :pisos
  has_many :servicos_refeicao, class_name: "ServicoRefeicao", dependent: :destroy

  normalizes :nome, with: ->(valor) { valor.squish }

  before_validation :atribuir_numero, on: :create

  validates :unidade_gestora, presence: { message: MSG_UNIDADE_OBRIGATORIA }
  validates :nome, presence: { message: MSG_NOME_OBRIGATORIO }
  validates :nome, uniqueness: { message: MSG_NOME_REPETIDO }, allow_blank: true
  validates :numero, numericality: { only_integer: true, greater_than: 0 },
                     uniqueness: { scope: :unidade_gestora_id }, if: :unidade_gestora
  validates :capacidade_refeicoes_hora, numericality: { only_integer: true, greater_than: 0, message: MSG_CAPACIDADE }
  validates :quantidade_pisos, numericality: { only_integer: true, greater_than: 0, message: MSG_PISOS }, on: :create

  scope :ativos, -> { where(ativo: true) }
  scope :ordenados, -> { order(:unidade_gestora_id, :numero) }

  # Cria o restaurante e seus pisos numa única transação: se algo falhar, nada é gravado.
  # Lança ActiveRecord::RecordInvalid quando os dados são inválidos.
  def self.criar_com_pisos!(atributos)
    restaurante = new(atributos)
    transaction do
      restaurante.save!
      (1..restaurante.quantidade_pisos.to_i).each { |numero| restaurante.pisos.create!(numero: numero) }
    end
    restaurante
  end

  private

  def atribuir_numero
    return if numero.present? || unidade_gestora.nil?

    self.numero = unidade_gestora.restaurantes.maximum(:numero).to_i + 1
  end

  def impedir_remocao_com_catracas
    return unless catracas.exists?

    errors.add(:base, MSG_POSSUI_CATRACAS)
    throw :abort
  end
end
