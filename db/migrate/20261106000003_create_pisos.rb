class CreatePisos < ActiveRecord::Migration[8.1]
  def change
    create_table :pisos do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.integer :numero, null: false

      t.timestamps

      t.check_constraint "numero > 0", name: "pisos_numero_positivo"
    end
    add_index :pisos, [ :restaurante_id, :numero ], unique: true
  end
end
