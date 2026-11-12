
require "rails_helper"

RSpec.describe ExportacaoRelatorio, type: :model do
  let(:exportacao) { build(:exportacao_relatorio) }

  it "é válida com os atributos obrigatórios" do
    expect(exportacao).to be_valid
  end

  it "pertence a um usuário" do
    exportacao.usuario = nil

    expect(exportacao).not_to be_valid
  end

  it "exige data da solicitação" do
    exportacao.solicitada_em = nil

    expect(exportacao).not_to be_valid
  end

  it "aceita os tipos de relatório previstos" do
    exportacao.tipo = "extrato_estudante"
    expect(exportacao).to be_valid

    exportacao.tipo = "operacao_global"
    expect(exportacao).to be_valid
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

  it "rejeita quantidade negativa de registros" do
    exportacao.quantidade_registros = -1

    expect(exportacao).not_to be_valid
  end

  it "rejeita totais financeiros negativos" do
    exportacao.total_debitos = -10

    expect(exportacao).not_to be_valid

    exportacao.total_debitos = 0
    exportacao.total_creditos = -5

    expect(exportacao).not_to be_valid
  end

  it "não permite emissão anterior à solicitação" do
    exportacao.emitida_em = exportacao.solicitada_em - 1.minute

    expect(exportacao).not_to be_valid
  end

  it "impede registrar arquivo antes da conclusão" do
    exportacao.arquivo_chave = "relatorios/teste.pdf"
    exportacao.arquivo_sha256 = "a" * 64

    expect(exportacao).not_to be_valid
  end

  it "exige chave e SHA-256 juntos" do
    exportacao.status = "concluida"
    exportacao.arquivo_chave = "relatorios/teste.pdf"

    expect(exportacao).not_to be_valid
  end

  it "aceita exportação concluída com arquivo e hash" do
    exportacao.status = "concluida"
    exportacao.emitida_em = Time.current
    exportacao.arquivo_chave = "relatorios/teste.pdf"
    exportacao.arquivo_sha256 = "a" * 64

    expect(exportacao).to be_valid
  end

  it "persiste filtros e agrupamentos em JSON" do
    filtros = { "turno" => "almoco" }
    agrupamentos = { "por" => ["restaurante"] }

    registro = create(
      :exportacao_relatorio,
      filtros: filtros,
      agrupamentos: agrupamentos
    )

    registro.reload

    expect(registro.filtros).to eq(filtros)
    expect(registro.agrupamentos).to eq(agrupamentos)
  end
end
