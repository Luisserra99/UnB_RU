namespace :cardapio do
  desc "Importa o cardapio.json para a semana da data informada (AAAA-MM-DD; padrão: semana atual)"
  task :importar, [ :semana ] => :environment do |_tarefa, argumentos|
    semana = argumentos[:semana].present? ? Date.iso8601(argumentos[:semana]) : Date.current
    resultado = Cardapios::ImportadorJson.new(semana: semana).importar
    puts "Cardápios importados: #{resultado.cardapios} | Serviços ausentes: #{resultado.servicos_ausentes}"
  end
end
