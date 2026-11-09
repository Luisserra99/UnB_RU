class CreateRegistroAcessos < ActiveRecord::Migration[8.1]
  def change
    create_table :registro_acessos do |t|
      t.references :configuracao_ponto_acesso, null: false, foreign_key: true
      t.references :estudante, foreign_key: true
      t.references :servico_refeicao, foreign_key: true
      t.references :tarifa_refeicao, foreign_key: true
      t.string :referencia_evento, null: false
      t.string :identificacao_lida, null: false
      t.decimal :saldo_lido, precision: 10, scale: 2
      t.decimal :valor_previsto, precision: 10, scale: 2
      t.string :estado, null: false
      t.string :mensagem, null: false
      t.datetime :lido_em, null: false
      t.datetime :liberado_em
      t.datetime :passagem_em
      t.datetime :bloqueado_em
      t.timestamps
      t.check_constraint "estado IN ('recusado', 'liberado', 'realizado', 'cancelado')", name: "registro_estado_valido"
      t.check_constraint "valor_previsto IS NULL OR valor_previsto > 0", name: "registro_valor_positivo"
      t.check_constraint "estado != 'realizado' OR (estudante_id IS NOT NULL AND liberado_em IS NOT NULL AND passagem_em IS NOT NULL AND bloqueado_em IS NOT NULL)", name: "registro_passagem_completa"
    end
    add_index :registro_acessos, :referencia_evento, unique: true
    add_foreign_key :movimentacao_saldos, :registro_acessos
    remove_check_constraint :movimentacao_saldos,
      "(natureza = 'credito_recarga' AND valor > 0 AND recarga_id IS NOT NULL AND registro_acesso_id IS NULL) OR " \
      "(natureza = 'debito_refeicao' AND valor < 0 AND recarga_id IS NULL)",
      name: "movimentacao_saldos_origem_coerente"
    add_check_constraint :movimentacao_saldos,
      "(natureza = 'credito_recarga' AND valor > 0 AND recarga_id IS NOT NULL AND registro_acesso_id IS NULL) OR " \
      "(natureza = 'debito_refeicao' AND valor < 0 AND recarga_id IS NULL AND registro_acesso_id IS NOT NULL)",
      name: "movimentacao_saldos_origem_coerente"
  end
end
