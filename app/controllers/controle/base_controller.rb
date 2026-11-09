module Controle
  # Base de todas as funções da aplicação de controle: exige sessão de funcionário válida.
  class BaseController < ApplicationController
    layout "controle"
    before_action :exigir_funcionario!
    helper_method :ponto_acesso_atual

    private

    def ponto_acesso_atual
      sessao_atual&.ponto_acesso_atual
    end

    def exigir_ponto_acesso!
      return if ponto_acesso_atual&.disponivel?
      redirect_to controle_root_path, alert: "Confirme o ponto de acesso para operar a catraca"
    end

    def carregar_painel
      @restaurantes = Restaurante.ativos.ordenados
      @restaurante = @restaurantes.find_by(id: params[:restaurante_id])
      @catracas = @restaurante ? @restaurante.catracas.disponiveis.includes(:piso).order(:identificacao) : Catraca.none
    end
  end
end
