require "rails_helper"

RSpec.describe PontosAcesso::Configurar do
  let(:sessao) { create(:sessao_autenticacao, usuario: create(:funcionario)) }
  let(:catraca) { create(:catraca) }

  def confirmar(restaurante_id: catraca.restaurante.id, catraca_id: catraca.id)
    described_class.call(sessao: sessao, restaurante_id: restaurante_id, catraca_id: catraca_id)
  end

  it "confirma o ponto e remove a pendência na mesma sessão" do
    ponto = confirmar
    expect(ponto).to be_persisted
    expect(ponto).to be_disponivel
    expect(sessao.reload.ponto_acesso_atual).to eq(ponto)
    expect(sessao).not_to be_ponto_acesso_pendente
  end

  {
    "restaurante ausente" => [ { restaurante_id: nil }, "Selecione um restaurante" ],
    "restaurante inexistente" => [ { restaurante_id: -1 }, "Restaurante indisponível" ],
    "catraca ausente" => [ { catraca_id: nil }, "Selecione uma catraca do restaurante" ],
    "catraca inexistente" => [ { catraca_id: -1 }, "Catraca indisponível" ]
  }.each do |caso, (parametros, mensagem)|
    it "recusa #{caso} sem criar configuração" do
      expect { confirmar(**parametros) }.to raise_error(described_class::Invalido, mensagem)
      expect(sessao.configuracoes_ponto_acesso).to be_empty
      expect(sessao.reload).to be_ponto_acesso_pendente
    end
  end

  it "recusa restaurante inativo" do
    catraca.restaurante.update!(ativo: false)
    expect { confirmar }.to raise_error(described_class::Invalido, "Restaurante indisponível")
  end

  it "recusa catraca inativa" do
    catraca.update!(ativa: false)
    expect { confirmar }.to raise_error(described_class::Invalido, "Catraca indisponível")
  end

  it "recusa catraca de outro restaurante" do
    outro = create(:restaurante)
    expect { confirmar(restaurante_id: outro.id) }
      .to raise_error(described_class::Invalido, "A catraca não pertence ao restaurante selecionado")
  end

  it "recusa sessão expirada" do
    sessao.update!(expira_em: 1.second.ago)
    expect { confirmar }.to raise_error(described_class::Invalido, "Sessão inválida")
    expect(sessao.configuracoes_ponto_acesso).to be_empty
  end

  it "recusa sessão encerrada" do
    sessao.encerrar!
    expect { confirmar }.to raise_error(described_class::Invalido, "Sessão inválida")
  end

  it "recusa operador sem papel de controle" do
    sessao.usuario.usuario_papeis.destroy_all
    expect { confirmar }.to raise_error(described_class::Invalido, "Sessão inválida")
  end

  it "preserva o ponto e a liberação anterior quando a nova seleção é inválida" do
    ponto = confirmar
    registro = create(:registro_acesso, configuracao_ponto_acesso: ponto,
      estado: :liberado, passagem_em: nil, bloqueado_em: nil)
    expect { confirmar(catraca_id: -1) }.to raise_error(described_class::Invalido)
    expect(ponto.reload.finalizada_em).to be_nil
    expect(registro.reload).to be_liberado
    expect(sessao.reload).not_to be_ponto_acesso_pendente
  end

  it "reverte cancelamentos e encerramento se a criação do novo ponto falha" do
    ponto = confirmar
    registro = create(:registro_acesso, configuracao_ponto_acesso: ponto,
      estado: :liberado, passagem_em: nil, bloqueado_em: nil)
    allow_any_instance_of(ConfiguracaoPontoAcesso).to receive(:save!)
      .and_raise(ActiveRecord::RecordInvalid.new(ConfiguracaoPontoAcesso.new))

    expect { confirmar }.to raise_error(ActiveRecord::RecordInvalid)
    expect(ponto.reload.finalizada_em).to be_nil
    expect(registro.reload).to be_liberado
    expect(sessao.reload.ponto_acesso_atual).to eq(ponto)
    expect(sessao.configuracoes_ponto_acesso.count).to eq(1)
  end
end
