# Sessão autenticada na aplicação de controle.
# O token fica só no cookie (criptografado) do navegador; no banco guardamos o SHA-256.
class SessaoAutenticacao < ApplicationRecord
  DURACAO = 8.hours

  belongs_to :usuario

  validates :token_digest, presence: true, uniqueness: true
  validates :autenticada_em, :expira_em, presence: true

  scope :ativas, -> { where(encerrada_em: nil).where("expira_em > ?", Time.current) }

  # Cria a sessão e devolve [sessao, token]. O token em texto puro não é salvo.
  def self.iniciar!(usuario, duracao: DURACAO)
    token = SecureRandom.urlsafe_base64(32)
    agora = Time.current
    sessao = create!(
      usuario: usuario,
      token_digest: digest(token),
      autenticada_em: agora,
      expira_em: agora + duracao,
      ponto_acesso_pendente: true
    )
    [sessao, token]
  end

  def self.localizar(token)
    return nil if token.blank?

    find_by(token_digest: digest(token))
  end

  def self.digest(token)
    OpenSSL::Digest::SHA256.hexdigest(token.to_s)
  end

  def encerrada?
    encerrada_em.present?
  end

  def expirada?
    !encerrada? && expira_em <= Time.current
  end

  def ativa?
    !encerrada? && !expirada? && usuario.ativo?
  end

  def encerrar!
    update!(encerrada_em: Time.current) unless encerrada?
  end
end
