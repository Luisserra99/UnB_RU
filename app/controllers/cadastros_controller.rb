# F01 — Cadastro de estudante.
class CadastrosController < ApplicationController
  # GET /cadastro: mostra o formulário de cadastro de estudante.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum (renderiza +new+).
  # Efeitos colaterais:: define @cadastro com um CadastroEstudante vazio.
  def new
    @cadastro = CadastroEstudante.new
  end

  # POST /cadastro: cria a conta do estudante.
  #
  # Argumentos:: +params[:cadastro_estudante]+ com +nome+, +matricula+, +email+ e +senha+.
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: com dados válidos, grava Usuario, Estudante e o papel de estudante (ver
  #                      CadastroEstudante#salvar) e redireciona para a página inicial com a
  #                      matrícula; com dados inválidos, renderiza +new+ com status 422 e os erros.
  def create
    @cadastro = CadastroEstudante.new(cadastro_params)

    if @cadastro.salvar
      redirect_to root_path, notice: "Conta criada com sucesso! Matrícula #{@cadastro.usuario.identificacao}."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  # Campos permitidos do formulário de cadastro.
  #
  # Argumentos:: nenhum (lê +params[:cadastro_estudante]+).
  # Retorno:: ActionController::Parameters com +nome+, +matricula+, +email+ e +senha+.
  # Efeitos colaterais:: responde 400 (Bad Request) se +params[:cadastro_estudante]+ não vier.
  def cadastro_params
    params.expect(cadastro_estudante: [ :nome, :matricula, :email, :senha ])
  end
end
