import { Controller } from "@hotwired/stimulus"

// Limita o número do piso ao maior piso do restaurante selecionado.
export default class extends Controller {
  static targets = ["restaurante", "piso", "aviso"]

  connect() {
    this.atualizar()
  }

  atualizar() {
    const opcao = this.restauranteTarget.selectedOptions[0]
    if (!opcao) return

    this.pisoTarget.max = opcao.dataset.maximoPiso
    this.avisoTarget.textContent = `Maior piso deste restaurante: ${opcao.dataset.maximoPiso}`
    this.limitar()
  }

  limitar() {
    if (Number(this.pisoTarget.value) > Number(this.pisoTarget.max)) {
      this.pisoTarget.value = this.pisoTarget.max
    }
  }
}
