import { create } from 'zustand'

/** Registro genérico usado pelas telas da esteira frontend. */
export interface PrototypeRecord {
  id: string
  title: string
  description: string
  status: 'ativo' | 'concluido' | 'programado'
  details: Record<string, string>
}

type RecordsByFeature = Record<string, PrototypeRecord[]>

const INITIAL_RECORDS: RecordsByFeature = {
  'cadastrar-area': [
    {
      id: 'area-1',
      title: 'Talhão 01',
      description: 'Agricultura · 42 ha',
      status: 'ativo',
      details: { Tipo: 'Agricultura', 'Área total': '42 ha', Localização: 'Setor Norte', Cultura: 'Soja' },
    },
    {
      id: 'area-2',
      title: 'Pasto Norte',
      description: 'Pecuária · 68 ha',
      status: 'ativo',
      details: { Tipo: 'Pecuária', 'Área total': '68 ha', Localização: 'Setor Norte', Cultura: 'Braquiária' },
    },
  ],
  formulacoes: [
    {
      id: 'form-1',
      title: 'Ração de engorda 18%',
      description: '1.000 kg · Ativa',
      status: 'ativo',
      details: { Responsável: 'João Oliveira', Produto: 'Ração de engorda', Referência: '1.000 kg', Tipo: 'Formulação' },
    },
    {
      id: 'form-2',
      title: 'Suplemento mineral',
      description: '500 kg · Ativa',
      status: 'ativo',
      details: { Responsável: 'Maria Souza', Produto: 'Suplemento mineral', Referência: '500 kg', Tipo: 'Formulação' },
    },
  ],
  batidas: [
    {
      id: 'batida-1',
      title: 'Batida #0042',
      description: 'Ração de engorda · 1.000 kg',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Produto: 'Ração de engorda', Destino: 'Armazém A', Quantidade: '1.000 kg' },
    },
  ],
  apontamento: [
    {
      id: 'apont-1',
      title: 'Aplicação no Talhão 01',
      description: 'Pulverização · 32 ha utilizados',
      status: 'concluido',
      details: { Responsável: 'Maria Souza', Área: 'Talhão 01', Operação: 'Pulverização', Atividade: 'Aplicação de defensivo' },
    },
    {
      id: 'apont-2',
      title: 'Preparo do Talhão 02',
      description: 'Gradagem · 18 ha utilizados',
      status: 'ativo',
      details: { Responsável: 'Carlos Dias', Área: 'Talhão 02', Operação: 'Preparo de solo', Atividade: 'Gradagem' },
    },
  ],
  abastecimentos: [
    {
      id: 'abast-1',
      title: 'Trator John Deere 6110',
      description: '180 L · Diesel S10',
      status: 'concluido',
      details: { Responsável: 'Carlos Dias', Data: '16/08/2026', Combustível: 'Diesel S10', Hodômetro: '1.842 h' },
    },
    {
      id: 'abast-2',
      title: 'Caminhão Boiadeiro',
      description: '220 L · Diesel S10',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Data: '15/08/2026', Combustível: 'Diesel S10', Hodômetro: '84.210 km' },
    },
  ],
  'manutencao-frota': [
    {
      id: 'manut-1',
      title: 'Revisão do Trator 6110',
      description: 'Programada · 20/08/2026',
      status: 'programado',
      details: { Tipo: 'Preventiva', Equipamento: 'Trator John Deere 6110', Previsão: '20/08/2026', Oficina: 'MecAgro Serviços' },
    },
    {
      id: 'manut-2',
      title: 'Sistema hidráulico',
      description: 'Em andamento · Colheitadeira CR7',
      status: 'ativo',
      details: { Tipo: 'Corretiva', Equipamento: 'Colheitadeira CR7', Abertura: '14/08/2026', Oficina: 'Oficina interna' },
    },
  ],
}

interface PrototypeRecordsState {
  recordsByFeature: RecordsByFeature
  nextId: number
  addRecord: (featureId: string, record: Omit<PrototypeRecord, 'id'>) => PrototypeRecord
}

export const usePrototypeRecordsStore = create<PrototypeRecordsState>((set, get) => ({
  recordsByFeature: INITIAL_RECORDS,
  nextId: 100,
  addRecord: (featureId, record) => {
    const created = { ...record, id: `${featureId}-${get().nextId}` }
    set((state) => ({
      nextId: state.nextId + 1,
      recordsByFeature: {
        ...state.recordsByFeature,
        [featureId]: [created, ...(state.recordsByFeature[featureId] ?? [])],
      },
    }))
    return created
  },
}))
