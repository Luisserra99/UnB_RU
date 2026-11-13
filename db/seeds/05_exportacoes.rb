# Seeds de exportações de relatório (F09, F11 e F12) — responsável: Tarsila.
# São só metadados de exemplo: nenhum arquivo é gerado aqui.
# Depende dos usuários de 01_identidade.rb (admin e estudante 251033574).

def seed_exportacao(usuario:, tipo:, formato:, solicitada_em:, **atributos)
  return if usuario.nil?

  ExportacaoRelatorio.find_or_create_by!(usuario: usuario, tipo: tipo, formato: formato,
                                         solicitada_em: solicitada_em) do |exportacao|
    exportacao.assign_attributes(atributos)
  end
end

administrador = Usuario.find_by(identificacao: "admin")
estudante = Usuario.find_by(identificacao: "251033574")
filtros_operacao = { "inicio" => "2026-10-14", "fim" => "2026-10-15", "restaurante" => "todos", "catraca" => "todas" }

# Relatório de operação concluído (F12)
seed_exportacao(usuario: administrador, tipo: "operacao_global", formato: "pdf",
                solicitada_em: Time.zone.local(2026, 10, 16, 20, 0, 0),
                emitida_em: Time.zone.local(2026, 10, 16, 20, 0, 3),
                status: "concluida", filtros: filtros_operacao,
                agrupamentos: { "por" => %w[restaurante catraca] },
                quantidade_registros: 4, total_debitos: BigDecimal("18.00"), total_creditos: BigDecimal("0"),
                arquivo_chave: "relatorios/operacao-global-20261016-200000.pdf",
                arquivo_sha256: Digest::SHA256.hexdigest("operacao-global-20261016-200000"))

# Relatório global em CSV concluído (F09)
seed_exportacao(usuario: administrador, tipo: "operacao_global", formato: "csv",
                solicitada_em: Time.zone.local(2026, 10, 16, 20, 5, 0),
                emitida_em: Time.zone.local(2026, 10, 16, 20, 5, 1),
                status: "concluida", filtros: { "data" => "2026-10-15", "turno" => "almoco" },
                quantidade_registros: 2, total_debitos: BigDecimal("9.00"), total_creditos: BigDecimal("0"),
                arquivo_chave: "relatorios/operacao-global-20261016-200500.csv",
                arquivo_sha256: Digest::SHA256.hexdigest("operacao-global-20261016-200500"))

# Período sem acessos: nada é emitido (F12)
seed_exportacao(usuario: administrador, tipo: "operacao_global", formato: "pdf",
                solicitada_em: Time.zone.local(2026, 10, 16, 20, 10, 0),
                status: "sem_dados", quantidade_registros: 0,
                filtros: filtros_operacao.merge("inicio" => "2026-10-01", "fim" => "2026-10-02"))

# Falha na geração do arquivo (F12)
seed_exportacao(usuario: administrador, tipo: "operacao_global", formato: "pdf",
                solicitada_em: Time.zone.local(2026, 10, 16, 20, 15, 0),
                status: "falhou", filtros: filtros_operacao)

# Extrato do estudante concluído; a assinatura digital ainda não existe (F11)
seed_exportacao(usuario: estudante, tipo: "extrato_estudante", formato: "pdf",
                solicitada_em: Time.zone.local(2026, 10, 16, 9, 0, 0),
                emitida_em: Time.zone.local(2026, 10, 16, 9, 0, 2),
                status: "concluida", assinatura_status: "pendente",
                filtros: { "periodo" => "ultimos_30_dias", "tipo_refeicao" => "todas", "catraca" => "todas" },
                quantidade_registros: 1, total_debitos: BigDecimal("0"), total_creditos: BigDecimal("22.50"),
                arquivo_chave: "extratos/251033574-20261016-090000.pdf",
                arquivo_sha256: Digest::SHA256.hexdigest("251033574-20261016-090000"))

puts "   Exportações: #{ExportacaoRelatorio.count} " \
       "(concluídas: #{ExportacaoRelatorio.concluida.count})"
