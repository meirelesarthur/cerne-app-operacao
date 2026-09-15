import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../helpers/cta_finder.dart';
import '../../../support/test_viewport.dart';

Widget _wrap(ProviderContainer container, String featureId) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(AppThemeVariant.light),
        home: Scaffold(
          body: MappedFeatureScreen(
            featureId: featureId,
            profile: FeatureProfile.operational,
          ),
        ),
      ),
    );

void _fillRequiredFields(
  FunctionalJourneyController controller,
  FeatureDefinition feature,
) {
  for (final field in feature.fields.where((field) => field.isRequired)) {
    controller.setValue(
      field.id,
      field.options.isNotEmpty
          ? field.options.first
          : field.type == FeatureFieldType.number
          ? '1'
          : field.type == FeatureFieldType.date
          ? '2026-08-16'
          : 'Dado de teste',
    );
  }
}

void main() {
  group('MappedFeatureScreen — Onda C', () {
    test(
      'os seis contratos bloqueiam sem hardware e concluem com simulação',
      () {
        const ids = {
          'conexao-aparelhos',
          'conexao-aparelhos-pecuaria',
          'transferencia-animal',
          'scanner-sisbov',
          'perdas',
          'localizar-animal',
        };

        for (final id in ids) {
          final feature = featureById(id)!;
          final controller = FunctionalJourneyController(feature)..startForm();
          _fillRequiredFields(controller, feature);

          final target = feature.simulationTargetField ?? '_hardware';
          // fidelidade-esteira (onda 13): `transferencia-animal` empilha a
          // captura numa coleção (`simulationCollectionName`) em vez de um
          // campo escalar — "sem hardware" aqui é a coleção vazia, e
          // "concluir com simulação" é ter ao menos um item capturado.
          final collectionName = feature.simulationCollectionName;
          if (collectionName != null) {
            // `destino-unico` = "Não" evita o `novo-lote` de cabeçalho
            // (XOR contra o `novo-lote` por item, que não é validado no
            // `submit()` — só no formulário de item da coleção).
            controller.setValue('destino-unico', 'Não');
            expect(controller.submit(), isNull, reason: id);
            expect(
              featureSimulationError(feature, controller.form),
              isNotNull,
              reason: id,
            );

            controller.addGroupItem(collectionName, {target: 'BRINCO 2048'});
            expect(controller.submit(), isNotNull, reason: id);
            expect(controller.mode, FunctionalJourneyMode.success, reason: id);
            continue;
          }

          controller.setValue(target, '');
          expect(controller.submit(), isNull, reason: id);
          expect(
            featureSimulationError(feature, controller.form),
            isNotNull,
            reason: id,
          );

          controller.setValue(target, 'Captura simulada');
          expect(controller.submit(), isNotNull, reason: id);
          expect(controller.mode, FunctionalJourneyMode.success, reason: id);
        }
      },
    );

    testWidgets('Bluetooth exige descoberta antes de conectar e concluir', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container, 'conexao-aparelhos'));
      await tester.pumpAndSettle();

      expect(find.byType(AppHardwareSimulator), findsOneWidget);
      await tester.tap(findCta('Concluir configuração'));
      await tester.pump();
      expect(find.text('Conclua a simulação para continuar.'), findsOneWidget);

      await tester.tap(find.text('Buscar dispositivos'));
      await tester.pump();
      expect(find.text('Balança BT-42'), findsOneWidget);
      expect(find.text('Leitor RFID CERNE'), findsOneWidget);

      await tester.tap(find.text('Conectar dispositivos'));
      await tester.pump();
      expect(find.textContaining('Balança BT-42 +'), findsOneWidget);

      await tester.tap(findCta('Concluir configuração'));
      await tester.pumpAndSettle();
      expect(find.text('Aparelhos conectados no protótipo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RFID oferece alternativa manual no próprio fluxo', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container, 'transferencia-animal'));
      await tester.pumpAndSettle();

      // fidelidade-esteira: CTA no rodapé flutuante fixo, rótulo em caixa alta.
      await tester.tap(find.text('NOVA TRANSFERÊNCIA DE ANIMAL'));
      await tester.pumpAndSettle();
      expect(find.byType(AppHardwareSimulator), findsOneWidget);
      expect(find.text('ou informe manualmente'), findsOneWidget);

      await tester.tap(findCta('Salvar transferência'));
      await tester.pump();
      // fidelidade-esteira (onda 13): a captura empilha numa coleção — sem
      // nenhum animal capturado, a mensagem é a de coleção vazia, não mais a
      // de campo escalar sem valor.
      expect(
        find.text('Capture ao menos um animal para continuar.'),
        findsOneWidget,
      );

      // multiCapture: digitar não confirma a leitura sozinho — precisa do
      // botão "Adicionar leitura manual" ao lado do campo.
      await tester.enterText(find.byType(TextFormField).first, 'BRINCO 2048');
      await tester.pump();
      expect(
        find.text('Capture ao menos um animal para continuar.'),
        findsOneWidget,
      );

      await tester.tap(find.bySemanticsLabel('Adicionar leitura manual'));
      await tester.pump();
      expect(
        find.text('Capture ao menos um animal para continuar.'),
        findsNothing,
      );
      expect(find.text('BRINCO 2048'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scanner SISBOV apresenta enquadramento, captura e sucesso', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container, 'scanner-sisbov'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label ==
                  'Área simulada de enquadramento da câmera',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Simular captura'));
      await tester.pump();
      expect(find.textContaining('SISBOV BR'), findsOneWidget);

      // `findCta` (não `find.text`) porque este é o CTA da `AppActionBar` —
      // renderiza em caixa alta. Ver docs/ESTEIRA-FIDELIDADE-CONTRATO.md.
      await tester.tap(findCta('Usar identificação capturada'));
      await tester.pumpAndSettle();
      expect(find.text('Identificação SISBOV capturada'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
