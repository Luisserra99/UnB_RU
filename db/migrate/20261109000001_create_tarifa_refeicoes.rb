class CreateTarifaRefeicoes < ActiveRecord::Migration[8.1]
  def change
    create_table :tarifa_refeicoes do |t|
      t.references :tipo_refeicao, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.datetime :vigente_desde, null: false
      t.datetime :vigente_ate

      t.timestamps

      t.check_constraint "valor > 0", name: "tarifa_refeicoes_valor_positivo"
      t.check_constraint "vigente_ate IS NULL OR vigente_ate > vigente_desde", name: "tarifa_refeicoes_vigencia_valida"
    end
    add_index :tarifa_refeicoes, [ :tipo_refeicao_id, :vigente_desde ], unique: true
  end
end
