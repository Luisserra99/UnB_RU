# Serviços de seleção do restaurante e da catraca da aplicação de controle.
module PontosAcesso
  # Valida a seleção e preserva o histórico das configurações anteriores (F05).
  class Configurar
    # Seleção ou sessão que não permite confirmar um ponto de acesso.
    class Invalido < StandardError; end

    # Confirma uma seleção de ponto de acesso para a sessão informada.
    #
    # Argumentos:: +sessao+ (SessaoAutenticacao): sessão do operador; +restaurante_id+ e
    #              +catraca_id+ (String ou Integer): identificadores escolhidos.
    # Retorno:: ConfiguracaoPontoAcesso criada para a seleção.
    # Efeitos colaterais:: cancela liberações antigas, encerra pontos anteriores e grava o novo
    #                      ponto numa transação; lança Invalido para seleção ou sessão inválida
    #                      e propaga ActiveRecord::RecordInvalid em falhas de gravação.
    def self.call(sessao:, restaurante_id:, catraca_id:)
      new(sessao).call(restaurante_id: restaurante_id, catraca_id: catraca_id)
    end

    # Guarda a sessão cuja seleção será confirmada.
    #
    # Argumentos:: +sessao+ (SessaoAutenticacao): sessão do operador.
    # Retorno:: Configurar inicializado.
    # Efeitos colaterais:: nenhum.
    def initialize(sessao)
      @sessao = sessao
    end

    # Valida e grava uma seleção sob o lock da sessão.
    #
    # Argumentos:: +restaurante_id+ e +catraca_id+ (String ou Integer): identificadores escolhidos.
    # Retorno:: ConfiguracaoPontoAcesso criada.
    # Efeitos colaterais:: encerra configurações anteriores e grava a nova atomicamente;
    #                      lança Invalido ou ActiveRecord::RecordInvalid sem gravações parciais.
    def call(restaurante_id:, catraca_id:)
      @sessao.with_lock do
        exigir_sessao!
        restaurante = localizar_restaurante!(restaurante_id)
        catraca = localizar_catraca!(catraca_id, restaurante)
        confirmar!(restaurante, catraca)
      end
    end

    private

    # Exige sessão vigente e papel autorizado na aplicação de controle.
    #
    # Argumentos:: nenhum.
    # Retorno:: nil quando a sessão está autorizada.
    # Efeitos colaterais:: consulta usuário e papéis; lança Invalido se a sessão não pode operar.
    def exigir_sessao!
      raise Invalido, "Sessão inválida" unless @sessao.ativa? && @sessao.usuario.pode_acessar_controle?
    end

    # Obtém o restaurante ativo solicitado.
    #
    # Argumentos:: +identificador+ (String, Integer ou nil): identificador da seleção.
    # Retorno:: Restaurante ativo.
    # Efeitos colaterais:: consulta o banco; lança Invalido se não foi selecionado ou está indisponível.
    def localizar_restaurante!(identificador)
      raise Invalido, "Selecione um restaurante" if identificador.blank?
      Restaurante.ativos.find_by(id: identificador) || raise(Invalido, "Restaurante indisponível")
    end

    # Obtém a catraca disponível e confere seu vínculo com o restaurante.
    #
    # Argumentos:: +identificador+ (String, Integer ou nil): catraca escolhida;
    #              +restaurante+ (Restaurante): restaurante validado.
    # Retorno:: Catraca disponível no restaurante.
    # Efeitos colaterais:: consulta o banco; lança Invalido para seleção ausente, indisponível ou incompatível.
    def localizar_catraca!(identificador, restaurante)
      raise Invalido, "Selecione uma catraca do restaurante" if identificador.blank?
      catraca = Catraca.disponiveis.find_by(id: identificador)
      raise Invalido, "Catraca indisponível" unless catraca
      raise Invalido, "A catraca não pertence ao restaurante selecionado" unless catraca.restaurante == restaurante
      catraca
    end

    # Substitui o ponto atual após concluir todas as validações da seleção.
    #
    # Argumentos:: +restaurante+ (Restaurante) e +catraca+ (Catraca): seleção validada.
    # Retorno:: ConfiguracaoPontoAcesso criada.
    # Efeitos colaterais:: cancela liberações, encerra pontos anteriores, cria o ponto e remove
    #                      a pendência da sessão; propaga erros de gravação para rollback do chamador.
    def confirmar!(restaurante, catraca)
      agora = Time.current
      encerrar_configuracoes!(agora)
      configuracao = @sessao.configuracoes_ponto_acesso.create!(restaurante: restaurante, catraca: catraca, confirmada_em: agora)
      @sessao.update!(ponto_acesso_pendente: false)
      configuracao
    end

    # Finaliza os pontos anteriores usando o mesmo horário da nova confirmação.
    #
    # Argumentos:: +agora+ (ActiveSupport::TimeWithZone): horário do servidor.
    # Retorno:: Integer com a quantidade de configurações encerradas.
    # Efeitos colaterais:: cancela liberações e atualiza as configurações abertas no banco;
    #                      propaga erros de gravação para rollback do chamador.
    def encerrar_configuracoes!(agora)
      @sessao.configuracoes_ponto_acesso.abertas.each(&:cancelar_liberacoes!)
      @sessao.configuracoes_ponto_acesso.abertas.update_all(finalizada_em: agora, updated_at: agora)
    end
  end
end
