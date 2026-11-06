class CreateUnidadeGestoras < ActiveRecord::Migration[8.1]
  def change
    create_table :unidade_gestoras do |t|
      t.string :nome, null: false
      t.boolean :ativa, null: false, default: true

      t.timestamps
    end
    add_index :unidade_gestoras, :nome, unique: true
  end
end
