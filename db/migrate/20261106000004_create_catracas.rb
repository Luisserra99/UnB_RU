class CreateCatracas < ActiveRecord::Migration[8.1]
  def change
    create_table :catracas do |t|
      t.references :piso, null: false, foreign_key: true
      t.string :identificacao, null: false
      t.boolean :ativa, null: false, default: true
      t.boolean :online, null: false, default: false
      t.datetime :estado_verificado_em

      t.timestamps
    end
  end
end
