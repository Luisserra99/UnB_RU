import { Controller } from "@hotwired/stimulus"

// Alterna a senha entre visível e oculta (ícone de olho no campo).
export default class extends Controller {
  static targets = ["campo", "botao"]

  alternar() {
    const visivel = this.campoTarget.type === "text"
    this.campoTarget.type = visivel ? "password" : "text"
    this.botaoTarget.setAttribute("aria-pressed", String(!visivel))
    this.botaoTarget.setAttribute("aria-label", visivel ? "Mostrar senha" : "Ocultar senha")
  }
}
