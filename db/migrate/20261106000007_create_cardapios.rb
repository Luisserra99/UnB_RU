class CreateCardapios < ActiveRecord::Migration[8.1]
  def change
    create_table :cardapios do |t|
      t.references :servico_refeicao, null: false, foreign_key: true
      t.date :data_referencia, null: false

      t.timestamps
    end
    add_index :cardapios, [ :servico_refeicao_id, :data_referencia ], unique: true
  end
end
