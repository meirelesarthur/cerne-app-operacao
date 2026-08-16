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
  'saldo-estoque': [
    {
      id: 'saldo-1',
      title: 'Ração Engorda',
      description: 'Armazém A · 12.400 kg',
      status: 'ativo',
      details: { Local: 'Armazém A', Saldo: '12.400 kg', Reserva: '1.000 kg', Atualização: 'Hoje, 08:42' },
    },
    {
      id: 'saldo-2',
      title: 'Sal Mineral',
      description: 'Armazém A · 3.200 kg',
      status: 'ativo',
      details: { Local: 'Armazém A', Saldo: '3.200 kg', Reserva: '240 kg', Atualização: 'Ontem, 17:18' },
    },
    {
      id: 'saldo-3',
      title: 'Vacina Aftosa',
      description: 'Farmácia · 540 doses',
      status: 'ativo',
      details: { Local: 'Farmácia', Saldo: '540 doses', Lote: 'VA-2026-08', Validade: '30/11/2026' },
    },
  ],
  processamentos: [
    {
      id: 'processo-1',
      title: 'Transferência do Lote 42',
      description: 'Pendente · aguardando sincronização',
      status: 'programado',
      details: { Tipo: 'Transferência', Lote: 'Lote 42', Responsável: 'João Oliveira', Estado: 'Aguardando sincronização' },
    },
    {
      id: 'processo-2',
      title: 'Pesagem do Lote 19',
      description: 'Concluída · hoje às 08:03',
      status: 'concluido',
      details: { Tipo: 'Pesagem', Lote: 'Lote 19', Responsável: 'Maria Souza', Estado: 'Concluída' },
    },
  ],
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
  carga: [
    {
      id: 'carga-1',
      title: 'Ração de engorda 18%',
      description: '1.000 kg · Misturador 01',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Origem: 'Armazém A', Equipamento: 'Misturador 01', Quantidade: '1.000 kg' },
    },
  ],
  descarga: [
    {
      id: 'descarga-1',
      title: 'Curral 7 · Cocho A',
      description: 'Ração de engorda · 980 kg',
      status: 'concluido',
      details: { Responsável: 'Carlos Dias', Produto: 'Ração de engorda', Destino: 'Curral 7 · Cocho A', Quantidade: '980 kg' },
    },
  ],
  'nota-cocho': [
    {
      id: 'cocho-1',
      title: 'Lote 42 · Curral 7',
      description: '2 — Adequado · 16/08/2026',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Data: '16/08/2026', Nota: '2 — Adequado', Observação: 'Consumo dentro do esperado' },
    },
  ],
  'configuracoes-misturador': [
    {
      id: 'config-mist-1',
      title: 'Configuração Fazenda São Pedro',
      description: 'kg · tolerância 2% · alertas ativados',
      status: 'ativo',
      details: { Responsável: 'Carlos Dias', Unidade: 'kg', Tolerância: '2%', Alertas: 'Ativados' },
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
  marcacao: [
    {
      id: 'marcacao-1',
      title: 'Erosão na curva de nível',
      description: 'Ponto de atenção · Talhão 02',
      status: 'ativo',
      details: { Responsável: 'Maria Souza', Área: 'Talhão 02', Tipo: 'Ponto de atenção', Referência: 'Próximo à porteira leste' },
    },
  ],
  'rebanho-inicial': [
    {
      id: 'rebanho-1',
      title: 'Vacas',
      description: '186 bovinos · Pasto Norte',
      status: 'ativo',
      details: { Responsável: 'João Oliveira', 'Data de referência': '01/08/2026', Espécie: 'Bovino', Categoria: 'Vaca', Quantidade: '186', 'Área inicial': 'Pasto Norte' },
    },
  ],
  'lote-animais': [
    {
      id: 'lote-1',
      title: 'Lote 42 · Engorda',
      description: 'Bovino · Boi',
      status: 'ativo',
      details: { Responsável: 'João Oliveira', Espécie: 'Bovino', Categoria: 'Boi', Descrição: 'Lote 42 · Engorda' },
    },
  ],
  'registrar-animal': [
    {
      id: 'animal-1',
      title: 'Novilha',
      description: 'Nelore · 318 kg',
      status: 'ativo',
      details: { Categoria: 'Novilha', Raça: 'Nelore', Nascimento: '14/09/2024', Peso: '318 kg' },
    },
  ],
  'transferencia-lote-area': [
    {
      id: 'transf-area-1',
      title: 'Lote 42 · Engorda',
      description: 'Talhão 01 · Módulo B',
      status: 'concluido',
      details: { Responsável: 'Carlos Dias', 'Local anterior': 'Pasto Norte · Módulo A', 'Nova área': 'Talhão 01', 'Novo módulo': 'Módulo B' },
    },
  ],
  'transferencia-animal': [
    {
      id: 'transf-animal-1',
      title: 'RFID 982 000123456120',
      description: 'Lote Recria 02 · Lote 42 · Engorda',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', 'Lote anterior': 'Lote Recria 02', 'Novo lote': 'Lote 42 · Engorda', Identificação: 'RFID 982 000123456120' },
    },
  ],
  perdas: [
    {
      id: 'perda-1',
      title: 'RFID 982 000123450082',
      description: 'Acidente · Lote Recria 02',
      status: 'concluido',
      details: { Responsável: 'Maria Souza', Data: '14/08/2026', Lote: 'Lote Recria 02', Motivo: 'Acidente' },
    },
  ],
  'compras-animais': [
    {
      id: 'compra-animal-1',
      title: 'Fazenda Boa Vista',
      description: '36 novilhas · 12/08/2026',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Espécie: 'Bovino', Categoria: 'Novilha', Quantidade: '36', Documento: 'NF 008421' },
    },
  ],
  sanitario: [
    {
      id: 'sanitario-1',
      title: 'Lote 42 · Engorda',
      description: 'Vacinação · 16/08/2026',
      status: 'concluido',
      details: { Responsável: 'Maria Souza', Tipo: 'Vacinação', Produto: 'Vacina clostridial', Data: '16/08/2026' },
    },
  ],
  desmama: [
    {
      id: 'desmama-1',
      title: 'Lote Bezerros 08',
      description: 'Desmama convencional · 24 matrizes',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Tipo: 'Desmama convencional', Identificações: '24 vacas paridas' },
    },
  ],
  apartacao: [
    {
      id: 'apartacao-1',
      title: 'Lote Recria 02',
      description: 'Peso · Lote Engorda 05 · 28 animais',
      status: 'concluido',
      details: { Responsável: 'Carlos Dias', Critério: 'Peso', Destino: 'Lote Engorda 05', Quantidade: '28', Data: '15/08/2026' },
    },
  ],
  pastagens: [
    {
      id: 'pastagem-1',
      title: 'Armazém de Produção A',
      description: 'Armazém de Insumos A · Carlos Dias',
      status: 'concluido',
      details: { Responsável: 'Carlos Dias', 'Armazém de insumos': 'Armazém de Insumos A', 'Armazém de produção': 'Armazém de Produção A', Insumos: '2 itens', Máquinas: '1 item' },
    },
  ],
  'estacao-monta': [
    {
      id: 'estacao-1',
      title: 'Estação 2026/2027',
      description: 'IATF · 01/10/2026 a 31/01/2027',
      status: 'programado',
      details: { Responsável: 'Maria Souza', Método: 'IATF', Início: '01/10/2026', Término: '31/01/2027' },
    },
  ],
  'lotes-reproducao': [
    {
      id: 'lote-repro-1',
      title: 'Lote Matrizes 01',
      description: 'Matrizes · Estação 2026/2027 · 120 animais',
      status: 'programado',
      details: { Responsável: 'Maria Souza', Estação: 'Estação 2026/2027', Finalidade: 'Matrizes', Quantidade: '120' },
    },
  ],
  'material-reprodutivo': [
    {
      id: 'material-1',
      title: 'Touro NE-4821',
      description: 'Touro · Nelore · 1 disponível',
      status: 'ativo',
      details: { Responsável: 'João Oliveira', Tipo: 'Touro', Raça: 'Nelore', Origem: 'Central Genética Vale', Quantidade: '1' },
    },
  ],
  'protocolos-estacao': [
    {
      id: 'protocolo-1',
      title: 'IATF Matrizes 01',
      description: 'IATF · Estação 2026/2027',
      status: 'programado',
      details: { Responsável: 'Maria Souza', Estação: 'Estação 2026/2027', Tipo: 'IATF', Etapas: '4 itens' },
    },
  ],
  'monta-natural': [
    {
      id: 'monta-1',
      title: 'Lote Matrizes 02',
      description: 'Touro NE-4821 · 35 fêmeas',
      status: 'concluido',
      details: { Responsável: 'João Oliveira', Data: '12/08/2026', Reprodutor: 'Touro NE-4821', Quantidade: '35' },
    },
  ],
  'diagnostico-gestacao': [
    {
      id: 'diagnostico-1',
      title: 'Lote Matrizes 01',
      description: 'Prenhe · 94 animais',
      status: 'concluido',
      details: { Responsável: 'Maria Souza', Data: '15/08/2026', Resultado: 'Prenhe', Quantidade: '94', Veterinário: 'Dr. Paulo Mendes' },
    },
  ],
  'minhas-os': [
    {
      id: 'os-1',
      title: 'OS #1048 · Cerca do Talhão 02',
      description: 'Em andamento · prioridade alta',
      status: 'ativo',
      details: { Responsável: 'João Oliveira', Fazenda: 'Fazenda São Pedro', Prioridade: 'Alta', Prazo: '18/08/2026' },
    },
    {
      id: 'os-2',
      title: 'OS #1039 · Inspeção do bebedouro',
      description: 'Programada · prioridade média',
      status: 'programado',
      details: { Responsável: 'João Oliveira', Fazenda: 'Fazenda São Pedro', Prioridade: 'Média', Prazo: '20/08/2026' },
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
