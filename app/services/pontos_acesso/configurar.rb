module PontosAcesso
  class Configurar
    class Invalido < StandardError; end

    def self.call(sessao:, restaurante_id:, catraca_id:)
      sessao.with_lock do
        raise Invalido, "Sessão inválida" unless sessao.ativa? && sessao.usuario.pode_acessar_controle?
        raise Invalido, "Selecione um restaurante" if restaurante_id.blank?
        restaurante = Restaurante.ativos.find_by(id: restaurante_id)
        raise Invalido, "Restaurante indisponível" unless restaurante
        raise Invalido, "Selecione uma catraca do restaurante" if catraca_id.blank?
        catraca = Catraca.disponiveis.find_by(id: catraca_id)
        raise Invalido, "Catraca indisponível" unless catraca
        raise Invalido, "A catraca não pertence ao restaurante selecionado" unless catraca.restaurante == restaurante

        agora = Time.current
        sessao.configuracoes_ponto_acesso.abertas.each(&:cancelar_liberacoes!)
        sessao.configuracoes_ponto_acesso.abertas.update_all(finalizada_em: agora, updated_at: agora)
        configuracao = sessao.configuracoes_ponto_acesso.create!(restaurante: restaurante, catraca: catraca, confirmada_em: agora)
        sessao.update!(ponto_acesso_pendente: false)
        configuracao
      end
    end
  end
end
