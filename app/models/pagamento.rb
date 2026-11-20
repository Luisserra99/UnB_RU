# Tentativa de pagamento de uma recarga (F02), via PIX ou cartão de crédito.
# A confirmação é a única forma de creditar saldo, e acontece no máximo uma vez por recarga.
class Pagamento < ApplicationRecord
  # Prazo do código PIX (RN02.4).
  VALIDADE_PIX = 10.minutes
  # Nome de cada método de pagamento para exibição.
  NOMES_METODOS = { "pix" => "PIX", "cartao_credito" => "Cartão de Crédito" }.freeze

  enum :metodo, { pix: "pix", cartao_credito: "cartao_credito" }, validate: true
  enum :status, { pendente: "pendente", confirmado: "confirmado", recusado: "recusado", expirado: "expirado" },
       validate: true

  belongs_to :recarga, inverse_of: :pagamentos

  validates :valor_solicitado, presence: true, numericality: { greater_than: 0 }
  validates :expira_em, :pix_copia_cola, presence: true, if: :pix?
  validates :referencia_provedor, uniqueness: true, allow_nil: true
  validates :confirmado_em, :valor_confirmado, presence: true, if: :confirmado?

  # Pagamentos pendentes cujo prazo terminou até +momento+ (padrão: agora).
  scope :vencidos, ->(momento = Time.current) { pendente.where(expira_em: ..momento) }

  # Traduz o código de um método de pagamento para exibição.
  #
  # Argumentos:: +metodo+ (String ou Symbol): ex.: "pix" ou :cartao_credito.
  # Retorno:: String com o nome ("PIX", "Cartão de Crédito"); um código desconhecido volta como texto.
  # Efeitos colaterais:: nenhum.
  def self.nome_metodo(metodo)
    NOMES_METODOS.fetch(metodo.to_s, metodo.to_s)
  end

  # Nome do método deste pagamento para exibição.
  #
  # Argumentos:: nenhum.
  # Retorno:: String, ex.: "PIX".
  # Efeitos colaterais:: nenhum.
  def nome_metodo
    self.class.nome_metodo(metodo)
  end

  # Indica se é um PIX pendente cujo prazo de 10 minutos acabou (RN02.4). Aos 10 minutos exatos já
  # está vencido.
  #
  # Argumentos:: +momento+ (Time): instante da verificação; padrão Time.current.
  # Retorno:: true se pendente e com prazo encerrado; false caso contrário (inclusive cartão).
  # Efeitos colaterais:: nenhum.
  def vencido?(momento = Time.current)
    pendente? && expira_em.present? && momento >= expira_em
  end

  # Confirma o pagamento e credita o saldo (RN02.2). É idempotente; se o PIX já venceu, expira em
  # vez de creditar.
  #
  # Argumentos:: +em+ (Time): momento da confirmação; padrão Time.current.
  # Retorno:: o próprio pagamento.
  # Efeitos colaterais:: numa transação com lock: se pendente e no prazo, grava o pagamento como
  #                      confirmado, confirma a recarga e cria o crédito no saldo; se vencido, expira
  #                      o pagamento e a recarga; nos demais casos, não altera nada.
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

  # Registra a recusa do pagamento pela operadora.
  #
  # Argumentos:: +em+ (Time): momento do retorno (aceito para seguir a interface de ProcessarRetorno).
  # Retorno:: o próprio pagamento.
  # Efeitos colaterais:: se pendente, grava o status recusado; a recarga continua pendente e
  #                      pode receber nova tentativa. Pagamentos não pendentes não mudam.
  def recusar!(em: Time.current)
    transaction do
      lock!
      update!(status: :recusado) if pendente?
    end
    self
  end

  # Expira o pagamento pendente.
  #
  # Argumentos:: +em+ (Time): momento da expiração (aceito para seguir a interface de ProcessarRetorno).
  # Retorno:: o próprio pagamento.
  # Efeitos colaterais:: se pendente, grava o status expirado; se for PIX, expira também a recarga
  #                      pendente. Pagamentos não pendentes não mudam.
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

  # Expira o pagamento só se o prazo já terminou.
  #
  # Argumentos:: +em+ (Time): momento da verificação; padrão Time.current.
  # Retorno:: o próprio pagamento.
  # Efeitos colaterais:: os de #expirar!, quando vencido; nenhum caso contrário.
  def expirar_se_vencido!(em: Time.current)
    expirar!(em: em) if vencido?(em)
    self
  end

  # Prazo do PIX em minutos, para exibição.
  #
  # Argumentos:: nenhum.
  # Retorno:: Integer (10).
  # Efeitos colaterais:: nenhum.
  def minutos_de_validade
    (VALIDADE_PIX / 60).to_i
  end
end
