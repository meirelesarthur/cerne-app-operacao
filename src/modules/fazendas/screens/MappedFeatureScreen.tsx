import { useEffect, useMemo, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Bluetooth, ClipboardCheck, Info, Plus, ShieldCheck } from 'lucide-react'
import { AddableGroupList } from '@/components/ui/AddableGroupList'
import { AuditExportPanel } from '@/components/ui/AuditExportPanel'
import { Banner } from '@/components/ui/Banner'
import { BottomSheet } from '@/components/ui/BottomSheet'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Chip } from '@/components/ui/Chip'
import { EmptyState } from '@/components/ui/EmptyState'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { Heading, SectionTitle } from '@/components/ui/Heading'
import { HardwareSimulator } from '@/components/ui/HardwareSimulator'
import { MenuItem } from '@/components/ui/MenuItem'
import { SuccessPanel } from '@/components/ui/SuccessPanel'
import { Tag } from '@/components/ui/Tag'
import { Textarea } from '@/components/ui/Textarea'
import { TextInput } from '@/components/ui/TextInput'
import { SubPageHeader } from '@/shell/components/SubPageHeader'
import { ContextBadge } from '../components/ContextBadge'
import {
  ADMIN_FEATURES,
  FEATURE_BY_ID,
  OPERATIONAL_FEATURES,
  type FeatureDefinition,
  type FeatureField,
} from '../functionalCatalog'
import {
  usePrototypeRecordsStore,
  type PrototypeRecord,
} from '../state/prototypeRecordsStore'

type WorkspaceRole = 'administrativo' | 'operacional'
type ScreenMode = 'list' | 'form' | 'success'

const ACTIVE_RECORD_FEATURES = new Set([
  'cadastrar-area',
  'formulacoes',
  'rebanho-inicial',
  'lote-animais',
  'registrar-animal',
  'material-reprodutivo',
  'configuracoes-misturador',
  'marcacao',
])
const PROGRAMMED_RECORD_FEATURES = new Set(['manutencao-frota', 'estacao-monta', 'lotes-reproducao', 'protocolos-estacao'])

function workspaceRoute(role: WorkspaceRole) {
  return `/fazendas/${role === 'administrativo' ? 'administracao' : 'operacional'}`
}

const READ_ONLY_SAMPLES: Record<string, { label: string; description: string }[]> = {
  'saldo-estoque': [
    { label: 'Ração Engorda', description: 'Armazém A · 12.400 kg' },
    { label: 'Sal Mineral', description: 'Armazém A · 3.200 kg' },
    { label: 'Vacina Aftosa', description: 'Farmácia · 540 doses' },
  ],
  processamentos: [
    { label: 'Transferência do Lote 42', description: 'Pendente · aguardando sincronização' },
    { label: 'Pesagem do Lote 19', description: 'Concluído · hoje às 08:03' },
  ],
}

const STATUS_LABEL: Record<PrototypeRecord['status'], string> = {
  ativo: 'Ativo',
  concluido: 'Concluído',
  programado: 'Programado',
}

const AUDIT_EXPORT_ROWS: Record<'estoque' | 'pecuaria', Record<string, string>[]> = {
  estoque: [
    { data: '2026-08-16 08:42', usuario: 'João Oliveira', acao: 'Batida registrada', entidade: 'Ração engorda', quantidade: '1.000 kg' },
    { data: '2026-08-15 17:18', usuario: 'Maria Souza', acao: 'Estoque ajustado', entidade: 'Sal mineral', quantidade: '120 kg' },
    { data: '2026-08-14 14:05', usuario: 'Carlos Dias', acao: 'Entrada confirmada', entidade: 'Milho moído', quantidade: '4.500 kg' },
  ],
  pecuaria: [
    { data: '2026-08-16 09:15', usuario: 'Maria Souza', acao: 'Diagnóstico registrado', entidade: 'Lote Matrizes 01', resultado: '94 prenhes' },
    { data: '2026-08-15 16:20', usuario: 'João Oliveira', acao: 'Transferência concluída', entidade: 'RFID 982000123456120', resultado: 'Lote 42' },
    { data: '2026-08-14 11:30', usuario: 'Carlos Dias', acao: 'Pesagem registrada', entidade: 'Lote Recria 02', resultado: '318 kg médio' },
  ],
}

