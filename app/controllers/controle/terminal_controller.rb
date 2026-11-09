module Controle
  class TerminalController < BaseController
    before_action :exigir_ponto_acesso!

    def show
      operador.expirar_pendentes!
      @registro = registros.find_by(id: params[:registro_id])
      @pendente = registros.liberado.first
      @referencia = SecureRandom.uuid
    end

    def ler
      registro = operador.ler(identificacao: params[:identificacao], referencia: params[:referencia_evento])
      redirect_to controle_terminal_path(registro_id: registro.id)
    rescue Catracas::Operar::Invalido => erro
      redirect_to controle_terminal_path, alert: erro.message
    end

    def passagem
      registro = operador.passar(registros.find(params[:id]))
      redirect_to controle_terminal_path(registro_id: registro.id)
    rescue Catracas::Operar::Invalido => erro
      redirect_to controle_root_path, alert: erro.message
    end

    def expirar
      registro = operador.expirar(registros.find(params[:id]))
      redirect_to controle_terminal_path(registro_id: registro.id)
    end

    private

    def operador
      @operador ||= Catracas::Operar.new(ponto_acesso_atual)
    end

    def registros
      ponto_acesso_atual.registros_acesso
    end
  end
end
