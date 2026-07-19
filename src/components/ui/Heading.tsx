import type { ReactNode } from 'react'
import { cn } from '@/lib/cn'

type Level = 1 | 2 | 3 | 4

export interface HeadingProps {
  level?: Level
  children: ReactNode
  className?: string
  id?: string
}

const levelCls: Record<Level, string> = {
  1: 'text-3xl font-extrabold',
  2: 'text-2xl font-bold',
  3: 'text-lg font-semibold',
  4: 'text-md font-semibold',
}

/** Título tipográfico — evita uso de <h1>–<h6> cru em páginas (Lei 1). */
export function Heading({ level = 2, children, className, id }: HeadingProps) {
  const Tag = `h${level}` as const
  return (
    <Tag id={id} className={cn('text-fg', levelCls[level], className)}>
      {children}
    </Tag>
  )
}

/** Título de seção (Nova UI): bold generoso como na referência ("Announcements", "Quick Actions"). */
export function SectionTitle({ children, className }: { children: ReactNode; className?: string }) {
  return <p className={cn('px-1 text-xl font-bold tracking-tight text-fg', className)}>{children}</p>
}
