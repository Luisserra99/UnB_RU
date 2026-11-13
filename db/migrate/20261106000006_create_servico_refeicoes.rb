class CreateServicoRefeicoes < ActiveRecord::Migration[8.1]
  def change
    create_table :servico_refeicoes do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.references :tipo_refeicao, null: false, foreign_key: true
      t.integer :dia_semana, null: false
      t.time :inicio, null: false
      t.time :fim, null: false
      t.boolean :ativo, null: false, default: true

      t.timestamps

      t.check_constraint "dia_semana BETWEEN 0 AND 6", name: "servico_refeicoes_dia_semana_valido"
      t.check_constraint "inicio < fim", name: "servico_refeicoes_inicio_antes_do_fim"
    end
    add_index :servico_refeicoes, [ :restaurante_id, :tipo_refeicao_id, :dia_semana ],
              unique: true, name: "index_servico_refeicoes_unico_por_dia"
  end
end
