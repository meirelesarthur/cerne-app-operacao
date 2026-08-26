import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';

import '../../../support/router_test_harness.dart';
import '../../../support/test_viewport.dart';

/// Regressão do mesmo padrão de bug corrigido em `MeusCurraisScreen`: tocar
/// numa função do grupo usava `context.go()` para uma rota-irmã fora da
/// linhagem de `GroupFeaturesScreen` — o voltar do sistema pulava direto para
/// a central do perfil, perdendo o contexto de "estava navegando o grupo
/// Pecuária". `context.push()` mantém a tela de grupo na pilha.
void main() {
  group('GroupFeaturesScreen', () {
    testWidgets(
      'voltar a partir de uma função com existingRoute retorna à listagem do grupo',
      (tester) async {
        await setTallSurface(tester, height: 2400);
        final harness = RouterTestHarness(
          profile: UserAccessProfile.operational,
        );
        addTearDown(harness.dispose);

        harness.router.go('/fazendas/operacional/grupo/pecuaria');
        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pesagens'));
        await tester.pumpAndSettle();

        expect(harness.router.canPop(), isTrue);

        harness.router.pop();
        await tester.pumpAndSettle();

        expect(find.textContaining('neste módulo'), findsOneWidget);
        expect(find.text('Pesagens'), findsOneWidget);
      },
    );
  });
}
