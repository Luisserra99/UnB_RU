require "rails_helper"

RSpec.describe "Página inicial", type: :request do
  it "mostra os caminhos para estudante e funcionário sem exigir login" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sou estudante", "Sou funcionário")
    expect(response.body).to include(%(href="#{novo_cadastro_path}"), %(href="#{controle_login_path}"))
  end

  it "responde 406 para formato não suportado" do
    get root_path(format: :json)
    expect(response).to have_http_status(:not_acceptable)
  end
end
