FactoryBot.define do
  factory :unidade_gestora do
    sequence(:nome) { |n| "Unidade #{n}" }
    ativa { true }
  end

  factory :restaurante do
    unidade_gestora
    sequence(:nome) { |n| "Restaurante #{n}" }
    capacidade_refeicoes_hora { 400 }
    quantidade_pisos { 1 }
    ativo { true }

    after(:create) do |restaurante|
      (1..restaurante.quantidade_pisos.to_i).each { |numero| restaurante.pisos.create!(numero: numero) }
    end
  end

  factory :piso do
    restaurante
    sequence(:numero) { |n| n + 1 }
  end

  factory :catraca do
    piso
    sequence(:identificacao) { |n| "Catraca #{n}" }
    ativa { true }
    online { false }
  end
end
