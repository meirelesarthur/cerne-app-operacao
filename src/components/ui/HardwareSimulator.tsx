import { useEffect, useState } from 'react'
import { Bluetooth, CheckCircle2, Radio, RotateCw, ScanLine, Scale } from 'lucide-react'
import { Button } from './Button'
import { Card } from './Card'
import { Chip } from './Chip'

export type HardwareSimulationKind = 'devices' | 'scale' | 'rfid' | 'scanner'

export interface HardwareSimulatorProps {
  kind: HardwareSimulationKind
  value?: string
  error?: string
  onCapture: (value: string) => void
}

const CAPTURE_VALUE: Record<Exclude<HardwareSimulationKind, 'devices'>, string> = {
  scale: '482,6 kg',
  rfid: 'RFID 982 000123456789',
  scanner: 'SISBOV BR 105 621 784 003',
}

const COPY: Record<HardwareSimulationKind, { title: string; description: string; action: string }> = {
  devices: {
    title: 'Dispositivos próximos',
    description: 'Simula a busca Bluetooth autorizada durante o uso do app.',
    action: 'Buscar dispositivos',
  },
  scale: {
    title: 'Leitura da balança',
    description: 'Simula um peso estável recebido do equipamento conectado.',
    action: 'Simular leitura',
  },
  rfid: {
    title: 'Identificação por RFID',
    description: 'Aproxime o brinco do leitor ou informe o código manualmente abaixo.',
    action: 'Simular leitura RFID',
  },
  scanner: {
    title: 'Scanner SISBOV',
    description: 'Posicione a identificação dentro da área de enquadramento.',
    action: 'Simular captura',
  },
}

const ICON = {
  devices: Bluetooth,
  scale: Scale,
  rfid: Radio,
  scanner: ScanLine,
} satisfies Record<HardwareSimulationKind, typeof Bluetooth>

const READY_LABEL: Record<HardwareSimulationKind, string> = {
  devices: 'Conectado no protótipo',
  scale: 'Leitura estável',
  rfid: 'Identificação disponível',
  scanner: 'Identificação capturada',
}

/** Simula integrações nativas sem apresentar a captura como conexão real de hardware. */
export function HardwareSimulator({ kind, value, error, onCapture }: HardwareSimulatorProps) {
  const [devicesFound, setDevicesFound] = useState(false)
  const copy = COPY[kind]
  const Icon = ICON[kind]
  const ready = Boolean(value)

  useEffect(() => {
    setDevicesFound(false)
  }, [kind])

  const runSimulation = () => {
    if (kind === 'devices' && !devicesFound) {
      setDevicesFound(true)
      return
    }
    onCapture(kind === 'devices' ? 'Balança BT-42 + Leitor RFID CERNE' : CAPTURE_VALUE[kind])
  }

  return (
    <Card className="flex flex-col gap-4">
      <div className="flex items-start gap-3">
        <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-amber-50 text-amber-600">
          <Icon size={21} />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-2">
            <p className="text-md font-bold text-fg">{copy.title}</p>
            <Chip tone="amber">Simulação</Chip>
          </div>
          <p className="mt-1 text-sm text-fg-muted">{copy.description}</p>
        </div>
      </div>

      {kind === 'scanner' && !ready && (
        <div className="flex min-h-32 items-center justify-center rounded-2xl border border-dashed border-amber-300 bg-amber-50/60 text-amber-600">
          <ScanLine size={42} aria-hidden="true" />
          <span className="sr-only">Área simulada de enquadramento da câmera</span>
        </div>
      )}

      {kind === 'devices' && devicesFound && !ready && (
        <div className="flex flex-col gap-2">
          <div className="flex min-h-12 items-center justify-between gap-3 rounded-2xl bg-surface-subtle px-4 py-2">
            <span className="text-sm font-semibold text-fg">Balança BT-42</span>
            <Chip tone="blue">Encontrada</Chip>
          </div>
          <div className="flex min-h-12 items-center justify-between gap-3 rounded-2xl bg-surface-subtle px-4 py-2">
            <span className="text-sm font-semibold text-fg">Leitor RFID CERNE</span>
            <Chip tone="blue">Encontrado</Chip>
          </div>
        </div>
      )}

      {ready && (
        <div className="flex min-h-14 items-center gap-3 rounded-2xl bg-brand-50 px-4 py-3 text-brand-700" role="status">
          <CheckCircle2 size={20} className="shrink-0" />
          <div className="min-w-0">
            <p className="text-xs font-semibold uppercase tracking-wide">{READY_LABEL[kind]}</p>
            <p className="truncate text-md font-bold">{value}</p>
          </div>
        </div>
      )}

      {error && <p className="text-sm font-semibold text-red-600">{error}</p>}

      <Button
        fullWidth
        variant={ready ? 'secondary' : 'primary'}
        leftIcon={ready ? <RotateCw size={17} /> : <Icon size={17} />}
        onClick={() => {
          if (ready) {
            onCapture('')
            setDevicesFound(false)
            return
          }
          runSimulation()
        }}
      >
        {ready ? 'Reiniciar simulação' : kind === 'devices' && devicesFound ? 'Conectar dispositivos' : copy.action}
      </Button>
    </Card>
  )
}
