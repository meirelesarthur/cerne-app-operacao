import { cn } from '@/lib/cn'

export type AvatarSize = 'sm' | 'md' | 'lg'

export interface AvatarProps {
  name: string
  initials?: string
  size?: AvatarSize
  className?: string
}

const sizeCls: Record<AvatarSize, string> = {
  sm: 'h-8 w-8 text-xs',
  md: 'h-10 w-10 text-sm',
  lg: 'h-14 w-14 text-lg',
}

/** Deriva iniciais a partir dos 2 primeiros nomes de `name`, em maiúsculas. */
function deriveInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return ''
  return parts
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? '')
    .join('')
}

/** Círculo de identificação com iniciais do usuário, derivadas do nome quando não informadas. */
export function Avatar({ name, initials, size = 'md', className }: AvatarProps) {
  const displayInitials = initials ?? deriveInitials(name)

  return (
    <span
      role="img"
      aria-label={name}
      className={cn(
        'inline-flex items-center justify-center shrink-0 rounded-full border border-border-default bg-accent-subtle font-semibold text-accent',
        sizeCls[size],
        className,
      )}
    >
      <span aria-hidden="true">{displayInitials}</span>
    </span>
  )
}
