# Be sure to restart your server when you modify this file.

# Regras de plural em português para os nomes de models/tabelas do UnB RU.
# O Rails só flexiona a última palavra de nomes compostos, então:
#   Papel              -> papeis
#   UsuarioPapel       -> usuario_papeis
#   SessaoAutenticacao -> sessao_autenticacoes
#   TarifaRefeicao     -> tarifa_refeicoes
#   OpcaoCardapio      -> opcao_cardapios
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural(/ao$/i, "oes")
  inflect.singular(/oes$/i, "ao")
  inflect.plural(/el$/i, "eis")
  inflect.singular(/eis$/i, "el")
end
