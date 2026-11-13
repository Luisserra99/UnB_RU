import { Controller } from "@hotwired/stimulus"

// Prévia ao vivo da recarga: recalcula subtotais e total enquanto o estudante digita e
// habilita o "Confirmar" somente com total maior que zero e todas as quantidades válidas. O servidor continua sendo
// quem decide: sem JavaScript, o botão "Calcular total" faz o mesmo cálculo.
export default class extends Controller {
  static targets = ["quantidade", "total", "confirmar", "aviso", "dicaMetodo"]

  connect() {
    this.atualizar()
  }

  atualizar(evento) {
    let totalCentavos = 0
    let algumInvalido = false

    this.quantidadeTargets.forEach((campo) => {
      const quantidade = this.quantidadeValida(campo)
      const valido = quantidade !== null
      if (!valido) algumInvalido = true
      this.marcarValidade(campo, valido, evento?.target === campo)

      const quantidadeExibida = valido ? quantidade : 0
      const precoCentavos = Number(campo.dataset.precoCentavos || 0)
      const subtotal = quantidadeExibida * precoCentavos
      totalCentavos += subtotal

      const linha = campo.dataset.linha
      this.escrever(`quantidade-${linha}`, valido ? quantidade : "—")
      this.escrever(linha, valido ? this.moeda(subtotal) : "—")
    })

    if (this.hasTotalTarget) {
      this.totalTarget.innerHTML = algumInvalido ? "<strong>—</strong>" : `<strong>${this.moeda(totalCentavos)}</strong>`
    }
    if (this.hasConfirmarTarget) this.confirmarTarget.disabled = algumInvalido || totalCentavos === 0
    if (this.hasAvisoTarget) this.avisoTarget.hidden = algumInvalido || totalCentavos > 0
  }

  // Inteiro entre 0 e o máximo do campo (vazio conta como 0); fora disso devolve null.
  // Não corrige o valor: a tabela não pode mostrar um número diferente do digitado.
  quantidadeValida(campo) {
    const texto = campo.value.trim()
    if (texto === "") return campo.validity.badInput ? null : 0

    const valor = Number(texto)
    const maximo = Number(campo.max) || Infinity
    return Number.isInteger(valor) && valor >= 0 && valor <= maximo ? valor : null
  }

  // `digitado`: o estudante acabou de editar este campo, então a mensagem do servidor
  // (se houver) ficou desatualizada e dá lugar à da prévia.
  marcarValidade(campo, valido, digitado) {
    const bloco = campo.closest(".campo")
    const errosServidor = bloco ? Array.from(bloco.querySelectorAll("[data-erro-servidor]")) : []
    if (digitado) errosServidor.forEach((elemento) => { elemento.hidden = true })
    const servidorVisivel = errosServidor.some((elemento) => !elemento.hidden)

    campo.closest(".campo-entrada")?.classList.toggle("invalido", !valido || servidorVisivel)
    campo.setAttribute("aria-invalid", String(!valido || servidorVisivel))

    const erro = bloco?.querySelector("[data-erro-previa]")
    if (erro) erro.hidden = valido || servidorVisivel
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
