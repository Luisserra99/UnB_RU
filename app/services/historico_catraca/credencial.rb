# F07 — RN07.1: valida a credencial (matrícula e senha) de quem pede o histórico de uma catraca.
# Só passa o funcionário ativo que gerencia a catraca agora, ou seja, que tem um ponto de acesso
# confirmado nela numa sessão válida. Qualquer outra situação é "Credencial inválida", sem dizer o motivo.
module HistoricoCatraca
  class Credencial
    MSG_INVALIDA = "Credencial inválida".freeze

    def self.valida?(matricula:, senha:, catraca:)
      usuario = Usuario.autenticar(matricula.to_s.strip, senha.to_s)
      return false unless usuario&.pode_acessar_controle?

      ConfiguracaoPontoAcesso.em_sessoes_validas
        .where(catraca_id: catraca.id, sessao_autenticacoes: { usuario_id: usuario.id, ponto_acesso_pendente: false })
        .exists?
    end
  end
end
