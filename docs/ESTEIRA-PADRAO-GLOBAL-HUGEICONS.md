# Esteira — Padrão global (Figma) + migração de iconografia para Hugeicons 1.2

Referência de design: `S8qJ9G8mbenqZ0Zcq3XnrE` (GB CERNE), nó `54300-2458`, seções **`operacao`**
(`54349:3294`) e **`administrativo`** (`54349:3295`).
Referências de código: `apps/mobile/lib/ui/` (catálogo), `apps/mobile/lib/shell/`,
`apps/mobile/lib/modules/` (6 módulos), `design/tokens.ts` (Lei 3/5).

## Objetivo

Duas entregas acopladas, na ordem em que se sustentam:

1. **Iconografia única.** Substituir Lucide por **Hugeicons *stroke-rounded* com traço 1.2** em todo
   o app, atrás de uma camada própria do catálogo — não trocando `IconData` por `IconData` espalhado
   em 98 arquivos.
2. **Padrão global de tela.** Elevar os 6 frames do Figma a gramática da aplicação: cabeçalho,
   busca, ladrilho de módulo, barra de ação fixa e passos. E fixar a separação **ADM × Operação**
   como dois arquétipos de home distintos, não como uma home com `if`.

**Status: em execução.** As seções 1–4 são auditoria e decisão (fechadas). A seção 5 é a esteira de
execução, com o estado de cada etapa anotado.

---

## 1. Leitura do Figma — o que os 6 frames definem

| Frame | Nó | Papel na gramática |
|---|---|---|
| `operacao-home` | `54300:15706` | Arquétipo **Operação**: lançador de tarefas |
| `modulo-confinamento` | `54349:3009` | Arquétipo **módulo**: grade de funcionalidades |
| `Cadastro bottom fixed(sem navbar)` | `54300:16032` | Arquétipo **fluxo curto**: form + barra de ação fixa |
| `Cadastro steps(sem navbar)` | `54349:1990` | Arquétipo **fluxo longo**: passos + duas ações |
| `administrativo-home` | `54300:16069` | Arquétipo **ADM**: torre financeira |
| `Menu-rapido-admin` | `54349:2829` | Arquétipo **descoberta**: produtos, atalhos, histórico |

### 1.1 Geometria medida (frame de 402 px)

Valores extraídos de `get_design_context`, não estimados da imagem:

| Elemento | Medida |
|---|---|
| Canvas | `#f0f0f0` |
| Seletor de fazenda | topo 16, ícone 20 px, rótulo 16 px `#047857`, caret 20 px |
| Cartão de conteúdo | branco, raio **24**, topo 53, largura 402 |
| Cabeçalho de usuário | 16/29, avatar 48, "Boa tarde," 14 px `#6b7280`, nome 20 px SemiBold `#141414` |
| Bolha de notificação | 44×44, raio 22, branco, sombra `0 2px 4px rgba(0,0,0,.04)`, ícone 28 |
| Campo de busca | 370×52, `#f0f0f0`, raio **20**, `pl 12 / pr 8`, botão 40 circular branco |
| Ladrilho de módulo | **180×116**, `#f0f0f0`, raio **20**, `px 12 / py 16`, sombra `0 4px 6px rgba(0,0,0,.02)` |
| Grade | 2 colunas, **gap 8**, ícone 24 no topo-esquerda, rótulo 14 px na base |
| Ladrilho largo | 370×116, mesma anatomia |
| Preto de marca | `#023535` |

### 1.2 Achados

**A. O ladrilho de módulo é um componente novo, não uma variação de `AppQuickAction`.**
`AppQuickAction` é círculo + rótulo centralizado. O ladrilho do Figma é retângulo 180×116 com
ícone **ancorado no topo-esquerda** e rótulo **ancorado na base-esquerda** (`justify-between` numa
coluna). São leituras visuais diferentes; forçar props em `AppQuickAction` violaria a Lei 2 pela
porta dos fundos. Entra no catálogo como componente próprio.

**B. O Figma mistura Outfit e Montserrat.** Rótulos de ladrilho e placeholder de busca vêm como
`Montserrat`; cabeçalho e seletor vêm como `Outfit`. A **Lei 3 do projeto prevalece**: Outfit é a
única família de apresentação. Divergência deliberada e registrada — não é lacuna de implementação.

**C. Raio 20/24 não existe na escala atual.** `radius` tem `xl: 18` e `2xl: 22`; o Figma pede 20
(ladrilho, busca) e 24 (cartão de conteúdo). Valores novos entram em `design/tokens.ts` primeiro
(Lei 5), como `radius.tile` e `radius.surface`.