function FieldControl({
  field,
  value,
  onChange,
}: {
  field: FeatureField
  value: string
  onChange: (value: string) => void
}) {
  if (field.type === 'select') {
    return (
      <FormSelect
        id={`feature-${field.id}`}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder="Selecione"
        options={(field.options ?? []).map((option) => ({ value: option, label: option }))}
      />
    )
  }

  if (field.type === 'textarea') {
    return (
      <Textarea
        id={`feature-${field.id}`}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder={field.placeholder}
      />
    )
  }

  return (
    <TextInput
      id={`feature-${field.id}`}
      type={field.type === 'number' || field.type === 'date' ? field.type : 'text'}
      inputMode={field.type === 'number' ? 'decimal' : undefined}
      value={value}
      onChange={(event) => onChange(event.target.value)}
      placeholder={field.placeholder}
    />
  )
}

function fieldError(feature: FeatureDefinition, field: FeatureField, values: Record<string, string>) {
  const value = values[field.id]?.trim() ?? ''
  if (field.required && !value) return 'Campo obrigatório.'
  if (field.type === 'number' && value && Number(value) <= 0) return 'Informe um valor maior que zero.'
  if (feature.id === 'estacao-monta' && field.id === 'fim' && value && values.inicio && value < values.inicio) {
    return 'A data final deve ser posterior à data inicial.'
  }
  return undefined
}

function FeatureForm({
  feature,
  onCancel,
  onComplete,
}: {
  feature: FeatureDefinition
  onCancel?: () => void
  onComplete: (values: Record<string, string>, groupCounts: Record<string, number>) => void
}) {
  const [values, setValues] = useState<Record<string, string>>({})
  const [groupCounts, setGroupCounts] = useState<Record<string, number>>({})
  const [attempted, setAttempted] = useState(false)
  const simulationTarget = feature.simulationTargetField ?? '_hardware'
  const simulationValue = values[simulationTarget] ?? ''
  const valid = (feature.fields ?? []).every((field) => !fieldError(feature, field, values))
    && (!feature.simulation || Boolean(simulationValue.trim()))

  return (
    <div className="flex flex-col gap-5">
      {feature.simulation && (
        <HardwareSimulator
          kind={feature.simulation}
          value={simulationValue}
          error={attempted && !feature.simulationTargetField && !simulationValue ? 'Conclua a simulação antes de continuar.' : undefined}
          onCapture={(value) => setValues((current) => ({ ...current, [simulationTarget]: value }))}
        />
      )}

      {feature.fields?.length ? (
        <Card className="flex flex-col gap-4">
          <SectionTitle>Dados do registro</SectionTitle>
          {feature.fields.map((field) => (
            <FormField
              key={field.id}
              label={field.label}
              htmlFor={`feature-${field.id}`}
              required={field.required}
              error={attempted || values[field.id] ? fieldError(feature, field, values) : undefined}
            >
              <FieldControl
                field={field}
                value={values[field.id] ?? ''}
                onChange={(value) => setValues((current) => ({ ...current, [field.id]: value }))}
              />
            </FormField>
          ))}
        </Card>
      ) : null}

      {feature.sections?.length ? (
        <Card>
          <SectionTitle className="mb-3">Itens vinculados</SectionTitle>
          <AddableGroupList
            groups={feature.sections}
            counts={groupCounts}
            onAdd={(group) => setGroupCounts((current) => ({ ...current, [group]: (current[group] ?? 0) + 1 }))}
          />
        </Card>
      ) : null}

      <div className="flex flex-col gap-2">
        <Button
          fullWidth
          size="lg"
          onClick={() => {
            setAttempted(true)
            if (valid) onComplete(values, groupCounts)
          }}
        >
          {feature.primaryAction ?? 'Salvar registro'}
        </Button>
        {onCancel && (
          <Button fullWidth size="lg" variant="ghost" onClick={onCancel}>
            Cancelar
          </Button>
        )}
      </div>
    </div>
  )
}

