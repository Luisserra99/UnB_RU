class CreateUsuarios < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      t.string :nome, null: false
      t.string :identificacao, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :ativo, null: false, default: true

      t.timestamps
    end
    add_index :usuarios, :identificacao, unique: true
    add_index :usuarios, :email, unique: true
  end
end
