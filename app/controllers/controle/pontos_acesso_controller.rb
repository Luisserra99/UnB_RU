# Aplicação de controle dos funcionários do restaurante.
module Controle
  # Confirma e inicia a troca do ponto de acesso da sessão do funcionário (F05).
  class PontosAcessoController < BaseController
    # POST /controle/ponto_acesso: confirma o restaurante e a catraca escolhidos.
    #
    # Argumentos:: +params[:restaurante_id]+ e +params[:catraca_id]+: identificadores da seleção.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: cancela liberações e grava a configuração; no sucesso, redireciona
    #                      ao painel com aviso; na seleção inválida, renderiza o painel com erro
    #                      e HTTP 422, mantendo a reconfiguração pendente.
    def create
      preparar_reconfiguracao!
      PontosAcesso::Configurar.call(sessao: sessao_atual, restaurante_id: params[:restaurante_id], catraca_id: params[:catraca_id])
      redirect_to controle_root_path, notice: "Ponto de acesso configurado com sucesso"
    rescue PontosAcesso::Configurar::Invalido => erro
      exibir_erro(erro)
    end

    # POST /controle/ponto_acesso/reconfigurar: inicia uma nova seleção.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum (ação de controller).
    # Efeitos colaterais:: cancela liberações, marca a sessão como pendente e redireciona ao painel.
    def edit
      preparar_reconfiguracao!
      redirect_to controle_root_path
    end

    private

    # Suspende a operação do ponto anterior antes de permitir uma nova seleção.
    #
    # Argumentos:: nenhum.
    # Retorno:: true quando a sessão é atualizada.
    # Efeitos colaterais:: cancela liberações e grava a pendência sob lock da sessão;
    #                      propaga ActiveRecord::RecordInvalid se a gravação falhar.
    def preparar_reconfiguracao!
      sessao_atual.with_lock do
        sessao_atual.ponto_acesso_atual&.cancelar_liberacoes!
        sessao_atual.update!(ponto_acesso_pendente: true)
      end
    end

    # Apresenta a seleção recusada no painel de configuração.
    #
    # Argumentos:: +erro+ (PontosAcesso::Configurar::Invalido): motivo da recusa.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: define o flash, carrega as opções e renderiza o painel com HTTP 422.
    def exibir_erro(erro)
      flash.now[:alert] = erro.message
      carregar_painel
      render "controle/painel/show", status: :unprocessable_content
    end
  end
end
