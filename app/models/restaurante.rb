class Restaurante < ApplicationRecord
  MSG_NOME_OBRIGATORIO = "Nome do restaurante é obrigatório".freeze
  MSG_NOME_REPETIDO = "Já existe um restaurante com esse nome".freeze
  MSG_UNIDADE_OBRIGATORIA = "Unidade gestora é obrigatória".freeze
  MSG_PISOS = "O restaurante deve ter ao menos 1 piso".freeze
  MSG_CAPACIDADE = "A capacidade deve ser maior que zero".freeze
  MSG_POSSUI_CATRACAS = "Remova as catracas do restaurante antes de excluí-lo".freeze
  MSG_REDUZIR_PISOS = "Não é possível remover pisos: informe %<atual>d ou mais".freeze

  # No cadastro cria os pisos; na edição só pode aumentar (pisos existentes nunca são removidos).
  attr_writer :quantidade_pisos

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
  validates :nome, uniqueness: { message: MSG_NOME_REPETIDO, case_sensitive: false }, allow_blank: true
  validates :numero, numericality: { only_integer: true, greater_than: 0 },
                     uniqueness: { scope: :unidade_gestora_id }, if: :unidade_gestora
  validates :capacidade_refeicoes_hora, numericality: { only_integer: true, greater_than: 0, message: MSG_CAPACIDADE }
  validates :quantidade_pisos, numericality: { only_integer: true, greater_than: 0, message: MSG_PISOS }, on: :create
  validate :impedir_reducao_de_pisos, on: :update

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

  # Atualiza os dados e acrescenta os pisos que faltarem para chegar à nova quantidade.
  def atualizar_com_pisos(atributos)
    transaction do
      assign_attributes(atributos)
      raise ActiveRecord::Rollback unless save

      ultimo = pisos.maximum(:numero).to_i
      (quantidade_pisos.to_i - pisos.count).times { |i| pisos.create!(numero: ultimo + i + 1) }
      true
    end || false
  end

  # Sem valor informado, a quantidade é a de pisos já gravados.
  def quantidade_pisos
    return @quantidade_pisos if @quantidade_pisos.present? || new_record?

    pisos.count
  end

  private

  def impedir_reducao_de_pisos
    return if @quantidade_pisos.blank?

    quantidade = Integer(@quantidade_pisos.to_s, exception: false)
    atual = pisos.count
    if quantidade.nil?
      errors.add(:quantidade_pisos, MSG_PISOS)
    elsif quantidade < atual
      errors.add(:quantidade_pisos, format(MSG_REDUZIR_PISOS, atual: atual))
    end
  end

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
