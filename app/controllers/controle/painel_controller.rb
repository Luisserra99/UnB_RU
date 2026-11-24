module Controle
  # Página inicial da aplicação de controle: escolha do ponto de acesso (F04/F05).
  class PainelController < BaseController
    # GET /controle: mostra o painel do funcionário com a escolha de restaurante e catraca.
    #
    # Argumentos:: +params[:restaurante_id]+ (opcional): restaurante cujas catracas serão listadas.
    # Retorno:: nenhum (renderiza +show+).
    # Efeitos colaterais:: os de Controle::BaseController#carregar_painel.
    def show
      carregar_painel
    end
  end
end
