import type { SearchSelectOption } from '@/components/ui/SearchSelect'
import type { FormSelectOption } from '@/components/ui/FormSelect'

/** Opções mockadas para os formulários operacionais (spec §5). */

export const LOTES_OPCOES: SearchSelectOption[] = [
  { value: 'l42', label: 'Lote 42', detail: '128 cabeças · Curral 02' },
  { value: 'l19', label: 'Lote 19', detail: '96 cabeças · Curral 05' },
  { value: 'l07', label: 'Lote 07', detail: '150 cabeças · Piquete 3' },
  { value: 'l33', label: 'Lote 33', detail: '64 cabeças · Curral 01' },
  { value: 'l51', label: 'Lote 51', detail: '110 cabeças · Piquete 1' },
  { value: 'l88', label: 'Lote 88', detail: '82 cabeças · Curral 04' },
]

export const DIETAS: FormSelectOption[] = [
  { value: 'd1', label: 'Dieta Engorda' },
  { value: 'd2', label: 'Dieta Recria' },
  { value: 'd3', label: 'Dieta Terminação' },
  { value: 'd4', label: 'Dieta Adaptação' },
]

export const DEPOSITOS: FormSelectOption[] = [
  { value: 'dep1', label: 'Armazém A' },
  { value: 'dep2', label: 'Armazém B' },
  { value: 'dep3', label: 'Silo Central' },
]

export const TALHOES: FormSelectOption[] = [
  { value: 't1', label: 'Talhão 1 — Sede' },
  { value: 't2', label: 'Talhão 2 — Baixada' },
  { value: 't3', label: 'Talhão 3 — Serra' },
  { value: 't4', label: 'Talhão 4 — Rio' },
]

export const CICLOS: FormSelectOption[] = [
  { value: 'ci1', label: 'Safra 24/25' },
  { value: 'ci2', label: 'Safrinha 25' },
]

export const INSUMOS: FormSelectOption[] = [
  { value: 'in1', label: 'Herbicida Glifosato' },
  { value: 'in2', label: 'Fertilizante NPK' },
  { value: 'in3', label: 'Inseticida' },
  { value: 'in4', label: 'Calcário' },
]

export const CAUSAS_MORTE: FormSelectOption[] = [
  { value: 'ca1', label: 'Doença' },
  { value: 'ca2', label: 'Acidente' },
  { value: 'ca3', label: 'Predador' },
  { value: 'ca4', label: 'Causa desconhecida' },
]

export const COND_PAGAMENTO: FormSelectOption[] = [
  { value: 'p1', label: 'À vista' },
  { value: 'p2', label: '30 dias' },
  { value: 'p3', label: '30/60 dias' },
  { value: 'p4', label: 'A prazo (negociado)' },
]

/** Itens de uma NF-e mockada para conferência (spec §5.4). */
export const NFE_ITENS = [
  { id: 'i1', descricao: 'Ração Engorda 40kg', qtd: '120 sc', valor: 'R$ 18.000' },
  { id: 'i2', descricao: 'Sal Mineral 25kg', qtd: '80 sc', valor: 'R$ 6.400' },
  { id: 'i3', descricao: 'Vacina Aftosa', qtd: '540 doses', valor: 'R$ 4.860' },
  { id: 'i4', descricao: 'Vermífugo', qtd: '30 fr', valor: 'R$ 2.100' },
]
export const NFE_CABECALHO = { fornecedor: 'Agropecuária Vale Ltda', numero: '4471', total: 'R$ 31.360' }
