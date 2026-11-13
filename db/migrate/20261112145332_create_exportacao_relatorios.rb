class CreateExportacaoRelatorios < ActiveRecord::Migration[8.1]
  def change
    create_table :exportacao_relatorios do |t|
      t.references :usuario, null: false, foreign_key: true

      t.string :tipo, null: false
      t.string :formato, null: false

      t.json :filtros, null: false, default: {}
      t.json :agrupamentos, null: false, default: {}

      t.datetime :solicitada_em, null: false
      t.datetime :emitida_em

      t.string :status, null: false, default: "processando"

      t.integer :quantidade_registros
      t.decimal :total_debitos, precision: 12, scale: 2
      t.decimal :total_creditos, precision: 12, scale: 2

      t.string :arquivo_chave
      t.string :arquivo_sha256

      t.string :assinatura_status,
               null: false,
               default: "nao_aplicavel"

      t.timestamps
    end

    add_index :exportacao_relatorios, [ :usuario_id, :solicitada_em ]

    add_check_constraint :exportacao_relatorios,
                         "quantidade_registros IS NULL OR quantidade_registros >= 0",
                         name: "exportacoes_quantidade_nao_negativa"

    add_check_constraint :exportacao_relatorios,
                         "total_debitos IS NULL OR total_debitos >= 0",
                         name: "exportacoes_debitos_nao_negativos"

    add_check_constraint :exportacao_relatorios,
                         "total_creditos IS NULL OR total_creditos >= 0",
                         name: "exportacoes_creditos_nao_negativos"
  end
end