function makeRecord(
  feature: FeatureDefinition,
  values: Record<string, string>,
  groupCounts: Record<string, number>,
): Omit<PrototypeRecord, 'id'> {
  const fieldLabel = Object.fromEntries((feature.fields ?? []).map((field) => [field.id, field.label]))
  const details = Object.fromEntries(
    Object.entries(values)
      .filter(([, value]) => value.trim())
      .map(([id, value]) => [fieldLabel[id] ?? id, value]),
  )

  Object.entries(groupCounts).forEach(([group, count]) => {
    if (count > 0) details[group] = `${count} item(ns)`
  })

  const title = values[feature.recordTitleField ?? 'nome'] || feature.title
  const fallbackDescription = (feature.recordDescriptionFields ?? [])
    .map((fieldId) => values[fieldId])
    .filter(Boolean)
    .join(' · ')
  const descriptionByFeature: Record<string, string> = {
    'cadastrar-area': [values.tipo, values['area-total'] && values.unidade ? `${values['area-total']} ${values.unidade}` : ''].filter(Boolean).join(' · '),
    formulacoes: [values.quantidade && values.unidade ? `${values.quantidade} ${values.unidade}` : '', values.ativo === 'Sim' ? 'Ativa' : 'Inativa'].filter(Boolean).join(' · '),
    batidas: [values.formulacao, values.quantidade && values.unidade ? `${values.quantidade} ${values.unidade}` : ''].filter(Boolean).join(' · '),
    apontamento: [values.operacao, values.data].filter(Boolean).join(' · '),
    abastecimentos: [values.quantidade ? `${values.quantidade} L` : '', values.combustivel].filter(Boolean).join(' · '),
    'manutencao-frota': [values.tipo, values.data].filter(Boolean).join(' · '),
    'rebanho-inicial': [values.quantidade && values.especie ? `${values.quantidade} animais · ${values.especie}` : '', values.area].filter(Boolean).join(' · '),
    'registrar-animal': [values.raca, values.peso ? `${values.peso} kg` : '', values.nascimento].filter(Boolean).join(' · '),
    'lotes-reproducao': [values.finalidade, values.estacao, values.quantidade ? `${values.quantidade} animais` : ''].filter(Boolean).join(' · '),
    'material-reprodutivo': [values.tipo, values.raca, values.quantidade ? `${values.quantidade} unidade(s)` : ''].filter(Boolean).join(' · '),
    'monta-natural': [values.touro, values.quantidade ? `${values.quantidade} fêmeas` : '', values.data].filter(Boolean).join(' · '),
    'diagnostico-gestacao': [values.resultado, values.quantidade ? `${values.quantidade} animais` : '', values.data].filter(Boolean).join(' · '),
    carga: [values.quantidade && values.unidade ? `${values.quantidade} ${values.unidade}` : '', values.equipamento].filter(Boolean).join(' · '),
    descarga: [values.produto, values.quantidade && values.unidade ? `${values.quantidade} ${values.unidade}` : ''].filter(Boolean).join(' · '),
    'configuracoes-misturador': [values.unidade, values.tolerancia ? `tolerância ${values.tolerancia}%` : '', values.alerta].filter(Boolean).join(' · '),
    'compras-animais': [values.quantidade ? `${values.quantidade} animais` : '', values.categoria, values.data].filter(Boolean).join(' · '),
    apartacao: [values.criterio, values['lote-destino'], values.quantidade ? `${values.quantidade} animais` : ''].filter(Boolean).join(' · '),
  }
  const description = descriptionByFeature[feature.id] || fallbackDescription
  const status = PROGRAMMED_RECORD_FEATURES.has(feature.id)
    ? 'programado'
    : ACTIVE_RECORD_FEATURES.has(feature.id)
      ? 'ativo'
      : 'concluido'

  return {
    title,
    description: description || 'Registro criado agora',
    status,
    details,
  }
}

