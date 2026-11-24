module Controle
  # Login e logout da aplicação de controle (F04), restrita a funcionários e administradores.
  class SessoesController < ApplicationController
    layout "controle"

    # Aviso para identificação ou senha incorreta e para conta inativa ou inexistente (RN04.2 e RN04.3).
    MSG_FALHA = "Não foi possível autenticar as credenciais.".freeze
    # Aviso para quem tem credencial válida, mas não é funcionário nem administrador (RN04.4).
    MSG_SOMENTE_FUNCIONARIOS = "Acesso negado: a aplicação de controle é restrita a funcionários.".freeze

    # GET /controle/login: mostra a tela de login do operador.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (renderiza +new+).
    # Efeitos colaterais:: redireciona para o painel de controle se já houver funcionário logado.
    def new
      redirect_to controle_root_path if funcionario_autenticado?
    end

    # POST /controle/login: autentica o funcionário pela identificação e senha.
    #
    # Argumentos:: +params[:identificacao]+ e +params[:senha]+.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: com campos em branco, renderiza +new+ com status 422 (os campos faltantes
    #                      ficam em @campos_obrigatorios); com credenciais recusadas ou conta sem
    #                      papel de controle, renderiza +new+ com status 422 e o motivo no flash. Com
    #                      sucesso, encerra sessões anteriores, cria a SessaoAutenticacao e
    #                      redireciona para o painel de controle.
    def create
      @identificacao = params[:identificacao].to_s.strip
      senha = params[:senha].to_s
      @campos_obrigatorios = campos_em_branco(senha)
      return render_falha if @campos_obrigatorios.any?

      autenticar(senha)
    end

    # DELETE /controle/logout: encerra a sessão do funcionário.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: encerra a SessaoAutenticacao e os pontos de acesso abertos no banco, limpa
    #                      a sessão do navegador e redireciona para o login do controle.
    def destroy
      encerrar_sessao_controle
      redirect_to controle_login_path, notice: "Sessão encerrada. Faça login novamente para acessar a aplicação de controle."
    end

    private

    # Lista os campos obrigatórios que vieram em branco.
    #
    # Argumentos:: +senha+ (String): senha digitada (a identificação vem de @identificacao).
    # Retorno:: Array com "Identificação" e/ou "Senha", nessa ordem; vazio se ambos foram preenchidos.
    # Efeitos colaterais:: nenhum.
    def campos_em_branco(senha)
      { "Identificação" => @identificacao, "Senha" => senha }.select { |_campo, valor| valor.blank? }.keys
    end

    # Confere as credenciais preenchidas e inicia a sessão ou recusa o login.
    #
    # Argumentos:: +senha+ (String): senha digitada (a identificação vem de @identificacao).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: os de #entrar quando o usuário pode entrar; os de #render_falha, com o
    #                      motivo de #motivo_da_recusa, caso contrário.
    def autenticar(senha)
      usuario = Usuario.autenticar(@identificacao, senha)
      motivo = motivo_da_recusa(usuario)
      motivo ? render_falha(motivo) : entrar(usuario)
    end

    # Diz por que o usuário não pode entrar na aplicação de controle.
    #
    # Argumentos:: +usuario+ (Usuario ou nil): resultado de Usuario.autenticar.
    # Retorno:: MSG_FALHA quando as credenciais foram recusadas (nil); MSG_SOMENTE_FUNCIONARIOS quando
    #           o usuário não tem papel de funcionário nem de administrador; nil quando pode entrar.
    # Efeitos colaterais:: consulta os papéis do usuário no banco.
    def motivo_da_recusa(usuario)
      return MSG_FALHA if usuario.nil?

      MSG_SOMENTE_FUNCIONARIOS unless usuario.pode_acessar_controle?
    end

    # Inicia a sessão do funcionário e o leva ao painel.
    #
    # Argumentos:: +usuario+ (Usuario): usuário autenticado com papel de controle.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: os de AutenticacaoFuncionario#iniciar_sessao_controle; redireciona para o
    #                      painel com aviso de boas-vindas.
    def entrar(usuario)
      iniciar_sessao_controle(usuario)
      redirect_to controle_root_path, notice: "Sessão autenticada. Bem-vindo(a), #{usuario.nome}."
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
end
