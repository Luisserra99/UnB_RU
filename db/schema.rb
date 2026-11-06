# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_06_000009) do
  create_table "cardapios", force: :cascade do |t|
    t.integer "servico_refeicao_id", null: false
    t.date "data_referencia", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["servico_refeicao_id", "data_referencia"], name: "index_cardapios_on_servico_refeicao_id_and_data_referencia", unique: true
    t.index ["servico_refeicao_id"], name: "index_cardapios_on_servico_refeicao_id"
  end

  create_table "catracas", force: :cascade do |t|
    t.integer "piso_id", null: false
    t.string "identificacao", null: false
    t.boolean "ativa", default: true, null: false
    t.boolean "online", default: false, null: false
    t.datetime "estado_verificado_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["piso_id"], name: "index_catracas_on_piso_id"
  end

  create_table "estudantes", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.string "matricula", null: false
    t.boolean "vinculo_ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_estudantes_on_matricula", unique: true
    t.index ["usuario_id"], name: "index_estudantes_on_usuario_id", unique: true
  end

  create_table "item_cardapios", force: :cascade do |t|
    t.integer "opcao_cardapio_id", null: false
    t.string "categoria", null: false
    t.string "descricao", null: false
    t.integer "ordem", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opcao_cardapio_id", "ordem"], name: "index_item_cardapios_on_opcao_cardapio_id_and_ordem", unique: true
    t.index ["opcao_cardapio_id"], name: "index_item_cardapios_on_opcao_cardapio_id"
    t.check_constraint "ordem > 0", name: "item_cardapios_ordem_positiva"
  end

  create_table "opcao_cardapios", force: :cascade do |t|
    t.integer "cardapio_id", null: false
    t.string "dieta", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cardapio_id", "dieta"], name: "index_opcao_cardapios_on_cardapio_id_and_dieta", unique: true
    t.index ["cardapio_id"], name: "index_opcao_cardapios_on_cardapio_id"
  end

  create_table "papeis", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "descricao", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_papeis_on_codigo", unique: true
  end

  create_table "pisos", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.integer "numero", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurante_id", "numero"], name: "index_pisos_on_restaurante_id_and_numero", unique: true
    t.index ["restaurante_id"], name: "index_pisos_on_restaurante_id"
    t.check_constraint "numero > 0", name: "pisos_numero_positivo"
  end

  create_table "restaurantes", force: :cascade do |t|
    t.integer "unidade_gestora_id", null: false
    t.string "nome", null: false
    t.integer "numero", null: false
    t.integer "capacidade_refeicoes_hora", null: false
    t.boolean "ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_restaurantes_on_nome", unique: true
    t.index ["unidade_gestora_id", "numero"], name: "index_restaurantes_on_unidade_gestora_id_and_numero", unique: true
    t.index ["unidade_gestora_id"], name: "index_restaurantes_on_unidade_gestora_id"
    t.check_constraint "capacidade_refeicoes_hora > 0", name: "restaurantes_capacidade_positiva"
    t.check_constraint "numero > 0", name: "restaurantes_numero_positivo"
  end

  create_table "servico_refeicoes", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.integer "tipo_refeicao_id", null: false
    t.integer "dia_semana", null: false
    t.time "inicio", null: false
    t.time "fim", null: false
    t.boolean "ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurante_id", "tipo_refeicao_id", "dia_semana"], name: "index_servico_refeicoes_unico_por_dia", unique: true
    t.index ["restaurante_id"], name: "index_servico_refeicoes_on_restaurante_id"
    t.index ["tipo_refeicao_id"], name: "index_servico_refeicoes_on_tipo_refeicao_id"
    t.check_constraint "dia_semana BETWEEN 0 AND 6", name: "servico_refeicoes_dia_semana_valido"
    t.check_constraint "inicio < fim", name: "servico_refeicoes_inicio_antes_do_fim"
  end

  create_table "sessao_autenticacoes", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.string "token_digest", null: false
    t.datetime "autenticada_em", null: false
    t.datetime "expira_em", null: false
    t.datetime "encerrada_em"
    t.boolean "ponto_acesso_pendente", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_digest"], name: "index_sessao_autenticacoes_on_token_digest", unique: true
    t.index ["usuario_id"], name: "index_sessao_autenticacoes_on_usuario_id"
  end

  create_table "tipo_refeicoes", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_tipo_refeicoes_on_codigo", unique: true
  end

  create_table "unidade_gestoras", force: :cascade do |t|
    t.string "nome", null: false
    t.boolean "ativa", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_unidade_gestoras_on_nome", unique: true
  end

  create_table "usuario_papeis", primary_key: ["usuario_id", "papel_id"], force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "papel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["papel_id"], name: "index_usuario_papeis_on_papel_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "nome", null: false
    t.string "identificacao", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["identificacao"], name: "index_usuarios_on_identificacao", unique: true
  end

  add_foreign_key "cardapios", "servico_refeicoes"
  add_foreign_key "catracas", "pisos"
  add_foreign_key "estudantes", "usuarios"
  add_foreign_key "item_cardapios", "opcao_cardapios"
  add_foreign_key "opcao_cardapios", "cardapios"
  add_foreign_key "pisos", "restaurantes"
  add_foreign_key "restaurantes", "unidade_gestoras"
  add_foreign_key "servico_refeicoes", "restaurantes"
  add_foreign_key "servico_refeicoes", "tipo_refeicoes"
  add_foreign_key "sessao_autenticacoes", "usuarios"
  add_foreign_key "usuario_papeis", "papeis"
  add_foreign_key "usuario_papeis", "usuarios"
end
