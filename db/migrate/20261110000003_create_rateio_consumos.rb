class CreateRateioConsumos < ActiveRecord::Migration[8.1]
  def change
    create_table :rateio_consumos do |t|
      t.references :movimentacao_saldo, null: false, foreign_key: true
      t.references :recarga, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.timestamps
      t.check_constraint "valor > 0", name: "rateio_valor_positivo"
    end
    add_index :rateio_consumos, [ :movimentacao_saldo_id, :recarga_id ], unique: true, name: "rateio_origem_unica"
  end
end
