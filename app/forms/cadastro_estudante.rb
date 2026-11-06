# Formulário de cadastro (F01): cria Usuario + Estudante + papel "estudante" numa transação.
class CadastroEstudante
  include ActiveModel::Model
  include ActiveModel::Attributes

  DOMINIOS_FACULDADE = %w[aluno.unb.br unb.br].freeze

  MSG_MATRICULA = "Matrícula inválida: informe exatamente 9 números".freeze
  MSG_EMAIL = "Email inválido: use o email institucional (@aluno.unb.br ou @unb.br)".freeze
  MSG_SENHA = "Senha inválida: informe no mínimo #{Usuario::SENHA_TAMANHO_MINIMO} caracteres".freeze

  attribute :nome, :string
  attribute :matricula, :string
  attribute :email, :string
  attribute :senha, :string

  attr_reader :usuario

  validates :nome, presence: { message: "Nome é obrigatório" }
  validate :validar_matricula
  validate :validar_email
  validate :validar_senha

  def self.dominio_da_faculdade?(email)
    dominio = email.to_s.strip.downcase.split("@", 2)[1]
    DOMINIOS_FACULDADE.include?(dominio)
  end

  def salvar
    return false unless valid?

    ActiveRecord::Base.transaction do
      @usuario = Usuario.create!(
        nome: nome,
        identificacao: matricula_normalizada,
        email: email_normalizado,
        password: senha,
        ativo: true
      )
      @usuario.create_estudante!(matricula: matricula_normalizada, vinculo_ativo: true)
      @usuario.atribuir_papel!(Papel::ESTUDANTE)
    end
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    errors.add(:base, "Não foi possível concluir o cadastro: #{e.message}")
    false
  end

  private

  def matricula_normalizada
    matricula.to_s.strip
  end

  def email_normalizado
    email.to_s.strip.downcase
  end

  def validar_matricula
    if !Estudante::FORMATO_MATRICULA.match?(matricula_normalizada)
      errors.add(:matricula, MSG_MATRICULA)
    elsif Estudante.exists?(matricula: matricula_normalizada) || Usuario.exists?(identificacao: matricula_normalizada)
      errors.add(:matricula, "Matrícula já cadastrada")
    end
  end

  def validar_email
    if !Usuario::FORMATO_EMAIL.match?(email_normalizado) || !self.class.dominio_da_faculdade?(email_normalizado)
      errors.add(:email, MSG_EMAIL)
    elsif Usuario.exists?(email: email_normalizado)
      errors.add(:email, "Email já cadastrado")
    end
  end

  def validar_senha
    errors.add(:senha, MSG_SENHA) if senha.to_s.length < Usuario::SENHA_TAMANHO_MINIMO
  end
end
