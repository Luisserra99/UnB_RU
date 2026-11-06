module Controle
  class SessoesController < ApplicationController
    layout "controle"

    MSG_FALHA = "Não foi possível autenticar as credenciais.".freeze
    MSG_SOMENTE_FUNCIONARIOS = "Acesso negado: a aplicação de controle é restrita a funcionários.".freeze

    def new
      redirect_to controle_root_path if funcionario_autenticado?
    end

    def create
      @identificacao = params[:identificacao].to_s.strip
      senha = params[:senha].to_s

      @campos_obrigatorios = []
      @campos_obrigatorios << "Identificação" if @identificacao.blank?
      @campos_obrigatorios << "Senha" if senha.blank?
      return render_falha if @campos_obrigatorios.any?

      usuario = Usuario.autenticar(@identificacao, senha)
      return render_falha(MSG_FALHA) if usuario.nil?
      return render_falha(MSG_SOMENTE_FUNCIONARIOS) unless usuario.pode_acessar_controle?

      iniciar_sessao_controle(usuario)
      redirect_to controle_root_path, notice: "Sessão autenticada. Bem-vindo(a), #{usuario.nome}."
    end

    def destroy
      encerrar_sessao_controle
      redirect_to controle_login_path, notice: "Sessão encerrada. Faça login novamente para acessar a aplicação de controle."
    end

    private

    def render_falha(mensagem = nil)
      flash.now[:alert] = mensagem if mensagem
      render :new, status: :unprocessable_content
    end
  end
end
