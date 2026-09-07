import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';

void main() {
  group('catálogo funcional AGRO365', () {
    test('preserva as 52 funcionalidades e a divisão por perfil', () {
      // banco-real (onda 2): +1 funcionalidade administrativa ("Produtos" —
      // consulta ao catálogo real de products, 543.983 linhas no dump gbcerne).
      // Ver docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md.
      // confinamento (onda 1): +5 funcionalidades operacionais do submódulo de
      // Confinamento (Meus currais, Produzir batelada, Trato diário, Leitura
      // de cocho, Ordens pendentes) — ver docs/ESTEIRA-PERFIS-AGRO365.md.
      // banco-real (onda 1 — fronteira operação/gestão): `vendas` e
      // `compras-animais` sobem do operacional para o administrativo (decisão
      // comercial/financeira, o ADM só visualiza) e `colheita-frutas` sai do
      // escopo — 13+2=15 administrativas, 46-2-1=43 operacionais, 15+43=58
      // no total. Ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
      // Auditoria dos painéis administrativos: `painel-pecuario` fundiu em
      // `painel-financeiro` (mesmo P&L; o bloco produtivo passou a ser servido
      // por `lotacao-currais`, onde há dado real) — 15-1=14 administrativas,
      // 14+43=57 no total. Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 2.
      // confinamento (onda 2): o Confinamento absorveu o que restava do
      // extinto grupo "Misturador" — `carga`, `descarga` e `balanca` deixaram
      // de existir como funcionalidades (a produção/distribuição de batelada
      // já é coberta por `producao-batelada`/`trato-diario`) e `nota-cocho`
      // saiu por ser duplicata exata de `leitura-cocho-confinamento` — 4
      // funcionalidades a menos: 43-4=39 operacionais, 14+39=53 no total.
      // reprodução (simplificação de grupo): `lotes-reproducao` saiu do
      // catálogo; Reprodução passa a ter só Acasalamento (ex-"Monta
      // natural") e Diagnóstico de gestação — 39-1=38 operacionais,
      // 14+38=52 no total.
      // `pastagens` sai do operacional e vira consulta administrativa
      // (fronteira operação/gestão, mesmo critério de `vendas`/
      // `compras-animais`) — 38-1=37 operacionais, 14+1=15
      // administrativas, 15+37=52 no total (sem mudança na soma).
      expect(adminFeatures, hasLength(15));
      expect(operationalFeatures, hasLength(37));
      expect(allFeatures, hasLength(52));

      expect(
        adminFeatures.every(
          (feature) => feature.profile == FeatureProfile.administration,
        ),
        isTrue,
      );
      expect(
        operationalFeatures.every(
          (feature) => feature.profile == FeatureProfile.operational,
        ),
        isTrue,
      );
    });

    test('mantém IDs únicos e permite consulta pelo identificador', () {
      final ids = allFeatures.map((feature) => feature.id).toSet();

      expect(ids, hasLength(allFeatures.length));
      for (final feature in allFeatures) {
        expect(featureById(feature.id), same(feature));
      }
      expect(featureById('funcionalidade-inexistente'), isNull);
    });

    test('preserva a maturidade 46 ready, 6 hardware e zero mapped', () {
      // banco-real (onda 1 — fronteira operação/gestão): `colheita-frutas`
      // (ready) saiu do escopo — 52-1=51. Auditoria dos painéis:
      // `painel-pecuario` (ready) fundiu em `painel-financeiro` — 51-1=50.
      // confinamento (onda 2): `carga`, `descarga` e `nota-cocho` (ready)
      // saíram do catálogo — 50-3=47; `balanca` (hardware) saiu junto — 7-1=6.
      // reprodução: `lotes-reproducao` (ready) saiu do catálogo — 47-1=46.
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.ready),
        hasLength(46),
      );
      expect(
        allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ),
        hasLength(6),
      );
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.mapped),
        isEmpty,
      );
    });

    test('preserva as invariantes estruturais do catálogo congelado', () {
      final fields = allFeatures.expand((feature) => feature.fields).toList();

      // banco-real (onda 1): +11 campos opcionais para alinhar o catálogo ao
      // schema real do dump gbcerne. banco-real (produto-busca): +4 campos em
      // consulta-produtos (a única criação em campo livre; +3 obrigatórios)
      // para virar a fonte de busca dos demais campos "produto". Ver
      // docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md.
      // banco-real (onda 1 — fronteira operação/gestão): `colheita-frutas`
      // saiu do catálogo com seus 4 campos (todos obrigatórios) — 183-4=179
      // campos; 159-4=155 obrigatórios. `vendas` ganhou `listMode` ao virar
      // consulta pelo motor genérico sem `existingRoute` (que saiu por
      // apontar para uma rota `/fazendas/campo/*` bloqueada para
      // administração) — 33+1=34 com `listMode`, 18-1=17 com
      // `existingRoute`. `colheita-frutas` saiu com sua 1 seção — 15-1=14.
      // Ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
      // banco-real (onda 2 — apontamento): -3 campos (`prazo`,
      // `resultado-esperado`, `criterio-sucesso`, nenhum obrigatório) e +4
      // campos (`data-apontamento` obrigatório, `descricao`,
      // `cultura-variedade`, `safra` opcionais) — 179-3+4=180 campos;
      // 155+1=156 obrigatórios. `apontamento` perdeu 2 seções
      // (`Abastecimentos` e `Produção`) — 14-2=12. Ver
      // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 2.
      // banco-real (onda 3 — duplicações): `carga` (6 campos, 6
      // obrigatórios), `descarga` (6 campos, 6 obrigatórios) e `nota-cocho`
      // (5 campos, 4 obrigatórios) viraram redirecionamento —
      // 180-17=163 campos; 156-16=140 obrigatórios. As três ganharam
      // `existingRoute` e perderam `listMode` — 34-3=31 com `listMode`;
      // 17+3=20 com `existingRoute`. Ver
      // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 3.
      // confinamento (onda 2): `carga`, `descarga` e `nota-cocho` saíram do
      // catálogo (já não tinham `fields`/`listMode` próprios, então essas
      // contagens não mudam) — cada uma levou seu `existingRoute`: 19-3=16.
      // `balanca` saiu com suas 2 capabilities (`Bluetooth`, `Balança`):
      // 25-2=23.
      // banco-real (onda 4 — apontamento): fonte real é `appropriations` +
      // tabelas filhas, não `service_orders` — motor genérico trocado por
      // fluxo dedicado (`ApontamentoFlow`). Saem os 12 campos (8
      // obrigatórios) e as 4 seções do `apontamento` — 163-12=151 campos;
      // 140-8=132 obrigatórios; 12-4=8 seções. Perde `listMode` e ganha
      // `existingRoute` — 31-1=30 com `listMode`; 16+1=17 com
      // `existingRoute`. Ver docs/ajustes-banco-real/04-apontamento-appropriations.md.
      // reprodução: `lotes-reproducao` saiu com seus 5 campos (5
      // obrigatórios) e seu `listMode` — 151-5=146 campos; 132-5=127
      // obrigatórios; 30-1=29 com `listMode`.
      // `pastagens` muda de perfil mas mantém os mesmos 3 campos (3
      // obrigatórios) e `listMode` — sem mudança nessas contagens; perde
      // as 3 seções (eram do fluxo de criação, que não existe mais numa
      // consulta somente leitura) — 8-3=5.
      expect(fields, hasLength(146));
      expect(fields.where((field) => field.isRequired), hasLength(127));
      expect(allFeatures.where((feature) => feature.listMode), hasLength(29));
      expect(
        allFeatures.where((feature) => feature.existingRoute != null),
        hasLength(17),
      );
      expect(allFeatures.expand((feature) => feature.sections), hasLength(5));
      expect(
        allFeatures.expand((feature) => feature.capabilities),
        hasLength(23),
      );
    });

    test('referências internas apontam para contratos e campos existentes', () {
      final featuresById = {
        for (final feature in allFeatures) feature.id: feature,
      };

      for (final feature in allFeatures) {
        final fieldIds = feature.fields.map((field) => field.id).toSet();
        expect(
          fieldIds,
          hasLength(feature.fields.length),
          reason: 'IDs de campo duplicados em ${feature.id}',
        );

        final dataSourceId = feature.dataSourceId;
        if (dataSourceId != null) {
          expect(
            featuresById[dataSourceId]?.profile,
            FeatureProfile.operational,
            reason: 'Fonte operacional inválida em ${feature.id}',
          );
        }

        final recordTitleField = feature.recordTitleField;
        if (recordTitleField != null) {
          expect(
            fieldIds,
            contains(recordTitleField),
            reason: 'Título de registro inválido em ${feature.id}',
          );
        }

        for (final descriptionField in feature.recordDescriptionFields) {
          expect(
            fieldIds,
            contains(descriptionField),
            reason: 'Descrição de registro inválida em ${feature.id}',
          );
        }

        final simulationTargetField = feature.simulationTargetField;
        if (simulationTargetField != null) {
          expect(
            fieldIds,
            contains(simulationTargetField),
            reason: 'Campo-alvo da simulação inválido em ${feature.id}',
          );
        }
      }
    });

    test('todo item de hardware declara uma simulação frontend', () {
      final hardware = {
        for (final feature in allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ))
          feature.id: feature.simulation,
      };

      expect(hardware, {
        'conexao-aparelhos': HardwareSimulationKind.devices,
        'conexao-aparelhos-pecuaria': HardwareSimulationKind.devices,
        'transferencia-animal': HardwareSimulationKind.rfid,
        'scanner-sisbov': HardwareSimulationKind.scanner,
        'perdas': HardwareSimulationKind.rfid,
        'localizar-animal': HardwareSimulationKind.rfid,
      });
    });

    test('preserva consultas compartilhadas e exportações de auditoria', () {
      expect(featureById('areas')?.dataSourceId, 'cadastrar-area');
      // confinamento (onda 2): `carga`, `descarga`, `balanca` e `nota-cocho`
      // saíram do catálogo — o Confinamento absorveu o que restava do
      // Misturador. Ver comentário em `functional_catalog.dart`.
      expect(featureById('carga'), isNull);
      expect(featureById('descarga'), isNull);
      expect(featureById('balanca'), isNull);
      expect(featureById('nota-cocho'), isNull);
      expect(
        featureById('exportar-log-estoque')?.auditExport,
        AuditExportKind.estoque,
      );
      expect(
        featureById('exportar-log-pecuaria')?.auditExport,
        AuditExportKind.pecuaria,
      );
    });
  });
}
