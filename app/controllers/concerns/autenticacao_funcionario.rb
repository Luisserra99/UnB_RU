# Autenticação da aplicação de controle (F04).
# Controllers de funções de controle devem herdar de Controle::BaseController,
# que já aplica `before_action :exigir_funcionario!`.
module AutenticacaoFuncionario
  extend ActiveSupport::Concern

  # Chave da sessão do navegador que guarda o token do funcionário.
  CHAVE_SESSAO = :token_sessao_controle
  # Aviso para quem tenta abrir a aplicação de controle sem login de funcionário.
  MSG_LOGIN_OBRIGATORIO = "Faça login como funcionário para acessar a aplicação de controle.".freeze
  # Aviso para quem volta com o token de uma sessão que já expirou.
  MSG_SESSAO_EXPIRADA = "Sua sessão expirou. Faça login novamente.".freeze

  included do
    helper_method :sessao_atual, :funcionario_atual, :funcionario_autenticado?
  end

  private

  # Localiza a sessão ativa do funcionário a partir do token guardado no navegador.
  #
  # Argumentos:: nenhum.
  # Retorno:: SessaoAutenticacao ativa de um usuário que pode acessar o controle, ou nil.
  # Efeitos colaterais:: consulta o banco na primeira chamada da requisição e guarda o resultado.
  def sessao_atual
    return @sessao_atual if defined?(@sessao_atual)

    sessao = SessaoAutenticacao.localizar(session[CHAVE_SESSAO])
    @sessao_atual = sessao if sessao&.ativa? && sessao.usuario.pode_acessar_controle?
  end

  # Funcionário (ou administrador) logado na aplicação de controle.
  #
  # Argumentos:: nenhum.
  # Retorno:: Usuario, ou nil sem login.
  # Efeitos colaterais:: os de #sessao_atual.
  def funcionario_atual
    sessao_atual&.usuario
  end

  # Indica se há um funcionário logado.
  #
  # Argumentos:: nenhum.
  # Retorno:: true ou false.
  # Efeitos colaterais:: os de #sessao_atual.
  def funcionario_autenticado?
    sessao_atual.present?
  end

  # Filtro das telas de controle: só deixa passar funcionário logado (RN04.6).
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: sem login válido, encerra no banco a sessão guardada no navegador (se
  #                      houver), limpa a sessão do navegador e redireciona ao login com
  #                      MSG_SESSAO_EXPIRADA ou MSG_LOGIN_OBRIGATORIO, o que interrompe a ação.
  def exigir_funcionario!
    return if funcionario_autenticado?

    anterior = SessaoAutenticacao.localizar(session[CHAVE_SESSAO])
    expirada = anterior&.expirada?
    anterior&.encerrar!
    reset_session
    redirect_to controle_login_path, alert: (expirada ? MSG_SESSAO_EXPIRADA : MSG_LOGIN_OBRIGATORIO)
  end

  # Encerra no banco as sessões de funcionário e de estudante guardadas no navegador.
  # reset_session remove os cookies, mas também é necessário encerrar a configuração no banco.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: chama SessaoAutenticacao#encerrar! em cada sessão encontrada.
  def encerrar_sessoes_anteriores
    [ :token_sessao_controle, :token_sessao_estudante ].each do |chave|
      SessaoAutenticacao.localizar(session[chave])&.encerrar!
    end
  end

  # Abre a sessão do funcionário depois de um login válido.
  #
  # Argumentos:: +usuario+ (Usuario): funcionário ou administrador autenticado.
  # Retorno:: a SessaoAutenticacao criada.
  # Efeitos colaterais:: encerra sessões anteriores, troca a sessão do navegador (evita fixação de
  #                      sessão), grava a nova SessaoAutenticacao no banco e guarda o token no cookie.
  def iniciar_sessao_controle(usuario)
    encerrar_sessoes_anteriores
    reset_session # evita fixação de sessão
    @sessao_atual, token = SessaoAutenticacao.iniciar!(usuario)
    session[CHAVE_SESSAO] = token
    @sessao_atual
  end

  # Encerra a sessão do funcionário no logout.
  #
  # Argumentos:: nenhum.
  # Retorno:: nil.
  # Efeitos colaterais:: encerra a SessaoAutenticacao no banco (se houver) e limpa a sessão do
  #                      navegador.
  def encerrar_sessao_controle
    SessaoAutenticacao.localizar(session[CHAVE_SESSAO])&.encerrar!
    reset_session
    @sessao_atual = nil
  end
end
