FactoryBot.define do
  factory :papel do
    sequence(:codigo) { |n| "papel#{n}" }
    descricao { "Papel de teste" }

    initialize_with { Papel.find_or_initialize_by(codigo: codigo) }
  end

  factory :usuario do
    sequence(:nome) { |n| "Usuário #{n}" }
    sequence(:identificacao) { |n| "usuario#{n}" }
    sequence(:email) { |n| "usuario#{n}@unb.br" }
    password { "senhaCorreta" }
    ativo { true }

    trait :inativo do
      ativo { false }
    end

    transient do
      papel_codigo { nil }
    end

    after(:create) do |usuario, contexto|
      if contexto.papel_codigo
        create(:papel, codigo: contexto.papel_codigo)
        usuario.atribuir_papel!(contexto.papel_codigo)
      end
    end

    factory :funcionario do
      sequence(:identificacao) { |n| "funcionario#{n.to_s.rjust(2, '0')}" }
      papel_codigo { Papel::FUNCIONARIO }
    end

    factory :administrador do
      sequence(:identificacao) { |n| "admin#{n}" }
      papel_codigo { Papel::ADMINISTRADOR }
    end

    factory :usuario_estudante do
      sequence(:identificacao) { |n| (200_000_000 + n).to_s }
      email { "#{identificacao}@aluno.unb.br" }
      papel_codigo { Papel::ESTUDANTE }

      after(:create) do |usuario|
        usuario.create_estudante!(matricula: usuario.identificacao)
      end
    end
  end

  factory :estudante do
    usuario
    sequence(:matricula) { |n| (300_000_000 + n).to_s }
    vinculo_ativo { true }
  end

  factory :sessao_autenticacao do
    usuario
    sequence(:token_digest) { |n| SessaoAutenticacao.digest("token-#{n}") }
    autenticada_em { Time.current }
    expira_em { SessaoAutenticacao::DURACAO.from_now }
    ponto_acesso_pendente { true }
  end
end
