class CreateEstudantes < ActiveRecord::Migration[8.1]
  def change
    create_table :estudantes do |t|
      t.references :usuario, null: false, foreign_key: true, index: { unique: true }
      t.string :matricula, null: false
      t.boolean :vinculo_ativo, null: false, default: true

      t.timestamps
    end
    add_index :estudantes, :matricula, unique: true
  end
end
