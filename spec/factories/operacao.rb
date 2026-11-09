FactoryBot.define do
  factory :configuracao_ponto_acesso do
    sessao_autenticacao { association :sessao_autenticacao, usuario: association(:funcionario), ponto_acesso_pendente: false }
    catraca
    restaurante { catraca.restaurante }
    confirmada_em { Time.current }
  end

  factory :registro_acesso do
    configuracao_ponto_acesso
    estudante
    referencia_evento { SecureRandom.uuid }
    identificacao_lida { estudante.matricula }
    estado { "realizado" }
    mensagem { "Boa refeição" }
    lido_em { Time.current - 2.seconds }
    liberado_em { lido_em }
    passagem_em { lido_em + 2.seconds }
    bloqueado_em { passagem_em }
  end
end
