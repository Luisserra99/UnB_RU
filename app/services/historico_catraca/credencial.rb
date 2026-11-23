# F07 — RN07.1: valida a credencial (matrícula e senha) de quem pede o histórico de uma catraca.
# Só passa o funcionário ativo que gerencia a catraca agora, ou seja, que tem um ponto de acesso
# confirmado nela numa sessão válida. Qualquer outra situação é "Credencial inválida", sem dizer o motivo.
module HistoricoCatraca
  # Conferência da credencial pedida antes de mostrar o histórico local (RN07.1).
  class Credencial
    # Aviso único para qualquer credencial recusada.
    MSG_INVALIDA = "Credencial inválida".freeze

    # Confere se a credencial é de quem gerencia a catraca agora.
    #
    # Argumentos:: +matricula+ (String): identificação digitada; +senha+ (String): senha digitada;
    #              +catraca+ (Catraca): catraca do ponto de acesso atual.
    # Retorno:: true se as credenciais conferem, a conta está ativa, tem papel de controle e tem ponto
    #           de acesso confirmado nessa catraca numa sessão válida; false em qualquer outro caso.
    # Efeitos colaterais:: consulta o banco.
    def self.valida?(matricula:, senha:, catraca:)
      usuario = Usuario.autenticar(matricula.to_s.strip, senha.to_s)
      return false unless usuario&.pode_acessar_controle?

      ConfiguracaoPontoAcesso.em_sessoes_validas
        .where(catraca_id: catraca.id, sessao_autenticacoes: { usuario_id: usuario.id, ponto_acesso_pendente: false })
        .exists?
    end
  end
end
