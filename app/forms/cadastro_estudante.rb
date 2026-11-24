# Formulário de cadastro (F01): cria Usuario + Estudante + papel "estudante" numa transação.
class CadastroEstudante
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Domínios de email aceitos no cadastro (RN01.4).
  DOMINIOS_FACULDADE = %w[aluno.unb.br unb.br].freeze

  # Erro de matrícula fora do formato de 9 números (RN01.1).
  MSG_MATRICULA = "Matrícula inválida: informe exatamente 9 números".freeze
  # Erro de email fora do formato ou fora dos domínios da faculdade (RN01.2 e RN01.4).
  MSG_EMAIL = "Email inválido: use o email institucional (@aluno.unb.br ou @unb.br)".freeze
  # Erro de senha curta (RN01.3).
  MSG_SENHA = "Senha inválida: informe no mínimo #{Usuario::SENHA_TAMANHO_MINIMO} caracteres".freeze

  attribute :nome, :string
  attribute :matricula, :string
  attribute :email, :string
  attribute :senha, :string

  # Usuario criado por #salvar; nil antes de um cadastro bem-sucedido.
  attr_reader :usuario

  validates :nome, presence: { message: "Nome é obrigatório" }
  validate :validar_matricula
  validate :validar_email
  validate :validar_senha

  # Indica se o email é de um domínio da faculdade (RN01.4).
  #
  # Argumentos:: +email+ (String ou nil): email digitado, com ou sem espaços e maiúsculas.
  # Retorno:: true se o domínio está em DOMINIOS_FACULDADE; false caso contrário (inclusive sem "@").
  # Efeitos colaterais:: nenhum.
  def self.dominio_da_faculdade?(email)
    dominio = email.to_s.strip.downcase.split("@", 2)[1]
    DOMINIOS_FACULDADE.include?(dominio)
  end

  # Valida o formulário e cria a conta do estudante (RN01.5).
  #
  # Argumentos:: nenhum.
  # Retorno:: true quando a conta foi criada (disponível em #usuario); false quando o formulário é
  #           inválido ou o banco rejeita a gravação (os motivos ficam em #errors).
  # Efeitos colaterais:: grava Usuario, Estudante e UsuarioPapel numa única transação (ver
  #                      #criar_conta!); se o banco rejeitar, desfaz tudo e adiciona o erro em +base+.
  def salvar
    return false unless valid?

    ActiveRecord::Base.transaction { criar_conta! }
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    errors.add(:base, "Não foi possível concluir o cadastro: #{e.message}")
    false
  end

  private

  # Cria o usuário ativo, o cadastro de estudante e o papel de estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: grava Usuario, Estudante e UsuarioPapel e guarda o usuário em @usuario.
  #                      Lança ActiveRecord::RecordInvalid ou ActiveRecord::RecordNotUnique se o banco
  #                      rejeitar algum registro.
  def criar_conta!
    @usuario = Usuario.create!(
      nome: nome, identificacao: matricula_normalizada, email: email_normalizado, password: senha, ativo: true
    )
    @usuario.create_estudante!(matricula: matricula_normalizada, vinculo_ativo: true)
    @usuario.atribuir_papel!(Papel::ESTUDANTE)
  end

  # Matrícula sem espaços em volta.
  #
  # Argumentos:: nenhum.
  # Retorno:: String (vazia se a matrícula não foi informada).
  # Efeitos colaterais:: nenhum.
  def matricula_normalizada
    matricula.to_s.strip
  end

  # Email sem espaços em volta e em minúsculas.
  #
  # Argumentos:: nenhum.
  # Retorno:: String (vazia se o email não foi informado).
  # Efeitos colaterais:: nenhum.
  def email_normalizado
    email.to_s.strip.downcase
  end

  # Validação da matrícula: 9 números (RN01.1) e ainda não cadastrada.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona MSG_MATRICULA ou "Matrícula já cadastrada" em +matricula+.
  def validar_matricula
    if !Estudante::FORMATO_MATRICULA.match?(matricula_normalizada)
      errors.add(:matricula, MSG_MATRICULA)
    elsif matricula_ja_cadastrada?
      errors.add(:matricula, "Matrícula já cadastrada")
    end
  end

  # Indica se a matrícula já é usada por um estudante ou como identificação de um usuário.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: consulta o banco.
  def matricula_ja_cadastrada?
    Estudante.exists?(matricula: matricula_normalizada) || Usuario.exists?(identificacao: matricula_normalizada)
  end

  # Validação do email: formato e domínio da faculdade (RN01.2 e RN01.4) e ainda não cadastrado.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona MSG_EMAIL ou "Email já cadastrado" em +email+.
  def validar_email
    if !email_institucional?
      errors.add(:email, MSG_EMAIL)
    elsif Usuario.exists?(email: email_normalizado)
      errors.add(:email, "Email já cadastrado")
    end
  end

  # Indica se o email tem formato válido e é de um domínio da faculdade.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: nenhum.
  def email_institucional?
    Usuario::FORMATO_EMAIL.match?(email_normalizado) && self.class.dominio_da_faculdade?(email_normalizado)
  end

  # Validação da senha: no mínimo Usuario::SENHA_TAMANHO_MINIMO caracteres (RN01.3).
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona MSG_SENHA em +senha+ quando a senha é curta.
  def validar_senha
    errors.add(:senha, MSG_SENHA) if senha.to_s.length < Usuario::SENHA_TAMANHO_MINIMO
  end
end
