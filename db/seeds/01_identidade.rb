# Seeds de identidade e acesso (F01/F04/F07) — responsável: Weldo.
# Senhas abaixo são SOMENTE para desenvolvimento/teste.

papeis = {
  Papel::ESTUDANTE => "Estudante com conta no RU",
  Papel::FUNCIONARIO => "Funcionário do restaurante (aplicação de controle)",
  Papel::ADMINISTRADOR => "Administrador geral (gestão e relatórios)"
}
papeis.each do |codigo, descricao|
  Papel.find_or_create_by!(codigo: codigo) { |papel| papel.descricao = descricao }
end

def seed_usuario(identificacao:, nome:, email:, senha:, papel:, ativo: true, matricula: nil)
  usuario = Usuario.find_or_initialize_by(identificacao: identificacao)
  if usuario.new_record?
    usuario.assign_attributes(nome: nome, email: email, password: senha, ativo: ativo)
    usuario.save!
  end
  usuario.atribuir_papel!(papel)
  usuario.create_estudante!(matricula: matricula) if matricula && usuario.estudante.nil?
  usuario
end

# Administrador geral
seed_usuario(identificacao: "admin", nome: "Administrador Geral", email: "admin@unb.br",
             senha: "Admin@1234", papel: Papel::ADMINISTRADOR)

# Funcionários (F04 e F07)
seed_usuario(identificacao: "funcionario01", nome: "Funcionário 01", email: "funcionario01@unb.br",
             senha: "senhaCorreta", papel: Papel::FUNCIONARIO)
seed_usuario(identificacao: "funcionario02", nome: "Funcionário Inativo", email: "funcionario02@unb.br",
             senha: "senhaCorreta", papel: Papel::FUNCIONARIO, ativo: false)
seed_usuario(identificacao: "100200300", nome: "Funcionário CAT-01", email: "100200300@unb.br",
             senha: "Senha@123", papel: Papel::FUNCIONARIO)
seed_usuario(identificacao: "100200301", nome: "Funcionário CAT-02", email: "100200301@unb.br",
             senha: "Senha@456", papel: Papel::FUNCIONARIO)

# Estudantes (identificação = matrícula)
seed_usuario(identificacao: "251033574", nome: "Estudante Teste", email: "251033574@aluno.unb.br",
             senha: "Estudante@123", papel: Papel::ESTUDANTE, matricula: "251033574")
seed_usuario(identificacao: "222014133", nome: "Weldo Gonçalves da Silva Junior", email: "222014133@aluno.unb.br",
             senha: "Estudante@123", papel: Papel::ESTUDANTE, matricula: "222014133")

puts "   Papéis: #{Papel.count} | Usuários: #{Usuario.count} | Estudantes: #{Estudante.count}"
