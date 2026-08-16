import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';
import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(AppThemeVariant.light),
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('MappedFeatureScreen — Onda A', () {
    test('os seis contratos têm lista, campos e ação de criação', () {
      const ids = {
        'cadastrar-area',
        'formulacoes',
        'batidas',
        'apontamento',
        'abastecimentos',
        'manutencao-frota',
      };

      for (final id in ids) {
        final feature = featureById(id);
        expect(feature, isNotNull, reason: id);
        expect(feature?.profile, FeatureProfile.operational, reason: id);
        expect(feature?.status, FeatureStatus.ready, reason: id);
        expect(feature?.listMode, isTrue, reason: id);
        expect(feature?.fields, isNotEmpty, reason: id);
        expect(feature?.createAction, isNotEmpty, reason: id);
      }
    });

    testWidgets('Áreas percorre lista, validação, sucesso e novo registro', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'cadastrar-area',
            profile: FeatureProfile.operational,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registros'), findsOneWidget);
      expect(find.text('Adicionar área'), findsOneWidget);

      await tester.tap(find.text('Adicionar área'));
      await tester.pumpAndSettle();

      expect(find.text('Dados do registro'), findsOneWidget);
      expect(find.text('Nome da área'), findsOneWidget);
      expect(find.text('Área total'), findsOneWidget);

      await tester.ensureVisible(find.text('Salvar área'));
      await tester.tap(find.text('Salvar área'));
      await tester.pumpAndSettle();

      expect(find.text('Campo obrigatório.'), findsNWidgets(5));
      expect(tester.takeException(), isNull);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Talhão 03');
      await tester.enterText(textFields.at(1), '24');
      await tester.enterText(textFields.at(2), 'Setor Sul');

      final selects = find.byType(DropdownButtonFormField<String>);
      await tester.tap(selects.at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agricultura').last);
      await tester.pumpAndSettle();

      await tester.tap(selects.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ha').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Salvar área'));
      await tester.tap(find.text('Salvar área'));
      await tester.pumpAndSettle();

      expect(find.text('Talhão 03 salvo'), findsOneWidget);
      expect(find.text('Ver registros'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Ver registros'));
      await tester.pumpAndSettle();

      expect(find.text('Talhão 03'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('consulta administrativa lê registro criado no operacional', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(prototypeRecordsProvider.notifier)
          .addRecord(
            featureId: 'cadastrar-area',
            title: 'Talhão Integração',
            description: 'Agricultura · 24 ha',
            status: PrototypeRecordStatus.active,
            details: const {'Localização': 'Setor Sul'},
          );

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'areas',
            profile: FeatureProfile.administration,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Talhão Integração'), findsOneWidget);
      expect(find.text('Agricultura · 24 ha'), findsOneWidget);
      expect(find.text('Novo registro'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
