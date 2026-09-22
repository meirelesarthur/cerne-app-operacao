import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/screens/fazendas_home.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../../../support/test_viewport.dart';

void main() {
  group('FazendasHome', () {
    testWidgets('mostra os lançamentos de campo (único perfil do app)', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(prototypeSessionProvider.notifier)
          .loginAs(UserAccessProfile.operational);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(AppThemeVariant.light),
            home: const Scaffold(body: FazendasHome()),
          ),
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
