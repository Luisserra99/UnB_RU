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

ActiveRecord::Schema[8.1].define(version: 2026_11_05_000005) do
  create_table "estudantes", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.string "matricula", null: false
    t.boolean "vinculo_ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_estudantes_on_matricula", unique: true
    t.index ["usuario_id"], name: "index_estudantes_on_usuario_id", unique: true
  end

  create_table "papeis", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "descricao", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_papeis_on_codigo", unique: true
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

  add_foreign_key "estudantes", "usuarios"
  add_foreign_key "sessao_autenticacoes", "usuarios"
  add_foreign_key "usuario_papeis", "papeis"
  add_foreign_key "usuario_papeis", "usuarios"
end
