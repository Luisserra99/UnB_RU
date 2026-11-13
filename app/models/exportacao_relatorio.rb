# Registro de cada exportação de relatório (F09, F11 e F12): quem emitiu, quando,
# em qual formato e com quais filtros. Guarda os metadados, não o arquivo em si.
class ExportacaoRelatorio < ApplicationRecord
  FORMATO_SHA256 = /\A[0-9a-f]{64}\z/i

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

  # O prefixo evita conflito com o `falhou` do enum de status.
  enum :assinatura_status, {
    nao_aplicavel: "nao_aplicavel",
    pendente: "pendente",
    assinada: "assinada",
    falhou: "falhou"
  }, prefix: true, validate: true

  validates :solicitada_em, presence: true
  validates :quantidade_registros,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true
  validates :total_debitos, :total_creditos,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true
  validates :arquivo_sha256, format: { with: FORMATO_SHA256 }, allow_nil: true

  validate :validar_objetos_json
  validate :validar_datas
  validate :validar_arquivo
  validate :validar_conclusao
  validate :validar_assinatura

  private

  def validar_objetos_json
    errors.add(:filtros, "deve ser um objeto JSON") unless filtros.is_a?(Hash)
    errors.add(:agrupamentos, "deve ser um objeto JSON") unless agrupamentos.is_a?(Hash)
  end

  def validar_datas
    return if solicitada_em.nil? || emitida_em.nil?

    errors.add(:emitida_em, "não pode ser anterior à solicitação") if emitida_em < solicitada_em
  end

  def validar_arquivo
    tem_chave = arquivo_chave.present?
    tem_hash = arquivo_sha256.present?

    errors.add(:base, "Arquivo e SHA-256 devem ser informados juntos") if tem_chave != tem_hash
    errors.add(:base, "Arquivo só pode ser registrado após conclusão") if !concluida? && (tem_chave || tem_hash)
  end

  # Uma exportação concluída tem data de emissão, arquivo e quantidade de registros.
  # Fora desse estado não existe documento emitido, então não há data de emissão.
  def validar_conclusao
    if concluida?
      errors.add(:emitida_em, "é obrigatória em exportação concluída") if emitida_em.nil?
      errors.add(:arquivo_chave, "é obrigatória em exportação concluída") if arquivo_chave.blank?
      errors.add(:quantidade_registros, "é obrigatória em exportação concluída") if quantidade_registros.nil?
    elsif emitida_em.present?
      errors.add(:emitida_em, "só pode ser registrada após conclusão")
    end
  end

  # Não se declara um documento como assinado antes de ele existir.
  def validar_assinatura
    return unless assinatura_status_assinada? && !concluida?

    errors.add(:assinatura_status, "só pode ser assinada após conclusão")
  end
end
