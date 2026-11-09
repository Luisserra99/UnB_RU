import { Controller } from "@hotwired/stimulus"

// Prévia ao vivo da recarga: recalcula subtotais e total enquanto o estudante digita e
// habilita o "Confirmar" somente com total maior que zero. O servidor continua sendo
// quem decide: sem JavaScript, o botão "Calcular total" faz o mesmo cálculo.
export default class extends Controller {
  static targets = ["quantidade", "total", "confirmar", "aviso", "dicaMetodo"]

  connect() {
    this.atualizar()
  }

  atualizar() {
    let totalCentavos = 0

    this.quantidadeTargets.forEach((campo) => {
      const quantidade = this.quantidadeValida(campo)
      const precoCentavos = Number(campo.dataset.precoCentavos || 0)
      const subtotal = quantidade * precoCentavos
      totalCentavos += subtotal

      const linha = campo.dataset.linha
      this.escrever(`quantidade-${linha}`, quantidade)
      this.escrever(linha, this.moeda(subtotal))
    })

    if (this.hasTotalTarget) this.totalTarget.innerHTML = `<strong>${this.moeda(totalCentavos)}</strong>`
    if (this.hasConfirmarTarget) this.confirmarTarget.disabled = totalCentavos === 0
    if (this.hasAvisoTarget) this.avisoTarget.hidden = totalCentavos > 0
  }

  quantidadeValida(campo) {
    const valor = Math.floor(Number(campo.value))
    const maximo = Number(campo.max) || Infinity
    return Number.isFinite(valor) && valor > 0 ? Math.min(valor, maximo) : 0
  }

  escrever(id, texto) {
    const elemento = document.getElementById(id)
    if (elemento) elemento.textContent = texto
  }

  moeda(centavos) {
    return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" })
      .format(centavos / 100)
      .replace(/ /g, " ")
  }
}
