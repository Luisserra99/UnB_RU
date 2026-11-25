# Telas de administração do sistema, restritas a funcionários com papel de administrador.
module Admin
  # Base das telas de administração: além da sessão de funcionário, exige o papel de administrador.
  class BaseController < Controle::BaseController
    # Aviso mostrado ao funcionário sem papel de administrador.
    MSG_SOMENTE_ADMINISTRADORES = "Acesso negado: esta função é restrita a administradores.".freeze

    before_action :exigir_administrador!

    private

    # Filtro +before_action+ que barra quem não é administrador.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: quando o funcionário logado não é administrador, redireciona ao painel de
    #                      controle com o alerta MSG_SOMENTE_ADMINISTRADORES, interrompendo a ação.
    def exigir_administrador!
      return if funcionario_atual.administrador?

      redirect_to controle_root_path, alert: MSG_SOMENTE_ADMINISTRADORES
    end

    # Remove um registro da gestão física (restaurante ou catraca) e volta à lista de restaurantes.
    #
    # Argumentos:: +registro+ (ApplicationRecord): registro a remover.
    #              +aviso+ (String): mensagem exibida quando a remoção dá certo.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: apaga o registro e redireciona à lista de restaurantes com +aviso+; quando
    #                      um callback impede a remoção, não apaga nada e redireciona com os erros do
    #                      registro como alerta.
    def remover_e_voltar_a_lista(registro, aviso)
      if registro.destroy
        redirect_to admin_restaurantes_path, notice: aviso
      else
        redirect_to admin_restaurantes_path, alert: registro.errors.full_messages.to_sentence
      end
    end
  end
end
