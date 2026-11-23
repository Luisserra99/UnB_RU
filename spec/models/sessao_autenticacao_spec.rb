require "rails_helper"

RSpec.describe SessaoAutenticacao, type: :model do
  let(:funcionario) { create(:funcionario) }

  describe ".iniciar!" do
    it "cria sessão ativa com ponto de acesso pendente e guarda só o digest do token" do
      sessao, token = described_class.iniciar!(funcionario)

      expect(sessao).to be_persisted
      expect(sessao).to be_ativa
      expect(sessao.ponto_acesso_pendente).to be(true)
      expect(sessao.token_digest).not_to eq(token)
      expect(described_class.localizar(token)).to eq(sessao)
    end

    it "expira após a duração padrão" do
      freeze_time do
        sessao, = described_class.iniciar!(funcionario)
        expect(sessao.expira_em).to eq(Time.current + SessaoAutenticacao::DURACAO)
      end
    end
  end

  describe ".localizar" do
    it "retorna nil para token vazio ou desconhecido" do
      expect(described_class.localizar(nil)).to be_nil
      expect(described_class.localizar("nao-existe")).to be_nil
    end
  end

  describe "estado da sessão" do
    it "fica expirada depois de expira_em" do
      sessao, = described_class.iniciar!(funcionario)
      travel_to(sessao.expira_em + 1.second) do
        expect(sessao).to be_expirada
        expect(sessao).not_to be_ativa
        expect(described_class.ativas).not_to include(sessao)
      end
    end

    it "fica inativa ao ser encerrada" do
      sessao, = described_class.iniciar!(funcionario)
      sessao.encerrar!
      expect(sessao.encerrada_em).to be_present
      expect(sessao).not_to be_ativa
      expect(sessao).not_to be_expirada
    end

    it "fica inativa se o usuário for desativado" do
      sessao, = described_class.iniciar!(funcionario)
      funcionario.update!(ativo: false)
      expect(sessao.reload).not_to be_ativa
    end
  end

  describe ".digest" do
    it "gera o mesmo SHA-256 para o mesmo token e outro para token diferente" do
      expect(described_class.digest("abc")).to eq(described_class.digest("abc")).and match(/\A\h{64}\z/)
      expect(described_class.digest("abc")).not_to eq(described_class.digest("abd"))
    end
  end

  describe "#ponto_acesso_atual" do
    let(:ponto) { create(:configuracao_ponto_acesso) }
    let(:sessao) { ponto.sessao_autenticacao }

    it "devolve a configuração aberta, ignorando as já finalizadas" do
      ponto.update!(finalizada_em: Time.current)
      aberta = create(:configuracao_ponto_acesso, sessao_autenticacao: sessao, confirmada_em: ponto.confirmada_em - 1.minute)
      expect(sessao.ponto_acesso_atual).to eq(aberta)
    end

    it "devolve nil sem ponto de acesso aberto" do
      sessao_sem_ponto, = described_class.iniciar!(funcionario)
      expect(sessao_sem_ponto.ponto_acesso_atual).to be_nil
    end

    it "devolve nil quando a sessão não está mais ativa" do
      travel_to(sessao.expira_em + 1.second) do
        expect(sessao.ponto_acesso_atual).to be_nil
      end
    end
  end

  describe "#encerrar!" do
    let(:ponto) { create(:configuracao_ponto_acesso) }
    let(:sessao) { ponto.sessao_autenticacao }

    it "finaliza os pontos de acesso abertos e volta a pedir o ponto de acesso" do
      sessao.encerrar!

      expect(ponto.reload.finalizada_em).to be_present
      expect(sessao.reload).to have_attributes(encerrada?: true, ponto_acesso_pendente: true)
    end

    it "não altera a data de uma sessão já encerrada" do
      sessao.encerrar!
      encerrada_em = sessao.reload.encerrada_em

      travel(1.hour) { sessao.encerrar! }
      expect(sessao.reload.encerrada_em).to eq(encerrada_em)
    end
  end
end
