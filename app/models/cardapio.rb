class Cardapio < ApplicationRecord
  belongs_to :servico_refeicao
  has_many :opcoes, class_name: "OpcaoCardapio", dependent: :destroy

  validates :data_referencia, presence: true, uniqueness: { scope: :servico_refeicao_id }
  validate :data_no_dia_do_servico

  def opcao_de(dieta)
    opcoes.find { |opcao| opcao.dieta == dieta }
  end

  private

  def data_no_dia_do_servico
    return if data_referencia.blank? || servico_refeicao.nil?
    return if data_referencia.wday == servico_refeicao.dia_semana

    errors.add(:data_referencia, "deve cair no dia da semana do serviço")
  end
end
