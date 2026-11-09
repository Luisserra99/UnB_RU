# Login e logout do Portal do Estudante (F02/F03).
class SessoesEstudanteController < ApplicationController
  MSG_FALHA = "Não foi possível autenticar as credenciais.".freeze
  MSG_SOMENTE_ESTUDANTES = "Acesso negado: o Portal do Estudante é restrito a estudantes.".freeze

  def new
    redirect_to new_recarga_path if estudante_autenticado?
  end

  def create
    @matricula = params[:matricula].to_s.strip
    senha = params[:senha].to_s

    @campos_obrigatorios = []
    @campos_obrigatorios << "Matrícula" if @matricula.blank?
    @campos_obrigatorios << "Senha" if senha.blank?
    return render_falha if @campos_obrigatorios.any?

    usuario = Usuario.autenticar(@matricula, senha)
    return render_falha(MSG_FALHA) if usuario.nil?
    return render_falha(MSG_SOMENTE_ESTUDANTES) if usuario.estudante.nil?

    retorno = iniciar_sessao_estudante(usuario)
    redirect_to retorno.presence || new_recarga_path, notice: "Bem-vindo(a), #{usuario.nome}."
  end

  def destroy
    encerrar_sessao_estudante
    redirect_to login_estudante_path, notice: "Sessão encerrada."
  end

  private

  def render_falha(mensagem = nil)
    flash.now[:alert] = mensagem if mensagem
    render :new, status: :unprocessable_content
  end
end
