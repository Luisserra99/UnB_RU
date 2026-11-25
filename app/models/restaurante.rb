# Restaurante de uma unidade gestora (F08), com seus pisos, catracas e serviços de refeição.
# É numerado dentro da unidade, nasce com ao menos um piso e não perde pisos na edição.
class Restaurante < ApplicationRecord
  # Erro quando o nome fica em branco.
  MSG_NOME_OBRIGATORIO = "Nome do restaurante é obrigatório".freeze
  # Erro quando outro restaurante já usa o nome, sem diferenciar maiúsculas.
  MSG_NOME_REPETIDO = "Já existe um restaurante com esse nome".freeze
  # Erro quando a unidade gestora não é informada.
  MSG_UNIDADE_OBRIGATORIA = "Unidade gestora é obrigatória".freeze
  # Erro quando a quantidade de pisos não é um inteiro positivo.
  MSG_PISOS = "O restaurante deve ter ao menos 1 piso".freeze
  # Erro quando a capacidade de refeições por hora não é um inteiro positivo.
  MSG_CAPACIDADE = "A capacidade deve ser maior que zero".freeze
  # Erro ao tentar remover um restaurante que ainda tem catracas.
  MSG_POSSUI_CATRACAS = "Remova as catracas do restaurante antes de excluí-lo".freeze
  # Erro ao informar menos pisos do que os já gravados; +%<atual>d+ recebe a quantidade atual.
  MSG_REDUZIR_PISOS = "Não é possível remover pisos: informe %<atual>d ou mais".freeze

  # Quantidade de pisos digitada no formulário. No cadastro cria os pisos; na edição só pode
  # aumentar (pisos existentes nunca são removidos).
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

  # Restaurantes em funcionamento, os únicos mostrados ao estudante e ao funcionário.
  scope :ativos, -> { where(ativo: true) }
  # Ordem de apresentação: por unidade gestora e, dentro dela, pelo número.
  scope :ordenados, -> { order(:unidade_gestora_id, :numero) }

  # Cria o restaurante e os pisos numerados de 1 até +quantidade_pisos+, numa única transação.
  #
  # Argumentos:: +atributos+ (Hash ou ActionController::Parameters): dados do restaurante, incluindo
  #              +quantidade_pisos+.
  # Retorno:: o Restaurante gravado.
  # Efeitos colaterais:: grava o restaurante e os pisos; se algo falhar, nada é gravado e a exceção
  #                      ActiveRecord::RecordInvalid é propagada (com o registro inválido em +record+).
  def self.criar_com_pisos!(atributos)
    restaurante = new(atributos)
    transaction do
      restaurante.save!
      (1..restaurante.quantidade_pisos.to_i).each { |numero| restaurante.pisos.create!(numero: numero) }
    end
    restaurante
  end

  # Atualiza os dados e acrescenta os pisos que faltarem para chegar à nova quantidade.
  #
  # Argumentos:: +atributos+ (Hash ou ActionController::Parameters): novos dados do restaurante.
  # Retorno:: true quando a atualização foi gravada; false quando os dados são inválidos (os
  #           motivos ficam em +errors+).
  # Efeitos colaterais:: grava o restaurante e cria os pisos novos numa transação; na falha,
  #                      nada é gravado.
  def atualizar_com_pisos(atributos)
    transaction do
      assign_attributes(atributos)
      raise ActiveRecord::Rollback unless save

      acrescentar_pisos_faltantes
      true
    end || false
  end

  # Informa a quantidade de pisos: a digitada ou, sem valor informado, a de pisos já gravados.
  #
  # Argumentos:: nenhum.
  # Retorno:: o valor digitado (String ou Integer); num registro novo sem valor, o próprio valor
  #           vazio (nil ou ""); num registro gravado sem valor, a contagem de pisos (Integer).
  # Efeitos colaterais:: consulta o banco quando conta os pisos.
  def quantidade_pisos
    return @quantidade_pisos if @quantidade_pisos.present? || new_record?

    pisos.count
  end

  private

  # Cria os pisos que faltam para chegar a +quantidade_pisos+, numerados depois do último existente.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: grava os pisos novos; propaga ActiveRecord::RecordInvalid se algum falhar.
  def acrescentar_pisos_faltantes
    numeros_dos_pisos_faltantes.each { |numero| pisos.create!(numero: numero) }
  end

  # Calcula os números dos pisos que faltam, em sequência depois do maior número já gravado.
  #
  # Argumentos:: nenhum.
  # Retorno:: Range de Integer; vazio quando a quantidade informada não passa da atual.
  # Efeitos colaterais:: consulta os pisos gravados.
  def numeros_dos_pisos_faltantes
    ultimo = pisos.maximum(:numero).to_i
    faltantes = quantidade_pisos.to_i - pisos.count
    (ultimo + 1)..(ultimo + faltantes)
  end

  # Valida, na edição, que a quantidade digitada é um inteiro e não é menor que a de pisos gravados.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta os pisos; adiciona erro em +quantidade_pisos+ quando o valor não é
  #                      inteiro ou reduz os pisos. Não valida quando nada foi digitado.
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

  # Callback +before_validation+ do cadastro que dá ao restaurante o próximo número da unidade.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: consulta o maior número da unidade e preenche +numero+ (sem gravar);
  #                      não faz nada se o número já foi informado ou se não há unidade.
  def atribuir_numero
    return if numero.present? || unidade_gestora.nil?

    self.numero = unidade_gestora.restaurantes.maximum(:numero).to_i + 1
  end

  # Callback +before_destroy+ que impede remover o restaurante enquanto ele tem catracas.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: quando há catracas, adiciona erro em +base+ e interrompe a remoção
  #                      (+throw :abort+), preservando os pisos.
  def impedir_remocao_com_catracas
    return unless catracas.exists?

    errors.add(:base, MSG_POSSUI_CATRACAS)
    throw :abort
  end
end
