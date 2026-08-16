/** Tipos do domínio do módulo Fazendas (ex-Cerne). Dados mockados no protótipo. */

export interface Farm {
  id: string
  name: string
  city: string
  uf: string
}

export type ActivityStatus = 'andamento' | 'concluida' | 'autorizada' | 'atrasada'

export interface Activity {
  id: string
  title: string
  subtitle: string
  status: ActivityStatus
  time: string
  kind: 'pesagem' | 'evento' | 'nfe' | 'venda' | 'insumo' | 'arracoamento'
}

/** Item da fila de sincronização offline (spec §3.2/§6.9). */
export interface SyncItem {
  id: string
  label: string
  detail: string
  kind: Activity['kind']
}
