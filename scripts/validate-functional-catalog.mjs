import { readFileSync, readdirSync } from 'node:fs'
import { join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const EXPECTED_ADMIN = 12
const EXPECTED_OPERATIONAL = 41
const catalogUrl = new URL('../src/modules/fazendas/functionalCatalog.ts', import.meta.url)
const source = readFileSync(catalogUrl, 'utf8')
const srcDir = fileURLToPath(new URL('../src/', import.meta.url))

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function sectionBetween(start, end) {
  const startIndex = source.indexOf(start)
  const endIndex = source.indexOf(end, startIndex + start.length)
  assert(startIndex >= 0 && endIndex > startIndex, `Seção ausente: ${start}`)
  return source.slice(startIndex, endIndex)
}

function parseFeatures(section) {
  return [...section.matchAll(/^  \{\r?\n    id: '([^']+)',([\s\S]*?)(?=^  \},?\r?$)/gm)].map((match) => {
    const body = match[2]
    const status = body.match(/^    status: '([^']+)',/m)?.[1]
    return {
      id: match[1],
      status,
      demonstrable: /^    (existingRoute|listMode|fields|sections|capabilities|auditExport|simulation):/m.test(body),
      simulated: /^    simulation:/m.test(body),
    }
  })
}

function listTsxFiles(dir) {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const path = join(dir, entry.name)
    if (entry.isDirectory()) return listTsxFiles(path)
    return entry.isFile() && entry.name.endsWith('.tsx') ? [path] : []
  })
}

const admin = parseFeatures(sectionBetween('export const ADMIN_FEATURES', 'export const OPERATIONAL_FEATURES'))
const operational = parseFeatures(sectionBetween('export const OPERATIONAL_FEATURES', 'export const FEATURE_BY_ID'))
const allFeatures = [...admin, ...operational]
const ids = allFeatures.map((feature) => feature.id)

assert(admin.length === EXPECTED_ADMIN, `Esperadas ${EXPECTED_ADMIN} funções administrativas.`)
assert(operational.length === EXPECTED_OPERATIONAL, `Esperadas ${EXPECTED_OPERATIONAL} funções operacionais.`)
assert(new Set(ids).size === ids.length, 'O catálogo possui identificadores duplicados.')

const mapped = allFeatures.filter((feature) => feature.status === 'mapped')
assert(mapped.length === 0, `Ainda existem funções apenas mapeadas: ${mapped.map((feature) => feature.id).join(', ')}`)

const withoutStatus = allFeatures.filter((feature) => !feature.status)
assert(withoutStatus.length === 0, `Funções sem status: ${withoutStatus.map((feature) => feature.id).join(', ')}`)

const withoutJourney = allFeatures.filter((feature) => !feature.demonstrable)
assert(withoutJourney.length === 0, `Funções sem jornada demonstrável: ${withoutJourney.map((feature) => feature.id).join(', ')}`)

const hardwareWithoutSimulation = allFeatures.filter(
  (feature) => feature.status === 'hardware' && !feature.simulated,
)
assert(hardwareWithoutSimulation.length === 0, `Hardware sem simulação: ${hardwareWithoutSimulation.map((feature) => feature.id).join(', ')}`)

const forbiddenElements = /<(button|input|select|textarea|table|thead|tr|td|h[1-6])\b/
const componentFirstViolations = listTsxFiles(srcDir)
  .filter((file) => !file.includes(`${join('components', 'ui')}\\`) && !file.includes(`${join('components', 'ui')}/`))
  .flatMap((file) => readFileSync(file, 'utf8').split(/\r?\n/).flatMap((line, index) => (
    forbiddenElements.test(line) ? [`${relative(srcDir, file)}:${index + 1}`] : []
  )))

assert(
  componentFirstViolations.length === 0,
  `Elementos HTML proibidos fora do catálogo UI: ${componentFirstViolations.join(', ')}`,
)

const hardcodedColor = /#[0-9a-f]{6}(?:[0-9a-f]{2})?\b|rgba?\(/i
const foreignFont = /fontFamily\s*:|font-(?:serif|mono|montserrat)\b|\b(?:Arial|Roboto|Inter|Montserrat)\b/
const tokenViolations = listTsxFiles(srcDir).flatMap((file) => (
  readFileSync(file, 'utf8').split(/\r?\n/).flatMap((line, index) => (
    hardcodedColor.test(line) || foreignFont.test(line)
      ? [`${relative(srcDir, file)}:${index + 1}`]
      : []
  ))
))

assert(tokenViolations.length === 0, `Valores visuais fora dos tokens: ${tokenViolations.join(', ')}`)

const globalCss = readFileSync(join(srcDir, 'index.css'), 'utf8')
assert(/font-family:\s*'Outfit'/.test(globalCss), 'A fonte global obrigatória Outfit não está configurada.')

const ready = allFeatures.filter((feature) => feature.status === 'ready').length
const hardware = allFeatures.filter((feature) => feature.status === 'hardware').length

console.log(`Catálogo validado: ${allFeatures.length} funções (${ready} prontas + ${hardware} com hardware simulado); Component-First e tokens íntegros.`)
