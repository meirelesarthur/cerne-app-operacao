import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/operacional/sincronizacao_flow.dart';
import 'package:cerne_app/ui/ui.dart';

Widget _app({ProviderContainer? container}) => UncontrolledProviderScope(
  container: container ?? ProviderContainer(),
  child: MaterialApp(
    theme: buildAppTheme(AppThemeVariant.light),
    home: const Scaffold(body: SincronizacaoFlow()),
  ),
);

/// O percentual central do medidor é pintado em `CustomPaint` (não é um
/// `Text` widget) — lido pelas propriedades do `AppGauge`, não por
/// `find.text`.
AppGauge _gauge(WidgetTester tester) =>
    tester.widget<AppGauge>(find.byType(AppGauge));

/// Avança tempo suficiente para as 38 funcionalidades operacionais do
/// catálogo terminarem — um item por tique (180ms) — bombeando o widget em
/// vez de `pumpAndSettle`: o progresso roda em `Timer`, não em
/// `AnimationController`.
Future<void> _runSyncToEnd(WidgetTester tester) async {
  for (var i = 0; i < 45; i++) {
    await tester.pump(const Duration(milliseconds: 180));
  }
}

void main() {
  group('SincronizacaoFlow', () {
    testWidgets('lista os módulos operacionais do catálogo, recolhidos', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // Mesmos grupos e mesma ordem de `ResponsibilityWorkspace` — fonte
      // única (`operationalFeatures` + `groupOrder`).
      expect(find.text('Confinamento'), findsOneWidget);
      expect(find.text('Pecuária'), findsOneWidget);
      expect(find.text('Agricultura'), findsOneWidget);
      expect(find.text('Ordem de Serviço'), findsOneWidget);
      expect(find.text('Reprodução'), findsOneWidget);
      expect(find.text('Consultas'), findsOneWidget);
      expect(find.text('Gestão de Frota'), findsOneWidget);
      // Confinamento e Consultas têm 7 funcionalidades cada — ainda pendentes.
      expect(find.text('0/7'), findsNWidgets(2));
      // Recolhido: a funcionalidade interna não aparece antes de sincronizar.
      expect(find.text('Conexão de aparelhos'), findsNothing);
      expect(_gauge(tester).label, '0/38');
      expect(find.text('SINCRONIZAR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'módulo ativo expande e mostra as funcionalidades internas reais',
      (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        await tester.tap(find.text('SINCRONIZAR'));
        await tester.pump();

        // Confinamento é o primeiro módulo e vira ativo sozinho — mesmas 7
        // funcionalidades do catálogo (GroupFeaturesScreen mostra as
        // mesmas).
        expect(find.text('Conexão de aparelhos'), findsOneWidget);
        expect(find.text('Configurações'), findsOneWidget);
        expect(find.text('Meus currais'), findsOneWidget);
        expect(find.text('Produzir batelada'), findsOneWidget);
        expect(find.text('Trato diário'), findsOneWidget);
        expect(find.text('Leitura de cocho'), findsOneWidget);
        expect(find.text('Ordens pendentes'), findsOneWidget);

        await _runSyncToEnd(tester);
        await tester.pumpAndSettle();

        // Ao concluir, cada módulo fecha — nenhuma funcionalidade interna
        // fica visível por padrão.
        expect(find.text('Conexão de aparelhos'), findsNothing);
        expect(_gauge(tester).label, '38/38');
        expect(find.text('CONCLUÍDO'), findsOneWidget);
        expect(find.text('MÓDULOS SINCRONIZADOS'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'permite reabrir um módulo já concluído para conferir onde parou',
      (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();

        await tester.tap(find.text('SINCRONIZAR'));
        await _runSyncToEnd(tester);
        await tester.pumpAndSettle();

        expect(find.text('Conexão de aparelhos'), findsNothing);

        await tester.tap(find.text('Confinamento'));
        await tester.pumpAndSettle();

        expect(find.text('Conexão de aparelhos'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
