# Tentativa de pagamento de uma recarga (F02), via PIX ou cartão de crédito.
# A confirmação é a única forma de creditar saldo, e acontece no máximo uma vez por recarga.
class Pagamento < ApplicationRecord
  VALIDADE_PIX = 10.minutes
  NOMES_METODOS = { "pix" => "PIX", "cartao_credito" => "Cartão de Crédito" }.freeze

  enum :metodo, { pix: "pix", cartao_credito: "cartao_credito" }, validate: true
  enum :status, { pendente: "pendente", confirmado: "confirmado", recusado: "recusado", expirado: "expirado" },
       validate: true

  belongs_to :recarga, inverse_of: :pagamentos

  validates :valor_solicitado, presence: true, numericality: { greater_than: 0 }
  validates :expira_em, :pix_copia_cola, presence: true, if: :pix?
  validates :referencia_provedor, uniqueness: true, allow_nil: true
  validates :confirmado_em, :valor_confirmado, presence: true, if: :confirmado?

  scope :vencidos, ->(momento = Time.current) { pendente.where(expira_em: ..momento) }

  def self.nome_metodo(metodo)
    NOMES_METODOS.fetch(metodo.to_s, metodo.to_s)
  end

  def nome_metodo
    self.class.nome_metodo(metodo)
  end

  # PIX pendente cujo prazo de 10 minutos acabou (RN02.4). Aos 10 minutos exatos já está vencido.
  def vencido?(momento = Time.current)
    pendente? && expira_em.present? && momento >= expira_em
  end

  # Confirma o pagamento e credita o saldo. É idempotente; se o PIX já venceu, expira em vez de creditar.
  def confirmar!(em: Time.current)
    transaction do
      lock!
      next if confirmado? || !pendente?
      next expirar!(em: em) if vencido?(em)

      update!(status: :confirmado, confirmado_em: em, valor_confirmado: valor_solicitado)
      recarga.confirmar!(em: em)
    end
    self
  end

  def recusar!(em: Time.current)
    transaction do
      lock!
      update!(status: :recusado) if pendente?
    end
    self
  end

  def expirar!(em: Time.current)
    transaction do
      lock!
      if pendente?
        update!(status: :expirado)
        recarga.update!(status: :expirada) if pix? && recarga.pendente?
      end
    end
    self
  end

  def expirar_se_vencido!(em: Time.current)
    expirar!(em: em) if vencido?(em)
    self
  end

  def minutos_de_validade
    (VALIDADE_PIX / 60).to_i
  end
end
