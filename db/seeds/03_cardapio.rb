# Cardápio da semana atual a partir do cardapio.json (F10) — responsável: Leonardo.
# Para outra semana: bin/rails "cardapio:importar[AAAA-MM-DD]"

resultado = Cardapios::ImportadorJson.new(semana: Date.current).importar
puts "   Cardápios importados: #{resultado.cardapios} | Serviços ausentes: #{resultado.servicos_ausentes}"
