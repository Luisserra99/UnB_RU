# Página pública do cardápio (F10): sem filtros mostra a refeição em andamento; com data e refeição
# consulta o cardápio daquele dia.
class CardapiosController < ApplicationController
  # GET /cardapio: mostra o cardápio do restaurante consultado.
  #
  # Argumentos:: +params[:restaurante_id]+ (opcional; padrão o primeiro restaurante ativo),
  #              +params[:data]+ (opcional, AAAA-MM-DD; padrão hoje) e +params[:refeicao]+
  #              (opcional, código do TipoRefeicao).
  # Retorno:: nenhum (ação de controller).
  # Efeitos colaterais:: consulta restaurantes, tipos, serviço e cardápio e renderiza +show+; sem
  #                      cardápio encontrado, a tela informa a ausência (sempre HTTP 200).
  def show
    carregar_restaurante
    carregar_refeicao
    @data = data_consultada
    @consulta_atual = @tipo.nil? && @data == Date.current
    @servico = servico_consultado
    @cardapio = cardapio_consultado
  end

  private

  # Carrega os restaurantes ativos e o restaurante consultado.
  #
  # Argumentos:: +params[:restaurante_id]+: restaurante escolhido (opcional).
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: define +@restaurantes+ e +@restaurante+ (o escolhido, se ativo; senão o
  #                      primeiro ativo; nil se não há nenhum).
  def carregar_restaurante
    @restaurantes = Restaurante.ativos.ordenados
    @restaurante = @restaurantes.find_by(id: params[:restaurante_id]) || @restaurantes.first
  end

  # Carrega os tipos de refeição e o tipo consultado.
  #
  # Argumentos:: +params[:refeicao]+: código do tipo (opcional).
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: define +@tipos+ e +@tipo+ (nil quando o código não é informado ou não existe).
  def carregar_refeicao
    @tipos = TipoRefeicao.ordenados
    @tipo = @tipos.find_by(codigo: params[:refeicao])
  end

  # Lê a data consultada.
  #
  # Argumentos:: +params[:data]+: data no formato ISO 8601 (opcional).
  # Retorno:: Date informada; Date.current quando a data falta ou é inválida.
  # Efeitos colaterais:: nenhum.
  def data_consultada
    Date.iso8601(params[:data].to_s)
  rescue Date::Error
    Date.current
  end

  # Escolhe o serviço de refeição da consulta.
  #
  # Argumentos:: nenhum (usa +@restaurante+, +@consulta_atual+, +@tipo+ e +@data+).
  # Retorno:: na consulta atual, o ServicoRefeicao em andamento agora; com refeição informada, o
  #           serviço ativo daquele tipo no dia da semana de +@data+; nil sem restaurante, fora de
  #           horário, sem refeição informada em outra data ou sem serviço cadastrado.
  # Efeitos colaterais:: consulta o banco.
  def servico_consultado
    return if @restaurante.nil?

    servicos = @restaurante.servicos_refeicao
    return servicos.em_andamento(Time.current) if @consulta_atual
    return if @tipo.nil?

    servicos.ativos.find_by(tipo_refeicao: @tipo, dia_semana: @data.wday)
  end

  # Busca o cardápio do serviço consultado na data, já com opções e itens.
  #
  # Argumentos:: nenhum (usa +@servico+ e +@data+).
  # Retorno:: o Cardapio encontrado; nil sem serviço ou sem cardápio publicado na data.
  # Efeitos colaterais:: consulta o banco.
  def cardapio_consultado
    return if @servico.nil?

    @servico.cardapios.includes(opcoes: :itens).find_by(data_referencia: @data)
  end
end
