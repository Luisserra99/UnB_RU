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

ActiveRecord::Schema[8.1].define(version: 2026_11_12_145332) do
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

  create_table "configuracao_ponto_acessos", force: :cascade do |t|
    t.integer "sessao_autenticacao_id", null: false
    t.integer "catraca_id", null: false
    t.integer "restaurante_id", null: false
    t.datetime "confirmada_em", null: false
    t.datetime "finalizada_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catraca_id"], name: "index_configuracao_ponto_acessos_on_catraca_id"
    t.index ["restaurante_id"], name: "index_configuracao_ponto_acessos_on_restaurante_id"
    t.index ["sessao_autenticacao_id"], name: "index_configuracao_ponto_acessos_on_sessao_autenticacao_id"
    t.index ["sessao_autenticacao_id"], name: "uma_configuracao_aberta_por_sessao", unique: true, where: "finalizada_em IS NULL"
    t.check_constraint "finalizada_em IS NULL OR finalizada_em >= confirmada_em", name: "configuracao_vigencia_valida"
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

  create_table "exportacao_relatorios", force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.string "tipo", null: false
    t.string "formato", null: false
    t.json "filtros", default: {}, null: false
    t.json "agrupamentos", default: {}, null: false
    t.datetime "solicitada_em", null: false
    t.datetime "emitida_em"
    t.string "status", default: "processando", null: false
    t.integer "quantidade_registros"
    t.decimal "total_debitos", precision: 12, scale: 2
    t.decimal "total_creditos", precision: 12, scale: 2
    t.string "arquivo_chave"
    t.string "arquivo_sha256"
    t.string "assinatura_status", default: "nao_aplicavel", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["usuario_id", "solicitada_em"], name: "index_exportacao_relatorios_on_usuario_id_and_solicitada_em"
    t.index ["usuario_id"], name: "index_exportacao_relatorios_on_usuario_id"
    t.check_constraint "quantidade_registros IS NULL OR quantidade_registros >= 0", name: "exportacoes_quantidade_nao_negativa"
    t.check_constraint "total_creditos IS NULL OR total_creditos >= 0", name: "exportacoes_creditos_nao_negativos"
    t.check_constraint "total_debitos IS NULL OR total_debitos >= 0", name: "exportacoes_debitos_nao_negativos"
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

  create_table "item_recargas", force: :cascade do |t|
    t.integer "recarga_id", null: false
    t.integer "tipo_refeicao_id", null: false
    t.integer "tarifa_refeicao_id", null: false
    t.integer "quantidade", null: false
    t.decimal "valor_unitario", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recarga_id", "tipo_refeicao_id"], name: "index_item_recargas_on_recarga_id_and_tipo_refeicao_id", unique: true
    t.index ["tarifa_refeicao_id"], name: "index_item_recargas_on_tarifa_refeicao_id"
    t.index ["tipo_refeicao_id"], name: "index_item_recargas_on_tipo_refeicao_id"
    t.check_constraint "quantidade > 0", name: "item_recargas_quantidade_positiva"
    t.check_constraint "valor_unitario > 0", name: "item_recargas_valor_unitario_positivo"
  end

  create_table "movimentacao_saldos", force: :cascade do |t|
    t.integer "estudante_id", null: false
    t.integer "recarga_id"
    t.bigint "registro_acesso_id"
    t.string "natureza", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.datetime "ocorrida_em", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estudante_id", "ocorrida_em"], name: "index_movimentacao_saldos_on_estudante_id_and_ocorrida_em"
    t.index ["recarga_id"], name: "index_movimentacao_saldos_on_recarga_id", unique: true
    t.index ["registro_acesso_id"], name: "index_movimentacao_saldos_on_registro_acesso_id", unique: true
    t.check_constraint "(natureza = 'credito_recarga' AND valor > 0 AND recarga_id IS NOT NULL AND registro_acesso_id IS NULL) OR (natureza = 'debito_refeicao' AND valor < 0 AND recarga_id IS NULL AND registro_acesso_id IS NOT NULL)", name: "movimentacao_saldos_origem_coerente"
    t.check_constraint "natureza IN ('credito_recarga', 'debito_refeicao')", name: "movimentacao_saldos_natureza_valida"
  end

  create_table "opcao_cardapios", force: :cascade do |t|
    t.integer "cardapio_id", null: false
    t.string "dieta", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cardapio_id", "dieta"], name: "index_opcao_cardapios_on_cardapio_id_and_dieta", unique: true
    t.index ["cardapio_id"], name: "index_opcao_cardapios_on_cardapio_id"
  end

  create_table "pagamentos", force: :cascade do |t|
    t.integer "recarga_id", null: false
    t.string "metodo", null: false
    t.string "status", default: "pendente", null: false
    t.string "referencia_provedor"
    t.decimal "valor_solicitado", precision: 10, scale: 2, null: false
    t.decimal "valor_confirmado", precision: 10, scale: 2
    t.datetime "expira_em"
    t.datetime "confirmado_em"
    t.text "pix_copia_cola"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recarga_id"], name: "index_pagamentos_on_recarga_id"
    t.index ["recarga_id"], name: "index_pagamentos_um_confirmado_por_recarga", unique: true, where: "status = 'confirmado'"
    t.index ["referencia_provedor"], name: "index_pagamentos_on_referencia_provedor", unique: true
    t.check_constraint "metodo <> 'pix' OR (expira_em IS NOT NULL AND pix_copia_cola IS NOT NULL)", name: "pagamentos_pix_com_codigo_e_validade"
    t.check_constraint "metodo IN ('pix', 'cartao_credito')", name: "pagamentos_metodo_valido"
    t.check_constraint "status <> 'confirmado' OR (confirmado_em IS NOT NULL AND valor_confirmado = valor_solicitado)", name: "pagamentos_confirmado_completo"
    t.check_constraint "status IN ('pendente', 'confirmado', 'recusado', 'expirado')", name: "pagamentos_status_valido"
    t.check_constraint "valor_solicitado > 0", name: "pagamentos_valor_solicitado_positivo"
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

  create_table "rateio_consumos", force: :cascade do |t|
    t.integer "movimentacao_saldo_id", null: false
    t.integer "recarga_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movimentacao_saldo_id", "recarga_id"], name: "rateio_origem_unica", unique: true
    t.index ["movimentacao_saldo_id"], name: "index_rateio_consumos_on_movimentacao_saldo_id"
    t.index ["recarga_id"], name: "index_rateio_consumos_on_recarga_id"
    t.check_constraint "valor > 0", name: "rateio_valor_positivo"
  end

  create_table "recargas", force: :cascade do |t|
    t.integer "estudante_id", null: false
    t.datetime "solicitada_em", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.string "status", default: "pendente", null: false
    t.datetime "confirmada_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estudante_id", "solicitada_em"], name: "index_recargas_on_estudante_id_and_solicitada_em"
    t.check_constraint "status <> 'confirmada' OR confirmada_em IS NOT NULL", name: "recargas_confirmada_com_data"
    t.check_constraint "status IN ('pendente', 'confirmada', 'expirada', 'cancelada')", name: "recargas_status_valido"
    t.check_constraint "valor_total > 0", name: "recargas_valor_total_positivo"
  end

  create_table "registro_acessos", force: :cascade do |t|
    t.integer "configuracao_ponto_acesso_id", null: false
    t.integer "estudante_id"
    t.integer "servico_refeicao_id"
    t.integer "tarifa_refeicao_id"
    t.string "referencia_evento", null: false
    t.string "identificacao_lida", null: false
    t.decimal "saldo_lido", precision: 10, scale: 2
    t.decimal "valor_previsto", precision: 10, scale: 2
    t.string "estado", null: false
    t.string "mensagem", null: false
    t.datetime "lido_em", null: false
    t.datetime "liberado_em"
    t.datetime "passagem_em"
    t.datetime "bloqueado_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["configuracao_ponto_acesso_id"], name: "index_registro_acessos_on_configuracao_ponto_acesso_id"
    t.index ["estudante_id"], name: "index_registro_acessos_on_estudante_id"
    t.index ["referencia_evento"], name: "index_registro_acessos_on_referencia_evento", unique: true
    t.index ["servico_refeicao_id"], name: "index_registro_acessos_on_servico_refeicao_id"
    t.index ["tarifa_refeicao_id"], name: "index_registro_acessos_on_tarifa_refeicao_id"
    t.check_constraint "estado != 'realizado' OR (estudante_id IS NOT NULL AND liberado_em IS NOT NULL AND passagem_em IS NOT NULL AND bloqueado_em IS NOT NULL)", name: "registro_passagem_completa"
    t.check_constraint "estado IN ('recusado', 'liberado', 'realizado', 'cancelado')", name: "registro_estado_valido"
    t.check_constraint "valor_previsto IS NULL OR valor_previsto > 0", name: "registro_valor_positivo"
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

  create_table "tarifa_refeicoes", force: :cascade do |t|
    t.integer "tipo_refeicao_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.datetime "vigente_desde", null: false
    t.datetime "vigente_ate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_refeicao_id", "vigente_desde"], name: "index_tarifa_refeicoes_on_tipo_refeicao_id_and_vigente_desde", unique: true
    t.index ["tipo_refeicao_id"], name: "index_tarifa_refeicoes_on_tipo_refeicao_id"
    t.check_constraint "valor > 0", name: "tarifa_refeicoes_valor_positivo"
    t.check_constraint "vigente_ate IS NULL OR vigente_ate > vigente_desde", name: "tarifa_refeicoes_vigencia_valida"
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
  add_foreign_key "configuracao_ponto_acessos", "catracas"
  add_foreign_key "configuracao_ponto_acessos", "restaurantes"
  add_foreign_key "configuracao_ponto_acessos", "sessao_autenticacoes"
  add_foreign_key "estudantes", "usuarios"
  add_foreign_key "exportacao_relatorios", "usuarios"
  add_foreign_key "item_cardapios", "opcao_cardapios"
  add_foreign_key "item_recargas", "recargas"
  add_foreign_key "item_recargas", "tarifa_refeicoes"
  add_foreign_key "item_recargas", "tipo_refeicoes"
  add_foreign_key "movimentacao_saldos", "estudantes"
  add_foreign_key "movimentacao_saldos", "recargas"
  add_foreign_key "movimentacao_saldos", "registro_acessos"
  add_foreign_key "opcao_cardapios", "cardapios"
  add_foreign_key "pagamentos", "recargas"
  add_foreign_key "pisos", "restaurantes"
  add_foreign_key "rateio_consumos", "movimentacao_saldos"
  add_foreign_key "rateio_consumos", "recargas"
  add_foreign_key "recargas", "estudantes"
  add_foreign_key "registro_acessos", "configuracao_ponto_acessos"
  add_foreign_key "registro_acessos", "estudantes"
  add_foreign_key "registro_acessos", "servico_refeicoes"
  add_foreign_key "registro_acessos", "tarifa_refeicoes"
  add_foreign_key "restaurantes", "unidade_gestoras"
  add_foreign_key "servico_refeicoes", "restaurantes"
  add_foreign_key "servico_refeicoes", "tipo_refeicoes"
  add_foreign_key "sessao_autenticacoes", "usuarios"
  add_foreign_key "tarifa_refeicoes", "tipo_refeicoes"
  add_foreign_key "usuario_papeis", "papeis"
  add_foreign_key "usuario_papeis", "usuarios"
end
