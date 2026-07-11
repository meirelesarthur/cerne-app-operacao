/**
 * Formatação monetária BRL para os fluxos de pagamento do Bank.
 * Entrada é o valor em reais (float); saída no padrão "R$ 1.234,56".
 */
const BRL = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' })

export function formatBRL(reais: number): string {
  if (!Number.isFinite(reais)) return BRL.format(0)
  return BRL.format(reais)
}

/** Converte o texto digitado (aceita vírgula ou ponto) em número de reais. */
export function parseReais(input: string): number {
  const normalized = input.replace(/\./g, '').replace(',', '.').replace(/[^0-9.]/g, '')
  const n = Number(normalized)
  return Number.isFinite(n) ? n : 0
}
