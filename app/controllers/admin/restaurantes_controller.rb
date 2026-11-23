# Telas de administração do sistema, restritas a funcionários com papel de administrador.
module Admin
  # Cadastro, edição e remoção de restaurantes e seus pisos pelo administrador (F08).
  class RestaurantesController < BaseController
    before_action :carregar_restaurante, only: %i[edit update remover destroy]

    # GET /admin/restaurantes: lista os restaurantes e as catracas.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: consulta restaurantes (com unidade e pisos) e catracas (com piso e
    #                      restaurante) e renderiza +index+.
    def index
      @restaurantes = Restaurante.ordenados.includes(:unidade_gestora, :pisos)
      @catracas = Catraca.eager_load(piso: :restaurante)
                         .order("restaurantes.numero", "pisos.numero", "catracas.identificacao")
    end

    # GET /admin/restaurantes/new: abre o cadastro com a unidade padrão e 1 piso pré-preenchidos.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: consulta a unidade padrão e renderiza +new+.
    def new
      @restaurante = Restaurante.new(unidade_gestora: UnidadeGestora.padrao, quantidade_pisos: 1)
    end

    # POST /admin/restaurantes: cadastra o restaurante com os pisos.
    #
    # Argumentos:: +params[:restaurante]+ com +unidade_gestora_id+, +nome+, +quantidade_pisos+ e
    #              +capacidade_refeicoes_hora+.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: grava o restaurante e os pisos; no sucesso, redireciona à lista com aviso;
    #                      com dados inválidos, não grava nada e renderiza +new+ com HTTP 422.
    def create
      Restaurante.criar_com_pisos!(params.expect(restaurante: %i[unidade_gestora_id nome quantidade_pisos capacidade_refeicoes_hora]))
      redirect_to admin_restaurantes_path, notice: "Restaurante cadastrado com sucesso"
    rescue ActiveRecord::RecordInvalid => erro
      @restaurante = erro.record
      render :new, status: :unprocessable_content
    end

    # GET /admin/restaurantes/:id/edit: abre a edição do restaurante.
    #
    # Argumentos:: +params[:id]+: restaurante editado.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: renderiza +edit+.
    def edit
    end

    # PATCH /admin/restaurantes/:id: atualiza o restaurante e acrescenta pisos.
    #
    # Argumentos:: +params[:id]+ e +params[:restaurante]+ com +nome+, +quantidade_pisos+,
    #              +capacidade_refeicoes_hora+ e +ativo+.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: grava as alterações e os pisos novos; no sucesso, redireciona à lista com
    #                      aviso; com dados inválidos, não grava nada e renderiza +edit+ com HTTP 422.
    def update
      if @restaurante.atualizar_com_pisos(params.expect(restaurante: %i[nome quantidade_pisos capacidade_refeicoes_hora ativo]))
        redirect_to admin_restaurantes_path, notice: "Restaurante atualizado com sucesso"
      else
        render :edit, status: :unprocessable_content
      end
    end

    # GET /admin/restaurantes/:id/remover: pede a confirmação da remoção.
    #
    # Argumentos:: +params[:id]+: restaurante a remover.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: renderiza +remover+, sem remover nada.
    def remover
    end

    # DELETE /admin/restaurantes/:id: remove o restaurante, seus pisos e serviços.
    #
    # Argumentos:: +params[:id]+: restaurante a remover.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: apaga o restaurante quando ele não tem catracas e redireciona à lista com
    #                      aviso; quando tem catracas, não apaga nada e redireciona com o alerta do erro.
    def destroy
      remover_e_voltar_a_lista(@restaurante, "Restaurante removido com sucesso")
    end

    private

    # Filtro +before_action+ que carrega o restaurante da rota.
    #
    # Argumentos:: +params[:id]+: identificador do restaurante.
    # Retorno:: o Restaurante encontrado.
    # Efeitos colaterais:: define +@restaurante+; lança ActiveRecord::RecordNotFound (HTTP 404) se
    #                      ele não existe.
    def carregar_restaurante
      @restaurante = Restaurante.find(params[:id])
    end
  end
end
