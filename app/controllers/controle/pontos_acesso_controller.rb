module Controle
  class PontosAcessoController < BaseController
    def create
      sessao_atual.with_lock do
        sessao_atual.ponto_acesso_atual&.cancelar_liberacoes!
        sessao_atual.update!(ponto_acesso_pendente: true)
      end
      PontosAcesso::Configurar.call(sessao: sessao_atual, restaurante_id: params[:restaurante_id], catraca_id: params[:catraca_id])
      redirect_to controle_root_path, notice: "Ponto de acesso configurado com sucesso"
    rescue PontosAcesso::Configurar::Invalido => erro
      flash.now[:alert] = erro.message
      carregar_painel
      render "controle/painel/show", status: :unprocessable_content
    end

    def edit
      sessao_atual.with_lock do
        sessao_atual.ponto_acesso_atual&.cancelar_liberacoes!
        sessao_atual.update!(ponto_acesso_pendente: true)
      end
      redirect_to controle_root_path
    end
  end
end
