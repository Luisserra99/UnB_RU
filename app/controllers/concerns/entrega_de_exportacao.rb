# F09, F11 e F12 — Resposta comum das ações que exportam relatórios (responsável: Tarsila).
# Entrega o arquivo quando a exportação deu certo e, caso contrário, volta para a tela do
# relatório com o motivo, sem baixar arquivo.
module EntregaDeExportacao
  extend ActiveSupport::Concern

  private

  # Responde à requisição com o arquivo exportado ou com o motivo de ele não ter sido gerado.
  #
  # Argumentos:: +resultado+ (Resultado de um serviço de exportação): responde a +sucesso?+,
  #              +conteudo+, +nome_arquivo+ e +mensagem+;
  #              +tipo_mime+ (String): tipo do arquivo entregue;
  #              +voltar_para+ (String): caminho da tela do relatório, com os filtros.
  # Retorno:: nenhum relevante.
  # Efeitos colaterais:: com sucesso, envia o arquivo como anexo (+send_data+); sem sucesso,
  #                      redireciona para +voltar_para+ com +flash[:alert]+ igual à mensagem.
  def entregar_exportacao(resultado, tipo_mime:, voltar_para:)
    if resultado.sucesso?
      send_data resultado.conteudo, filename: resultado.nome_arquivo, type: tipo_mime, disposition: "attachment"
    else
      redirect_to voltar_para, alert: resultado.mensagem
    end
  end
end
