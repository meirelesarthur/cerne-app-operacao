import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/admin/dash_uso.dart';
import 'package:cerne_app/shell/state/shell_store.dart';

import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

void main() {
  group('DashUso', () {
    testWidgets(
      'renderiza sem exceção e mostra a fazenda expandida por padrão',
      (tester) async {
        await setTallSurface(tester);
        await tester.pumpWidget(_wrap(const DashUso()));
        await tester.pumpAndSettle();

        expect(find.text('Análise de Uso'), findsWidgets);
        expect(find.text('Acesso restrito'), findsOneWidget);
        expect(find.text('Fazenda São Pedro'), findsOneWidget);
        expect(find.text('João Silva'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mostra estado de erro com retry quando offline', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(shellStoreProvider.notifier).setOnline(false);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: DashUso()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Indisponível offline'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
