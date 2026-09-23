<p align="center">
  <img src="apps/mobile/assets/images/Logo.svg" alt="GB CERNE" width="240" />
</p>

# GB CERNE Operação

App de campo do **GB CERNE**: cadastros e rotinas do dia a dia da fazenda para a equipe
operacional. Protótipo frontend navegável (Flutter Web), dados simulados, sem backend.

## Stack

Flutter 3.44.6 + Dart 3 · Riverpod · go_router · Widgetbook · Cloudflare Workers Static Assets.

## Funcionalidades e fluxos

Login único (sem seleção de perfil) leva direto à tela **Início**: as OS em andamento no topo (com
situação e ação rápida confirmada) e os atalhos das rotinas logo abaixo. O farm switcher fica no
topo e a navbar é **Início · Pecuária · Agricultura · Menu**; o menu lateral lista todas as rotinas.
Mapa completo em [`docs/SITEMAP.md`](docs/SITEMAP.md).

- **Confinamento** — trato diário (distribuição de batelada por curral), arraçoamento, leitura de
  cocho (sobras e ocorrências sanitárias/estruturais/ambientais), meus currais, produção de
  batelada.
- **Pecuária** — cadastro e pesagem de animais, manejo sanitário, transferência de animal/lote,
  apartação, nascimentos, desmama, mortes, perdas, rebanho inicial, pastagens, localização de
  animal e scanner SISBOV (identificação por brinco, RFID ou câmera — simulados).
- **Agricultura** — apontamento agrícola (operação + recursos utilizados) e marcação de áreas.
- **Reprodução** — estação de monta, protocolos reprodutivos, gestão de material (touros/sêmen/
  embrião), acasalamento e diagnóstico de gestação.
- **Ordem de Serviço** — minhas OS, ordens pendentes e apontamentos agrícolas por OS.
- **Gestão de Frota** — abastecimentos e manutenção de veículos/equipamentos.
- **Sincronização** — fila de envio para quando a conexão cair; banner de offline no shell.

Todo cadastro segue o mesmo desenho: farm switcher fixo, formulário em etapas com revisão final e
confirmação, e bloqueios de negócio simulados na própria UI (ex.: transferência de lote exige
pesagem do dia).

## Como rodar

```bash
npm install
npm run dev                # Flutter Web no Chrome
npm run lint               # flutter analyze --fatal-infos
npm test                   # suíte Flutter completa
npm run quality:functional # gates de arquitetura, acesso e catálogo funcional
npm run build              # app + Widgetbook em apps/mobile/build/site
npm run smoke:deploy       # rotas e fallbacks do Worker Cloudflare
```

## Limites do protótipo

Frontend puro: autenticação, RBAC, APIs e persistência são simulados. Bluetooth, RFID, câmera,
localização e balança têm jornadas demonstrativas, sem integração nativa real.