**D. A separação ADM × Operação já existe no código, mas não como arquétipo.**
`FazendasHome` ramifica em `_HomeCampo` / `_HomeGerencial` por `UserAccessProfile`. O Figma confirma
a divisão e a torna mais forte: as duas homes não compartilham **nenhum** bloco de conteúdo —
Operação é lançador de tarefa, ADM é torre financeira com abas. O que elas compartilham é o
**cabeçalho** (seletor de fazenda + saudação + busca), e só ele.

**E. Dois ícones do Figma não são Hugeicons.** As camadas `confinamento` (34×28) e a de Pecuária
(33.9×28) são vetores autorais multi-path, não pertencem ao set. Ver decisão em §3.3.

---

## 2. Auditoria da iconografia atual

| Métrica | Valor |
|---|---|
| Referências `LucideIcons.*` em `lib/` | **384** |
| Ícones Lucide distintos em uso | **119** |
| Arquivos que importam `lucide_icons_flutter` | **98** |
| Usos de `Icon(` | 174 |
| Componentes de `lib/ui/` com `IconData` na assinatura | **12** |
| Ícone Material remanescente | 1 (`Icons.info_outline`) |

Componentes do catálogo com `IconData` na API pública: `alert_strip`, `app_icon_tile`, `bento_tile`,
`dashboard_card`, `empty_state`, `hardware_simulator`, `illustration_slot`, `menu_item`,
`mini_app_tile`, `quick_action`, `stepper`, `success_panel`.

---

## 3. Decisões técnicas

### 3.1 Pacote: `hugeicons` 1.1.7 — e por que traço 1.2 é atingível

Verificado no código-fonte do pacote (não na documentação):

- Os ícones **não são `IconData`**. São `List<List<dynamic>>` — estrutura JSON de tags + atributos
  SVG, montada em runtime e desenhada por `flutter_svg`.
- `HugeIcon` expõe `strokeWidth`, e o builder **sobrescreve** o atributo `strokeWidth` do JSON
  (`lib/hugeicons.dart`, `_buildSvgFromJson`). O set gratuito nasce em `1.5`; **1.2 é aplicável
  exatamente**, sem redesenhar nada.
- Cobertura: **5 159** ícones *stroke-rounded*.

Isso descarta a alternativa de gerar uma fonte de ícones: converter traço em contorno congelaria o
1.2 no binário e perderia o override. O caminho SVG mantém a espessura como **token**.

### 3.2 A camada `AppIcon` — consequência da Lei 1 e da Lei 2

Como o ícone deixa de ser `IconData`, a API pública do catálogo muda. Em vez de espalhar
`HugeIcon(...)` por 98 arquivos:

```dart
typedef AppIconData = List<List<dynamic>>;   // tipo do projeto, não do pacote
class AppIcons { static const AppIconData confinamento = ...; }   // catálogo semântico
class AppIcon extends StatelessWidget { ... }                     // único renderizador
```

Três consequências desejadas:

1. **A espessura 1.2 é definida em um lugar só** — `AppIcon` lê o token, nenhuma tela passa
   `strokeWidth`.
2. **O catálogo é semântico, não gráfico.** Telas pedem `AppIcons.confinamento`, não
   `HugeIcons.strokeRoundedBarns`. Trocar o desenho de "confinamento" vira uma linha.
3. **O pacote fica isolado.** Nenhum `import 'package:hugeicons/...'` fora de `lib/ui/`.

### 3.3 Os dois vetores autorais do Figma

`confinamento` e `pecuária` não existem no set gratuito (não há bovino em Hugeicons free — a busca
por `Cow`/`Cattle`/`Bull` retorna vazio). Duas saídas, e a escolha é por etapa:

- **E1–E5 (migração):** mapear para o equivalente semântico mais próximo do set (`Barns` e `Steak`),
  mantendo a app inteira numa família só.
- **E6 (fidelidade):** exportar os dois SVGs do Figma para `assets/icons/`, normalizados a traço
  1.2, e servi-los pela **mesma** API `AppIcon` — o consumidor não sabe a origem.

Registrado como divergência aberta até E6.

### 3.4 Mapa Lucide → Hugeicons

