class CreatePagamentos < ActiveRecord::Migration[8.1]
  def change
    create_table :pagamentos do |t|
      t.references :recarga, null: false, foreign_key: true
      t.string :metodo, null: false
      t.string :status, null: false, default: "pendente"
      t.string :referencia_provedor
      t.decimal :valor_solicitado, precision: 10, scale: 2, null: false
      t.decimal :valor_confirmado, precision: 10, scale: 2
      t.datetime :expira_em
      t.datetime :confirmado_em
      t.text :pix_copia_cola

      t.timestamps

      t.check_constraint "metodo IN ('pix', 'cartao_credito')", name: "pagamentos_metodo_valido"
      t.check_constraint "status IN ('pendente', 'confirmado', 'recusado', 'expirado')", name: "pagamentos_status_valido"
      t.check_constraint "valor_solicitado > 0", name: "pagamentos_valor_solicitado_positivo"
      t.check_constraint "status <> 'confirmado' OR (confirmado_em IS NOT NULL AND valor_confirmado = valor_solicitado)",
                         name: "pagamentos_confirmado_completo"
      t.check_constraint "metodo <> 'pix' OR (expira_em IS NOT NULL AND pix_copia_cola IS NOT NULL)",
                         name: "pagamentos_pix_com_codigo_e_validade"
    end
    add_index :pagamentos, :referencia_provedor, unique: true
    # No máximo um pagamento confirmado por recarga: a confirmação nunca credita duas vezes.
    add_index :pagamentos, :recarga_id, unique: true, where: "status = 'confirmado'",
              name: "index_pagamentos_um_confirmado_por_recarga"
  end
end
