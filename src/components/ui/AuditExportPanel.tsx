import { useState } from 'react'
import { Download, FileCheck2, ShieldCheck } from 'lucide-react'
import { Banner } from './Banner'
import { Button } from './Button'
import { Card } from './Card'
import { FormField } from './FormField'
import { FormSelect } from './FormSelect'
import { SectionTitle } from './Heading'

export interface AuditExportPanelProps {
  filename: string
  rows: Record<string, string>[]
}

function csvValue(value: string) {
  return `"${value.replace(/"/g, '""')}"`
}

/** Exportação local de auditoria para protótipos, sem depender de API ou armazenamento remoto. */
export function AuditExportPanel({ filename, rows }: AuditExportPanelProps) {
  const [period, setPeriod] = useState('30')
  const [format, setFormat] = useState('csv')
  const [exportedFile, setExportedFile] = useState('')

  const exportRows = () => {
    const filteredRows = period === '7' ? rows.slice(0, 2) : rows
    const content = format === 'json'
      ? JSON.stringify(filteredRows, null, 2)
      : [
          Object.keys(filteredRows[0] ?? {}).map(csvValue).join(','),
          ...filteredRows.map((row) => Object.values(row).map(csvValue).join(',')),
        ].join('\n')
    const completeFilename = `${filename}-${period}-dias.${format}`
    const url = URL.createObjectURL(new Blob([content], { type: format === 'json' ? 'application/json' : 'text/csv;charset=utf-8' }))
    const link = document.createElement('a')
    link.href = url
    link.download = completeFilename
    link.click()
    URL.revokeObjectURL(url)
    setExportedFile(completeFilename)
  }

  return (
    <div className="flex flex-col gap-4">
      <Card className="flex flex-col gap-4">
        <div className="flex items-start gap-3">
          <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-blue-50 text-blue-600">
            <ShieldCheck size={21} />
          </span>
          <div>
            <SectionTitle>Preparar arquivo de auditoria</SectionTitle>
            <p className="mt-1 text-sm text-fg-muted">O arquivo é gerado localmente com dados demonstrativos do período selecionado.</p>
          </div>
        </div>

        <FormField label="Período" htmlFor="audit-period" required>
          <FormSelect
            id="audit-period"
            value={period}
            onChange={(event) => setPeriod(event.target.value)}
            options={[
              { value: '7', label: 'Últimos 7 dias' },
              { value: '30', label: 'Últimos 30 dias' },
              { value: '365', label: 'Safra atual' },
            ]}
          />
        </FormField>

        <FormField label="Formato" htmlFor="audit-format" required>
          <FormSelect
            id="audit-format"
            value={format}
            onChange={(event) => setFormat(event.target.value)}
            options={[
              { value: 'csv', label: 'CSV' },
              { value: 'json', label: 'JSON' },
            ]}
          />
        </FormField>

        <Button fullWidth size="lg" leftIcon={<Download size={18} />} onClick={exportRows}>
          Exportar {format.toUpperCase()}
        </Button>
      </Card>

      {exportedFile && (
        <Banner tone="success" icon={<FileCheck2 size={16} />} className="mx-0 mt-0">
          Arquivo {exportedFile} gerado com {period === '7' ? Math.min(2, rows.length) : rows.length} registros.
        </Banner>
      )}
    </div>
  )
}
