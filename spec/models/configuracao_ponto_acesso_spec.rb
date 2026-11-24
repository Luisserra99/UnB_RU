require "rails_helper"

RSpec.describe ConfiguracaoPontoAcesso, type: :model do
  let(:ponto) { create(:configuracao_ponto_acesso) }

  it "disponibiliza apenas o ponto confirmado e vinculado ao restaurante" do
    expect(ponto).to be_disponivel
    expect(ponto.funcionario).to eq(ponto.sessao_autenticacao.usuario)
  end

  {
    "ponto finalizado" => ->(ponto) { ponto.finalizada_em = Time.current },
    "sessão expirada" => ->(ponto) { ponto.sessao_autenticacao.expira_em = 1.second.ago },
    "sessão encerrada" => ->(ponto) { ponto.sessao_autenticacao.encerrada_em = Time.current },
    "reconfiguração pendente" => ->(ponto) { ponto.sessao_autenticacao.ponto_acesso_pendente = true },
    "usuário inativo" => ->(ponto) { ponto.usuario.ativo = false },
    "operador sem papel de controle" => ->(ponto) { ponto.usuario.usuario_papeis.destroy_all },
    "restaurante inativo" => ->(ponto) { ponto.restaurante.ativo = false },
    "catraca inativa" => ->(ponto) { ponto.catraca.ativa = false },
    "catraca transferida" => ->(ponto) { ponto.catraca.restaurante = FactoryBot.create(:restaurante) }
  }.each do |caso, alterar|
    it "bloqueia operação com #{caso}" do
      alterar.call(ponto)
      expect(ponto).not_to be_disponivel
    end
  end

  it "recusa a criação de um ponto com catraca de outro restaurante" do
    ponto = build(:configuracao_ponto_acesso, restaurante: create(:restaurante))
    expect(ponto).not_to be_valid
    expect(ponto.errors[:catraca]).to include("não pertence ao restaurante selecionado")
  end

  it "cancela liberações vigentes no instante atual e vencidas no limite, preservando passagens" do
    travel_to Time.zone.local(2026, 11, 23, 12) do
      vencido = create(:registro_acesso, configuracao_ponto_acesso: ponto,
        estado: :liberado, liberado_em: 6.seconds.ago, passagem_em: nil, bloqueado_em: nil)
      vigente = create(:registro_acesso, configuracao_ponto_acesso: ponto,
        estado: :liberado, liberado_em: 1.second.ago, passagem_em: nil, bloqueado_em: nil)
      realizado = create(:registro_acesso, configuracao_ponto_acesso: ponto)

      ponto.cancelar_liberacoes!
      expect(vencido.reload).to be_cancelado
      expect(vencido.bloqueado_em).to eq(vencido.limite_em)
      expect(vigente.reload).to be_cancelado
      expect(vigente.bloqueado_em).to eq(Time.current)
      expect(realizado.reload).to be_realizado
      expect(MovimentacaoSaldo.debitos).to be_empty
    end
  end
end
