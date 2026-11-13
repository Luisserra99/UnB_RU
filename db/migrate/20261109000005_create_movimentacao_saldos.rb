# Extrato do saldo do estudante: o saldo é a soma de `valor` (créditos positivos, débitos negativos).
# F02 (Luis) cria a parte de crédito. O débito de refeição é da F06 (Daniel): quando a tabela
# registro_acessos existir, a F06 adiciona a FK de registro_acesso_id e passa a exigi-lo no débito.
class CreateMovimentacaoSaldos < ActiveRecord::Migration[8.1]
  def change
    create_table :movimentacao_saldos do |t|
      t.references :estudante, null: false, foreign_key: true, index: false
      t.references :recarga, foreign_key: true, index: { unique: true }
      t.bigint :registro_acesso_id
      t.string :natureza, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.datetime :ocorrida_em, null: false

      t.timestamps

      t.check_constraint "natureza IN ('credito_recarga', 'debito_refeicao')", name: "movimentacao_saldos_natureza_valida"
      t.check_constraint "(natureza = 'credito_recarga' AND valor > 0 AND recarga_id IS NOT NULL AND registro_acesso_id IS NULL) " \
                         "OR (natureza = 'debito_refeicao' AND valor < 0 AND recarga_id IS NULL)",
                         name: "movimentacao_saldos_origem_coerente"
    end
    add_index :movimentacao_saldos, :registro_acesso_id, unique: true
    add_index :movimentacao_saldos, [ :estudante_id, :ocorrida_em ]
  end
end