**132 entradas, validadas programaticamente contra os 5 159 nomes do pacote; 0 inválidas; cobertura
de 119/119 ícones em uso.** O mapa é a fonte da migração e vive versionado em
`scripts/icon-map.json`. Escolhas guiadas, quando existe, pelo **nome de camada do Figma** —
`BarnsIcon`, `TractorIcon`, `ScanHeartIcon`, `BookSearchIcon`, `CloudSyncIcon`, `BankIcon`,
`EyeOffIcon`, `CreditCardAcceptIcon`, `ArrowRight01Icon`, `FilterHorizontalIcon`, `AiSearch01Icon`,
`Store02Icon`, `ConnectIcon`, `Cash02Icon`, `SaveAllIcon`, `GreenHouseIcon`.

Substituições que mudam o desenho e merecem atenção em revisão visual:

| Lucide | Hugeicons | Motivo |
|---|---|---|
| `beef` | `Steak` | não há bovino no set gratuito |
| `boxes` | `Cube` | `BoxesIcon` do Figma é Pro |
| `eyeOff` | `ViewOff` | nomenclatura do set |
| `partyPopper` | `Party` | nomenclatura do set |
| `cloudSync` | `CloudSavingDone01` | não há nuvem+refresh no set gratuito |
| `handshake` | `Agreement01` | não há aperto de mão no set gratuito |
| `sprout` | `Plant01` | não há broto no set gratuito |
| `heartCrack` | `Sad02` | não há coração partido no set gratuito |

---

## 4. Arquétipos de home — ADM × Operação

O que separa as duas não é conteúdo: é **a pergunta que a tela responde**.

| | Operação | ADM |
|---|---|---|
| Pergunta | "o que eu executo agora?" | "o que precisa da minha decisão?" |
| Corpo | grade de ladrilhos de módulo | abas + cartão financeiro + listas |
| Densidade | 1 nível, sem rolagem longa | multi-seção, rolagem |
| Ação terminal | abrir um fluxo de registro | abrir um painel de leitura |
| Compartilhado | \multicolumn — cabeçalho (seletor + saudação + busca) e nada mais ||

Regra derivada: **nenhum bloco de conteúdo pode ser compartilhado entre as duas homes.** O que for
comum sobe para o cabeçalho global; o que for específico fica no arquétipo.

---

## 5. Esteira de execução

| Etapa | Escopo | Critério de aceite | Estado |
|---|---|---|---|
| **E1** | Fundação: `hugeicons` no pubspec; tokens de ícone (`iconStroke`, escala de tamanho, `radius.tile/surface`) em `design/tokens.ts` → DTCG → Dart; `AppIcon` + `AppIconData` + `AppIcons` em `lib/ui/`; caso no Widgetbook | `npm run tokens:verify` limpo; `AppIcon` registrado no Widgetbook | a fazer |
| **E2** | Catálogo `lib/ui/`: 12 assinaturas `IconData` → `AppIconData`; todos os `Icon(` internos → `AppIcon` | `flutter analyze --fatal-infos` limpo; goldens revisados | a fazer |
| **E3** | `lib/shell/`: header, tab bar, reveal menu, `module_config.dart` | shell sem `lucide` | a fazer |
| **E4** | 6 módulos (`fazendas`, `bank`, `credito`, `marketplace`, `armazem`, `hub`) | módulos sem `lucide` | a fazer |
| **E5** | Remoção da dependência `lucide_icons_flutter`; gate anti-regressão no teste de arquitetura | `npm test` verde; `npm run quality:functional` 53/53 | a fazer |
| **E6** | Padrão global: `AppModuleTile`, cabeçalho com seletor de fazenda, campo de busca, barra de ação fixa, passos; SVGs autorais de §3.3 | casos no Widgetbook; goldens dos dois temas | a fazer |
| **E7** | Homes ADM e Operação reescritas nos arquétipos da §4 | nenhum bloco de conteúdo compartilhado entre as duas | a fazer |

### Gates permanentes adicionados

- `component_first_test.dart` passa a proibir `import 'package:lucide_icons_flutter/...'` e
  `import 'package:hugeicons/...'` fora de `lib/ui/`.
- `token_integrity_test.dart` passa a proibir `strokeWidth:` literal em `AppIcon`.

### Riscos

| Risco | Mitigação |
|---|---|
| `HugeIcon` é `StatefulWidget` + `flutter_svg`; custo por ícone maior que uma glifo de fonte | o widget cacheia o SVG montado por (ícone, cor, traço); medir em listas longas antes de E7 |
| Tamanho do bundle web (8 MB de fonte Dart no pacote) | os ícones são `static const` por campo — medir `flutter build web` antes e depois em E5 |
| Goldens quebram em massa | E2 revisa e regrava em bloco único, com inspeção visual dos dois temas |
