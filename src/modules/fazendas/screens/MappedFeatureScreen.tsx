import { useMemo, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Bluetooth, ClipboardCheck, Info, ShieldCheck } from 'lucide-react'
import { Banner } from '@/components/ui/Banner'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Chip } from '@/components/ui/Chip'
import { EmptyState } from '@/components/ui/EmptyState'
import { FormField } from '@/components/ui/FormField'
import { FormSelect } from '@/components/ui/FormSelect'
import { Heading, SectionTitle } from '@/components/ui/Heading'
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

type WorkspaceRole = 'administrativo' | 'operacional'

const READ_ONLY_SAMPLES: Record<string, { label: string; description: string }[]> = {
  areas: [
    { label: 'Talhão 01', description: 'Agricultura · 42 ha' },
    { label: 'Pasto Norte', description: 'Pecuária · 68 ha' },
    { label: 'Pomar Sul', description: 'Fruticultura · 15 ha' },
  ],
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

function FeatureForm({ feature, onComplete }: { feature: FeatureDefinition; onComplete: () => void }) {
  const [values, setValues] = useState<Record<string, string>>({})
  const valid = (feature.fields ?? []).every((field) => !field.required || Boolean(values[field.id]?.trim()))

  return (
    <div className="flex flex-col gap-5">
      <Card className="flex flex-col gap-4">
        <SectionTitle>Dados do registro</SectionTitle>
        {feature.fields?.map((field) => (
          <FormField
            key={field.id}
            label={field.label}
            htmlFor={`feature-${field.id}`}
            required={field.required}
          >
            <FieldControl
              field={field}
              value={values[field.id] ?? ''}
              onChange={(value) => setValues((current) => ({ ...current, [field.id]: value }))}
            />
          </FormField>
        ))}
      </Card>

      {feature.sections && (
        <Card>
          <SectionTitle className="mb-3">Grupos do fluxo</SectionTitle>
          <div className="flex flex-wrap gap-2">
            {feature.sections.map((section) => (
              <Tag key={section}>{section}</Tag>
            ))}
          </div>
          <p className="mt-3 text-xs text-fg-muted">
            Os grupos seguem a estrutura observada e serão detalhados em etapas próprias na evolução do protótipo.
          </p>
        </Card>
      )}

      <Button fullWidth size="lg" disabled={!valid} onClick={onComplete}>
        {feature.primaryAction ?? 'Salvar registro'}
      </Button>
    </div>
  )
}

/** Tela de detalhe dirigida pelo catálogo para itens ainda sem uma tela dedicada. */
export function MappedFeatureScreen({ role }: { role: WorkspaceRole }) {
  const { featureId } = useParams()
  const navigate = useNavigate()
  const [complete, setComplete] = useState(false)
  const feature = featureId ? FEATURE_BY_ID[featureId] : undefined
  const allowedIds = useMemo(
    () => new Set((role === 'administrativo' ? ADMIN_FEATURES : OPERATIONAL_FEATURES).map((item) => item.id)),
    [role],
  )

  if (!feature || !allowedIds.has(feature.id)) {
    return (
      <EmptyState
        icon={ShieldCheck}
        title="Funcionalidade fora deste perfil"
        description="Volte ao ambiente correspondente para acessar esta responsabilidade."
        action={<Button onClick={() => navigate(`/fazendas/${role}`)}>Voltar ao ambiente</Button>}
        className="h-full"
      />
    )
  }

  if (complete) {
    return (
      <SuccessPanel
        title="Registro de demonstração concluído"
        description="O fluxo foi validado no protótipo e está pronto para o detalhamento técnico do time mobile."
      >
        <Button fullWidth onClick={() => navigate(`/fazendas/${role}`)}>
          Voltar às funcionalidades
        </Button>
      </SuccessPanel>
    )
  }

  const samples = READ_ONLY_SAMPLES[feature.id]

  return (
    <div className="flex h-full flex-col bg-canvas">
      <SubPageHeader title={feature.title} />
      {role === 'operacional' && <ContextBadge />}
      <div className="no-scrollbar flex flex-1 flex-col gap-4 overflow-y-auto p-4">
        <div>
          <div className="flex items-center gap-2">
            <Chip tone={role === 'administrativo' ? 'blue' : 'brand'}>
              {role === 'administrativo' ? 'Administração' : 'Operação'}
            </Chip>
            <Chip tone={feature.status === 'hardware' ? 'amber' : feature.status === 'mapped' ? 'blue' : 'brand'}>
              {feature.status === 'hardware' ? 'Depende de hardware' : feature.status === 'mapped' ? 'Escopo mapeado' : 'Fluxo detalhado'}
            </Chip>
          </div>
          <Heading level={2} className="mt-3">
            {feature.title}
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
            A apresentação simula a preparação do fluxo. A integração nativa será validada no app mobile.
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

        {feature.fields?.length ? (
          <FeatureForm feature={feature} onComplete={() => setComplete(true)} />
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
              A navegação e a responsabilidade estão definidas. Os campos aguardam evidência funcional para não criar regras incorretas.
            </p>
            <Button fullWidth variant="secondary" leftIcon={<ClipboardCheck size={18} />} disabled>
              {feature.primaryAction}
            </Button>
          </Card>
        ) : null}
      </div>
    </div>
  )
}
