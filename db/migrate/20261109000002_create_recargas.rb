class CreateRecargas < ActiveRecord::Migration[8.1]
  def change
    create_table :recargas do |t|
      t.references :estudante, null: false, foreign_key: true, index: false
      t.datetime :solicitada_em, null: false
      t.decimal :valor_total, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: "pendente"
      t.datetime :confirmada_em

      t.timestamps

      t.check_constraint "valor_total > 0", name: "recargas_valor_total_positivo"
      t.check_constraint "status IN ('pendente', 'confirmada', 'expirada', 'cancelada')", name: "recargas_status_valido"
      t.check_constraint "status <> 'confirmada' OR confirmada_em IS NOT NULL", name: "recargas_confirmada_com_data"
    end
    add_index :recargas, [ :estudante_id, :solicitada_em ]
  end
end
