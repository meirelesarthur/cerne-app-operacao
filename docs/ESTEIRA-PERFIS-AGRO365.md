# Esteira de desenvolvimento por perfil — AGRO365 / GB CERNE

Referência funcional: `mapeamento_funcional_agro365_v2.md`, gravação de 16/08/2026.

## Objetivo

Separar a experiência de gestão da experiência de campo sem duplicar componentes ou regras.
O catálogo em `src/modules/fazendas/functionalCatalog.ts` é a fonte única das funcionalidades
mapeadas, do responsável por cada uma e do nível de fidelidade disponível no protótipo.

## Fronteira de responsabilidade

| Perfil | Pode fazer | Não pode fazer |
|---|---|---|
| Administração | Ler indicadores, filtrar análises, consultar cadastros, acompanhar processos e exportar auditoria | Criar lançamentos de campo |
| Operacional | Selecionar fazenda, cadastrar, lançar, operar hardware e sincronizar dados | Acessar dashboards e decisões gerenciais |

Filtros de dashboards não são considerados entrada operacional: eles apenas alteram a consulta.
A fazenda ativa, os estados offline e os componentes do design system continuam transversais.

## O que foi entregue nesta etapa

- Login demonstrativo com entradas independentes para **Administração** e **Operacional**.
- Identidade do ambiente persistente no shell durante a sessão.
- Navegação contextual por perfil: `Gestão` para administração e `Rotinas` para operação.
- Bloqueio de rotas cruzadas dentro do módulo Fazendas.
- Central administrativa com 12 acessos de decisão, consulta e auditoria.
- Central operacional com 41 acessos cobrindo Estoque, Misturador, Agricultura, Pecuária,
  Reprodução, Frota, OS e Sincronização.
- Formulários dirigidos por catálogo para os campos que a gravação efetivamente mostrou.
- Estados honestos para itens cujo acesso foi mostrado sem campos internos.
- Identificação explícita das dependências nativas: Bluetooth, localização, balança, RFID e câmera.
- Dashboard financeiro/operacional ampliado com filtros, posição financeira, COE, COT,
  custeio, produção e resultados apurados.
- Dashboard pecuário ampliado com estoque por categoria, desempenho no intervalo e última pesagem.
- Pesagem e Nutrição/Arraçoamento aperfeiçoados com os campos observados no mapeamento.

## Execução da esteira frontend

### Onda A — concluída no protótipo

- **Áreas:** lista e cadastro operacional, validação obrigatória, detalhe e consulta administrativa
  alimentada pela mesma fonte em memória.
- **Formulações:** lista, criação, matérias-primas vinculadas, validação e confirmação.
- **Batidas:** lista, formulário de produção, destino, quantidade, itens vinculados e confirmação.
- **Apontamento agrícola:** lista, operação, área, data, recursos associados e confirmação.
- **Frota:** listas e formulários de Abastecimento e Manutenção, com campos operacionais,
  validação e detalhe do registro.
- **Motor reutilizável:** todas as rotinas acima percorrem lista → formulário → validação → sucesso
  → consulta, com estado frontend compartilhado durante a sessão e sem dependência de backend.

Com esta onda, o catálogo possui **27 funcionalidades prontas**, **19 mapeadas** e
**7 dependentes de hardware**. As Ondas B a E permanecem na fila priorizada abaixo.

## Convenção de maturidade no protótipo

| Selo | Significado | Próxima ação |
|---|---|---|
| Pronto | Há tela dedicada ou formulário navegável com os campos conhecidos | Contrato de API, regras finais e testes |
| Mapeado | A função está navegável, mas a fonte não mostrou todos os campos | Validar fluxo com especialista antes de detalhar |
| Hardware | A função está posicionada e descreve dependências nativas | Spike no app mobile e teste em dispositivo real |

`Mapeado` não significa esquecido. É uma trava contra a invenção de requisitos que não aparecem
na evidência fornecida.

## Cobertura do Markdown

| Área do mapeamento | Perfil | Cobertura no protótipo |
|---|---|---|
| Seleção de fazenda | Ambos | Contexto global e tela de fazendas |
| Painel financeiro e operacional | Administração | Dashboard detalhado |
| Áreas | Administração / Operacional | Consulta administrativa e entrada operacional separadas |
| Estoque | Administração / Operacional | Saldo e logs na gestão; Formulações e Batidas na operação |
| Misturador | Operacional | Conexão, Carga, Descarga, Balança, Nota de Cocho e Configurações |
| Agricultura | Operacional | Apontamento, Marcação e Colheita de Frutas |
| Pecuária | Administração / Operacional | Dashboard na gestão; todas as rotinas e dependências na operação |
| Reprodução | Operacional | Seis entradas funcionais mapeadas |
| Gestão de Frota | Operacional | Abastecimento e Manutenção |
| Ordem de Serviço | Operacional | Minhas OS |
| Sincronização | Operacional | Fila offline já navegável |

## Esteira recomendada para o time mobile

### 1. Descoberta funcional

1. Selecionar um item `Mapeado` do catálogo.
2. Revisar a gravação e entrevistar um operador responsável pela rotina.
3. Fechar campos, validações, estados vazios e efeitos no restante do sistema.
4. Atualizar primeiro o catálogo e o protótipo; o mobile consome a decisão consolidada.

### 2. Contrato e risco

1. Definir DTO, permissões e escopo da fazenda no backend.
2. Identificar se o fluxo é offline e qual entidade entra na fila de sincronização.
3. Para hardware, executar um spike isolado de permissão, conexão, perda de sinal e retomada.
4. Registrar conflitos e estratégia de idempotência antes de liberar escrita.

### 3. Construção vertical

1. Reutilizar os componentes equivalentes do catálogo mobile.
2. Implementar uma fatia completa: lista/estado vazio → formulário → validação → sucesso → sync.
3. Respeitar o perfil na rota e também na autorização do backend; ocultar menu não é RBAC.
4. Instrumentar eventos mínimos: abertura, início, erro, salvamento local e sincronização.

### 4. Aceite

Uma funcionalidade só muda de `Mapeado` para `Pronto` quando possui:

- responsável e rota definidos;
- campos e validações aprovados por alguém do domínio;
- estados loading, vazio, erro, offline e sucesso quando aplicáveis;
- proteção de perfil e fazenda no frontend e no contrato;
- acessibilidade de toque, foco e rótulos;
- teste de sincronização e retomada quando houver escrita offline;
- teste em dispositivo real quando houver Bluetooth, RFID, câmera, localização ou balança;
- documentação de efeitos (estoque, financeiro, animal, nota fiscal ou ordem de serviço).

## Ordem sugerida de evolução

1. **Onda A — alto uso, baixo risco (concluída no frontend):** Áreas, Formulações, Batidas,
   Apontamento e Frota.
2. **Onda B — pecuária sem hardware:** Lotes, Animal, Transferência de Lote/Área, Sanitário,
   Desmama, Pastagens e Reprodução.
3. **Onda C — hardware:** Conexão, Balança, RFID, Scanner SISBOV, Localizar Animal e Perdas.
4. **Onda D — supervisão e auditoria:** consultas reais, processamentos e exportação de logs.
5. **Onda E — endurecimento:** RBAC real, telemetria, testes automatizados e paridade Flutter.
