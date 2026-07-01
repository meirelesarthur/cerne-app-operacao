import { useRef, useState } from 'react'
import { UploadCloud, FileCheck2, X } from 'lucide-react'

export interface FileUploadProps {
  accept?: string
  hint?: string
  onFile?: (name: string | null) => void
}

/** Dropzone/seletor de arquivo (ex.: XML da NF-e). Não faz upload real no protótipo. */
export function FileUpload({ accept = '.xml', hint = 'Toque para selecionar o arquivo', onFile }: FileUploadProps) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [fileName, setFileName] = useState<string | null>(null)

  const pick = () => inputRef.current?.click()
  const set = (name: string | null) => {
    setFileName(name)
    onFile?.(name)
  }

  if (fileName) {
    return (
      <div className="flex items-center gap-3 rounded-xl border border-brand-200 bg-brand-50 p-3">
        <FileCheck2 size={20} className="text-accent" />
        <span className="flex-1 truncate text-md font-medium text-fg">{fileName}</span>
        <button aria-label="Remover arquivo" onClick={() => set(null)} className="text-fg-subtle">
          <X size={18} />
        </button>
      </div>
    )
  }

  return (
    <>
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        className="hidden"
        onChange={(e) => set(e.target.files?.[0]?.name ?? 'nota-fiscal.xml')}
      />
      <button
        type="button"
        onClick={pick}
        className="flex w-full flex-col items-center gap-2 rounded-xl border-2 border-dashed border-border-strong bg-surface-subtle px-4 py-8 text-center"
      >
        <UploadCloud size={28} className="text-fg-subtle" />
        <span className="text-md font-semibold text-fg">Selecionar arquivo XML</span>
        <span className="text-sm text-fg-muted">{hint}</span>
      </button>
    </>
  )
}
