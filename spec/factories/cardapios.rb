FactoryBot.define do
  factory :tipo_refeicao do
    codigo { TipoRefeicao::ALMOCO }
    nome { "Almoço" }

    initialize_with { TipoRefeicao.find_or_initialize_by(codigo: codigo) }
  end

  factory :servico_refeicao do
    restaurante
    tipo_refeicao
    dia_semana { 3 }
    inicio { "11:00" }
    fim { "14:30" }
    ativo { true }
  end

  factory :cardapio do
    servico_refeicao
    # 01/11/2026 é um domingo (wday 0), então a soma cai no dia da semana do serviço.
    data_referencia { Date.new(2026, 11, 1) + servico_refeicao.dia_semana }
  end

  factory :opcao_cardapio do
    cardapio
    dieta { OpcaoCardapio::PADRAO }
  end

  factory :item_cardapio do
    opcao_cardapio
    categoria { "prato_principal" }
    sequence(:descricao) { |n| "Item #{n}" }
    sequence(:ordem) { |n| n }
  end
end
