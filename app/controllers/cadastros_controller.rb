# F01 — Cadastro de estudante.
class CadastrosController < ApplicationController
  def new
    @cadastro = CadastroEstudante.new
  end

  def create
    @cadastro = CadastroEstudante.new(cadastro_params)

    if @cadastro.salvar
      redirect_to root_path, notice: "Conta criada com sucesso! Matrícula #{@cadastro.usuario.identificacao}."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def cadastro_params
    params.expect(cadastro_estudante: [ :nome, :matricula, :email, :senha ])
  end
end
