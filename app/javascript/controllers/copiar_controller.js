import { Controller } from "@hotwired/stimulus"

// Copia o texto de um campo (ex.: código PIX Copia e Cola) para a área de transferência e
// confirma no próprio botão. Sem a Clipboard API (página fora de HTTPS), seleciona o texto
// para o estudante copiar com Ctrl+C.
export default class extends Controller {
  static targets = ["origem", "botao", "status"]

  async copiar() {
    const texto = this.origemTarget.value
    try {
      await navigator.clipboard.writeText(texto)
      this.avisar("Código copiado")
    } catch {
      this.origemTarget.focus()
      this.origemTarget.select()
      this.avisar("Código selecionado: use Ctrl+C para copiar")
    }
  }

  avisar(mensagem) {
    if (this.hasStatusTarget) this.statusTarget.textContent = mensagem
    clearTimeout(this.temporizador)
    this.temporizador = setTimeout(() => {
      if (this.hasStatusTarget) this.statusTarget.textContent = ""
    }, 4000)
  }

  disconnect() {
    clearTimeout(this.temporizador)
  }
}
