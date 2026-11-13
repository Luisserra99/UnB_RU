module Admin
  class RestaurantesController < BaseController
    before_action :carregar_restaurante, only: %i[edit update remover destroy]

    def index
      @restaurantes = Restaurante.ordenados.includes(:unidade_gestora, :pisos)
      @catracas = Catraca.eager_load(piso: :restaurante)
                         .order("restaurantes.numero", "pisos.numero", "catracas.identificacao")
    end

    def new
      @restaurante = Restaurante.new(unidade_gestora: UnidadeGestora.padrao, quantidade_pisos: 1)
    end

    def create
      Restaurante.criar_com_pisos!(params.expect(restaurante: %i[unidade_gestora_id nome quantidade_pisos capacidade_refeicoes_hora]))
      redirect_to admin_restaurantes_path, notice: "Restaurante cadastrado com sucesso"
    rescue ActiveRecord::RecordInvalid => erro
      @restaurante = erro.record
      render :new, status: :unprocessable_content
    end

    def edit
    end

    def update
      if @restaurante.atualizar_com_pisos(params.expect(restaurante: %i[nome quantidade_pisos capacidade_refeicoes_hora ativo]))
        redirect_to admin_restaurantes_path, notice: "Restaurante atualizado com sucesso"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def remover
    end

    def destroy
      if @restaurante.destroy
        redirect_to admin_restaurantes_path, notice: "Restaurante removido com sucesso"
      else
        redirect_to admin_restaurantes_path, alert: @restaurante.errors.full_messages.to_sentence
      end
    end

    private

    def carregar_restaurante
      @restaurante = Restaurante.find(params[:id])
    end
  end
end
