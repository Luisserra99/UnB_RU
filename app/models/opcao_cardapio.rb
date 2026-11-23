# Opção de um cardápio para uma dieta (F10), com os itens na ordem de apresentação.
# Cada cardápio tem no máximo uma opção por dieta.
class OpcaoCardapio < ApplicationRecord
  # Código da dieta padrão.
  PADRAO = "padrao".freeze
  # Código da dieta ovolactovegetariana.
  OVOLACTOVEGETARIANA = "ovolactovegetariana".freeze
  # Código da dieta vegetariana estrita.
  VEGETARIANA_ESTRITA = "vegetariana_estrita".freeze

  # Código da dieta => rótulo exibido, na ordem de apresentação.
  DIETAS = {
    PADRAO => "Padrão",
    OVOLACTOVEGETARIANA => "Ovolactovegetariano",
    VEGETARIANA_ESTRITA => "Vegetariano estrito"
  }.freeze

  belongs_to :cardapio
  has_many :itens, -> { order(:ordem) }, class_name: "ItemCardapio", dependent: :destroy

  validates :dieta, inclusion: { in: DIETAS.keys }, uniqueness: { scope: :cardapio_id }
end
