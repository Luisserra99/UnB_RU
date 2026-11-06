# F10: sem filtros mostra a refeição em andamento; com data e refeição consulta o cardápio daquele dia.
class CardapiosController < ApplicationController
  def show
    @restaurantes = Restaurante.ativos.ordenados
    @restaurante = @restaurantes.find_by(id: params[:restaurante_id]) || @restaurantes.first
    @tipos = TipoRefeicao.ordenados
    @tipo = @tipos.find_by(codigo: params[:refeicao])
    @data = data_consultada
    @consulta_atual = @tipo.nil? && @data == Date.current
    @servico = servico_consultado
    @cardapio = @servico&.cardapios&.includes(opcoes: :itens)&.find_by(data_referencia: @data)
  end

  private

  def data_consultada
    Date.iso8601(params[:data].to_s)
  rescue Date::Error
    Date.current
  end

  def servico_consultado
    return if @restaurante.nil?

    servicos = @restaurante.servicos_refeicao
    return servicos.em_andamento(Time.current) if @consulta_atual
    return if @tipo.nil?

    servicos.ativos.find_by(tipo_refeicao: @tipo, dia_semana: @data.wday)
  end
end
