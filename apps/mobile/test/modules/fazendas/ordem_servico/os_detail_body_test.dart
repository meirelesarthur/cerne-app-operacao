import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/mocks.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/models.dart';
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

  Future<void> pumpOs(WidgetTester tester, OrdemServico os) =>
      tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(AppThemeVariant.light),
          home: Scaffold(
            body: SingleChildScrollView(child: OsDetailBody(os: os)),
          ),
        ),
      );

  Future<void> abrir(WidgetTester tester, String texto) async {
    // Só linhas tocáveis: "João Oliveira" também aparece como responsável.
    final alvo = find
        .descendant(of: find.byType(InkWell), matching: find.text(texto))
        .first;
    await tester.ensureVisible(alvo);
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  testWidgets('cada insumo abre a dock com os campos da aba do WEB', (
    tester,
  ) async {
    final insumo = os.insumos.first;
    await pumpOs(tester, os);
    await abrir(tester, insumo.produto);

    for (final rotulo in [
      'Un. medida',
      'Estoque',
      'Qtd/ha',
      'Qtd total',
      'Armazém de insumos',
    ]) {
      expect(find.text(rotulo), findsOneWidget, reason: rotulo);
    }
    expect(find.text(os.armazemInsumos!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('produção lista o que o serviço gera e abre o detalhe', (
    tester,
  ) async {
    final comProducao = ordensServico.firstWhere((o) => o.producao.isNotEmpty);
    final item = comProducao.producao.first;
    await pumpOs(tester, comProducao);
    await abrir(tester, item.produto);

    expect(find.text('Qtde'), findsOneWidget);
    expect(find.text('Armazém de produção'), findsOneWidget);
    expect(find.text(comProducao.armazemProducao!), findsOneWidget);
    expect(find.text(item.observacao!), findsOneWidget);
  });

  testWidgets('sem produção, a seção avisa em vez de sumir', (tester) async {
    await pumpOs(tester, os);
    expect(os.producao, isEmpty);
    expect(find.text('Este serviço não gera produção.'), findsOneWidget);
  });

  testWidgets('mão de obra, máquina, EPI e evidência abrem o detalhe', (
    tester,
  ) async {
    await pumpOs(tester, os);
    Future<void> fechar() async {
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
    }

    await abrir(tester, os.maoDeObra.first.nome);
    expect(find.text('Função'), findsOneWidget);
    await fechar();

    await abrir(tester, os.maquinas.first.nome);
    expect(find.text('Uso previsto'), findsOneWidget);
    await fechar();

    await abrir(tester, os.epis.first.nome);
    expect(find.text('CA'), findsOneWidget);
    await fechar();

    final ev = os.evidencias.first;
    await abrir(tester, ev.legenda);
    expect(find.text('Registrado por'), findsOneWidget);
    expect(find.text(ev.observacao!), findsOneWidget);
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
