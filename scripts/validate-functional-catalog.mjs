import { readFileSync } from 'node:fs'

const EXPECTED_ADMIN = 12
const EXPECTED_OPERATIONAL = 41
const catalogUrl = new URL('../src/modules/fazendas/functionalCatalog.ts', import.meta.url)
const source = readFileSync(catalogUrl, 'utf8')

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

const ready = allFeatures.filter((feature) => feature.status === 'ready').length
const hardware = allFeatures.filter((feature) => feature.status === 'hardware').length

console.log(`Catálogo validado: ${allFeatures.length} funções (${ready} prontas + ${hardware} com hardware simulado).`)
