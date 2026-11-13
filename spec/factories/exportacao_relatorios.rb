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

    trait :concluida do
      status { "concluida" }
      emitida_em { solicitada_em + 2.seconds }
      quantidade_registros { 4 }
      total_debitos { 18 }
      total_creditos { 0 }
      arquivo_chave { "relatorios/operacao-global.pdf" }
      arquivo_sha256 { "a" * 64 }
    end

    trait :sem_dados do
      status { "sem_dados" }
      quantidade_registros { 0 }
    end

    trait :falhou do
      status { "falhou" }
    end

    trait :extrato do
      tipo { "extrato_estudante" }
    end
  end
end
