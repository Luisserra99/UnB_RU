# Factories da F02 (Luis): tarifas, recargas, pagamentos e movimentações de saldo.
FactoryBot.define do
  factory :tarifa_refeicao do
    tipo_refeicao
    valor { BigDecimal("4.50") }
    vigente_desde { Time.zone.local(2000, 1, 1) }
    vigente_ate { nil }

    # Reaproveita a tarifa aberta do tipo, para não violar a regra de vigências sem sobreposição.
    initialize_with { TarifaRefeicao.find_or_initialize_by(tipo_refeicao: tipo_refeicao, vigente_ate: nil) }

    trait :cafe do
      tipo_refeicao { association :tipo_refeicao, codigo: TipoRefeicao::CAFE_DA_MANHA, nome: "Café da manhã" }
      valor { BigDecimal("2.50") }
    end

    trait :almoco do
      tipo_refeicao { association :tipo_refeicao, codigo: TipoRefeicao::ALMOCO, nome: "Almoço" }
    end

    trait :jantar do
      tipo_refeicao { association :tipo_refeicao, codigo: TipoRefeicao::JANTAR, nome: "Jantar" }
    end
  end

  factory :recarga do
    estudante
    solicitada_em { Time.current }

    transient do
      quantidade { 1 }
      tarifa { TarifaRefeicao.vigente_para(TipoRefeicao::ALMOCO) || association(:tarifa_refeicao, :almoco) }
      # Permite valores arbitrários (ex.: saldo de R$ 2,00 nos testes da F06).
      valor_unitario { tarifa.valor }
    end

    valor_total { valor_unitario * quantidade }

    after(:build) do |recarga, contexto|
      next if recarga.itens.any?

      recarga.itens.build(tipo_refeicao: contexto.tarifa.tipo_refeicao, tarifa_refeicao: contexto.tarifa,
                          quantidade: contexto.quantidade, valor_unitario: contexto.valor_unitario)
    end

    # Passa pelo fluxo real: pagamento confirmado, recarga confirmada e crédito no saldo.
    trait :confirmada do
      after(:create) do |recarga|
        pagamento = recarga.pagamentos.create!(metodo: :cartao_credito, valor_solicitado: recarga.valor_total)
        pagamento.confirmar!
        recarga.reload
      end
    end
  end

  factory :item_recarga do
    recarga
    tarifa_refeicao { association :tarifa_refeicao, :cafe }
    tipo_refeicao { tarifa_refeicao.tipo_refeicao }
    quantidade { 1 }
    valor_unitario { tarifa_refeicao.valor }
  end

  factory :pagamento do
    recarga
    metodo { "cartao_credito" }
    valor_solicitado { recarga.valor_total }

    trait :cartao do
      metodo { "cartao_credito" }
    end

    trait :pix do
      metodo { "pix" }
      after(:build) { |pagamento| Pagamentos::GatewaySimulado.emitir_pix(pagamento) }
    end

    trait :confirmado do
      after(:create, &:confirmar!)
    end
  end

  # Débito com origem real em RegistroAcesso; sem serviço, mantém o fallback histórico da F03.
  factory :movimentacao_saldo do
    estudante
    natureza { "debito_refeicao" }
    valor { BigDecimal("-4.50") }
    ocorrida_em { Time.current }

    registro_acesso do
      if natureza.to_s == "debito_refeicao"
        association :registro_acesso, estudante: estudante, lido_em: ocorrida_em - 2.seconds,
          liberado_em: ocorrida_em - 2.seconds, passagem_em: ocorrida_em, bloqueado_em: ocorrida_em
      end
    end

    trait :debito_refeicao

    trait :credito_recarga do
      natureza { "credito_recarga" }
      valor { BigDecimal("10.00") }
      recarga do
        association :recarga, estudante: estudante, valor_unitario: valor, status: "confirmada", confirmada_em: ocorrida_em
      end
    end
  end
end

# Saldo inicial nos estudantes de teste: create(:estudante, saldo: 7.5) ou create(:usuario_estudante, saldo: 7.5).
module SaldoInicialFactory
  def self.creditar(estudante, valor)
    valor = BigDecimal(valor.to_s)
    return if valor.zero?
    raise ArgumentError, "saldo inicial negativo não é suportado" if valor.negative?

    FactoryBot.create(:movimentacao_saldo, :credito_recarga, estudante: estudante, valor: valor)
  end
end

FactoryBot.modify do
  factory :estudante do
    transient do
      saldo { 0 }
    end

    after(:create) { |estudante, contexto| SaldoInicialFactory.creditar(estudante, contexto.saldo) }
  end

  factory :usuario_estudante do
    transient do
      saldo { 0 }
    end

    after(:create) { |usuario, contexto| SaldoInicialFactory.creditar(usuario.estudante, contexto.saldo) }
  end
end
