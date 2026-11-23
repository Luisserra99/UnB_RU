# Serviços de operação dos terminais de acesso ao restaurante.
module Catracas
  # Comandos de um terminal simulado. Datas são sempre do servidor, nunca enviadas pelo cliente.
  class Operar
    # Comando que não pode ser executado no estado atual da catraca.
    class Invalido < StandardError; end

    # Associa os comandos a um ponto de acesso confirmado.
    #
    # Argumentos:: +configuracao+ (ConfiguracaoPontoAcesso): origem das leituras.
    # Retorno:: Operar inicializado.
    # Efeitos colaterais:: nenhum.
    def initialize(configuracao)
      @configuracao = configuracao
    end

    # Registra uma leitura ou devolve o evento já registrado pela mesma configuração.
    #
    # Argumentos:: +identificacao+ (String ou nil): matrícula lida; +referencia+ (String): chave do evento.
    # Retorno:: RegistroAcesso liberado ou recusado; o registro anterior para referência repetida.
    # Efeitos colaterais:: sob lock da sessão, expira liberações e grava a leitura, sem debitar;
    #                      lança Invalido para entrada, ponto ou sequência inválidos e propaga erros do banco.
    def ler(identificacao:, referencia:)
      validar_leitura!(identificacao, referencia)
      @configuracao.sessao_autenticacao.with_lock do
        exigir_ponto!
        existente = registro_da_referencia(referencia)
        return existente if existente
        exigir_catraca_livre!
        registrar_leitura(identificacao, referencia)
      end
    end

    # Confirma uma passagem e cobra a refeição uma única vez, dentro do prazo inclusivo.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura do ponto atual.
    # Retorno:: RegistroAcesso realizado, cancelado por prazo/saldo, ou inalterado se já concluído/recusado.
    # Efeitos colaterais:: bloqueia sessão, leitura e estudante; grava passagem, débito e rateios na
    #                      mesma transação; lança Invalido ou erro do banco com rollback em caso de falha.
    def passar(registro)
      @configuracao.sessao_autenticacao.with_lock do
        exigir_ponto!
        registro.lock!
        return registro unless registro.liberado?
        agora = Time.current
        return cancelar(registro, em: registro.limite_em) if agora > registro.limite_em
        cobrar_passagem!(registro, agora)
        registro
      end
    end

    # Registra a confirmação física da liberação e reinicia a janela de cinco segundos (F07).
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura cuja liberação foi confirmada.
    # Retorno:: RegistroAcesso com horário atualizado; cancelado se vencido; inalterado se não está liberado.
    # Efeitos colaterais:: bloqueia sessão e leitura e grava o horário ou cancelamento; lança Invalido
    #                      para ponto indisponível e propaga erros do banco. Sem confirmação, vale a leitura.
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

    # Cancela uma liberação apenas quando o prazo de passagem já foi ultrapassado.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura a verificar.
    # Retorno:: RegistroAcesso cancelado se vencido; inalterado nos demais casos.
    # Efeitos colaterais:: bloqueia sessão e leitura, grava eventual cancelamento sem débito
    #                      e propaga erros do banco.
    def expirar(registro)
      @configuracao.sessao_autenticacao.with_lock do
        registro.lock!
        cancelar(registro, em: registro.limite_em) if registro.liberado? && Time.current > registro.limite_em
        registro
      end
    end

    # Cancela todas as liberações vencidas do ponto de acesso.
    #
    # Argumentos:: nenhum.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: bloqueia a sessão e cada leitura vencida, grava cancelamentos sem débito
    #                      e propaga erros do banco.
    def expirar_pendentes!
      @configuracao.sessao_autenticacao.with_lock do
        liberacoes_vencidas.find_each do |registro|
          registro.lock!
          cancelar(registro, em: registro.limite_em) if registro.liberado?
        end
      end
    end

    private

    # Valida o formato da referência e o tamanho máximo da identificação recebida.
    #
    # Argumentos:: +identificacao+ (String ou nil): leitura bruta; +referencia+ (Object): chave recebida.
    # Retorno:: nil quando as entradas são aceitas.
    # Efeitos colaterais:: lança Invalido para referência inválida ou identificação maior que 100 caracteres.
    def validar_leitura!(identificacao, referencia)
      raise Invalido, "Referência de evento inválida" unless referencia_valida?(referencia)
      raise Invalido, "Identificação inválida" if identificacao.to_s.length > 100
    end

    # Verifica se a referência é uma string não vazia de até 64 caracteres.
    #
    # Argumentos:: +referencia+ (Object): valor recebido do terminal.
    # Retorno:: true para referência válida; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def referencia_valida?(referencia)
      referencia.is_a?(String) && referencia.present? && referencia.length <= 64
    end

    # Localiza um evento repetido sem permitir reutilizar a referência de outro ponto.
    #
    # Argumentos:: +referencia+ (String): chave validada do evento.
    # Retorno:: RegistroAcesso do ponto atual; nil para uma referência nova.
    # Efeitos colaterais:: consulta o banco e lança Invalido se a referência pertence a outro ponto.
    def registro_da_referencia(referencia)
      existente = @configuracao.registros_acesso.find_by(referencia_evento: referencia)
      return existente if existente
      raise Invalido, "Referência de evento inválida" if RegistroAcesso.exists?(referencia_evento: referencia)
      nil
    end

    # Exige que nenhuma liberação vigente esteja aguardando passagem.
    #
    # Argumentos:: nenhum.
    # Retorno:: nil se a catraca pode receber outra leitura.
    # Efeitos colaterais:: expira liberações antigas; lança Invalido se ainda há liberação pendente.
    def exigir_catraca_livre!
      expirar_pendentes!
      raise Invalido, "Aguarde a passagem ou o bloqueio da catraca" if @configuracao.registros_acesso.liberado.exists?
    end

    # Constrói e persiste uma leitura com o resultado da avaliação do estudante.
    #
    # Argumentos:: +identificacao+ (String ou nil): leitura bruta; +referencia+ (String): chave do evento.
    # Retorno:: RegistroAcesso persistido, liberado ou recusado.
    # Efeitos colaterais:: consulta estudante, saldo e refeição e grava a leitura; propaga erros do banco.
    def registrar_leitura(identificacao, referencia)
      registro = @configuracao.registros_acesso.new(referencia_evento: referencia,
        identificacao_lida: identificacao.to_s.strip, lido_em: Time.current, estado: :recusado,
        mensagem: "Identificação desconhecida")
      avaliar_estudante(registro)
      registro.save!
      registro
    end

    # Associa à leitura apenas um estudante com matrícula válida, vínculo e usuário ativos.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura ainda não persistida.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: consulta o banco e preenche estudante, saldo, refeição e resultado em memória.
    def avaliar_estudante(registro)
      estudante = Estudante.com_vinculo_ativo.joins(:usuario).where(usuarios: { ativo: true })
        .find_by(matricula: registro.identificacao_lida)
      return unless estudante && Estudante::FORMATO_MATRICULA.match?(registro.identificacao_lida)
      registro.estudante = estudante
      registro.saldo_lido = estudante.saldo
      carregar_refeicao(registro)
      avaliar_liberacao(registro)
    end

    # Captura a refeição em andamento e sua tarifa no instante da leitura.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura com estudante identificado.
    # Retorno:: BigDecimal com o valor previsto; nil quando não há tarifa vigente.
    # Efeitos colaterais:: consulta serviço e tarifa e preenche as associações em memória.
    def carregar_refeicao(registro)
      servico = @configuracao.restaurante.servicos_refeicao.em_andamento(registro.lido_em)
      tarifa = servico && TarifaRefeicao.vigente_para(servico.tipo_refeicao, registro.lido_em)
      registro.servico_refeicao = servico
      registro.tarifa_refeicao = tarifa
      registro.valor_previsto = tarifa&.valor
    end

    # Decide a liberação a partir da tarifa vigente e do saldo capturado.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura com refeição e saldo avaliados.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: altera mensagem, estado e horário de liberação apenas em memória.
    def avaliar_liberacao(registro)
      if registro.tarifa_refeicao.nil?
        registro.mensagem = "Nenhuma refeição disponível neste horário"
      elsif registro.saldo_lido < registro.tarifa_refeicao.valor
        registro.mensagem = "Saldo insuficiente"
      else
        registro.assign_attributes(estado: :liberado, liberado_em: registro.lido_em, mensagem: "Catraca liberada")
      end
    end

    # Revalida o estudante e efetiva a passagem sob seu lock de escrita.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura liberada no prazo;
    #              +agora+ (ActiveSupport::TimeWithZone): instante da passagem.
    # Retorno:: RegistroAcesso cancelado se perdeu vínculo/saldo; nenhum relevante no sucesso.
    # Efeitos colaterais:: atualiza o estudante para adquirir lock no SQLite e grava passagem, débito
    #                      e rateios; propaga falhas para rollback da transação de #passar.
    def cobrar_passagem!(registro, agora)
      estudante = registro.estudante
      estudante.with_lock do
        # Força aquisição do lock de escrita também no SQLite antes de reler o saldo.
        estudante.touch
        return cancelar(registro, em: agora, mensagem: "Saldo insuficiente") unless estudante_apto?(estudante, registro)
        registro.update!(estado: :realizado, passagem_em: agora, bloqueado_em: agora, mensagem: "Boa refeição")
        ratear!(debitar!(estudante, registro, agora))
      end
    end

    # Confere novamente o vínculo, o usuário ativo e o saldo suficiente na passagem.
    #
    # Argumentos:: +estudante+ (Estudante): estudante bloqueado; +registro+ (RegistroAcesso): leitura liberada.
    # Retorno:: true se o estudante pode consumir; false caso contrário.
    # Efeitos colaterais:: consulta usuário e saldo, sem gravar alterações.
    def estudante_apto?(estudante, registro)
      estudante.vinculo_ativo? && estudante.usuario.ativo? && estudante.saldo >= registro.valor_previsto
    end

    # Grava o débito associado exclusivamente à passagem realizada.
    #
    # Argumentos:: +estudante+ (Estudante): titular; +registro+ (RegistroAcesso): passagem realizada;
    #              +agora+ (ActiveSupport::TimeWithZone): horário do servidor.
    # Retorno:: MovimentacaoSaldo com valor negativo igual ao preço previsto.
    # Efeitos colaterais:: grava o débito e propaga erros do banco para rollback do chamador.
    def debitar!(estudante, registro, agora)
      MovimentacaoSaldo.create!(estudante: estudante, registro_acesso: registro,
        natureza: :debito_refeicao, valor: -registro.valor_previsto, ocorrida_em: agora)
    end

    # Seleciona liberações cujo prazo já terminou, sem incluir o quinto segundo exato.
    #
    # Argumentos:: nenhum.
    # Retorno:: ActiveRecord::Relation de RegistroAcesso vencidos do ponto.
    # Efeitos colaterais:: nenhum; a relação consulta o banco quando consumida.
    def liberacoes_vencidas
      @configuracao.registros_acesso.liberado.where("liberado_em < ?", Time.current - RegistroAcesso::LIMITE_PASSAGEM)
    end

    # Recarrega e exige um ponto confirmado e disponível para a operação.
    #
    # Argumentos:: nenhum.
    # Retorno:: nil quando o ponto está disponível.
    # Efeitos colaterais:: recarrega a configuração e lança Invalido se não pode operar.
    def exigir_ponto!
      @configuracao.reload
      raise Invalido, "Confirme o ponto de acesso para operar a catraca" unless @configuracao.disponivel?
    end

    # Bloqueia uma leitura sem registrar passagem nem cobrança.
    #
    # Argumentos:: +registro+ (RegistroAcesso): leitura; +em+ (ActiveSupport::TimeWithZone): bloqueio;
    #              +mensagem+ (String): motivo, por padrão "Acesso cancelado".
    # Retorno:: RegistroAcesso cancelado.
    # Efeitos colaterais:: grava estado, bloqueio e mensagem; propaga erros de gravação.
    def cancelar(registro, em:, mensagem: "Acesso cancelado")
      registro.update!(estado: :cancelado, bloqueado_em: em, mensagem: mensagem)
      registro
    end

    # Distribui o débito entre créditos reais em FIFO por confirmação e identificador.
    #
    # Argumentos:: +debito+ (MovimentacaoSaldo): débito de refeição persistido.
    # Retorno:: nil quando todo o débito foi distribuído.
    # Efeitos colaterais:: grava os rateios; lança Invalido se faltam créditos e propaga erros do
    #                      banco para rollback da passagem, do débito e dos rateios pelo chamador.
    def ratear!(debito)
      restante = debito.valor.abs
      creditos_no_fifo(debito).each do |credito|
        restante = consumir_credito!(debito, credito, restante)
        break if restante.zero?
      end
      raise Invalido, "Créditos indisponíveis para rateio" unless restante.zero?
    end

    # Ordena apenas os créditos efetivos do estudante, incluindo suas recargas.
    #
    # Argumentos:: +debito+ (MovimentacaoSaldo): consumo a distribuir.
    # Retorno:: ActiveRecord::Relation de créditos em ordem de ocorrência e identificador.
    # Efeitos colaterais:: nenhum; consulta o banco quando a relação é consumida.
    def creditos_no_fifo(debito)
      debito.estudante.movimentacoes_saldo.creditos.includes(:recarga).order(:ocorrida_em, :id)
    end

    # Consome até o saldo disponível de uma recarga, ignorando créditos já esgotados.
    #
    # Argumentos:: +debito+ e +credito+ (MovimentacaoSaldo): destino e origem;
    #              +restante+ (BigDecimal): parcela ainda não distribuída.
    # Retorno:: BigDecimal com o restante após o consumo, ou inalterado se o crédito está esgotado.
    # Efeitos colaterais:: consulta rateios e grava a parcela consumida; propaga erros do banco.
    def consumir_credito!(debito, credito, restante)
      disponivel = credito.valor - RateioConsumo.where(recarga_id: credito.recarga_id).sum(:valor)
      return restante unless disponivel.positive?
      valor = [ restante, disponivel ].min
      debito.rateios_consumo.create!(recarga: credito.recarga, valor: valor)
      restante - valor
    end
  end
end
