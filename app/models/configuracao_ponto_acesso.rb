# Cada confirmação é um registro novo: os eventos antigos preservam o ponto de origem.
class ConfiguracaoPontoAcesso < ApplicationRecord
  has_many :registros_acesso, class_name: "RegistroAcesso", dependent: :restrict_with_error
  belongs_to :sessao_autenticacao
  belongs_to :catraca
  belongs_to :restaurante
  delegate :usuario, to: :sessao_autenticacao
  alias_method :funcionario, :usuario

  validates :confirmada_em, presence: true
  validate :vinculo_do_ponto, on: :create

  scope :abertas, -> { where(finalizada_em: nil) }
  scope :em_sessoes_validas, -> {
    abertas.joins(sessao_autenticacao: { usuario: :papeis })
      .merge(SessaoAutenticacao.ativas).where(usuarios: { ativo: true })
      .where(papeis: { codigo: Papel::CODIGOS_CONTROLE }).distinct
  }

  # Informa se a sessão e os cadastros ainda permitem operar o ponto confirmado.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se o ponto está aberto, autorizado e ativo; false caso contrário.
  # Efeitos colaterais:: consulta os cadastros associados, sem gravar alterações.
  def disponivel?
    finalizada_em.nil? && sessao_disponivel? && cadastros_disponiveis?
  end

  # Cancela liberações sem passagem durante a reconfiguração ou o logout.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: grava o cancelamento de cada liberação, sem debitar saldo;
  #                      propaga ActiveRecord::RecordInvalid se uma atualização falhar.
  def cancelar_liberacoes!
    registros_acesso.liberado.find_each do |registro|
      registro.update!(estado: :cancelado, bloqueado_em: [ Time.current, registro.limite_em ].min, mensagem: "Acesso cancelado")
    end
  end

  private

  # Verifica a autenticação, a pendência de seleção e o papel do operador.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se a sessão pode operar; false se expirada, encerrada, pendente ou sem papel.
  # Efeitos colaterais:: consulta o usuário e seus papéis, sem gravar alterações.
  def sessao_disponivel?
    sessao_autenticacao.ativa? && !sessao_autenticacao.ponto_acesso_pendente? &&
      sessao_autenticacao.usuario.pode_acessar_controle?
  end

  # Verifica se restaurante e catraca continuam ativos e vinculados entre si.
  #
  # Argumentos:: nenhum.
  # Retorno:: true para cadastros ativos e coerentes; false caso contrário.
  # Efeitos colaterais:: consulta as associações, sem gravar alterações.
  def cadastros_disponiveis?
    restaurante.ativo? && catraca.ativa? && catraca.restaurante == restaurante
  end

  # Valida o vínculo da catraca com o restaurante na criação do ponto.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +catraca+ quando pertence a outro restaurante.
  def vinculo_do_ponto
    errors.add(:catraca, "não pertence ao restaurante selecionado") if catraca && catraca.restaurante != restaurante
  end
end
