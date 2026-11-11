# F07 — Histórico local da catraca (responsável: Weldo).
# Exige sessão de funcionário (F04) e ponto de acesso confirmado (F05); antes de mostrar o histórico,
# pede de novo matrícula e senha (RN07.1). A liberação vale só para o ponto atual e por pouco tempo.
module Controle
  class HistoricoController < BaseController
    CHAVE_SESSAO = :historico_catraca
    VALIDADE = 15.minutes

    before_action :exigir_ponto_acesso!

    def show
      @catraca = ponto_acesso_atual.catraca
      return unless historico_liberado?

      @consulta = HistoricoCatraca::Consulta.new(@catraca, pagina: params[:pagina])
    end

    def create
      @catraca = ponto_acesso_atual.catraca

      if HistoricoCatraca::Credencial.valida?(matricula: params[:matricula], senha: params[:senha], catraca: @catraca)
        session[CHAVE_SESSAO] = { "configuracao_id" => ponto_acesso_atual.id, "ate" => VALIDADE.from_now.to_i }
        redirect_to controle_historico_path, notice: "Credencial validada"
      else
        session.delete(CHAVE_SESSAO)
        @matricula = params[:matricula].to_s.strip
        flash.now[:alert] = HistoricoCatraca::Credencial::MSG_INVALIDA
        render :show, status: :unprocessable_content
      end
    end

    def destroy
      session.delete(CHAVE_SESSAO)
      redirect_to controle_historico_path, notice: "Histórico bloqueado"
    end

    private

    def historico_liberado?
      liberacao = session[CHAVE_SESSAO]
      liberacao.is_a?(Hash) &&
        liberacao["configuracao_id"] == ponto_acesso_atual.id &&
        liberacao["ate"].to_i > Time.current.to_i
    end
  end
end
