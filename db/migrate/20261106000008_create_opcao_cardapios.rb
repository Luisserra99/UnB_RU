class CreateOpcaoCardapios < ActiveRecord::Migration[8.1]
  def change
    create_table :opcao_cardapios do |t|
      t.references :cardapio, null: false, foreign_key: true
      t.string :dieta, null: false

      t.timestamps
    end
    add_index :opcao_cardapios, [ :cardapio_id, :dieta ], unique: true
  end
end
