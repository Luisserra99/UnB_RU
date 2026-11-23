# Preserva a leitura, a liberação e o resultado da passagem no ponto de origem (F06).
class RegistroAcesso < ApplicationRecord
  # Prazo inclusivo entre a liberação e a passagem física pela catraca.
  LIMITE_PASSAGEM = 5.seconds
  enum :estado, { recusado: "recusado", liberado: "liberado", realizado: "realizado", cancelado: "cancelado" }, validate: true
  belongs_to :configuracao_ponto_acesso
  belongs_to :estudante, optional: true
  belongs_to :servico_refeicao, optional: true
  belongs_to :tarifa_refeicao, optional: true
  has_one :movimentacao_saldo, dependent: :restrict_with_error
  delegate :restaurante, :catraca, :funcionario, to: :configuracao_ponto_acesso

  validates :referencia_evento, presence: true, uniqueness: true, length: { maximum: 64 }
  validates :identificacao_lida, length: { maximum: 100 }
  validates :lido_em, :mensagem, presence: true
  validates :valor_previsto, numericality: { greater_than: 0 }, allow_nil: true
  validate :coerencia_da_passagem

  # Calcula o último instante permitido para a passagem.
  #
  # Argumentos:: nenhum.
  # Retorno:: ActiveSupport::TimeWithZone com o limite; nil se a catraca não foi liberada.
  # Efeitos colaterais:: nenhum.
  def limite_em
    liberado_em && liberado_em + LIMITE_PASSAGEM
  end

  # Informa se houve liberação física, inclusive em um acesso já concluído ou cancelado.
  #
  # Argumentos:: nenhum.
  # Retorno:: true quando há horário de liberação; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def catraca_liberada?
    liberado_em.present?
  end

  # Informa se a passagem física foi registrada.
  #
  # Argumentos:: nenhum.
  # Retorno:: true quando há horário de passagem; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def acesso_realizado?
    passagem_em.present?
  end

  private

  # Confere a presença dos dados da passagem e o prazo de liberação.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erros em +base+ e/ou +passagem_em+ para dados incoerentes.
  def coerencia_da_passagem
    validar_dados_da_passagem
    validar_prazo_da_passagem
  end

  # Exige estudante e todos os horários de um acesso realizado.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +base+ quando um acesso realizado está incompleto.
  def validar_dados_da_passagem
    if realizado? && dados_da_passagem_incompletos?
      errors.add(:base, "Passagem exige estudante, liberação e bloqueio")
    end
  end

  # Detecta dados obrigatórios ausentes na confirmação de uma passagem.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se algum dado está ausente; false se todos estão presentes.
  # Efeitos colaterais:: consulta o estudante associado, sem gravar alterações.
  def dados_da_passagem_incompletos?
    estudante.nil? || liberado_em.nil? || passagem_em.nil? || bloqueado_em.nil?
  end

  # Valida se a passagem ocorreu dentro dos cinco segundos, inclusive nos limites.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +passagem_em+ se não há liberação ou o prazo é inválido.
  def validar_prazo_da_passagem
    if passagem_em && fora_do_prazo?
      errors.add(:passagem_em, "deve ocorrer em até 5 segundos após a liberação")
    end
  end

  # Compara a passagem informada com a janela de liberação.
  #
  # Argumentos:: nenhum; requer +passagem_em+ preenchido.
  # Retorno:: true se não há liberação ou a passagem está fora da janela; false se está dentro.
  # Efeitos colaterais:: nenhum.
  def fora_do_prazo?
    liberado_em.nil? || passagem_em < liberado_em || passagem_em > limite_em
  end
end