function RecordsList({
  feature,
  records,
  canCreate,
  onCreate,
  onSelect,
}: {
  feature: FeatureDefinition
  records: PrototypeRecord[]
  canCreate: boolean
  onCreate: () => void
  onSelect: (record: PrototypeRecord) => void
}) {
  return (
    <div className="flex flex-col gap-4">
      <Card>
        <div className="mb-3 flex items-center justify-between gap-3">
          <SectionTitle>Registros</SectionTitle>
          <Chip tone="neutral">{records.length}</Chip>
        </div>
        {records.length ? (
          <div className="flex flex-col gap-2">
            {records.map((record) => (
              <MenuItem
                key={record.id}
                label={record.title}
                description={record.description}
                trailing={<Chip tone={record.status === 'programado' ? 'blue' : 'brand'}>{STATUS_LABEL[record.status]}</Chip>}
                onClick={() => onSelect(record)}
              />
            ))}
          </div>
        ) : (
          <EmptyState
            icon={ClipboardCheck}
            title={feature.emptyLabel ?? 'Nenhum registro encontrado'}
            description="Use a ação abaixo para criar o primeiro registro desta rotina."
          />
        )}
      </Card>

      {canCreate && (
        <Button fullWidth size="lg" leftIcon={<Plus size={18} />} onClick={onCreate}>
          {feature.createAction ?? 'Novo registro'}
        </Button>
      )}
    </div>
  )
}

function RecordDetailsSheet({ record, onClose }: { record: PrototypeRecord | null; onClose: () => void }) {
  return (
    <BottomSheet open={Boolean(record)} onClose={onClose} title={record?.title}>
      {record && (
        <div className="flex flex-col gap-4">
          <Chip tone={record.status === 'programado' ? 'blue' : 'brand'} className="self-start">
            {STATUS_LABEL[record.status]}
          </Chip>
          <div className="flex flex-col gap-2">
            {Object.entries(record.details).map(([label, value]) => (
              <div key={label} className="flex items-start justify-between gap-4 border-b border-border-subtle py-2 last:border-b-0">
                <p className="text-sm text-fg-muted">{label}</p>
                <p className="text-right text-sm font-semibold text-fg">{value}</p>
              </div>
            ))}
          </div>
          <Button fullWidth variant="secondary" onClick={onClose}>
            Fechar
          </Button>
        </div>
      )}
    </BottomSheet>
  )
}

