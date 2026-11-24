module Controle
  # Base de todas as funções da aplicação de controle: exige sessão de funcionário válida.
  class BaseController < ApplicationController
    layout "controle"
    before_action :exigir_funcionario!
    helper_method :ponto_acesso_atual

    private

    # Ponto de acesso (restaurante e catraca) confirmado na sessão atual (F05).
    #
    # Argumentos:: nenhum.
    # Retorno:: ConfiguracaoPontoAcesso aberta mais recente da sessão; nil sem sessão ou sem ponto
    #           confirmado.
    # Efeitos colaterais:: consulta o banco.
    def ponto_acesso_atual
      sessao_atual&.ponto_acesso_atual
    end

    # Filtro das telas que operam a catraca: exige ponto de acesso confirmado e disponível.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: sem ponto de acesso disponível, redireciona para o painel com aviso, o que
    #                      interrompe a ação.
    def exigir_ponto_acesso!
      return if ponto_acesso_atual&.disponivel?
      redirect_to controle_root_path, alert: "Confirme o ponto de acesso para operar a catraca"
    end

    # Carrega os dados da escolha de restaurante e catraca do painel.
    #
    # Argumentos:: nenhum (lê +params[:restaurante_id]+, opcional).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define @restaurantes (ativos), @restaurante (o escolhido ou nil) e
    #                      @catracas (as disponíveis do restaurante escolhido, ou nenhuma).
    def carregar_painel
      @restaurantes = Restaurante.ativos.ordenados
      @restaurante = @restaurantes.find_by(id: params[:restaurante_id])
      @catracas = @restaurante ? @restaurante.catracas.disponiveis.includes(:piso).order(:identificacao) : Catraca.none
    end
  end
end
