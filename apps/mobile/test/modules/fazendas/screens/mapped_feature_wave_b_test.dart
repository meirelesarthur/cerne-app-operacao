import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';
import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';

import '../../../support/test_viewport.dart';

void main() {
  group('MappedFeatureScreen — Onda B', () {
    test('os 13 contratos de pecuária e reprodução estão executáveis', () {
      const ids = {
        'rebanho-inicial',
        'lote-animais',
        'registrar-animal',
        'transferencia-lote-area',
        'sanitario',
        'desmama',
        'pastagens',
        'estacao-monta',
        'lotes-reproducao',
        'material-reprodutivo',
        'protocolos-estacao',
        'monta-natural',
        'diagnostico-gestacao',
      };

      for (final id in ids) {
        final feature = featureById(id);
        expect(feature, isNotNull, reason: id);
        expect(feature?.profile, FeatureProfile.operational, reason: id);
        expect(feature?.status, FeatureStatus.ready, reason: id);
        expect(feature?.fields, isNotEmpty, reason: id);
        expect(feature?.primaryAction, isNotEmpty, reason: id);
      }
    });

    test(
      'estação de monta rejeita período invertido e salva como programada',
      () {
        final feature = featureById('estacao-monta')!;
        final controller = FunctionalJourneyController(feature)..startForm();

        for (final field in feature.fields.where((field) => field.isRequired)) {
          final value = field.options.isNotEmpty
              ? field.options.first
              : field.type == FeatureFieldType.number
              ? '1'
              : 'Dado de teste';
          controller.setValue(field.id, value);
        }
        controller
          ..setValue('nome', 'Estação 2026/2027')
          ..setValue('inicio', '2026-10-01')
          ..setValue('fim', '2026-01-31');

        expect(controller.submit(), isNull);
        expect(
          featureFieldError(feature, feature.fields[3], controller.form.values),
          'A data final deve ser posterior à data inicial.',
        );

        controller.setValue('fim', '2027-01-31');
        final draft = controller.submit();

        expect(draft?.title, 'Estação 2026/2027');
        expect(draft?.status, PrototypeRecordStatus.scheduled);
      },
    );

    testWidgets(
      'Pastagens permite adicionar itens aos três grupos vinculados',
      (tester) async {
        await setTallSurface(tester);
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: buildAppTheme(AppThemeVariant.light),
              home: const Scaffold(
                body: MappedFeatureScreen(
                  featureId: 'pastagens',
                  profile: FeatureProfile.operational,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Novo manejo de pastagem'));
        await tester.pumpAndSettle();

        expect(find.text('Itens vinculados'), findsOneWidget);
        expect(find.text('Insumos'), findsOneWidget);
        expect(find.text('Abastecimentos'), findsOneWidget);
        expect(find.text('Máquinas / Equipamentos'), findsOneWidget);

        await tester.tap(find.text('Adicionar').first);
        await tester.pump();

        expect(find.text('1 item(ns) adicionado(s)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
