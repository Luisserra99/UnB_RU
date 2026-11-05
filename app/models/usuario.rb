class Usuario < ApplicationRecord
  SENHA_TAMANHO_MINIMO = 8
  FORMATO_EMAIL = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  has_secure_password

  has_one :estudante, dependent: :destroy
  has_many :usuario_papeis, dependent: :destroy
  has_many :papeis, through: :usuario_papeis
  has_many :sessoes, class_name: "SessaoAutenticacao", dependent: :destroy

  normalizes :identificacao, with: ->(valor) { valor.strip }
  normalizes :email, with: ->(valor) { valor.strip.downcase }
  normalizes :nome, with: ->(valor) { valor.squish }

  validates :nome, presence: true
  validates :identificacao, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: FORMATO_EMAIL }
  validates :password, length: { minimum: SENHA_TAMANHO_MINIMO }, allow_nil: true

  scope :ativos, -> { where(ativo: true) }

  # Valida identificação e senha sem revelar qual das duas está errada.
  # Retorna o usuário somente se as credenciais conferem e a conta está ativa.
  def self.autenticar(identificacao, senha)
    return nil if identificacao.blank? || senha.blank?

    usuario = authenticate_by(identificacao: identificacao.to_s.strip, password: senha)
    usuario if usuario&.ativo?
  end

  def possui_papel?(codigo)
    papeis.exists?(codigo: codigo)
  end

  def atribuir_papel!(codigo)
    papel = Papel.find_by!(codigo: codigo)
    papeis << papel unless papeis.include?(papel)
  end

  def estudante?
    possui_papel?(Papel::ESTUDANTE)
  end

  def funcionario?
    possui_papel?(Papel::FUNCIONARIO)
  end

  def administrador?
    possui_papel?(Papel::ADMINISTRADOR)
  end

  # Funcionários e administradores podem usar a aplicação de controle.
  def pode_acessar_controle?
    papeis.exists?(codigo: Papel::CODIGOS_CONTROLE)
  end
end
