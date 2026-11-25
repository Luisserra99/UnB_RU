# Aplicação de controle dos funcionários do restaurante.
module Controle
  # Lista as catracas que um funcionário pode selecionar em um restaurante ativo.
  class CatracasController < BaseController
    # GET /controle/restaurantes/:restaurante_id/catracas: lista as catracas ativas do restaurante.
    #
    # Argumentos:: +params[:restaurante_id]+: restaurante consultado.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: consulta as catracas ativas, ordenadas por piso e identificação, e
    #                      renderiza +index+; lança ActiveRecord::RecordNotFound (HTTP 404) se o
    #                      restaurante não existe ou está inativo.
    def index
      @restaurante = Restaurante.ativos.find(params[:restaurante_id])
      @catracas = @restaurante.catracas.disponiveis.includes(:piso).order("pisos.numero", :identificacao)
    end
  end
end
