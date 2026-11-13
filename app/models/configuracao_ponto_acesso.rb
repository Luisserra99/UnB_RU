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

  def disponivel?
    finalizada_em.nil? && sessao_autenticacao.ativa? &&
      !sessao_autenticacao.ponto_acesso_pendente? &&
      sessao_autenticacao.usuario.pode_acessar_controle? &&
      restaurante.ativo? && catraca.ativa? && catraca.restaurante == restaurante
  end

  # Reconfiguração/logout cancelam liberações que ainda não tiveram passagem.
  def cancelar_liberacoes!
    registros_acesso.liberado.find_each do |registro|
      registro.update!(estado: :cancelado, bloqueado_em: [ Time.current, registro.limite_em ].min, mensagem: "Acesso cancelado")
    end
  end

  private

  def vinculo_do_ponto
    errors.add(:catraca, "não pertence ao restaurante selecionado") if catraca && catraca.restaurante != restaurante
  end
end
