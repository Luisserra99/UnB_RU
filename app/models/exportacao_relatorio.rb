# Registro de cada exportação de relatório (F09, F11 e F12): quem emitiu, quando,
# em qual formato e com quais filtros. Guarda os metadados, não o arquivo em si.
class ExportacaoRelatorio < ApplicationRecord
  # Formato do SHA-256 do arquivo: 64 dígitos hexadecimais.
  FORMATO_SHA256 = /\A[0-9a-f]{64}\z/i
  # Atributos que toda exportação concluída precisa ter.
  CAMPOS_DA_CONCLUSAO = %i[emitida_em arquivo_chave quantidade_registros].freeze

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
  validate :validar_emissao_sem_conclusao
  validate :validar_assinatura

  private

  # Valida que os filtros e os agrupamentos são objetos JSON (Hash), e não texto ou lista.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +filtros+ e/ou +agrupamentos+.
  def validar_objetos_json
    errors.add(:filtros, "deve ser um objeto JSON") unless filtros.is_a?(Hash)
    errors.add(:agrupamentos, "deve ser um objeto JSON") unless agrupamentos.is_a?(Hash)
  end

  # Valida que a emissão não aconteceu antes da solicitação.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +emitida_em+.
  def validar_datas
    return if solicitada_em.nil? || emitida_em.nil?

    errors.add(:emitida_em, "não pode ser anterior à solicitação") if emitida_em < solicitada_em
  end

  # Valida que a chave do arquivo e o SHA-256 andam juntos e só existem em exportação concluída.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +base+.
  def validar_arquivo
    tem_chave = arquivo_chave.present?
    tem_hash = arquivo_sha256.present?

    errors.add(:base, "Arquivo e SHA-256 devem ser informados juntos") if tem_chave != tem_hash
    errors.add(:base, "Arquivo só pode ser registrado após conclusão") if !concluida? && (tem_chave || tem_hash)
  end

  # Valida que a exportação concluída tem data de emissão, arquivo e quantidade de registros.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em cada atributo de CAMPOS_DA_CONCLUSAO que estiver vazio.
  def validar_conclusao
    return unless concluida?

    CAMPOS_DA_CONCLUSAO.each do |campo|
      errors.add(campo, "é obrigatória em exportação concluída") if self[campo].blank?
    end
  end

  # Valida que não há data de emissão fora da conclusão: sem documento emitido, não há emissão.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +emitida_em+.
  def validar_emissao_sem_conclusao
    return if concluida? || emitida_em.blank?

    errors.add(:emitida_em, "só pode ser registrada após conclusão")
  end

  # Valida que o documento só é declarado como assinado depois de existir.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +assinatura_status+.
  def validar_assinatura
    return unless assinatura_status_assinada? && !concluida?

    errors.add(:assinatura_status, "só pode ser assinada após conclusão")
  end
end
