class CreateUsuarioPapeis < ActiveRecord::Migration[8.1]
  def change
    # PK composta (usuario_id, papel_id), conforme o diagrama.
    create_table :usuario_papeis, primary_key: [ :usuario_id, :papel_id ] do |t|
      t.references :usuario, null: false, foreign_key: true, index: false
      t.references :papel, null: false, foreign_key: true

      t.timestamps
    end
  end
end
