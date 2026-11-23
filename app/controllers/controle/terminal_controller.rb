# Aplicação de controle dos funcionários do restaurante.
module Controle
  # Interface HTTP do terminal simulado de leitura e passagem (F06).
  class TerminalController < BaseController
    before_action :exigir_ponto_acesso!

    # GET /controle/terminal: mostra a leitura selecionada e a liberação pendente.
    #
    # Argumentos:: +params[:registro_id]+ (String ou nil): leitura da configuração atual.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: expira liberações vencidas, gera a referência do próximo evento
    #                      e renderiza o terminal com o registro encontrado, ou sem registro.
    def show
      operador.expirar_pendentes!
      @registro = registros.find_by(id: params[:registro_id])
      @pendente = registros.liberado.first
      @referencia = SecureRandom.uuid
    end

    # POST /controle/terminal/leituras: registra uma identificação no ponto atual.
    #
    # Argumentos:: +params[:identificacao]+ e +params[:referencia_evento]+ (String): leitura e referência.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: grava ou reutiliza a leitura e redireciona ao registro; se o comando
    #                      for inválido, redireciona ao terminal com o motivo no flash.
    def ler
      registro = operador.ler(identificacao: params[:identificacao], referencia: params[:referencia_evento])
      redirect_to controle_terminal_path(registro_id: registro.id)
    rescue Catracas::Operar::Invalido => erro
      redirect_to controle_terminal_path, alert: erro.message
    end

    # POST /controle/terminal/:id/passagem: confirma a passagem de uma leitura da sessão.
    #
    # Argumentos:: +params[:id]+ (String): identificador da leitura no ponto atual.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: realiza ou cancela a passagem e redireciona ao registro; comando inválido
    #                      redireciona ao painel com erro; registro de outro ponto resulta em HTTP 404.
    def passagem
      registro = operador.passar(registros.find(params[:id]))
      redirect_to controle_terminal_path(registro_id: registro.id)
    rescue Catracas::Operar::Invalido => erro
      redirect_to controle_root_path, alert: erro.message
    end

    # POST /controle/terminal/:id/expirar: verifica o prazo de uma liberação.
    #
    # Argumentos:: +params[:id]+ (String): identificador da leitura no ponto atual.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: cancela a leitura vencida e redireciona ao registro; registro ausente
    #                      ou de outro ponto resulta em HTTP 404.
    def expirar
      registro = operador.expirar(registros.find(params[:id]))
      redirect_to controle_terminal_path(registro_id: registro.id)
    end

    private

    # Obtém o serviço de operação para o ponto confirmado da sessão.
    #
    # Argumentos:: nenhum.
    # Retorno:: Catracas::Operar associado ao ponto atual.
    # Efeitos colaterais:: memoriza o serviço durante a requisição.
    def operador
      @operador ||= Catracas::Operar.new(ponto_acesso_atual)
    end

    # Restringe as leituras ao ponto de acesso atual.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso.
    # Efeitos colaterais:: nenhum; a consulta é executada quando a relação é consumida.
    def registros
      ponto_acesso_atual.registros_acesso
    end
  end
end
