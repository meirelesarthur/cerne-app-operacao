import { t } from '@/design/tokens'

export interface DonutSlice {
  label: string
  value: number
  color?: string
}

export interface DonutChartProps {
  data: DonutSlice[]
  size?: number
  thickness?: number
  centerLabel?: string
  centerValue?: string
}

/** Donut SVG próprio (tokenizado) com legenda. */
export function DonutChart({ data, size = 140, thickness = 20, centerLabel, centerValue }: DonutChartProps) {
  const total = data.reduce((sum, d) => sum + d.value, 0) || 1
  const radius = (size - thickness) / 2
  const circumference = 2 * Math.PI * radius
  let offset = 0

  return (
    <div className="flex items-center gap-4">
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="shrink-0">
        <g transform={`rotate(-90 ${size / 2} ${size / 2})`}>
          {data.map((d, i) => {
            const frac = d.value / total
            const dash = frac * circumference
            const circle = (
              <circle
                key={d.label}
                cx={size / 2}
                cy={size / 2}
                r={radius}
                fill="none"
                stroke={d.color ?? t.chart.series[i % t.chart.series.length]}
                strokeWidth={thickness}
                strokeDasharray={`${dash} ${circumference - dash}`}
                strokeDashoffset={-offset}
              />
            )
            offset += dash
            return circle
          })}
        </g>
        {(centerValue || centerLabel) && (
          <text x="50%" y="50%" textAnchor="middle" dominantBaseline="middle">
            {centerValue && (
              <tspan x="50%" dy="-2" fontSize="16" fontWeight="700" fill="var(--fg-default)">
                {centerValue}
              </tspan>
            )}
            {centerLabel && (
              <tspan x="50%" dy="16" fontSize="9" fill="var(--fg-muted)">
                {centerLabel}
              </tspan>
            )}
          </text>
        )}
      </svg>
      <ul className="flex flex-col gap-1.5">
        {data.map((d, i) => (
          <li key={d.label} className="flex items-center gap-2 text-sm">
            <span
              className="h-2.5 w-2.5 shrink-0 rounded-full"
              style={{ background: d.color ?? t.chart.series[i % t.chart.series.length] }}
            />
            <span className="text-fg-muted">{d.label}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}
