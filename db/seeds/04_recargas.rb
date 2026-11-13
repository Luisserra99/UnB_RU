# Seeds de tarifas e de uma recarga de exemplo (F02) — responsável: Luis.
# Os preços são os dos cenários BDD (café R$ 2,50, almoço e jantar R$ 4,50): valores provisórios,
# porque o material do grupo não define as tarifas oficiais. Não cria débitos (são da F06).

vigencia_inicial = Time.zone.local(2026, 1, 1)

{
  TipoRefeicao::CAFE_DA_MANHA => [ "Café da manhã", "2.50" ],
  TipoRefeicao::ALMOCO => [ "Almoço", "4.50" ],
  TipoRefeicao::JANTAR => [ "Jantar", "4.50" ]
}.each do |codigo, (nome, valor)|
  tipo = TipoRefeicao.find_or_create_by!(codigo: codigo) { |t| t.nome = nome }
  TarifaRefeicao.find_or_create_by!(tipo_refeicao: tipo, vigente_desde: vigencia_inicial) do |tarifa|
    tarifa.valor = BigDecimal(valor)
  end
end

# O estudante 251033574 começa com uma recarga PIX confirmada de R$ 22,50 (5 almoços/jantares).
# O estudante 222014133 fica sem lançamentos, para mostrar o saldo zerado.
estudante = Estudante.find_by(matricula: "251033574")
if estudante && !estudante.recargas.exists?
  solicitacao = SolicitacaoRecarga.new(estudante: estudante, quantidade_cafes: "0", quantidade_almocos: "5",
                                       metodo: "pix")
  if solicitacao.salvar
    Pagamentos::ProcessarRetorno.call(solicitacao.recarga.pagamento_atual, "Confirmada")
  else
    puts "   Recarga de exemplo não criada: #{solicitacao.errors.full_messages.to_sentence}"
  end
end

puts "   Tarifas vigentes: #{TarifaRefeicao.vigentes_em(Time.current).count} | " \
     "Recargas: #{Recarga.count} | Saldo de 251033574: R$ #{format('%.2f', estudante&.saldo || 0)}"
