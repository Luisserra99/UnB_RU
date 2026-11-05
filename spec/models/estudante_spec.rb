require "rails_helper"

RSpec.describe Estudante, type: :model do
  it "é válido com matrícula de 9 números" do
    expect(build(:estudante, matricula: "222014133")).to be_valid
  end

  it "rejeita matrícula fora do formato de 9 números" do
    %w[12345678 1234567890 abc123xyz 12345678a].each do |matricula|
      expect(build(:estudante, matricula: matricula)).not_to be_valid, "esperava rejeitar #{matricula}"
    end
  end

  it "não permite matrícula repetida" do
    create(:estudante, matricula: "222014133")
    expect(build(:estudante, matricula: "222014133")).not_to be_valid
  end

  it "não permite dois estudantes para o mesmo usuário" do
    estudante = create(:estudante)
    expect(build(:estudante, usuario: estudante.usuario)).not_to be_valid
  end

  it "tem vínculo ativo por padrão" do
    expect(Estudante.new.vinculo_ativo).to be(true)
  end
end
