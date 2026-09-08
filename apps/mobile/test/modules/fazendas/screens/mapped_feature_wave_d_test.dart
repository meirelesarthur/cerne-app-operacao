import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(
  ProviderContainer container, {
  required String featureId,
  required FeatureProfile profile,
}) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(
      body: MappedFeatureScreen(featureId: featureId, profile: profile),
    ),
  ),
);

void _fillRequiredFields(
  FunctionalJourneyController controller,
  FeatureDefinition feature,
) {
  for (final field in feature.fields.where((field) => field.isRequired)) {
    controller.setValue(
      field.id,
      field.options.isNotEmpty
          ? field.options.first
          : field.type == FeatureFieldType.number
          ? '1'
          : field.type == FeatureFieldType.date
          ? '2026-08-16'
          : 'Dado de teste',
    );
  }
}

void main() {
  group('MappedFeatureScreen — Onda D', () {
    // banco-real (onda 1 — fronteira operação/gestão): `colheita-frutas` saiu
    // do catálogo (fora de escopo) e `compras-animais` virou consulta
    // administrativa somente leitura (`readOnly: true`) — nenhuma das duas
    // tem mais caminho de UI até este formulário (`canCreate` em
    // `mapped_feature_screen.dart` já bloqueia `compras-animais`; a outra nem
    // existe mais). Sobram seis formulários. Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    // banco-real (onda 3 — duplicações): `carga`, `descarga` e `nota-cocho`
    // gravam na mesma tabela real que `producao-batelada`, `trato-diario` e
    // `leitura-cocho-confinamento` do Confinamento (ver
    // docs/ajustes-banco-real/01-mapa-catalogo-banco.md) — viraram
    // redirecionamento (`existingRoute`) para a tela nova, sem `fields`
    // próprios. 6-3=3 formulários. A cobertura de validação que as três
    // tinham aqui não se perde: ela já existe nos testes das telas de
    // Confinamento equivalentes (batelada/trato-diário/leitura de cocho). Ver
    // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 3.
    test('os três formulários finais percorrem validação e sucesso', () {
      const ids = {'configuracoes-misturador', 'marcacao', 'apartacao'};

      for (final id in ids) {
        final feature = featureById(id)!;
        final controller = FunctionalJourneyController(feature)..startForm();

        expect(controller.submit(), isNull, reason: id);
        _fillRequiredFields(controller, feature);
        expect(controller.submit(), isNotNull, reason: id);
        expect(controller.mode, FunctionalJourneyMode.success, reason: id);
      }
    });

    test('todas as 47 funcionalidades Ready têm destino executável', () {
      final ready = allFeatures.where(
        (feature) => feature.status == FeatureStatus.ready,
      );

      // confinamento (onda 1): +5 funcionalidades operacionais Ready — ver
      // functional_catalog_test.dart.
      // banco-real (onda 1 — fronteira operação/gestão): `colheita-frutas`
      // (ready) saiu do escopo — 52-1=51. Ver
      // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
      // Auditoria dos painéis: `painel-pecuario` (ready) fundiu em
      // `painel-financeiro` — 51-1=50. Ver docs/ESTEIRA-DASHBOARDS-ADM.md.
      // confinamento (onda 2): `carga`, `descarga` e `nota-cocho` (ready)
      // saíram do catálogo — 50-3=47. reprodução: `lotes-reproducao`
      // (ready) saiu do catálogo — 47-1=46 (`pastagens` continua ready,
      // só muda de perfil). fidelidade-campos (onda 4): `lotes-reproducao`
      // voltou como consulta administrativa — 46+1=47. Ver
      // functional_catalog_test.dart.
      expect(ready, hasLength(47));
      for (final feature in ready) {
        final handledByMappedScreen =
            feature.auditExport != null ||
            feature.listMode ||
            feature.fields.isNotEmpty ||
            feature.sections.isNotEmpty;
        expect(
          feature.existingRoute != null || handledByMappedScreen,
          isTrue,
          reason: feature.id,
        );
      }
    });

    testWidgets('não expõe premissas internas na abertura do Sanitário', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'sanitario',
          profile: FeatureProfile.operational,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Criar um manejo sanitário por responsável e lote.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'A fonte mostrou apenas a primeira etapa; os campos complementares são premissas do protótipo frontend.',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('cadastros começam populados e permitem busca com paginação', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'sanitario',
          profile: FeatureProfile.operational,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('6'), findsOneWidget);
      expect(find.text('Sanitário · Registro 1'), findsOneWidget);
      expect(find.text('Sanitário · Registro 6'), findsNothing);
      expect(find.byType(AppPagination), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Próxima página'));
      await tester.pumpAndSettle();
      expect(find.text('Sanitário · Registro 6'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Registro 3');
      await tester.pumpAndSettle();
      expect(find.text('Sanitário · Registro 3'), findsOneWidget);
      expect(find.text('Sanitário · Registro 6'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('saldo de estoque abre dados demonstrativos e detalhe', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'saldo-estoque',
          profile: FeatureProfile.administration,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda'), findsOneWidget);
      expect(find.text('Sal Mineral'), findsOneWidget);
      expect(find.text('Vacina Aftosa'), findsOneWidget);
      expect(find.text('Novo registro'), findsNothing);

      await tester.tap(find.text('Ração Engorda'));
      await tester.pumpAndSettle();
      expect(find.text('12.400 kg'), findsWidgets);
      expect(find.text('1.000 kg'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('auditoria alterna para JSON e prepara três registros', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'exportar-log-estoque',
          profile: FeatureProfile.administration,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preparar arquivo de auditoria'), findsOneWidget);
      expect(find.text('Baixar CSV'), findsOneWidget);

      final selects = find.byType(DropdownButtonFormField<String>);
      await tester.tap(selects.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('JSON').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Baixar JSON'));
      await tester.pump();

      expect(
        find.text('auditoria-estoque-30-dias.json preparado com 3 registros.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Minhas OS é consulta operacional sem ação de criação', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        _wrap(
          container,
          featureId: 'minhas-os',
          profile: FeatureProfile.operational,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('OS #1048'), findsOneWidget);
      expect(find.textContaining('OS #1039'), findsOneWidget);
      expect(find.text('Novo registro'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
