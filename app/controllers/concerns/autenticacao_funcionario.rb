# Autenticação da aplicação de controle (F04).
# Controllers de funções de controle devem herdar de Controle::BaseController,
# que já aplica `before_action :exigir_funcionario!`.
module AutenticacaoFuncionario
  extend ActiveSupport::Concern

  CHAVE_SESSAO = :token_sessao_controle
  MSG_LOGIN_OBRIGATORIO = "Faça login como funcionário para acessar a aplicação de controle.".freeze
  MSG_SESSAO_EXPIRADA = "Sua sessão expirou. Faça login novamente.".freeze

  included do
    helper_method :sessao_atual, :funcionario_atual, :funcionario_autenticado?
  end

  private

  def sessao_atual
    return @sessao_atual if defined?(@sessao_atual)

    sessao = SessaoAutenticacao.localizar(session[CHAVE_SESSAO])
    @sessao_atual = sessao if sessao&.ativa? && sessao.usuario.pode_acessar_controle?
  end

  def funcionario_atual
    sessao_atual&.usuario
  end

  def funcionario_autenticado?
    sessao_atual.present?
  end

  def exigir_funcionario!
    return if funcionario_autenticado?

    anterior = SessaoAutenticacao.localizar(session[CHAVE_SESSAO])
    expirada = anterior&.expirada?
    anterior&.encerrar!
    reset_session
    redirect_to controle_login_path, alert: (expirada ? MSG_SESSAO_EXPIRADA : MSG_LOGIN_OBRIGATORIO)
  end

  # reset_session remove cookies, mas também é necessário encerrar a configuração no banco.
  def encerrar_sessoes_anteriores
    [ :token_sessao_controle, :token_sessao_estudante ].each do |chave|
      SessaoAutenticacao.localizar(session[chave])&.encerrar!
    end
  end

  def iniciar_sessao_controle(usuario)
    encerrar_sessoes_anteriores
    reset_session # evita fixação de sessão
    @sessao_atual, token = SessaoAutenticacao.iniciar!(usuario)
    session[CHAVE_SESSAO] = token
    @sessao_atual
  end

  def encerrar_sessao_controle
    SessaoAutenticacao.localizar(session[CHAVE_SESSAO])&.encerrar!
    reset_session
    @sessao_atual = nil
  end
end
