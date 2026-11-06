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
end
