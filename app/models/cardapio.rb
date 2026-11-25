# Cardápio publicado para um serviço de refeição numa data (F10), com uma opção por dieta.
# A data precisa cair no dia da semana do serviço.
class Cardapio < ApplicationRecord
  belongs_to :servico_refeicao
  has_many :opcoes, class_name: "OpcaoCardapio", dependent: :destroy

  validates :data_referencia, presence: true, uniqueness: { scope: :servico_refeicao_id }
  validate :data_no_dia_do_servico

  # Busca a opção de uma dieta entre as opções já carregadas (aproveita o +includes+ do controller).
  #
  # Argumentos:: +dieta+ (String): código da dieta (ex.: OpcaoCardapio::PADRAO).
  # Retorno:: a OpcaoCardapio da dieta; nil quando o cardápio não tem opção para ela.
  # Efeitos colaterais:: carrega as opções do banco se ainda não estiverem carregadas.
  def opcao_de(dieta)
    opcoes.find { |opcao| opcao.dieta == dieta }
  end

  private

  # Valida que a data de referência cai no dia da semana do serviço.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +data_referencia+ quando o dia da semana difere; não valida
  #                      sem data ou sem serviço.
  def data_no_dia_do_servico
    return if data_referencia.blank? || servico_refeicao.nil?
    return if data_referencia.wday == servico_refeicao.dia_semana

    errors.add(:data_referencia, "deve cair no dia da semana do serviço")
  end
end
