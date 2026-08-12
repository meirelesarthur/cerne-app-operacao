import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/components/view_switch.dart';
import 'package:cerne_app/modules/fazendas/state/fazendas_store.dart';
import 'package:cerne_app/modules/fazendas/types.dart';

void main() {
  group('ViewSwitch', () {
    testWidgets('alterna a visão da store ao tocar em "Campo"', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: buildAppTheme(AppThemeVariant.light), home: const Scaffold(body: ViewSwitch())),
        ),
      );

      expect(container.read(fazendasStoreProvider).view, FarmView.gerencial);

      await tester.tap(find.text('Campo'));
      await tester.pump();

      expect(container.read(fazendasStoreProvider).view, FarmView.campo);
      expect(tester.takeException(), isNull);
    });
  });
}
