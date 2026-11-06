require "rails_helper"

RSpec.describe "Cadastro de estudante (F01)", type: :request do
  before { create(:papel, codigo: Papel::ESTUDANTE) }

  let(:params_validos) do
    { cadastro_estudante: { nome: "Estudante", matricula: "222014133", email: "222014133@aluno.unb.br", senha: "senhaSegura" } }
  end

  it "exibe o formulário" do
    get novo_cadastro_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Cadastro de estudante")
  end

  it "cria a conta e redireciona com mensagem de sucesso" do
    expect { post cadastro_path, params: params_validos }.to change(Estudante, :count).by(1)
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Conta criada com sucesso")
  end

  it "re-exibe o formulário com erro e status 422 quando inválido" do
    params_validos[:cadastro_estudante][:senha] = "123"
    expect { post cadastro_path, params: params_validos }.not_to change(Usuario, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Senha inválida")
  end
end
