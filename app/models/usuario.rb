# Pessoa que acessa o sistema (estudante, funcionário ou administrador), com login por
# identificação e senha (F01, F04). O que cada um pode fazer vem dos papéis (Papel).
class Usuario < ApplicationRecord
  # Tamanho mínimo da senha, em caracteres (RN01.3).
  SENHA_TAMANHO_MINIMO = 8
  # Formato aceito para o email: algo@dominio.extensao, sem espaços.
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

  # Valida identificação e senha sem revelar qual das duas está errada (RN04.2 e RN04.3).
  #
  # Argumentos:: +identificacao+ (String): matrícula ou login; +senha+ (String): senha em texto.
  # Retorno:: o Usuario, se as credenciais conferem e a conta está ativa; nil com campo em branco,
  #           identificação desconhecida, senha errada ou conta inativa.
  # Efeitos colaterais:: consulta o banco (comparação da senha em tempo constante).
  def self.autenticar(identificacao, senha)
    return nil if identificacao.blank? || senha.blank?

    usuario = authenticate_by(identificacao: identificacao.to_s.strip, password: senha)
    usuario if usuario&.ativo?
  end

  # Indica se o usuário tem o papel informado.
  #
  # Argumentos:: +codigo+ (String): código do Papel, ex.: Papel::FUNCIONARIO.
  # Retorno:: true ou false.
  # Efeitos colaterais:: consulta o banco.
  def possui_papel?(codigo)
    papeis.exists?(codigo: codigo)
  end

  # Atribui um papel ao usuário, sem duplicar.
  #
  # Argumentos:: +codigo+ (String): código do Papel, ex.: Papel::ESTUDANTE.
  # Retorno:: a coleção de papéis, quando o papel é novo; nil quando o usuário já o tinha.
  # Efeitos colaterais:: grava um UsuarioPapel no banco quando o papel é novo. Lança
  #                      ActiveRecord::RecordNotFound se não houver Papel com esse código.
  def atribuir_papel!(codigo)
    papel = Papel.find_by!(codigo: codigo)
    papeis << papel unless papeis.include?(papel)
  end

  # Indica se o usuário tem o papel de estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: consulta o banco.
  def estudante?
    possui_papel?(Papel::ESTUDANTE)
  end

  # Indica se o usuário tem o papel de funcionário.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: consulta o banco.
  def funcionario?
    possui_papel?(Papel::FUNCIONARIO)
  end

  # Indica se o usuário tem o papel de administrador.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: consulta o banco.
  def administrador?
    possui_papel?(Papel::ADMINISTRADOR)
  end

  # Indica se o usuário pode usar a aplicação de controle: funcionários e administradores (RN04.4).
  #
  # Argumentos:: nenhum.
  # Retorno:: true se tem algum papel de Papel::CODIGOS_CONTROLE; false caso contrário.
  # Efeitos colaterais:: consulta o banco.
  def pode_acessar_controle?
    papeis.exists?(codigo: Papel::CODIGOS_CONTROLE)
  end
end
