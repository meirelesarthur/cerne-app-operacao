import type { ReactNode } from 'react'
import { Card } from './Card'
import { Heading } from './Heading'

export interface ChartCardProps {
  title: string
  subtitle?: string
  action?: ReactNode
  children: ReactNode
}

/** Card contêiner para um gráfico, com título e ação opcional. */
export function ChartCard({ title, subtitle, action, children }: ChartCardProps) {
  return (
    <Card>
      <div className="mb-3 flex items-start justify-between">
        <div>
          <Heading level={4}>{title}</Heading>
          {subtitle && <p className="text-sm text-fg-muted">{subtitle}</p>}
        </div>
        {action}
      </div>
      {children}
    </Card>
  )
}
