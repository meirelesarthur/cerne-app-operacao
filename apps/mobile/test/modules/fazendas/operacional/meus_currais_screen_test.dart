import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/meus_currais_screen.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../../../support/router_test_harness.dart';
import '../../../support/test_viewport.dart';

Widget _wrap(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: Scaffold(body: child),
  ),
);

/// Regressão: as três ações rápidas apontavam para `campo/<id>` por simetria,
/// mas só `pesagem` existe nesse dispatcher — `sanitario` é resolvido pelo
/// motor genérico (`operacional/:featureId`) e `mortes` compartilha a rota
/// `campo/ciclo` com nascimentos. As outras duas caíam no fallback vazio de
/// `buildCampoFlow`, e o smoke test original não pegava porque não tocava
/// nesses botões. Este teste navega de verdade, pelo router real.
Future<void> _esperaDestinoReal(WidgetTester tester, String acao) async {
  await setTallSurface(tester, height: 2400);
  final harness = RouterTestHarness(profile: UserAccessProfile.operational);
  addTearDown(harness.dispose);

  harness.router.go('/fazendas/campo/meus-currais');
  await tester.pumpWidget(harness.buildApp());
  await tester.pumpAndSettle();

  await tester.tap(find.text(acao).first);
  await tester.pumpAndSettle();

  expect(
    find.text('Lançamento'),
    findsNothing,
    reason: '"$acao" caiu no fallback vazio de buildCampoFlow',
  );
  expect(tester.takeException(), isNull, reason: acao);
}

void main() {
  group('MeusCurraisScreen', () {
    testWidgets('renderiza sem exceção e mostra o aviso de ordem pendente', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const MeusCurraisScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Meus currais'), findsOneWidget);
      expect(find.text('Curral 01'), findsOneWidget);
      expect(
        find.text('1 ordem pendente do ADM para este curral'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('altera a situação do curral pelo bottom sheet', (
      tester,
    ) async {
      await setTallSurface(tester);
      await tester.pumpWidget(_wrap(const MeusCurraisScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alterar situação').first);
      await tester.pumpAndSettle();

      expect(find.text('Salvar situação'), findsOneWidget);
      await tester.tap(find.text('Salvar situação'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('ação rápida "Pesagem" abre uma tela real', (tester) async {
      await _esperaDestinoReal(tester, 'Pesagem');
    });

    testWidgets('ação rápida "Sanitário" abre uma tela real', (tester) async {
      await _esperaDestinoReal(tester, 'Sanitário');
    });

    testWidgets('ação rápida "Óbito" abre uma tela real', (tester) async {
      await _esperaDestinoReal(tester, 'Óbito');
    });
  });
}
