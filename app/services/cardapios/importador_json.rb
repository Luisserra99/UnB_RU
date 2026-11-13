module Cardapios
  # Gera os cardápios datados de uma semana a partir do cardapio.json.
  # É idempotente: importar a mesma semana de novo substitui as opções e os itens.
  #
  # Campos com sufixo de dieta (ex.: prato_principal_padrao) pertencem só àquela dieta;
  # os demais (salada, bebida...) são comuns e copiados para cada dieta. Uma dieta sem
  # item próprio não recebe nada, para aparecer como indisponível em vez de só com os comuns.
  class ImportadorJson
    CAMINHO_PADRAO = Rails.root.join("cardapio.json")
    DIAS = %w[segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado domingo].freeze
    SUFIXOS_DIETA = {
      "_padrao" => OpcaoCardapio::PADRAO,
      "_ovolactovegetariano" => OpcaoCardapio::OVOLACTOVEGETARIANA,
      "_vegetariano_estrito" => OpcaoCardapio::VEGETARIANA_ESTRITA
    }.freeze

    Resultado = Data.define(:cardapios, :servicos_ausentes)

    def initialize(semana:, caminho: CAMINHO_PADRAO, restaurantes: Restaurante.ativos)
      @segunda = semana.beginning_of_week(:monday)
      @caminho = caminho
      @restaurantes = restaurantes
    end

    def importar
      dados = JSON.parse(File.read(@caminho, encoding: "UTF-8"))
      tipos = TipoRefeicao.all.index_by(&:codigo)
      cardapios = 0
      servicos_ausentes = 0

      Cardapio.transaction do
        @restaurantes.find_each do |restaurante|
          dados.each do |dia, refeicoes|
            data = data_do_dia(dia)
            refeicoes.each do |codigo, campos|
              servico = restaurante.servicos_refeicao.find_by(tipo_refeicao: tipos.fetch(codigo), dia_semana: data.wday)
              if servico
                importar_cardapio(servico, data, campos)
                cardapios += 1
              else
                servicos_ausentes += 1
              end
            end
          end
        end
      end

      Resultado.new(cardapios: cardapios, servicos_ausentes: servicos_ausentes)
    end

    private

    def data_do_dia(dia)
      indice = DIAS.index(dia) or raise ArgumentError, "Dia desconhecido no cardápio: #{dia}"
      @segunda + indice
    end

    def importar_cardapio(servico, data, campos)
      cardapio = servico.cardapios.find_or_create_by!(data_referencia: data)
      cardapio.opcoes.destroy_all

      SUFIXOS_DIETA.each_value do |dieta|
        itens = itens_da_dieta(campos, dieta)
        next if itens.empty?

        opcao = cardapio.opcoes.create!(dieta: dieta)
        itens.each.with_index(1) do |(categoria, descricao), ordem|
          opcao.itens.create!(categoria: categoria, descricao: descricao, ordem: ordem)
        end
      end
    end

    def itens_da_dieta(campos, dieta)
      proprios = campos.select { |campo, _valor| dieta_do_campo(campo) == dieta }
      return [] if proprios.values.flat_map { |valor| valores(valor) }.empty?

      campos.flat_map do |campo, valor|
        next [] unless [ nil, dieta ].include?(dieta_do_campo(campo))

        valores(valor).map { |descricao| [ categoria_do_campo(campo), descricao ] }
      end
    end

    def dieta_do_campo(campo)
      SUFIXOS_DIETA.find { |sufixo, _dieta| campo.end_with?(sufixo) }&.last
    end

    def categoria_do_campo(campo)
      SUFIXOS_DIETA.keys.inject(campo) { |categoria, sufixo| categoria.delete_suffix(sufixo) }
    end

    # null, texto em branco ou lista vazia não viram item.
    def valores(valor)
      Array(valor).map { |item| item.to_s.squish }.reject(&:blank?)
    end
  end
end
