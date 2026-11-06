# Carrega os seeds de cada módulo em ordem (db/seeds/NN_nome.rb).
# Cada integrante mantém o próprio arquivo para evitar conflitos de merge.
# Todos os seeds devem ser idempotentes (rodar `bin/rails db:seed` duas vezes não duplica dados).
Dir[Rails.root.join("db/seeds/*.rb")].sort.each do |arquivo|
  puts "== Seed: #{File.basename(arquivo)}"
  load arquivo
end
