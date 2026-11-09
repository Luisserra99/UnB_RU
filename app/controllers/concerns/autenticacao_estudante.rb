# Autenticação do Portal do Estudante (F02/F03). Segue o mesmo modelo da F04
# (SessaoAutenticacao com token no cookie e SHA-256 no banco), com chave de sessão própria.
# Controllers do portal devem herdar de PortalEstudanteController.
#
# Observação: os dois logins chamam `reset_session`, então entrar como estudante encerra
# uma sessão de funcionário no mesmo navegador, e vice-versa.
module AutenticacaoEstudante
  extend ActiveSupport::Concern

  CHAVE_SESSAO_ESTUDANTE = :token_sessao_estudante
  MSG_LOGIN_ESTUDANTE_OBRIGATORIO = "Faça login como estudante para acessar o Portal do Estudante.".freeze

  included do
    helper_method :sessao_estudante, :estudante_atual, :estudante_autenticado?
  end

  private

  def sessao_estudante
    return @sessao_estudante if defined?(@sessao_estudante)

    sessao = SessaoAutenticacao.localizar(session[CHAVE_SESSAO_ESTUDANTE])
    @sessao_estudante = sessao if sessao&.ativa? && sessao.usuario.estudante.present?
  end

  def estudante_atual
    sessao_estudante&.usuario&.estudante
  end

  def estudante_autenticado?
    sessao_estudante.present?
  end

  def exigir_estudante!
    return if estudante_autenticado?

    expirada = SessaoAutenticacao.localizar(session[CHAVE_SESSAO_ESTUDANTE])&.expirada?
    destino = request.get? ? request.fullpath : nil
    reset_session
    session[:retorno_estudante] = destino if destino
    mensagem = expirada ? AutenticacaoFuncionario::MSG_SESSAO_EXPIRADA : MSG_LOGIN_ESTUDANTE_OBRIGATORIO
    redirect_to login_estudante_path, alert: mensagem
  end

  def iniciar_sessao_estudante(usuario)
    encerrar_sessoes_anteriores
    retorno = session[:retorno_estudante]
    reset_session # evita fixação de sessão
    @sessao_estudante, token = SessaoAutenticacao.iniciar!(usuario)
    session[CHAVE_SESSAO_ESTUDANTE] = token
    retorno
  end

  def encerrar_sessao_estudante
    SessaoAutenticacao.localizar(session[CHAVE_SESSAO_ESTUDANTE])&.encerrar!
    reset_session
    @sessao_estudante = nil
  end
end
