# Telas de administração do sistema, restritas a funcionários com papel de administrador.
module Admin
  # Cadastro, edição e remoção de catracas nos pisos dos restaurantes pelo administrador (F08).
  class CatracasController < BaseController
    # Erro quando o restaurante escolhido no formulário não existe.
    MSG_RESTAURANTE_NAO_ENCONTRADO = "Restaurante não encontrado".freeze

    before_action :carregar_catraca, only: %i[edit update remover destroy]

    # GET /admin/catracas/new: abre o cadastro com o piso 1 pré-preenchido.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: renderiza +new+.
    def new
      @catraca = Catraca.new
      @piso_numero = 1
    end

    # POST /admin/catracas: cadastra a catraca no piso do restaurante escolhido.
    #
    # Argumentos:: +params[:catraca]+ com +identificacao+, +restaurante_id+, +piso_numero+ e +ativa+.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: os de #salvar, renderizando +new+ na falha.
    def create
      @catraca = Catraca.new
      salvar(:new, "Catraca cadastrada com sucesso")
    end

    # GET /admin/catracas/:id/edit: abre a edição com o restaurante e o piso atuais.
    #
    # Argumentos:: +params[:id]+: catraca editada.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: consulta o piso da catraca e renderiza +edit+.
    def edit
      piso = @catraca.piso
      @restaurante_id = piso.restaurante_id
      @piso_numero = piso.numero
    end

    # PATCH /admin/catracas/:id: atualiza a identificação, o local e a situação da catraca.
    #
    # Argumentos:: +params[:id]+ e +params[:catraca]+, como em #create.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: os de #salvar, renderizando +edit+ na falha.
    def update
      salvar(:edit, "Catraca atualizada com sucesso")
    end

    # GET /admin/catracas/:id/remover: pede a confirmação da remoção.
    #
    # Argumentos:: +params[:id]+: catraca a remover.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: renderiza +remover+, sem remover nada.
    def remover
    end

    # DELETE /admin/catracas/:id: remove a catraca.
    #
    # Argumentos:: +params[:id]+: catraca a remover.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: apaga a catraca fora de operação e redireciona à lista de restaurantes com
    #                      aviso; em operação, não apaga e redireciona com o alerta do erro.
    def destroy
      remover_e_voltar_a_lista(@catraca, "Catraca removida com sucesso")
    end

    private

    # Filtro +before_action+ que carrega a catraca da rota.
    #
    # Argumentos:: +params[:id]+: identificador da catraca.
    # Retorno:: a Catraca encontrada.
    # Efeitos colaterais:: define +@catraca+; lança ActiveRecord::RecordNotFound (HTTP 404) se ela
    #                      não existe.
    def carregar_catraca
      @catraca = Catraca.find(params[:id])
    end

    # Aplica o formulário à catraca, localiza o piso no restaurante escolhido e grava.
    #
    # Argumentos:: +tela+ (Symbol): template renderizado na falha (+:new+ ou +:edit+).
    #              +mensagem_sucesso+ (String): aviso exibido após gravar.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: grava a catraca e redireciona à lista de restaurantes com aviso; com
    #                      restaurante inexistente ou dados inválidos (ex.: piso inexistente), não
    #                      grava e renderiza +tela+ com HTTP 422.
    def salvar(tela, mensagem_sucesso)
      preencher_catraca(params_catraca)
      restaurante = Restaurante.find_by(id: @restaurante_id)
      return recusar_restaurante_inexistente(tela) if restaurante.nil?

      @catraca.piso = restaurante.pisos.find_by(numero: @piso_numero)
      if @catraca.save
        redirect_to admin_restaurantes_path, notice: mensagem_sucesso
      else
        render tela, status: :unprocessable_content
      end
    end

    # Lê os campos permitidos do formulário de catraca.
    #
    # Argumentos:: +params[:catraca]+ com +identificacao+, +restaurante_id+, +piso_numero+ e +ativa+.
    # Retorno:: ActionController::Parameters com os campos permitidos.
    # Efeitos colaterais:: lança ActionController::ParameterMissing (HTTP 400) sem +params[:catraca]+.
    def params_catraca
      params.expect(catraca: %i[identificacao restaurante_id piso_numero ativa])
    end

    # Copia os dados do formulário para a catraca e para as variáveis da tela.
    #
    # Argumentos:: +dados+ (ActionController::Parameters): campos de #params_catraca.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define +@restaurante_id+ e +@piso_numero+ e altera a catraca em memória,
    #                      sem gravar; +ativa+ só muda quando o campo foi enviado.
    def preencher_catraca(dados)
      @restaurante_id = dados[:restaurante_id]
      @piso_numero = dados[:piso_numero]
      @catraca.identificacao = dados[:identificacao]
      @catraca.ativa = dados[:ativa] if dados.key?(:ativa)
    end

    # Recusa o formulário quando o restaurante escolhido não existe.
    #
    # Argumentos:: +tela+ (Symbol): template renderizado (+:new+ ou +:edit+).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: adiciona MSG_RESTAURANTE_NAO_ENCONTRADO em +base+ e renderiza +tela+ com HTTP 422.
    def recusar_restaurante_inexistente(tela)
      @catraca.errors.add(:base, MSG_RESTAURANTE_NAO_ENCONTRADO)
      render tela, status: :unprocessable_content
    end
  end
end
