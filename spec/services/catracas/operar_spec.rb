require "rails_helper"

RSpec.describe Catracas::Operar do
  let(:agora) { Time.zone.local(2026, 11, 9, 12) }
  let(:ponto) { create(:configuracao_ponto_acesso) }
  let(:servico) { create(:servico_refeicao, restaurante: ponto.restaurante, dia_semana: agora.wday) }
  let!(:estudante) { create(:estudante, saldo: 10) }
  let(:operador) { described_class.new(ponto) }

  before do
    travel_to agora
    create(:tarifa_refeicao, tipo_refeicao: servico.tipo_refeicao, valor: 2.5)
  end
  after { travel_back }

  def ler(referencia = SecureRandom.uuid)
    operador.ler(identificacao: estudante.matricula, referencia: referencia)
  end

  it "cobra somente na passagem e rateia o débito real" do
    registro = ler
    expect(registro).to be_liberado
    expect(estudante.saldo).to eq(10)
    travel 2.seconds
    operador.passar(registro)
    expect(registro).to be_realizado
    expect(estudante.saldo).to eq(7.5)
    expect(registro.movimentacao_saldo.valor).to eq(-2.5)
    expect(registro.movimentacao_saldo.tipo_refeicao).to eq(servico.tipo_refeicao)
    expect(registro.movimentacao_saldo.rateios_consumo.sum(:valor)).to eq(2.5)
  end

  it "não duplica leitura nem passagem ao repetir a referência/evento" do
    registro = ler("evento-unico")
    expect(ler("evento-unico")).to eq(registro)
    travel 2.seconds
    2.times { operador.passar(registro) }
    expect(ponto.registros_acesso.count).to eq(1)
    expect(estudante.movimentacoes_saldo.debitos.count).to eq(1)
    expect(estudante.saldo).to eq(7.5)
  end

  it "aceita passagem aos 5 segundos exatos" do
    registro = ler
    travel 5.seconds
    operador.expirar(registro)
    expect(registro).to be_liberado
    operador.passar(registro)
    expect(registro).to be_realizado
  end

  it "expira após 5 segundos sem débito e mantém o horário limite" do
    registro = ler
    travel 6.seconds
    operador.passar(registro)
    expect(registro).to be_cancelado
    expect(registro.passagem_em).to be_nil
    expect(registro.bloqueado_em).to eq(agora + 5.seconds)
    expect(estudante.saldo).to eq(10)
    expect(estudante.movimentacoes_saldo.debitos).to be_empty
  end

  it "rejeita leitura desconhecida sem saldo nem timestamps de liberação" do
    registro = operador.ler(identificacao: "abc123xyz", referencia: SecureRandom.uuid)
    expect(registro).to be_recusado
    expect(registro.estudante).to be_nil
    expect(registro.saldo_lido).to be_nil
    expect(registro.liberado_em).to be_nil
    expect(registro.bloqueado_em).to be_nil
  end

  it "não libera fora do horário de serviço" do
    servico.update!(ativo: false)
    expect(ler.mensagem).to eq("Nenhuma refeição disponível neste horário")
  end

  it "revalida o saldo na passagem após consumo em outro terminal" do
    registro = ler
    outro_ponto = create(:configuracao_ponto_acesso)
    create(:servico_refeicao, restaurante: outro_ponto.restaurante, dia_semana: agora.wday, tipo_refeicao: servico.tipo_refeicao)
    outro = described_class.new(outro_ponto)
    create(:tarifa_refeicao, tipo_refeicao: servico.tipo_refeicao).update!(valor: 9)
    acesso = outro.ler(identificacao: estudante.matricula, referencia: SecureRandom.uuid)
    outro.passar(acesso)
    operador.passar(registro)
    expect(registro).to be_cancelado
    expect(registro.mensagem).to eq("Saldo insuficiente")
    expect(estudante.saldo).to eq(1)
    expect(estudante.movimentacoes_saldo.debitos.count).to eq(1)
  end

  it "não permite segunda liberação antes de concluir a primeira" do
    ler
    expect { ler }.to raise_error(described_class::Invalido, /Aguarde/)
  end

  it "rejeita evento de outra configuração sem revelar o registro" do
    registro = ler
    outro = described_class.new(create(:configuracao_ponto_acesso))
    expect { outro.ler(identificacao: estudante.matricula, referencia: registro.referencia_evento) }
      .to raise_error(described_class::Invalido, /Referência/)
  end

  it "não opera com ponto pendente ou sessão encerrada" do
    ponto.sessao_autenticacao.update!(ponto_acesso_pendente: true)
    expect { ler }.to raise_error(described_class::Invalido, /Confirme/)
  end

  it "cancela liberação no encerramento da sessão" do
    registro = ler
    ponto.sessao_autenticacao.encerrar!
    expect(registro.reload).to be_cancelado
    expect(estudante.saldo).to eq(10)
  end

  it "divide FIFO entre recargas e preserva a soma do débito" do
    # O saldo inicial é criado antes do travel_to; fixa a data para o FIFO não depender do relógio real.
    credito_antigo = estudante.movimentacoes_saldo.creditos.first
    credito_antigo.update_columns(ocorrida_em: agora - 1.day)
    credito_antigo.recarga.update_columns(confirmada_em: agora - 1.day)
    # Consome R$ 9, restam R$ 1 da primeira recarga e R$ 2 da nova.
    create(:tarifa_refeicao, tipo_refeicao: servico.tipo_refeicao).update!(valor: 9)
    operador.passar(ler)
    travel 1.second
    SaldoInicialFactory.creditar(estudante, 2)
    TarifaRefeicao.vigente_para(servico.tipo_refeicao).update!(valor: 2.5)
    registro = ler
    operador.passar(registro)
    expect(registro.movimentacao_saldo.rateios_consumo.order(:id).pluck(:valor)).to eq([ 1, 1.5 ])
    expect(estudante.saldo).to eq(0.5)
  end

  it "reverte passagem, débito e rateio se a distribuição falhar" do
    registro = ler
    allow_any_instance_of(RateioConsumo).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(RateioConsumo.new))
    expect { operador.passar(registro) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(registro.reload).to be_liberado
    expect(estudante.saldo).to eq(10)
    expect(estudante.movimentacoes_saldo.debitos).to be_empty
    expect(RateioConsumo.count).to eq(0)
  end
end
