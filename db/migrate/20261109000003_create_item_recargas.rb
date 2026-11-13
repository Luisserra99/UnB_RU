class CreateItemRecargas < ActiveRecord::Migration[8.1]
  def change
    create_table :item_recargas do |t|
      t.references :recarga, null: false, foreign_key: true, index: false
      t.references :tipo_refeicao, null: false, foreign_key: true
      t.references :tarifa_refeicao, null: false, foreign_key: true
      t.integer :quantidade, null: false
      t.decimal :valor_unitario, precision: 10, scale: 2, null: false

      t.timestamps

      t.check_constraint "quantidade > 0", name: "item_recargas_quantidade_positiva"
      t.check_constraint "valor_unitario > 0", name: "item_recargas_valor_unitario_positivo"
    end
    add_index :item_recargas, [ :recarga_id, :tipo_refeicao_id ], unique: true
  end
end
