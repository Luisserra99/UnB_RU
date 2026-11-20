import { Controller } from "@hotwired/stimulus"

// Máscaras do formulário de pagamento com cartão (F02). Só ajudam na digitação: quem decide se os
// dados são válidos continua sendo o DadosCartao, no servidor, inclusive com o JavaScript desligado.
// - Número: só dígitos, no máximo 16, agrupados de 4 em 4 ("4111 1111 1111 1111").
// - Validade: só dígitos, no máximo 4, com a barra inserida sozinha ("0331" vira "03/31").
export default class extends Controller {
  static targets = ["numero", "validade"]

  connect() {
    if (this.hasNumeroTarget) this.aplicar(this.numeroTarget, formatarNumero)
    if (this.hasValidadeTarget) this.aplicar(this.validadeTarget, formatarValidade)
  }

  numero() {
    this.aplicar(this.numeroTarget, formatarNumero)
  }

  validade() {
    this.aplicar(this.validadeTarget, formatarValidade)
  }

  // Troca o valor do campo pelo formatado, mantendo o cursor depois do mesmo dígito em que estava,
  // para que editar no meio do número não jogue o cursor para o fim.
  aplicar(campo, formatar) {
    const formatado = formatar(campo.value)
    if (formatado === campo.value) return

    const emFoco = document.activeElement === campo
    const digitosAntesDoCursor = emFoco ? contarDigitos(campo.value.slice(0, campo.selectionStart)) : 0
    campo.value = formatado
    if (emFoco) {
      const posicao = posicaoAposDigitos(formatado, digitosAntesDoCursor)
      campo.setSelectionRange(posicao, posicao)
    }
  }
}

const MAXIMO_DIGITOS_NUMERO = 16
const MAXIMO_DIGITOS_VALIDADE = 4

function somenteDigitos(texto) {
  return String(texto ?? "").replace(/\D/g, "")
}

function contarDigitos(texto) {
  return somenteDigitos(texto).length
}

// Posição logo depois do n-ésimo dígito do texto (0 = início).
function posicaoAposDigitos(texto, quantidade) {
  if (quantidade === 0) return 0

  let vistos = 0
  for (let indice = 0; indice < texto.length; indice++) {
    if (/\d/.test(texto[indice]) && ++vistos === quantidade) return indice + 1
  }
  return texto.length
}

export function formatarNumero(texto) {
  return somenteDigitos(texto).slice(0, MAXIMO_DIGITOS_NUMERO).replace(/(\d{4})(?=\d)/g, "$1 ")
}

// A barra só aparece quando já há dígito do ano, para o Backspace conseguir apagá-la. A exceção é
// quem digita a barra depois do mês ("03/"): ela é mantida.
export function formatarValidade(texto) {
  const digitos = somenteDigitos(texto).slice(0, MAXIMO_DIGITOS_VALIDADE)
  if (digitos.length > 2) return `${digitos.slice(0, 2)}/${digitos.slice(2)}`
  if (digitos.length === 2 && /\/\s*$/.test(String(texto))) return `${digitos}/`
  return digitos
}
