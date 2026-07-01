import { t } from '@/design/tokens'

export interface BarDatum {
  label: string
  value: number
  color?: string
}

export interface BarChartProps {
  data: BarDatum[]
  height?: number
  formatValue?: (v: number) => string
}

/** Gráfico de barras SVG próprio (tokenizado), horizontal-friendly em mobile. */
export function BarChart({ data, height = 160, formatValue = (v) => String(v) }: BarChartProps) {
  const max = Math.max(...data.map((d) => d.value), 1)

  return (
    <div className="flex flex-col gap-2" style={{ minHeight: height }}>
      {data.map((d, i) => {
        const pct = (d.value / max) * 100
        return (
          <div key={d.label} className="flex items-center gap-2">
            <span className="w-24 shrink-0 truncate text-sm text-fg-muted">{d.label}</span>
            <div className="h-6 flex-1 overflow-hidden rounded-md bg-surface-subtle">
              <div
                className="flex h-full items-center justify-end rounded-md pr-2 text-xs font-semibold text-white"
                style={{ width: `${Math.max(pct, 14)}%`, background: d.color ?? t.chart.series[i % t.chart.series.length] }}
              >
                {formatValue(d.value)}
              </div>
            </div>
          </div>
        )
      })}
    </div>
  )
}
