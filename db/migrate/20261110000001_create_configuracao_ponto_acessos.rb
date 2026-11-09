class CreateConfiguracaoPontoAcessos < ActiveRecord::Migration[8.1]
  def change
    create_table :configuracao_ponto_acessos do |t|
      t.references :sessao_autenticacao, null: false, foreign_key: true
      t.references :catraca, null: false, foreign_key: true
      t.references :restaurante, null: false, foreign_key: true
      t.datetime :confirmada_em, null: false
      t.datetime :finalizada_em
      t.timestamps
      t.check_constraint "finalizada_em IS NULL OR finalizada_em >= confirmada_em", name: "configuracao_vigencia_valida"
    end
    add_index :configuracao_ponto_acessos, :sessao_autenticacao_id, unique: true,
              where: "finalizada_em IS NULL", name: "uma_configuracao_aberta_por_sessao"
  end
end
