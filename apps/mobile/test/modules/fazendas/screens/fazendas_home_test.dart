import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/fazendas_home.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';
import 'package:cerne_app/modules/fazendas/types.dart';

import '../../../support/test_viewport.dart';

void main() {
  group('FazendasHome', () {
    testWidgets('visão gerencial mostra resumo da safra e atividades recentes', (tester) async {
      await setTallSurface(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: const Scaffold(body: FazendasHome())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resumo da safra'), findsOneWidget);
      expect(find.text('Atividades recentes'), findsOneWidget);
      expect(find.text('Crédito pré-aprovado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('visão campo mostra os lançamentos de campo', (tester) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(fazendasStoreProvider.notifier).setView(FarmView.campo);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: const Scaffold(body: FazendasHome())),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Lançamentos de campo'), findsOneWidget);
      expect(find.text('Pesagem'), findsOneWidget);
      expect(find.text('Fila de sincronização'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
