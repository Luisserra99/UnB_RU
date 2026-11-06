class CreateTipoRefeicoes < ActiveRecord::Migration[8.1]
  def change
    create_table :tipo_refeicoes do |t|
      t.string :codigo, null: false
      t.string :nome, null: false

      t.timestamps
    end
    add_index :tipo_refeicoes, :codigo, unique: true
  end
end
