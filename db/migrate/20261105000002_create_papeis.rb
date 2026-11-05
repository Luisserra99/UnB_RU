class CreatePapeis < ActiveRecord::Migration[8.1]
  def change
    create_table :papeis do |t|
      t.string :codigo, null: false
      t.string :descricao, null: false

      t.timestamps
    end
    add_index :papeis, :codigo, unique: true
  end
end
