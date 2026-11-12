
FactoryBot.define do
  factory :exportacao_relatorio do
    association :usuario

    tipo { "operacao_global" }
    formato { "pdf" }

    filtros { {} }
    agrupamentos { {} }

    solicitada_em { Time.current }
    status { "processando" }
    assinatura_status { "nao_aplicavel" }
  end
end
