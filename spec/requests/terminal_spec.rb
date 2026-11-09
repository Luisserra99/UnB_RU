require "rails_helper"

RSpec.describe "Terminal de validação (F06)", type: :request do
  let(:funcionario) { create(:funcionario) }
  let(:catraca) { create(:catraca) }

  def configurar
    login_controle(funcionario)
    post controle_ponto_acesso_path, params: { restaurante_id: catraca.restaurante.id, catraca_id: catraca.id }
  end

  it "exige autenticação e ponto confirmado no terminal e nos comandos" do
    get controle_terminal_path
    expect(response).to redirect_to(controle_login_path)
    login_controle(funcionario)
    post controle_leitura_terminal_path, params: { identificacao: "251033574", referencia_evento: SecureRandom.uuid }
    expect(response).to redirect_to(controle_root_path)
    expect(RegistroAcesso.count).to eq(0)
  end

  it "recusa comandos para registros de outra sessão" do
    configurar
    registro = create(:registro_acesso)
    post controle_passagem_terminal_path(registro)
    expect(response).to have_http_status(:not_found)
  end

  it "bloqueia comandos durante reconfiguração e cancela liberações pendentes" do
    configurar
    registro = create(:registro_acesso, configuracao_ponto_acesso: ConfiguracaoPontoAcesso.last,
      estado: :liberado, passagem_em: nil, bloqueado_em: nil, mensagem: "Catraca liberada")
    post reconfigurar_controle_ponto_acesso_path
    expect(registro.reload).to be_cancelado
    post controle_passagem_terminal_path(registro)
    expect(response).to redirect_to(controle_root_path)
    expect(MovimentacaoSaldo.debitos).to be_empty
  end

  it "o terminal mostra formulário e recusa identificação desconhecida sem erro" do
    configurar
    get controle_terminal_path
    expect(response.body).to include("Matrícula do estudante")
    post controle_leitura_terminal_path, params: { identificacao: "", referencia_evento: SecureRandom.uuid }
    follow_redirect!
    expect(response.body).to include("Identificação desconhecida")
  end
end

RSpec.describe "Integração recarga, catraca e extrato", type: :request do
  it "debita na passagem via HTTP e mostra a refeição real no extrato do estudante" do
    travel_to Time.zone.local(2026, 11, 9, 12) do
      aluno = create(:usuario_estudante, saldo: 10)
      catraca = create(:catraca)
      servico = create(:servico_refeicao, restaurante: catraca.restaurante, dia_semana: Time.current.wday)
      create(:tarifa_refeicao, tipo_refeicao: servico.tipo_refeicao, valor: 2.5)
      login_controle(create(:funcionario))
      post controle_ponto_acesso_path, params: { restaurante_id: catraca.restaurante.id, catraca_id: catraca.id }
      post controle_leitura_terminal_path, params: { identificacao: aluno.estudante.matricula, referencia_evento: SecureRandom.uuid }
      follow_redirect!
      expect(response.body).to include('data-controller="terminal"')
      registro = RegistroAcesso.last
      travel 2.seconds
      post controle_passagem_terminal_path(registro)
      follow_redirect!
      expect(response.body).to include("Boa refeição")
      expect(aluno.estudante.saldo).to eq(7.5)
      login_estudante(aluno)
      get extrato_path
      expect(response.body).to include("R$ 7,50", "Almoço")
      expect(catraca).not_to be_em_operacao
    end
  end
end
