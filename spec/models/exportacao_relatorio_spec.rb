require "rails_helper"

RSpec.describe ExportacaoRelatorio, type: :model do
  let(:exportacao) { build(:exportacao_relatorio) }
  let(:concluida) { build(:exportacao_relatorio, :concluida) }

  describe "atributos obrigatórios" do
    it "é válida com os atributos obrigatórios" do
      expect(exportacao).to be_valid
    end

    it "nasce processando e sem assinatura aplicável" do
      nova = described_class.new

      expect(nova.status).to eq("processando")
      expect(nova.assinatura_status).to eq("nao_aplicavel")
    end

    it "pertence a um usuário" do
      exportacao.usuario = nil

      expect(exportacao).not_to be_valid
    end

    it "exige data da solicitação" do
      exportacao.solicitada_em = nil

      expect(exportacao).not_to be_valid
    end
  end

  describe "valores permitidos" do
    it "aceita os tipos de relatório previstos" do
      %w[extrato_estudante operacao_global].each do |tipo|
        exportacao.tipo = tipo
        expect(exportacao).to be_valid
      end
    end

    it "aceita os formatos previstos" do
      %w[pdf csv].each do |formato|
        exportacao.formato = formato
        expect(exportacao).to be_valid
      end
    end

    it "aceita os estados sem documento emitido" do
      %w[processando sem_dados falhou].each do |status|
        exportacao.status = status
        expect(exportacao).to be_valid
      end
    end

    it "aceita os status de assinatura de uma exportação em andamento" do
      %w[nao_aplicavel pendente falhou].each do |assinatura|
        exportacao.assinatura_status = assinatura
        expect(exportacao).to be_valid
      end
    end

    it "rejeita tipos de relatório desconhecidos" do
      exportacao.tipo = "desconhecido"

      expect(exportacao).not_to be_valid
    end

    it "rejeita formatos não suportados" do
      exportacao.formato = "docx"

      expect(exportacao).not_to be_valid
    end

    it "rejeita estados inválidos" do
      exportacao.status = "invalido"

      expect(exportacao).not_to be_valid
    end

    it "rejeita status de assinatura inválido" do
      exportacao.assinatura_status = "invalido"

      expect(exportacao).not_to be_valid
    end

    it "exige tipo e formato" do
      exportacao.tipo = nil
      expect(exportacao).not_to be_valid

      exportacao.tipo = "operacao_global"
      exportacao.formato = nil
      expect(exportacao).not_to be_valid
    end
  end

  describe "filtros e agrupamentos" do
    it "rejeita filtros que não sejam objetos JSON" do
      exportacao.filtros = []

      expect(exportacao).not_to be_valid
    end

    it "rejeita agrupamentos que não sejam objetos JSON" do
      exportacao.agrupamentos = "restaurante"

      expect(exportacao).not_to be_valid
    end

    it "permite filtros e agrupamentos vazios" do
      exportacao.filtros = {}
      exportacao.agrupamentos = {}

      expect(exportacao).to be_valid
    end

    it "persiste filtros e agrupamentos em JSON" do
      filtros = { "turno" => "almoco" }
      agrupamentos = { "por" => [ "restaurante" ] }

      registro = create(:exportacao_relatorio, filtros: filtros, agrupamentos: agrupamentos)
      registro.reload

      expect(registro.filtros).to eq(filtros)
      expect(registro.agrupamentos).to eq(agrupamentos)
    end
  end

  describe "quantidades e totais" do
    it "rejeita quantidade negativa de registros" do
      exportacao.quantidade_registros = -1

      expect(exportacao).not_to be_valid
    end

    it "rejeita quantidade de registros não inteira" do
      exportacao.quantidade_registros = 1.5

      expect(exportacao).not_to be_valid
    end

    it "rejeita totais financeiros negativos" do
      exportacao.total_debitos = -10
      expect(exportacao).not_to be_valid

      exportacao.total_debitos = 0
      exportacao.total_creditos = -5
      expect(exportacao).not_to be_valid
    end

    it "aceita quantidade e totais zerados" do
      exportacao.assign_attributes(quantidade_registros: 0, total_debitos: 0, total_creditos: 0)

      expect(exportacao).to be_valid
    end

    it "o banco também recusa valores negativos" do
      registro = create(:exportacao_relatorio)

      expect { registro.update_columns(quantidade_registros: -1) }
        .to raise_error(ActiveRecord::StatementInvalid)
      expect { registro.update_columns(total_debitos: -1) }
        .to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe "arquivo gerado" do
    it "impede registrar arquivo antes da conclusão" do
      exportacao.arquivo_chave = "relatorios/teste.pdf"
      exportacao.arquivo_sha256 = "a" * 64

      expect(exportacao).not_to be_valid
    end

    it "exige chave e SHA-256 juntos" do
      concluida.arquivo_sha256 = nil

      expect(concluida).not_to be_valid
    end

    it "rejeita SHA-256 com tamanho errado" do
      concluida.arquivo_sha256 = "a" * 63

      expect(concluida).not_to be_valid
    end

    it "rejeita SHA-256 com caracteres não hexadecimais" do
      concluida.arquivo_sha256 = "g" * 64

      expect(concluida).not_to be_valid
    end
  end

  describe "conclusão" do
    it "aceita exportação concluída com emissão, arquivo e quantidade" do
      expect(concluida).to be_valid
    end

    it "exige data de emissão na conclusão" do
      concluida.emitida_em = nil

      expect(concluida).not_to be_valid
    end

    it "exige arquivo na conclusão" do
      concluida.assign_attributes(arquivo_chave: nil, arquivo_sha256: nil)

      expect(concluida).not_to be_valid
    end

    it "exige quantidade de registros na conclusão" do
      concluida.quantidade_registros = nil

      expect(concluida).not_to be_valid
    end

    it "não permite emissão anterior à solicitação" do
      concluida.emitida_em = concluida.solicitada_em - 1.minute

      expect(concluida).not_to be_valid
    end

    it "não permite data de emissão sem conclusão" do
      %w[processando sem_dados falhou].each do |status|
        exportacao.assign_attributes(status: status, emitida_em: exportacao.solicitada_em + 1.second)
        expect(exportacao).not_to be_valid
      end
    end
  end

  describe "assinatura" do
    it "não permite marcar como assinada antes da conclusão" do
      exportacao.assinatura_status = "assinada"

      expect(exportacao).not_to be_valid
    end

    it "permite marcar como assinada uma exportação concluída" do
      concluida.assinatura_status = "assinada"

      expect(concluida).to be_valid
    end
  end

  describe "factory" do
    it "gera exportações válidas em cada variação" do
      %i[concluida sem_dados falhou extrato].each do |variacao|
        expect(build(:exportacao_relatorio, variacao)).to be_valid
      end
    end
  end
end
