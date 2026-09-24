import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/mocks.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/widgets.dart';

void main() {
  final os = ordensServico.firstWhere((o) => o.id == 'os-2198');

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(AppThemeVariant.light),
      home: Scaffold(
        body: SingleChildScrollView(child: OsDetailBody(os: os)),
      ),
    ),
  );

  testWidgets('abre em Detalhes, com os agrupadores e sem o histórico', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Serviço'), findsOneWidget);
    expect(find.text('Solicitação e autorização'), findsOneWidget);
    expect(find.text('Instruções de segurança'), findsOneWidget);
    expect(find.text('OS solicitada'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a aba Histórico mostra os eventos, o mais recente primeiro', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Histórico (${os.historico.length})'));
    await tester.pumpAndSettle();

    expect(find.text('Solicitação e autorização'), findsNothing);
    final recente = tester.getTopLeft(find.text(os.historico.last.acao));
    final antigo = tester.getTopLeft(find.text(os.historico.first.acao));
    expect(recente.dy, lessThan(antigo.dy));
  });

  testWidgets('tocar num evento abre a dock com o registro completo', (
    tester,
  ) async {
    final os = ordensServico.firstWhere(
      (o) => o.historico.any((e) => e.observacao != null),
    );
    final evento = os.historico.lastWhere((e) => e.observacao != null);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppThemeVariant.light),
        home: Scaffold(
          body: SingleChildScrollView(child: OsDetailBody(os: os)),
        ),
      ),
    );
    await tester.tap(find.text('Histórico (${os.historico.length})'));
    await tester.pumpAndSettle();

    final linha = find.text('${evento.autor} · ${evento.observacao}');
    await tester.ensureVisible(linha);
    await tester.tap(linha);
    await tester.pumpAndSettle();

    expect(find.text('Registrado por'), findsOneWidget);
    expect(find.text('Observação'), findsOneWidget);
    expect(find.text(evento.observacao!), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Registrado por'), findsNothing);
  });
}
