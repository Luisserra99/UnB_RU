# F07 — Histórico local da catraca (responsável: Weldo).
# Exige sessão de funcionário (F04) e ponto de acesso confirmado (F05); antes de mostrar o histórico,
# pede de novo matrícula e senha (RN07.1). A liberação vale só para o ponto atual e por pouco tempo.
module Controle
  # Tela do histórico local da catraca gerenciada pelo funcionário (F07).
  class HistoricoController < BaseController
    # Chave da sessão do navegador que guarda a liberação do histórico.
    CHAVE_SESSAO = :historico_catraca
    # Por quanto tempo a credencial confirmada libera o histórico.
    VALIDADE = 15.minutes

    before_action :exigir_ponto_acesso!

    # GET /controle/historico: mostra o histórico da catraca ou o pedido de credencial.
    #
    # Argumentos:: +params[:pagina]+ (opcional): página da listagem.
    # Retorno:: nenhum (renderiza +show+).
    # Efeitos colaterais:: com a liberação vigente, consulta os registros da catraca em @consulta;
    #                      sem ela, a tela mostra só o formulário de credencial.
    def show
      @catraca = ponto_acesso_atual.catraca
      return unless historico_liberado?

      @consulta = HistoricoCatraca::Consulta.new(@catraca, pagina: params[:pagina])
    end

    # POST /controle/historico: confere a credencial e libera o histórico (RN07.1).
    #
    # Argumentos:: +params[:matricula]+ e +params[:senha]+.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: com credencial válida, grava a liberação na sessão e redireciona para o
    #                      histórico; com credencial inválida, apaga a liberação e renderiza +show+
    #                      com status 422 e "Credencial inválida".
    def create
      @catraca = ponto_acesso_atual.catraca
      credencial_valida? ? liberar_historico : recusar_credencial
    end

    # DELETE /controle/historico: bloqueia o histórico de novo.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: apaga a liberação da sessão e redireciona para o histórico, que volta a
    #                      pedir a credencial.
    def destroy
      session.delete(CHAVE_SESSAO)
      redirect_to controle_historico_path, notice: "Histórico bloqueado"
    end

    private

    # Confere a credencial enviada para a catraca atual.
    #
    # Argumentos:: nenhum (lê +params[:matricula]+, +params[:senha]+ e @catraca).
    # Retorno:: true se HistoricoCatraca::Credencial.valida? aceita a credencial; false caso contrário.
    # Efeitos colaterais:: consulta o banco.
    def credencial_valida?
      HistoricoCatraca::Credencial.valida?(matricula: params[:matricula], senha: params[:senha], catraca: @catraca)
    end

    # Libera o histórico para o ponto de acesso atual durante VALIDADE.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: grava o id da configuração e o fim da validade na sessão do navegador e
    #                      redireciona para o histórico com "Credencial validada".
    def liberar_historico
      session[CHAVE_SESSAO] = { "configuracao_id" => ponto_acesso_atual.id, "ate" => VALIDADE.from_now.to_i }
      redirect_to controle_historico_path, notice: "Credencial validada"
    end

    # Recusa a credencial sem dizer o motivo.
    #
    # Argumentos:: nenhum (lê +params[:matricula]+).
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: apaga uma liberação anterior da sessão, guarda a matrícula digitada em
    #                      @matricula, põe "Credencial inválida" no flash e renderiza +show+ com
    #                      status 422.
    def recusar_credencial
      session.delete(CHAVE_SESSAO)
      @matricula = params[:matricula].to_s.strip
      flash.now[:alert] = HistoricoCatraca::Credencial::MSG_INVALIDA
      render :show, status: :unprocessable_content
    end

    # Indica se a sessão tem uma liberação do histórico vigente para o ponto de acesso atual.
    #
    # Argumentos:: nenhum.
    # Retorno:: true se a liberação existe, é do ponto de acesso atual e ainda não venceu; false caso
    #           contrário (inclusive depois de trocar de catraca ou de VALIDADE).
    # Efeitos colaterais:: nenhum.
    def historico_liberado?
      liberacao = session[CHAVE_SESSAO]
      liberacao.is_a?(Hash) && liberacao_vigente?(liberacao)
    end

    # Confere se a liberação guardada é do ponto de acesso atual e ainda está no prazo.
    #
    # Argumentos:: +liberacao+ (Hash): <tt>{"configuracao_id" => Integer, "ate" => Integer}</tt>,
    #              gravado por #liberar_historico.
    # Retorno:: true se a configuração é a do ponto atual e "ate" (segundos desde a época) ainda não
    #           passou; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def liberacao_vigente?(liberacao)
      liberacao["configuracao_id"] == ponto_acesso_atual.id && liberacao["ate"].to_i > Time.current.to_i
    end
  end
end
