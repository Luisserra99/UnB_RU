import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["expiracao"]
  static values = { limite: String }

  connect() {
    const espera = Math.max(0, Date.parse(this.limiteValue) - Date.now() + 100)
    this.temporizador = setTimeout(() => this.expiracaoTarget.requestSubmit(), espera)
  }

  disconnect() {
    clearTimeout(this.temporizador)
  }
}
