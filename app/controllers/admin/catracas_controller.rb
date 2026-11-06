module Admin
  class CatracasController < BaseController
    MSG_RESTAURANTE_NAO_ENCONTRADO = "Restaurante não encontrado".freeze

    before_action :carregar_catraca, only: %i[edit update remover destroy]

    def new
      @catraca = Catraca.new
      @piso_numero = 1
    end

    def create
      @catraca = Catraca.new
      salvar(:new, "Catraca cadastrada com sucesso")
    end

    def edit
      @restaurante_id = @catraca.piso.restaurante_id
      @piso_numero = @catraca.piso.numero
    end

    def update
      salvar(:edit, "Catraca atualizada com sucesso")
    end

    def remover
    end

    def destroy
      if @catraca.destroy
        redirect_to admin_restaurantes_path, notice: "Catraca removida com sucesso"
      else
        redirect_to admin_restaurantes_path, alert: @catraca.errors.full_messages.to_sentence
      end
    end

    private

    def carregar_catraca
      @catraca = Catraca.find(params[:id])
    end

    def salvar(tela, mensagem_sucesso)
      dados = params.expect(catraca: %i[identificacao restaurante_id piso_numero ativa])
      @restaurante_id = dados[:restaurante_id]
      @piso_numero = dados[:piso_numero]
      @catraca.identificacao = dados[:identificacao]
      @catraca.ativa = dados[:ativa] if dados.key?(:ativa)

      restaurante = Restaurante.find_by(id: @restaurante_id)
      if restaurante.nil?
        @catraca.errors.add(:base, MSG_RESTAURANTE_NAO_ENCONTRADO)
        return render(tela, status: :unprocessable_content)
      end

      @catraca.piso = restaurante.pisos.find_by(numero: @piso_numero)
      if @catraca.save
        redirect_to admin_restaurantes_path, notice: mensagem_sucesso
      else
        render tela, status: :unprocessable_content
      end
    end
  end
end
