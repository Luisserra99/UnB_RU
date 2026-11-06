module Controle
  # Lista as catracas que um funcionário pode selecionar em um restaurante ativo.
  class CatracasController < BaseController
    def index
      @restaurante = Restaurante.ativos.find(params[:restaurante_id])
      @catracas = @restaurante.catracas.disponiveis.includes(:piso).order("pisos.numero", :identificacao)
    end
  end
end
