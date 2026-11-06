Rails.application.routes.draw do
  root "paginas#inicio"

  # F01 — Cadastro de estudante
  get "cadastro", to: "cadastros#new", as: :novo_cadastro
  post "cadastro", to: "cadastros#create", as: :cadastro

  # Aplicação de controle (funcionários)
  namespace :controle do
    root "painel#show"

    # F04 — Login de funcionário
    get "login", to: "sessoes#new", as: :login
    post "login", to: "sessoes#create"
    delete "logout", to: "sessoes#destroy", as: :logout
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
