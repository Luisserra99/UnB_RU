module Catracas
  # Comandos de um terminal simulado. Datas são sempre do servidor, nunca enviadas pelo cliente.
  class Operar
    class Invalido < StandardError; end

    def initialize(configuracao)
      @configuracao = configuracao
    end

    def ler(identificacao:, referencia:)
      raise Invalido, "Referência de evento inválida" unless referencia.is_a?(String) && referencia.present? && referencia.length <= 64
      raise Invalido, "Identificação inválida" if identificacao.to_s.length > 100
      @configuracao.sessao_autenticacao.with_lock do
        exigir_ponto!
        existente = @configuracao.registros_acesso.find_by(referencia_evento: referencia)
        return existente if existente
        if RegistroAcesso.exists?(referencia_evento: referencia)
          raise Invalido, "Referência de evento inválida"
        end
        expirar_pendentes!
        raise Invalido, "Aguarde a passagem ou o bloqueio da catraca" if @configuracao.registros_acesso.liberado.exists?

        agora = Time.current
        registro = @configuracao.registros_acesso.new(referencia_evento: referencia,
          identificacao_lida: identificacao.to_s.strip, lido_em: agora, estado: :recusado,
          mensagem: "Identificação desconhecida")
        estudante = Estudante.com_vinculo_ativo.joins(:usuario).where(usuarios: { ativo: true })
          .find_by(matricula: registro.identificacao_lida)
        if estudante && Estudante::FORMATO_MATRICULA.match?(registro.identificacao_lida)
          registro.estudante = estudante
          registro.saldo_lido = estudante.saldo
          servico = @configuracao.restaurante.servicos_refeicao.em_andamento(agora)
          tarifa = servico && TarifaRefeicao.vigente_para(servico.tipo_refeicao, agora)
          registro.servico_refeicao = servico
          registro.tarifa_refeicao = tarifa
          registro.valor_previsto = tarifa&.valor
          if tarifa.nil?
            registro.mensagem = "Nenhuma refeição disponível neste horário"
          elsif registro.saldo_lido < tarifa.valor
            registro.mensagem = "Saldo insuficiente"
          else
            registro.assign_attributes(estado: :liberado, liberado_em: agora, mensagem: "Catraca liberada")
          end
        end
        registro.save!
        registro
      end
    end

    def passar(registro)
      @configuracao.sessao_autenticacao.with_lock do
        exigir_ponto!
        registro.lock!
        return registro unless registro.liberado?
        agora = Time.current
        return cancelar(registro, em: registro.limite_em) if agora > registro.limite_em
        estudante = registro.estudante
        estudante.with_lock do
          # Força aquisição do lock de escrita também no SQLite antes de reler o saldo.
          estudante.touch
          if !estudante.vinculo_ativo? || !estudante.usuario.ativo? || estudante.saldo < registro.valor_previsto
            return cancelar(registro, em: agora, mensagem: "Saldo insuficiente")
          end
          registro.update!(estado: :realizado, passagem_em: agora, bloqueado_em: agora, mensagem: "Boa refeição")
          debito = MovimentacaoSaldo.create!(estudante: estudante, registro_acesso: registro,
            natureza: :debito_refeicao, valor: -registro.valor_previsto, ocorrida_em: agora)
          ratear!(debito)
        end
        registro
      end
    end

    # F07: confirmação física da liberação, que a catraca pode enviar alguns instantes após a leitura.
    # O prazo de 5 segundos para a passagem passa a contar a partir dessa confirmação.
    # Opcional: sem ela, vale a liberação registrada no momento da leitura.
    def confirmar_liberacao(registro)
      @configuracao.sessao_autenticacao.with_lock do
        exigir_ponto!
        registro.lock!
        return registro unless registro.liberado? && registro.passagem_em.nil?
        agora = Time.current
        return cancelar(registro, em: registro.limite_em) if agora > registro.limite_em
        registro.update!(liberado_em: agora)
        registro
      end
    end

    def expirar(registro)
      @configuracao.sessao_autenticacao.with_lock do
        registro.lock!
        cancelar(registro, em: registro.limite_em) if registro.liberado? && Time.current > registro.limite_em
        registro
      end
    end

    def expirar_pendentes!
      @configuracao.sessao_autenticacao.with_lock do
        @configuracao.registros_acesso.liberado.where("liberado_em < ?", Time.current - RegistroAcesso::LIMITE_PASSAGEM).find_each do |registro|
          registro.lock!
          cancelar(registro, em: registro.limite_em) if registro.liberado?
        end
      end
    end

    private

    def exigir_ponto!
      @configuracao.reload
      raise Invalido, "Confirme o ponto de acesso para operar a catraca" unless @configuracao.disponivel?
    end

    def cancelar(registro, em:, mensagem: "Acesso cancelado")
      registro.update!(estado: :cancelado, bloqueado_em: em, mensagem: mensagem)
      registro
    end

    # FIFO por confirmação e id. Consome somente créditos reais, nunca valores de pedidos pendentes.
    def ratear!(debito)
      restante = debito.valor.abs
      debito.estudante.movimentacoes_saldo.creditos.includes(:recarga).order(:ocorrida_em, :id).each do |credito|
        disponivel = credito.valor - RateioConsumo.where(recarga_id: credito.recarga_id).sum(:valor)
        next unless disponivel.positive?
        valor = [ restante, disponivel ].min
        debito.rateios_consumo.create!(recarga: credito.recarga, valor: valor)
        restante -= valor
        break if restante.zero?
      end
      raise Invalido, "Créditos indisponíveis para rateio" unless restante.zero?
    end
  end
end
