# Sessão autenticada na aplicação de controle.
# O token fica só no cookie (criptografado) do navegador; no banco guardamos o SHA-256.
class SessaoAutenticacao < ApplicationRecord
  # Tempo de vida de uma sessão (RN04.6).
  DURACAO = 8.hours

  has_many :configuracoes_ponto_acesso, class_name: "ConfiguracaoPontoAcesso", dependent: :restrict_with_error

  belongs_to :usuario

  validates :token_digest, presence: true, uniqueness: true
  validates :autenticada_em, :expira_em, presence: true

  scope :ativas, -> { where(encerrada_em: nil).where("expira_em > ?", Time.current) }

  # Cria a sessão do usuário com um token novo. O token em texto puro não é salvo.
  #
  # Argumentos:: +usuario+ (Usuario): dono da sessão; +duracao+ (ActiveSupport::Duration, opcional):
  #              tempo de vida, DURACAO por padrão.
  # Retorno:: Array <tt>[sessao, token]</tt>: a SessaoAutenticacao criada e o token que vai para o
  #           cookie.
  # Efeitos colaterais:: grava a sessão no banco com o digest do token e +ponto_acesso_pendente+
  #                      verdadeiro. Lança ActiveRecord::RecordInvalid se a sessão for inválida.
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
    [ sessao, token ]
  end

  # Busca a sessão pelo token guardado no navegador.
  #
  # Argumentos:: +token+ (String ou nil): token em texto puro.
  # Retorno:: SessaoAutenticacao com esse token (em qualquer estado); nil com token em branco ou
  #           desconhecido.
  # Efeitos colaterais:: consulta o banco.
  def self.localizar(token)
    return nil if token.blank?

    find_by(token_digest: digest(token))
  end

  # Calcula o digest guardado no banco para um token.
  #
  # Argumentos:: +token+ (String): token em texto puro.
  # Retorno:: String com o SHA-256 do token em hexadecimal.
  # Efeitos colaterais:: nenhum.
  def self.digest(token)
    OpenSSL::Digest::SHA256.hexdigest(token.to_s)
  end

  # Indica se a sessão foi encerrada por logout ou novo login.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se +encerrada_em+ está preenchido; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def encerrada?
    encerrada_em.present?
  end

  # Indica se a sessão venceu sem ter sido encerrada.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se não foi encerrada e +expira_em+ já passou; false caso contrário.
  # Efeitos colaterais:: nenhum.
  def expirada?
    !encerrada? && expira_em <= Time.current
  end

  # Indica se a sessão ainda dá acesso.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se não foi encerrada, não expirou e o usuário está ativo; false caso contrário.
  # Efeitos colaterais:: carrega o usuário do banco.
  def ativa?
    !encerrada? && !expirada? && usuario.ativo?
  end

  # Ponto de acesso (configuração de restaurante e catraca) em uso nesta sessão (F05).
  #
  # Argumentos:: nenhum.
  # Retorno:: ConfiguracaoPontoAcesso aberta confirmada mais recentemente; nil se a sessão não está
  #           ativa ou não tem ponto aberto.
  # Efeitos colaterais:: consulta o banco.
  def ponto_acesso_atual
    return nil unless ativa?
    configuracoes_ponto_acesso.abertas.order(confirmada_em: :desc).first
  end

  # Encerra a sessão e os pontos de acesso abertos nela.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: com a sessão travada no banco, cancela as liberações pendentes e finaliza
  #                      as configurações de ponto de acesso abertas; marca +encerrada_em+ e
  #                      +ponto_acesso_pendente+ se a sessão ainda não estava encerrada.
  def encerrar!
    with_lock do
      agora = Time.current
      configuracoes_ponto_acesso.abertas.each(&:cancelar_liberacoes!)
      configuracoes_ponto_acesso.abertas.update_all(finalizada_em: agora, updated_at: agora)
      update!(encerrada_em: agora, ponto_acesso_pendente: true) unless encerrada?
    end
  end
end
