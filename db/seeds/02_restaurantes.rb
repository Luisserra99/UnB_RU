# Seeds de restaurantes, catracas e serviços de refeição (F08/F10) — responsável: Leonardo.
# Os horários são valores iniciais: o material do grupo ainda não define os horários oficiais.

unidade = UnidadeGestora.find_or_create_by!(nome: UnidadeGestora::NOME_PADRAO)

tipos = {
  TipoRefeicao::CAFE_DA_MANHA => "Café da manhã",
  TipoRefeicao::ALMOCO => "Almoço",
  TipoRefeicao::JANTAR => "Jantar"
}
tipos.each do |codigo, nome|
  TipoRefeicao.find_or_create_by!(codigo: codigo) { |tipo| tipo.nome = nome }
end

restaurante = Restaurante.find_by(nome: "RU Darcy Ribeiro") ||
              Restaurante.criar_com_pisos!(unidade_gestora: unidade, nome: "RU Darcy Ribeiro",
                                           quantidade_pisos: 3, capacidade_refeicoes_hora: 1200)

[ "CAT-01", "CAT-02" ].each do |identificacao|
  next if restaurante.catracas.exists?(identificacao: identificacao)

  restaurante.pisos.find_by!(numero: 1).catracas.create!(identificacao: identificacao)
end

horarios = {
  TipoRefeicao::CAFE_DA_MANHA => %w[07:00 09:00],
  TipoRefeicao::ALMOCO => %w[11:00 14:30],
  TipoRefeicao::JANTAR => %w[17:00 19:30]
}
horarios.each do |codigo, (inicio, fim)|
  tipo = TipoRefeicao.find_by!(codigo: codigo)
  ServicoRefeicao::DIAS_SEMANA.each do |dia_semana|
    ServicoRefeicao.find_or_create_by!(restaurante: restaurante, tipo_refeicao: tipo, dia_semana: dia_semana) do |servico|
      servico.inicio = inicio
      servico.fim = fim
    end
  end
end

puts "   Unidades: #{UnidadeGestora.count} | Restaurantes: #{Restaurante.count} | " \
     "Catracas: #{Catraca.count} | Serviços: #{ServicoRefeicao.count}"