/** Tela dirigida pelo catálogo: suporta consulta, lista, formulário e sucesso em memória. */
export function MappedFeatureScreen({ role }: { role: WorkspaceRole }) {
  const { featureId } = useParams()
  const navigate = useNavigate()
  const [mode, setMode] = useState<ScreenMode>('list')
  const [selectedRecord, setSelectedRecord] = useState<PrototypeRecord | null>(null)
  const [lastCreated, setLastCreated] = useState<PrototypeRecord | null>(null)
  const feature = featureId ? FEATURE_BY_ID[featureId] : undefined
  const recordsByFeature = usePrototypeRecordsStore((state) => state.recordsByFeature)
  const addRecord = usePrototypeRecordsStore((state) => state.addRecord)
  const allowedIds = useMemo(
    () => new Set((role === 'administrativo' ? ADMIN_FEATURES : OPERATIONAL_FEATURES).map((item) => item.id)),
    [role],
  )

  useEffect(() => {
    setMode('list')
    setSelectedRecord(null)
    setLastCreated(null)
  }, [featureId])

  if (!feature || !allowedIds.has(feature.id)) {
    return (
      <EmptyState
        icon={ShieldCheck}
        title="Funcionalidade fora deste perfil"
        description="Volte ao ambiente correspondente para acessar esta responsabilidade."
        action={<Button onClick={() => navigate(workspaceRoute(role))}>Voltar ao ambiente</Button>}
        className="h-full"
      />
    )
  }

  const dataSourceId = feature.dataSourceId ?? feature.id
  const records = recordsByFeature[dataSourceId] ?? []
  const samples = READ_ONLY_SAMPLES[feature.id]
  const canCreate = role === 'operacional' && Boolean(feature.fields?.length)

  const completeForm = (values: Record<string, string>, groupCounts: Record<string, number>) => {
    const created = addRecord(dataSourceId, makeRecord(feature, values, groupCounts))
    setLastCreated(created)
    setMode('success')
  }

  if (mode === 'success') {
    return (
      <SuccessPanel
        title={feature.successTitle ?? `${lastCreated?.title ?? feature.title} salvo`}
        description={feature.successDescription ?? 'O registro foi incluído no protótipo e já está disponível na lista desta sessão.'}
      >
        {feature.listMode && (
          <Button fullWidth onClick={() => setMode('list')}>
            Ver registros
          </Button>
        )}
        <Button fullWidth variant="secondary" onClick={() => navigate(workspaceRoute(role))}>
          Voltar às funcionalidades
        </Button>
      </SuccessPanel>
    )
  }

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader
        title={feature.title}
        onBack={mode === 'form' && feature.listMode ? () => setMode('list') : undefined}
      />
      {role === 'operacional' && <ContextBadge />}
      <div className="no-scrollbar flex flex-1 flex-col gap-4 overflow-y-auto p-4">
        <div>
          <div className="flex flex-wrap items-center gap-2">
            <Chip tone={role === 'administrativo' ? 'blue' : 'brand'}>
              {role === 'administrativo' ? 'Administração' : 'Operação'}
            </Chip>
            <Chip tone={feature.status === 'hardware' ? 'amber' : feature.status === 'mapped' ? 'blue' : 'brand'}>
              {feature.status === 'hardware' ? 'Simulação de hardware' : feature.status === 'mapped' ? 'Escopo mapeado' : 'Funcional no protótipo'}
            </Chip>
          </div>
          <Heading level={2} className="mt-3">
            {mode === 'form' ? feature.createAction ?? feature.title : feature.title}
          </Heading>
          <p className="mt-1 text-md text-fg-muted">{feature.objective}</p>
        </div>

        {feature.sourceDetail && (
          <Banner tone="info" icon={<Info size={15} />}>
            {feature.sourceDetail}
          </Banner>
        )}

        {feature.status === 'hardware' && (
          <Banner tone="offline" icon={<Bluetooth size={15} />}>
            A integração nativa é simulada neste protótipo frontend.
          </Banner>
        )}

        {feature.capabilities && (
          <Card>
            <SectionTitle className="mb-3">Recursos envolvidos</SectionTitle>
            <div className="flex flex-wrap gap-2">
              {feature.capabilities.map((capability) => (
                <Tag key={capability}>{capability}</Tag>
              ))}
            </div>
          </Card>
        )}

        {feature.auditExport ? (
          <AuditExportPanel
            filename={`auditoria-${feature.auditExport}`}
            rows={AUDIT_EXPORT_ROWS[feature.auditExport]}
          />
        ) : feature.listMode && mode === 'list' ? (
          <RecordsList
            feature={feature}
            records={records}
            canCreate={canCreate}
            onCreate={() => setMode('form')}
            onSelect={setSelectedRecord}
          />
        ) : feature.fields?.length || feature.simulation ? (
          <FeatureForm
            feature={feature}
            onComplete={completeForm}
            onCancel={feature.listMode ? () => setMode('list') : undefined}
          />
        ) : samples ? (
          <Card className="flex flex-col gap-2">
            <SectionTitle>Visão de consulta</SectionTitle>
            {samples.map((sample) => (
              <MenuItem key={sample.label} label={sample.label} description={sample.description} />
            ))}
          </Card>
        ) : feature.emptyLabel ? (
          <Card padded={false}>
            <EmptyState
              icon={ClipboardCheck}
              title={feature.emptyLabel}
              description="Estado vazio preservado conforme o padrão observado no aplicativo de referência."
            />
          </Card>
        ) : feature.primaryAction ? (
          <Card>
            <SectionTitle className="mb-2">Acesso prototipado</SectionTitle>
            <p className="mb-4 text-sm text-fg-muted">
              A navegação e a responsabilidade estão definidas. Este fluxo será detalhado na próxima onda.
            </p>
            <Button fullWidth variant="secondary" leftIcon={<ClipboardCheck size={18} />} disabled>
              {feature.primaryAction}
            </Button>
          </Card>
        ) : null}
      </div>

      <RecordDetailsSheet record={selectedRecord} onClose={() => setSelectedRecord(null)} />
    </div>
  )
}
