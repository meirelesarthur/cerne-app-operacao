import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/shell/state/shell_store.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../helpers/app_icon_finder.dart';
import '../../support/router_test_harness.dart';

void main() {
  late RouterTestHarness harness;

  setUp(() {
    harness = RouterTestHarness(profile: UserAccessProfile.operational);
    addTearDown(harness.dispose);
    harness.router.go('/notificacoes');
  });

  group('NotificacoesPage', () {
    testWidgets('Novidades lista as não lidas agrupadas por dia', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Novidades'), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);
      expect(find.textContaining('Hoje, '), findsOneWidget);
      expect(find.byType(AppNotificationTile), findsNWidgets(3));
      expect(find.text('Pesagem registrada'), findsOneWidget);
      expect(find.text('Nova ordem de serviço atribuída'), findsOneWidget);
      // Lidas ficam só no Histórico.
      expect(find.text('Novidade no aplicativo'), findsNothing);
      expect(find.text('Marcar lidas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Histórico mostra as lidas, sem "Marcar lidas"', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Histórico'));
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationTile), findsNWidgets(3));
      expect(find.text('Novidade no aplicativo'), findsOneWidget);
      expect(find.textContaining('Ontem, '), findsOneWidget);
      expect(find.text('Pesagem registrada'), findsNothing);
      expect(find.text('Marcar lidas'), findsNothing);
    });

    testWidgets('"Marcar lidas" esvazia Novidades', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Marcar lidas'));
      await tester.pumpAndSettle();

      expect(harness.container.read(shellStoreProvider).unreadCount, 0);
      expect(find.text('Você está em dia'), findsOneWidget);
      expect(find.text('Marcar lidas'), findsNothing);
    });

    testWidgets('em dia oferece o atalho para o Histórico', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Marcar lidas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver histórico de notificações'));
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationTile), findsWidgets);
      expect(find.text('Você está em dia'), findsNothing);
    });

    testWidgets('tocar marca como lida e abre a tela de origem', (
      tester,
    ) async {
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nova ordem de serviço atribuída'));
      await tester.pumpAndSettle();

      final n2 = harness.container
          .read(shellStoreProvider)
          .notifications
          .firstWhere((n) => n.id == 'n2');
      expect(n2.read, isTrue);
      expect(find.text('Ordens de serviço'), findsWidgets);
    });

    testWidgets('"Voltar" sem tela anterior leva à tela Início', (
      tester,
    ) async {
      // Aberta com `go` (link direto): não há pilha para onde voltar.
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(findAppIcon(AppIcons.arrowLeft));
      await tester.pumpAndSettle();

      expect(
        harness.router.routerDelegate.currentConfiguration.uri.path,
        '/fazendas/operacional',
      );
    });

    testWidgets('aberta pelo sino, "Voltar" retorna à tela anterior', (
      tester,
    ) async {
      harness.router.go('/fazendas/operacional');
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(findAppIcon(AppIcons.bell));
      await tester.pumpAndSettle();
      expect(find.byType(AppNotificationTile), findsWidgets);

      await tester.tap(findAppIcon(AppIcons.arrowLeft));
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationTile), findsNothing);
      expect(find.text('Ver todas'), findsOneWidget);
    });
  });
}
