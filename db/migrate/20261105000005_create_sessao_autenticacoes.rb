class CreateSessaoAutenticacoes < ActiveRecord::Migration[8.1]
  def change
    create_table :sessao_autenticacoes do |t|
      t.references :usuario, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :autenticada_em, null: false
      t.datetime :expira_em, null: false
      t.datetime :encerrada_em
      t.boolean :ponto_acesso_pendente, null: false, default: true

      t.timestamps
    end
    add_index :sessao_autenticacoes, :token_digest, unique: true
  end
end
