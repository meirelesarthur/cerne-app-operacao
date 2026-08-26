import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/batelada_flow.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('BateladaFlow', () {
    testWidgets('renderiza sem exceção', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const BateladaFlow()));
      await tester.pumpAndSettle();

      expect(find.text('Produzir batelada'), findsWidgets);
      expect(find.text('Dieta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('escolher a dieta revela os ingredientes escalados', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const BateladaFlow()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dieta Adaptação').last);
      await tester.pumpAndSettle();

      expect(find.text('Ingredientes'), findsOneWidget);
      expect(find.text('Silagem de Milho'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem preencher, valida os campos obrigatórios ao registrar', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: BateladaFlow()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar batelada'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione a dieta.'), findsOneWidget);
      expect(container.read(shellStoreProvider).isOnline, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
