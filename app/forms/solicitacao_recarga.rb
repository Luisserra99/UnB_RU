# Formulário da recarga de saldo (F02): calcula subtotais e total pelas tarifas vigentes
# e, ao confirmar, cria a Recarga, seus itens e o Pagamento pendente numa única transação.
class SolicitacaoRecarga
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Erro de RN02.6: recarga sem nenhuma refeição.
  MSG_COBRANCA_ZERADA = "Não é possível gerar uma cobrança zerada".freeze
  # Aviso após gerar uma cobrança PIX (RN02.4).
  MSG_SUCESSO_PIX = "Código PIX gerado. Válido por 10 minutos.".freeze
  # Aviso após gerar uma cobrança no cartão.
  MSG_SUCESSO_CARTAO = "Cobrança gerada com sucesso".freeze
  # Maior quantidade aceita por categoria.
  QUANTIDADE_MAXIMA = 100

  # A interface agrupa almoço e jantar numa só categoria: ela é registrada como um item do tipo
  # `almoco`, com a tarifa do almoço. O crédito é em reais e serve para qualquer refeição.
  CATEGORIAS = {
    cafes: { codigo: TipoRefeicao::CAFE_DA_MANHA, rotulo: "Cafés da Manhã", unitario: "Café da Manhã" },
    almocos: { codigo: TipoRefeicao::ALMOCO, rotulo: "Almoços/Jantares", unitario: "Almoço/Jantar" }
  }.freeze

  attribute :quantidade_cafes, :string
  attribute :quantidade_almocos, :string
  attribute :metodo, :string

  # Estudante que faz a recarga (Estudante) e recarga criada por #salvar (Recarga ou nil).
  attr_reader :estudante, :recarga

  validate :quantidades_validas
  validate :tarifas_disponiveis
  validate :total_positivo
  validates :metodo, inclusion: { in: Pagamento.metodos.keys, message: "Selecione o método de pagamento" }

  # Cria o formulário.
  #
  # Argumentos:: +estudante+ (Estudante): dono da recarga. +atributos+: +quantidade_cafes+,
  #              +quantidade_almocos+ e +metodo+ ("pix" ou "cartao_credito"), como vêm do formulário.
  # Retorno:: a nova SolicitacaoRecarga.
  # Efeitos colaterais:: nenhum.
  def initialize(estudante:, **atributos)
    @estudante = estudante
    super(**atributos)
  end

  # Converte a quantidade digitada de uma categoria.
  #
  # Argumentos:: +categoria+ (Symbol): uma chave de CATEGORIAS (:cafes ou :almocos).
  # Retorno:: Integer (0 quando em branco) ou nil quando o texto não é um número inteiro.
  # Efeitos colaterais:: nenhum.
  def quantidade(categoria)
    valor = public_send("quantidade_#{categoria}").to_s.strip
    return 0 if valor.empty?

    Integer(valor, 10)
  rescue ArgumentError
    nil
  end

  # Busca a tarifa vigente de uma categoria, guardando o resultado.
  #
  # Argumentos:: +categoria+ (Symbol): uma chave de CATEGORIAS.
  # Retorno:: TarifaRefeicao vigente agora, ou nil se não houver.
  # Efeitos colaterais:: consulta o banco na primeira chamada de cada categoria.
  def tarifa(categoria)
    @tarifas ||= {}
    @tarifas[categoria] ||= TarifaRefeicao.vigente_para(CATEGORIAS.fetch(categoria)[:codigo])
  end

  # Informa o preço unitário de uma categoria.
  #
  # Argumentos:: +categoria+ (Symbol): uma chave de CATEGORIAS.
  # Retorno:: BigDecimal com o valor da tarifa vigente, ou nil sem tarifa.
  # Efeitos colaterais:: nenhum além dos de #tarifa.
  def preco(categoria)
    tarifa(categoria)&.valor
  end

  # Calcula o subtotal de uma categoria: quantidade × preço (RN02.5).
  #
  # Argumentos:: +categoria+ (Symbol): uma chave de CATEGORIAS.
  # Retorno:: BigDecimal; zero se a quantidade for inválida ou negativa, ou se não houver tarifa.
  # Efeitos colaterais:: nenhum além dos de #tarifa.
  def subtotal(categoria)
    qtd = quantidade(categoria)
    return BigDecimal("0") if qtd.nil? || qtd.negative? || preco(categoria).nil?

    preco(categoria) * qtd
  end

  # Soma os subtotais das categorias (RN02.5).
  #
  # Argumentos:: nenhum.
  # Retorno:: BigDecimal com o valor total da recarga.
  # Efeitos colaterais:: nenhum além dos de #tarifa.
  def valor_total
    CATEGORIAS.keys.sum(BigDecimal("0")) { |categoria| subtotal(categoria) }
  end

  # Indica se a recarga não tem nenhum valor a cobrar (RN02.6).
  #
  # Argumentos:: nenhum.
  # Retorno:: true quando o total é zero; false caso contrário.
  # Efeitos colaterais:: nenhum além dos de #tarifa.
  def zerada?
    valor_total.zero?
  end

  # Indica se todas as categorias têm tarifa vigente.
  #
  # Argumentos:: nenhum.
  # Retorno:: true se todas têm tarifa; false se falta alguma.
  # Efeitos colaterais:: nenhum além dos de #tarifa.
  def tarifas_cadastradas?
    CATEGORIAS.keys.all? { |categoria| tarifa(categoria) }
  end

  # Escolhe o aviso mostrado depois de gerar a cobrança.
  #
  # Argumentos:: nenhum.
  # Retorno:: MSG_SUCESSO_PIX para PIX; MSG_SUCESSO_CARTAO para cartão.
  # Efeitos colaterais:: nenhum.
  def mensagem_sucesso
    metodo == "pix" ? MSG_SUCESSO_PIX : MSG_SUCESSO_CARTAO
  end

  # Junta os erros de validação numa frase para o aviso da tela.
  #
  # Argumentos:: nenhum.
  # Retorno:: String com as mensagens distintas separadas por ". " (vazia sem erros).
  # Efeitos colaterais:: nenhum.
  def mensagem_erro
    errors.map(&:message).uniq.join(". ")
  end

  # Valida o formulário e grava a recarga com seus itens e o pagamento pendente (RN02.2).
  #
  # Argumentos:: nenhum.
  # Retorno:: true quando a recarga foi gravada (disponível em #recarga); false quando o formulário
  #           é inválido ou o banco rejeita a gravação (os motivos ficam em #errors).
  # Efeitos colaterais:: grava Recarga, ItemRecarga e Pagamento numa única transação; para PIX,
  #                      gera o código Copia e Cola. Não credita saldo.
  def salvar
    return false unless valid?

    ActiveRecord::Base.transaction { montar_recarga(Time.current).save! }
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  end

  private

  # Monta em memória a recarga, os itens das categorias compradas e o pagamento.
  #
  # Argumentos:: +agora+ (Time): momento da solicitação e início da validade do PIX.
  # Retorno:: a Recarga ainda não gravada (também guardada em #recarga).
  # Efeitos colaterais:: define @recarga.
  def montar_recarga(agora)
    @recarga = estudante.recargas.build(solicitada_em: agora, valor_total: valor_total)
    categorias_compradas.each { |categoria| adicionar_item(categoria) }
    adicionar_pagamento(agora)
    @recarga
  end

  # Lista as categorias com quantidade maior que zero.
  #
  # Argumentos:: nenhum.
  # Retorno:: Array de Symbols (chaves de CATEGORIAS).
  # Efeitos colaterais:: nenhum.
  def categorias_compradas
    CATEGORIAS.keys.reject { |categoria| quantidade(categoria).zero? }
  end

  # Acrescenta à recarga o item de uma categoria, com o preço da tarifa vigente.
  #
  # Argumentos:: +categoria+ (Symbol): uma chave de CATEGORIAS com quantidade positiva.
  # Retorno:: o ItemRecarga criado em memória.
  # Efeitos colaterais:: altera os itens de @recarga (sem gravar).
  def adicionar_item(categoria)
    vigente = tarifa(categoria)
    @recarga.itens.build(tipo_refeicao: vigente.tipo_refeicao, tarifa_refeicao: vigente,
                         quantidade: quantidade(categoria), valor_unitario: vigente.valor)
  end

  # Acrescenta à recarga o pagamento pendente; para PIX, emite o código Copia e Cola.
  #
  # Argumentos:: +agora+ (Time): início da validade do PIX.
  # Retorno:: o Pagamento criado em memória (ou nil, quando é de cartão).
  # Efeitos colaterais:: altera os pagamentos de @recarga (sem gravar).
  def adicionar_pagamento(agora)
    pagamento = @recarga.pagamentos.build(metodo: metodo, valor_solicitado: valor_total)
    Pagamentos::GatewaySimulado.emitir_pix(pagamento, agora) if pagamento.pix?
  end

  # Validação: cada quantidade deve ser um inteiro entre 0 e QUANTIDADE_MAXIMA.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona um erro em +quantidade_<categoria>+ para cada quantidade inválida.
  def quantidades_validas
    CATEGORIAS.each do |categoria, config|
      qtd = quantidade(categoria)
      next if qtd && qtd.between?(0, QUANTIDADE_MAXIMA)

      errors.add(:"quantidade_#{categoria}",
                 "#{config[:rotulo]}: informe um número inteiro entre 0 e #{QUANTIDADE_MAXIMA}")
    end
  end

  # Validação: todas as categorias precisam de tarifa vigente.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona erro em +base+ quando falta tarifa.
  def tarifas_disponiveis
    errors.add(:base, "As tarifas das refeições não estão cadastradas") unless tarifas_cadastradas?
  end

  # Validação de RN02.6: rejeita cobrança zerada. Só roda se as outras validações passaram.
  #
  # Argumentos:: nenhum.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: adiciona MSG_COBRANCA_ZERADA em +base+ quando o total é zero.
  def total_positivo
    return if errors.any?

    errors.add(:base, MSG_COBRANCA_ZERADA) if zerada?
  end
end
