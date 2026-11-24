# Ligação entre Usuario e Papel (chave primária composta). Um usuário não repete o mesmo papel.
class UsuarioPapel < ApplicationRecord
  belongs_to :usuario
  belongs_to :papel

  validates :papel_id, uniqueness: { scope: :usuario_id }
end
