require "rails_helper"

# F07 — confirmação física da liberação (Catracas::Operar#confirmar_liberacao).
RSpec.describe Catracas::Operar, "#confirmar_liberacao" do
  let(:agora) { Time.zone.local(2026, 10, 14, 11, 30) }
  let(:ponto) { create(:configuracao_ponto_acesso) }
  let(:servico) { create(:servico_refeicao, restaurante: ponto.restaurante, dia_semana: agora.wday) }
  let!(:estudante) { create(:estudante, saldo: 10) }
  let(:operador) { described_class.new(ponto) }

  before do
    travel_to agora
    create(:tarifa_refeicao, tipo_refeicao: servico.tipo_refeicao, valor: 2.5)
  end
  after { travel_back }

  def ler
    operador.ler(identificacao: estudante.matricula, referencia: SecureRandom.uuid)
  end

  it "registra o instante da liberação física, depois da leitura" do
    registro = ler
    travel 1.second
    operador.confirmar_liberacao(registro)

    expect(registro.reload.lido_em).to eq(agora)
    expect(registro.liberado_em).to eq(agora + 1.second)
    expect(registro).to be_liberado
  end

  it "conta os 5 segundos para a passagem a partir da liberação confirmada" do
    registro = ler
    travel 1.second
    operador.confirmar_liberacao(registro)
    travel 5.seconds # 6s depois da leitura, mas 5s depois da liberação

    operador.passar(registro)
    expect(registro.reload).to be_realizado
    expect(registro.bloqueado_em).to eq(agora + 6.seconds)
  end

  it "bloqueia no fim do tempo contado da liberação confirmada quando não há passagem" do
    registro = ler
    travel 1.second
    operador.confirmar_liberacao(registro)
    travel 6.seconds

    operador.expirar(registro)
    expect(registro.reload).to be_cancelado
    expect(registro.bloqueado_em).to eq(agora + 6.seconds)
    expect(estudante.saldo).to eq(10)
  end

  it "não altera leituras recusadas" do
    sem_saldo = create(:estudante)
    registro = operador.ler(identificacao: sem_saldo.matricula, referencia: SecureRandom.uuid)
    expect(registro).to be_recusado

    operador.confirmar_liberacao(registro)
    expect(registro.reload.liberado_em).to be_nil
  end

  it "cancela em vez de confirmar quando o prazo da liberação já passou" do
    registro = ler
    travel 6.seconds

    operador.confirmar_liberacao(registro)
    expect(registro.reload).to be_cancelado
    expect(registro.bloqueado_em).to eq(agora + 5.seconds)
  end
end
