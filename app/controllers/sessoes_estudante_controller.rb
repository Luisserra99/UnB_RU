# Login e logout do Portal do Estudante (F02/F03).
class SessoesEstudanteController < ApplicationController
  # Aviso para matrícula ou senha incorreta, conta inativa ou usuário sem cadastro de estudante.
  MSG_FALHA = "Não foi possível autenticar as credenciais.".freeze

  # GET /entrar: mostra a tela de login.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum (renderiza +new+).
  # Efeitos colaterais:: redireciona para a recarga se o estudante já estiver logado.
  def new
    redirect_to new_recarga_path if estudante_autenticado?
  end

  # POST /entrar: autentica o estudante pela matrícula e senha.
  #
  # Argumentos:: +params[:matricula]+ e +params[:senha]+.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: com campos em branco, credenciais recusadas ou usuário sem cadastro de
  #                      estudante (ex.: funcionário), renderiza +new+ com status 422 (os campos
  #                      faltantes ficam em @campos_obrigatorios). Com sucesso,
  #                      encerra sessões anteriores, cria a sessão do estudante e redireciona para
  #                      a página pedida antes do login ou para a recarga.
  def create
    @matricula = params[:matricula].to_s.strip
    senha = params[:senha].to_s
    @campos_obrigatorios = campos_em_branco(senha)
    return render_falha if @campos_obrigatorios.any?

    usuario = Usuario.autenticar(@matricula, senha)
    usuario&.estudante ? entrar(usuario) : render_falha(MSG_FALHA)
  end

  # DELETE /sair: encerra a sessão do estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: encerra a sessão no banco, limpa a sessão do navegador e redireciona para o
  #                      login.
  def destroy
    encerrar_sessao_estudante
    redirect_to login_estudante_path, notice: "Sessão encerrada."
  end

  private

  # Lista os campos obrigatórios que vieram em branco.
  #
  # Argumentos:: +senha+ (String): senha digitada (a matrícula vem de @matricula).
  # Retorno:: Array com "Matrícula" e/ou "Senha", nessa ordem; vazio se ambos foram preenchidos.
  # Efeitos colaterais:: nenhum.
  def campos_em_branco(senha)
    { "Matrícula" => @matricula, "Senha" => senha }.select { |_campo, valor| valor.blank? }.keys
  end

  # Inicia a sessão do estudante e o leva à página certa.
  #
  # Argumentos:: +usuario+ (Usuario): usuário autenticado com cadastro de estudante.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: os de AutenticacaoEstudante#iniciar_sessao_estudante; redireciona com aviso
  #                      de boas-vindas.
  def entrar(usuario)
    retorno = iniciar_sessao_estudante(usuario)
    redirect_to retorno.presence || new_recarga_path, notice: "Bem-vindo(a), #{usuario.nome}."
  end

  # Mostra de novo a tela de login com o motivo da falha.
  #
  # Argumentos:: +mensagem+ (String ou nil): aviso; nil quando a tela já indica os campos em branco.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: põe a mensagem no flash e renderiza +new+ com status 422.
  def render_falha(mensagem = nil)
    flash.now[:alert] = mensagem if mensagem
    render :new, status: :unprocessable_content
  end
end
