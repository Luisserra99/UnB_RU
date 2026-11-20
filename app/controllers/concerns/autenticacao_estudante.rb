# Autenticação do Portal do Estudante (F02/F03). Segue o mesmo modelo da F04
# (SessaoAutenticacao com token no cookie e SHA-256 no banco), com chave de sessão própria.
# Controllers do portal devem herdar de PortalEstudanteController.
#
# Observação: os dois logins chamam `reset_session`, então entrar como estudante encerra
# uma sessão de funcionário no mesmo navegador, e vice-versa.
module AutenticacaoEstudante
  extend ActiveSupport::Concern

  # Chave da sessão do navegador que guarda o token do estudante.
  CHAVE_SESSAO_ESTUDANTE = :token_sessao_estudante
  # Aviso para quem tenta abrir o portal sem login de estudante.
  MSG_LOGIN_ESTUDANTE_OBRIGATORIO = "Faça login como estudante para acessar o Portal do Estudante.".freeze

  included do
    helper_method :sessao_estudante, :estudante_atual, :estudante_autenticado?
  end

  private

  # Localiza a sessão ativa do estudante a partir do token guardado no navegador.
  #
  # Argumentos:: nenhum.
  # Retorno:: SessaoAutenticacao ativa de um usuário com cadastro de estudante, ou nil.
  # Efeitos colaterais:: consulta o banco na primeira chamada da requisição e guarda o resultado.
  def sessao_estudante
    return @sessao_estudante if defined?(@sessao_estudante)

    sessao = SessaoAutenticacao.localizar(session[CHAVE_SESSAO_ESTUDANTE])
    @sessao_estudante = sessao if sessao&.ativa? && sessao.usuario.estudante.present?
  end

  # Estudante logado.
  #
  # Argumentos:: nenhum.
  # Retorno:: Estudante, ou nil sem login.
  # Efeitos colaterais:: os de #sessao_estudante.
  def estudante_atual
    sessao_estudante&.usuario&.estudante
  end

  # Indica se há um estudante logado.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: os de #sessao_estudante.
  def estudante_autenticado?
    sessao_estudante.present?
  end

  # Filtro das telas do portal: só deixa passar estudante logado.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: sem login, limpa a sessão do navegador, guarda a página pedida (só em GET)
  #                      para voltar a ela depois do login e redireciona ao login com o aviso de
  #                      sessão expirada ou de login obrigatório.
  def exigir_estudante!
    return if estudante_autenticado?

    mensagem = mensagem_de_login_obrigatorio
    destino = request.get? ? request.fullpath : nil
    reset_session
    session[:retorno_estudante] = destino if destino
    redirect_to login_estudante_path, alert: mensagem
  end

  # Escolhe o aviso do redirecionamento ao login.
  #
  # Argumentos:: nenhum.
  # Retorno:: AutenticacaoFuncionario::MSG_SESSAO_EXPIRADA se o token do navegador pertence a uma
  #           sessão expirada; MSG_LOGIN_ESTUDANTE_OBRIGATORIO caso contrário.
  # Efeitos colaterais:: consulta o banco.
  def mensagem_de_login_obrigatorio
    expirada = SessaoAutenticacao.localizar(session[CHAVE_SESSAO_ESTUDANTE])&.expirada?
    expirada ? AutenticacaoFuncionario::MSG_SESSAO_EXPIRADA : MSG_LOGIN_ESTUDANTE_OBRIGATORIO
  end

  # Abre a sessão do estudante depois de um login válido.
  #
  # Argumentos:: +usuario+ (Usuario): usuário autenticado com cadastro de estudante.
  # Retorno:: String com a página pedida antes do login, ou nil.
  # Efeitos colaterais:: encerra as sessões anteriores do usuário, limpa a sessão do navegador
  #                      (evita fixação de sessão), cria uma SessaoAutenticacao no banco e guarda o
  #                      token no navegador.
  def iniciar_sessao_estudante(usuario)
    encerrar_sessoes_anteriores
    retorno = session[:retorno_estudante]
    reset_session # evita fixação de sessão
    @sessao_estudante, token = SessaoAutenticacao.iniciar!(usuario)
    session[CHAVE_SESSAO_ESTUDANTE] = token
    retorno
  end

  # Encerra a sessão do estudante (logout).
  #
  # Argumentos:: nenhum.
  # Retorno:: nil.
  # Efeitos colaterais:: marca a SessaoAutenticacao como encerrada no banco e limpa a sessão do
  #                      navegador.
  def encerrar_sessao_estudante
    SessaoAutenticacao.localizar(session[CHAVE_SESSAO_ESTUDANTE])&.encerrar!
    reset_session
    @sessao_estudante = nil
  end
end
