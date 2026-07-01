import { cn } from '@/lib/cn'

export interface SkeletonProps {
  className?: string
  rounded?: 'md' | 'lg' | 'xl' | '2xl' | 'full'
}

const roundedCls = {
  md: 'rounded-md',
  lg: 'rounded-lg',
  xl: 'rounded-xl',
  '2xl': 'rounded-2xl',
  full: 'rounded-full',
} as const

export function Skeleton({ className, rounded = 'lg' }: SkeletonProps) {
  return (
    <div
      className={cn('animate-pulse bg-neutral-200/70 dark:bg-white/10', roundedCls[rounded], className)}
      aria-hidden="true"
    />
  )
}

/** Skeleton pré-montado no formato de um card de dashboard. */
export function CardSkeleton() {
  return (
    <div className="rounded-2xl bg-surface border border-border-default p-4">
      <Skeleton className="h-8 w-8" rounded="lg" />
      <Skeleton className="mt-3 h-3 w-2/3" />
      <Skeleton className="mt-2 h-6 w-1/2" />
      <Skeleton className="mt-3 h-8 w-full" />
    </div>
  )
}
