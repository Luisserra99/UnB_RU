Rails.application.routes.draw do
  root "paginas#inicio"

  # F01 — Cadastro de estudante
  get "cadastro", to: "cadastros#new", as: :novo_cadastro
  post "cadastro", to: "cadastros#create", as: :cadastro

  # F10 — Cardápio (consulta pública)
  get "cardapio", to: "cardapios#show", as: :cardapio

  # F02/F03 — Portal do estudante (Luis)
  get "entrar", to: "sessoes_estudante#new", as: :login_estudante
  post "entrar", to: "sessoes_estudante#create"
  delete "sair", to: "sessoes_estudante#destroy", as: :logout_estudante
  resources :recargas, only: %i[new create show] do
    member do
      post :pagar_cartao
      post :simular_confirmacao # só existe em desenvolvimento e teste
    end
  end
  get "extrato", to: "extratos#show", as: :extrato
  get "estudantes/:estudante_id/extrato", to: "extratos#show", as: :extrato_estudante
  # F11 — Exportação do extrato em PDF/CSV (Tarsila)
  post "extrato/exportacoes", to: "exportacoes_extrato#create", as: :exportacoes_extrato

  # Aplicação de controle (funcionários)
  namespace :controle do
    root "painel#show"

    # F04 — Login de funcionário
    get "login", to: "sessoes#new", as: :login
    post "login", to: "sessoes#create"
    delete "logout", to: "sessoes#destroy", as: :logout

    # F06 — Terminal de simulação de leitura e passagem
    get "terminal", to: "terminal#show", as: :terminal
    post "terminal/leituras", to: "terminal#ler", as: :leitura_terminal
    post "terminal/:id/passagem", to: "terminal#passagem", as: :passagem_terminal
    post "terminal/:id/expirar", to: "terminal#expirar", as: :expirar_terminal

    # F07 — Histórico local da catraca
    get "historico", to: "historico#show", as: :historico
    post "historico", to: "historico#create"
    delete "historico", to: "historico#destroy"

    # F05 — Configuração do ponto de acesso
    resource :ponto_acesso, only: [ :create ], controller: "pontos_acesso" do
      post :reconfigurar, to: "pontos_acesso#edit"
    end

    # F08 — Catracas disponíveis para seleção (reaproveitável na F05)
    resources :restaurantes, only: [] do
      resources :catracas, only: :index
    end
  end

  # F08 — Gestão de restaurantes e catracas (somente administrador)
  namespace :admin do
    resources :restaurantes, except: :show do
      get :remover, on: :member
    end
    resources :catracas, except: %i[index show] do
      get :remover, on: :member
    end
  end

  # F09 — Relatório Global de Operação (somente administrador; Tarsila)
  get "admin/relatorio-global", to: "admin/relatorios_globais#show", as: :admin_relatorio_global
  post "admin/relatorio-global/exportacoes", to: "admin/relatorios_globais#exportar",
                                             as: :exportar_admin_relatorio_global
  # F12 — Acessos do relatório de operação e exportação em PDF para auditoria (Tarsila)
  get "admin/relatorio-global/acessos", to: "admin/acessos_operacao#index", as: :admin_acessos_relatorio_global
  post "admin/relatorio-global/acessos/exportacoes", to: "admin/acessos_operacao#exportar",
                                                     as: :exportar_admin_acessos_relatorio_global

  get "up" => "rails/health#show", as: :rails_health_check
end
