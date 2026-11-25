# Serviços de cardápio (F10).
module Cardapios
  # Gera os cardápios datados de uma semana a partir do cardapio.json.
  # É idempotente: importar a mesma semana de novo substitui as opções e os itens.
  #
  # Campos com sufixo de dieta (ex.: prato_principal_padrao) pertencem só àquela dieta;
  # os demais (salada, bebida...) são comuns e copiados para cada dieta. Uma dieta sem
  # item próprio não recebe nada, para aparecer como indisponível em vez de só com os comuns.
  class ImportadorJson
    # Arquivo lido quando nenhum caminho é informado.
    CAMINHO_PADRAO = Rails.root.join("cardapio.json")
    # Chaves de dia do JSON, na ordem da semana a partir da segunda-feira.
    DIAS = %w[segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado domingo].freeze
    # Sufixo do campo no JSON => código da dieta (OpcaoCardapio) a que o campo pertence.
    SUFIXOS_DIETA = {
      "_padrao" => OpcaoCardapio::PADRAO,
      "_ovolactovegetariano" => OpcaoCardapio::OVOLACTOVEGETARIANA,
      "_vegetariano_estrito" => OpcaoCardapio::VEGETARIANA_ESTRITA
    }.freeze

    # Resultado da importação: +cardapios+ gravados e +servicos_ausentes+ (refeições do JSON sem
    # serviço cadastrado no restaurante e dia).
    Resultado = Data.define(:cardapios, :servicos_ausentes)

    # Prepara a importação de uma semana.
    #
    # Argumentos:: +semana+ (Date): qualquer dia da semana a importar; a semana começa na segunda.
    #              +caminho+ (String ou Pathname): arquivo JSON; padrão CAMINHO_PADRAO.
    #              +restaurantes+ (ActiveRecord::Relation): restaurantes que recebem os cardápios;
    #              padrão Restaurante.ativos.
    # Retorno:: a nova instância.
    # Efeitos colaterais:: nenhum.
    def initialize(semana:, caminho: CAMINHO_PADRAO, restaurantes: Restaurante.ativos)
      @segunda = semana.beginning_of_week(:monday)
      @caminho = caminho
      @restaurantes = restaurantes
    end

    # Lê o JSON e grava o cardápio de cada refeição, em cada restaurante, numa única transação.
    #
    # Argumentos:: nenhum.
    # Retorno:: Resultado com a contagem de cardápios gravados e de serviços ausentes.
    # Efeitos colaterais:: grava Cardapio, OpcaoCardapio e ItemCardapio, substituindo as opções de
    #                      cardápios já importados. Se o JSON tiver um dia desconhecido
    #                      (ArgumentError) ou uma refeição desconhecida (KeyError), nada é gravado e
    #                      a exceção é propagada; arquivo ausente ou JSON inválido também propagam
    #                      a exceção da leitura.
    def importar
      dados = JSON.parse(File.read(@caminho, encoding: "UTF-8"))
      @tipos = TipoRefeicao.all.index_by(&:codigo)
      contagem = { cardapios: 0, servicos_ausentes: 0 }

      Cardapio.transaction do
        @restaurantes.find_each { |restaurante| importar_restaurante(restaurante, dados, contagem) }
      end

      Resultado.new(**contagem)
    end

    private

    # Importa todas as refeições do JSON para um restaurante.
    #
    # Argumentos:: +restaurante+ (Restaurante): restaurante que recebe os cardápios.
    #              +dados+ (Hash): JSON lido, no formato dia => { refeição => campos }.
    #              +contagem+ (Hash): totais de +:cardapios+ e +:servicos_ausentes+.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: grava os cardápios e soma cada refeição em +contagem+; propaga
    #                      ArgumentError para dia desconhecido.
    def importar_restaurante(restaurante, dados, contagem)
      dados.each do |dia, refeicoes|
        data = data_do_dia(dia)
        refeicoes.each do |codigo, campos|
          chave = importar_refeicao(restaurante, data, codigo, campos) ? :cardapios : :servicos_ausentes
          contagem[chave] += 1
        end
      end
    end

    # Importa o cardápio de uma refeição se o restaurante tem o serviço naquele dia.
    #
    # Argumentos:: +restaurante+ (Restaurante), +data+ (Date): dia do cardápio,
    #              +codigo+ (String): código do TipoRefeicao, +campos+ (Hash): campos da refeição no JSON.
    # Retorno:: true quando o cardápio foi gravado; false quando o serviço não existe.
    # Efeitos colaterais:: consulta o serviço e grava o cardápio; propaga KeyError se o código da
    #                      refeição não existe.
    def importar_refeicao(restaurante, data, codigo, campos)
      servico = restaurante.servicos_refeicao.find_by(tipo_refeicao: @tipos.fetch(codigo), dia_semana: data.wday)
      return false unless servico

      importar_cardapio(servico, data, campos)
      true
    end

    # Converte a chave de dia do JSON na data correspondente da semana importada.
    #
    # Argumentos:: +dia+ (String): chave de DIAS (ex.: "quarta-feira").
    # Retorno:: Date do dia dentro da semana.
    # Efeitos colaterais:: lança ArgumentError quando o dia não está em DIAS.
    def data_do_dia(dia)
      indice = DIAS.index(dia) or raise ArgumentError, "Dia desconhecido no cardápio: #{dia}"
      @segunda + indice
    end

    # Grava o cardápio de um serviço numa data, recriando as opções de cada dieta.
    #
    # Argumentos:: +servico+ (ServicoRefeicao), +data+ (Date), +campos+ (Hash): campos da refeição no JSON.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: cria o Cardapio se ainda não existe, remove as opções antigas e grava as
    #                      novas; dietas sem item próprio ficam sem opção. Propaga
    #                      ActiveRecord::RecordInvalid se algum registro for inválido.
    def importar_cardapio(servico, data, campos)
      cardapio = servico.cardapios.find_or_create_by!(data_referencia: data)
      cardapio.opcoes.destroy_all

      SUFIXOS_DIETA.each_value do |dieta|
        itens = itens_da_dieta(campos, dieta)
        criar_opcao(cardapio, dieta, itens) unless itens.empty?
      end
    end

    # Grava a opção de uma dieta com seus itens numerados a partir de 1.
    #
    # Argumentos:: +cardapio+ (Cardapio), +dieta+ (String): código da dieta,
    #              +itens+ (Array): pares [categoria, descrição], na ordem do JSON.
    # Retorno:: nenhum relevante.
    # Efeitos colaterais:: grava OpcaoCardapio e ItemCardapio; propaga ActiveRecord::RecordInvalid.
    def criar_opcao(cardapio, dieta, itens)
      opcao = cardapio.opcoes.create!(dieta: dieta)
      itens.each.with_index(1) do |(categoria, descricao), ordem|
        opcao.itens.create!(categoria: categoria, descricao: descricao, ordem: ordem)
      end
    end

    # Monta os itens de uma dieta: os campos próprios dela mais os campos comuns.
    #
    # Argumentos:: +campos+ (Hash): campos da refeição no JSON, +dieta+ (String): código da dieta.
    # Retorno:: Array de pares [categoria, descrição]; vazio quando a dieta não tem item próprio.
    # Efeitos colaterais:: nenhum.
    def itens_da_dieta(campos, dieta)
      return [] unless possui_item_proprio?(campos, dieta)

      campos.flat_map do |campo, valor|
        next [] unless campo_da_dieta?(campo, dieta)

        valores(valor).map { |descricao| [ categoria_do_campo(campo), descricao ] }
      end
    end

    # Indica se algum campo exclusivo da dieta tem valor preenchido.
    #
    # Argumentos:: +campos+ (Hash): campos da refeição, +dieta+ (String): código da dieta.
    # Retorno:: true se a dieta tem ao menos um item próprio; false caso contrário.
    # Efeitos colaterais:: nenhum.
    def possui_item_proprio?(campos, dieta)
      campos.any? { |campo, valor| dieta_do_campo(campo) == dieta && valores(valor).any? }
    end

    # Indica se um campo entra na opção da dieta: é comum (sem sufixo) ou exclusivo dela.
    #
    # Argumentos:: +campo+ (String): nome do campo no JSON, +dieta+ (String): código da dieta.
    # Retorno:: true se o campo pertence à dieta; false se é de outra dieta.
    # Efeitos colaterais:: nenhum.
    def campo_da_dieta?(campo, dieta)
      [ nil, dieta ].include?(dieta_do_campo(campo))
    end

    # Descobre a dieta de um campo pelo sufixo.
    #
    # Argumentos:: +campo+ (String): nome do campo no JSON.
    # Retorno:: o código da dieta do sufixo; nil quando o campo é comum a todas as dietas.
    # Efeitos colaterais:: nenhum.
    def dieta_do_campo(campo)
      SUFIXOS_DIETA.find { |sufixo, _dieta| campo.end_with?(sufixo) }&.last
    end

    # Remove o sufixo de dieta do nome do campo, obtendo a categoria do item.
    #
    # Argumentos:: +campo+ (String): nome do campo (ex.: "prato_principal_padrao").
    # Retorno:: String com a categoria (ex.: "prato_principal"); o próprio campo quando não há sufixo.
    # Efeitos colaterais:: nenhum.
    def categoria_do_campo(campo)
      SUFIXOS_DIETA.keys.inject(campo) { |categoria, sufixo| categoria.delete_suffix(sufixo) }
    end

    # Normaliza o valor de um campo em descrições de itens. null, texto em branco ou lista vazia
    # não viram item.
    #
    # Argumentos:: +valor+ (String, Array, nil): valor do campo no JSON.
    # Retorno:: Array de String sem espaços extras e sem itens em branco; vazio quando não há valor.
    # Efeitos colaterais:: nenhum.
    def valores(valor)
      Array(valor).map { |item| item.to_s.squish }.reject(&:blank?)
    end
  end
end
