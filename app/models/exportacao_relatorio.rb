
class ExportacaoRelatorio < ApplicationRecord
  belongs_to :usuario

  enum :tipo, {
    extrato_estudante: "extrato_estudante",
    operacao_global: "operacao_global"
  }, validate: true

  enum :formato, {
    pdf: "pdf",
    csv: "csv"
  }, validate: true

  enum :status, {
    processando: "processando",
    concluida: "concluida",
    sem_dados: "sem_dados",
    falhou: "falhou"
  }, validate: true

  enum :assinatura_status, {
    nao_aplicavel: "nao_aplicavel",
    pendente: "pendente",
    assinada: "assinada",
    falhou: "falhou"
  }, prefix:true, validate: true

  validates :tipo, :formato, :status, :assinatura_status,
            presence: true

  validates :solicitada_em, presence: true

  validates :quantidade_registros,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            },
            allow_nil: true

  validates :total_debitos, :total_creditos,
            numericality: {
              greater_than_or_equal_to: 0
            },
            allow_nil: true

  validates :arquivo_sha256,
            format: { with: /\A[0-9a-f]{64}\z/i },
            allow_nil: true

  validate :validar_objetos_json
  validate :validar_datas
  validate :validar_arquivo

  private

  def validar_objetos_json
    unless filtros.is_a?(Hash)
      errors.add(:filtros, "deve ser um objeto JSON")
    end

    unless agrupamentos.is_a?(Hash)
      errors.add(:agrupamentos, "deve ser um objeto JSON")
    end
  end

  def validar_datas
    return if solicitada_em.nil? || emitida_em.nil?

    if emitida_em < solicitada_em
      errors.add(:emitida_em, "não pode ser anterior à solicitação")
    end
  end

  def validar_arquivo
    tem_chave = arquivo_chave.present?
    tem_hash = arquivo_sha256.present?

    if tem_chave != tem_hash
      errors.add(:base, "Arquivo e SHA-256 devem ser informados juntos")
    end

    if !concluida? && (tem_chave || tem_hash)
      errors.add(:base, "Arquivo só pode ser registrado após conclusão")
    end
  end
end
