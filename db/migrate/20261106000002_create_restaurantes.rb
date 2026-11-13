class CreateRestaurantes < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurantes do |t|
      t.references :unidade_gestora, null: false, foreign_key: true
      t.string :nome, null: false
      t.integer :numero, null: false
      t.integer :capacidade_refeicoes_hora, null: false
      t.boolean :ativo, null: false, default: true

      t.timestamps

      t.check_constraint "numero > 0", name: "restaurantes_numero_positivo"
      t.check_constraint "capacidade_refeicoes_hora > 0", name: "restaurantes_capacidade_positiva"
    end
    add_index :restaurantes, :nome, unique: true
    add_index :restaurantes, [ :unidade_gestora_id, :numero ], unique: true
  end
end
