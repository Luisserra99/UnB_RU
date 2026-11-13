class CreateItemCardapios < ActiveRecord::Migration[8.1]
  def change
    create_table :item_cardapios do |t|
      t.references :opcao_cardapio, null: false, foreign_key: true
      t.string :categoria, null: false
      t.string :descricao, null: false
      t.integer :ordem, null: false

      t.timestamps

      t.check_constraint "ordem > 0", name: "item_cardapios_ordem_positiva"
    end
    add_index :item_cardapios, [ :opcao_cardapio_id, :ordem ], unique: true
  end
end
