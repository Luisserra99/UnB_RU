class OpcaoCardapio < ApplicationRecord
  PADRAO = "padrao".freeze
  OVOLACTOVEGETARIANA = "ovolactovegetariana".freeze
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
