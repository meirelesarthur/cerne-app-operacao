import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/app_theme.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/screens/mapped_feature_screen.dart';
import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';
import 'package:cerne_app/ui/ui.dart';

import '../../../helpers/cta_finder.dart';
import '../../../helpers/app_icon_finder.dart';
import '../../../support/test_viewport.dart';

/// Localiza o controle (`TextFormField`/`DropdownButtonFormField`) do
/// [AppFormField] pelo rótulo, não por índice posicional na árvore — um
/// índice cru quebra silenciosamente sempre que um campo novo é intercalado
/// no catálogo funcional.
Finder _fieldByLabel(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(AppFormField));

Future<void> _enterFieldText(
  WidgetTester tester,
  String label,
  String value,
) async {
  final input = find.descendant(
    of: _fieldByLabel(label),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(input, value);
}

Future<void> _selectFieldOption(
  WidgetTester tester,
  String label,
  String option,
) async {
  final dropdown = find.descendant(
    of: _fieldByLabel(label),
    matching: find.byType(DropdownButtonFormField<String>),
  );
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Widget _wrap(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(AppThemeVariant.light),
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('MappedFeatureScreen — Onda A', () {
    test('os cinco contratos têm lista, campos e ação de criação', () {
      // banco-real (onda 4): `apontamento` saiu do motor genérico — fluxo
      // dedicado (`ApontamentoFlow`) com fonte real (`appropriations`).
      const ids = {
        'cadastrar-area',
        'formulacoes',
        'batidas',
        'abastecimentos',
        'manutencao-frota',
      };

      for (final id in ids) {
        final feature = featureById(id);
        expect(feature, isNotNull, reason: id);
        expect(feature?.profile, FeatureProfile.operational, reason: id);
        expect(feature?.status, FeatureStatus.ready, reason: id);
        expect(feature?.listMode, isTrue, reason: id);
        expect(feature?.fields, isNotEmpty, reason: id);
        expect(feature?.createAction, isNotEmpty, reason: id);
      }
    });

    testWidgets('o topo segue o padrão: voltar à esquerda do título', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'cadastrar-area',
            profile: FeatureProfile.operational,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final back = tester.getRect(findAppIcon(AppIcons.arrowLeft));
      final title = tester.getRect(find.text('Áreas'));

      expect(back.right, lessThan(title.left));
      expect(back.top, lessThan(title.bottom));
      expect(back.bottom, greaterThan(title.top));

      // O padrão antigo era um botão fantasma rotulado, numa linha acima.
      expect(find.text('Voltar ao ambiente'), findsNothing);
    });

    testWidgets('o topo não mostra as chips de perfil e de status', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'cadastrar-area',
            profile: FeatureProfile.operational,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Operação'), findsNothing);
      expect(find.text('Funcional no protótipo'), findsNothing);
      expect(find.text('Áreas'), findsOneWidget);
    });

    // banco-real (onda 1 — fronteira operação/gestão): `cadastrar-area` virou
    // consulta (`readOnly: true`) — estrutura física da fazenda é cadastro
    // estruturante, não ação diária de campo. O round-trip completo de
    // criação (validação → sucesso → lista) que este teste cobria para
    // "Áreas" passou para `abastecimentos`, que continua criável; este teste
    // agora garante que a consulta somente leitura não oferece caminho para
    // o formulário. Ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
    testWidgets('Áreas é consulta somente leitura, sem ação de criação', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'cadastrar-area',
            profile: FeatureProfile.operational,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registros'), findsOneWidget);
      expect(find.text('Adicionar área'), findsNothing);
      // banco-real (correção de demonstrabilidade): `cadastrar-area` tem
      // amostra semeada em `prototype_records_store.dart` — a consulta não
      // pode ficar vazia para sempre só porque o app não cria mais registro
      // para esta rotina. Ver docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md.
      expect(find.text('Talhão 03'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Áreas mostra estado vazio honesto quando não há amostra sincronizada',
      (tester) async {
        await setTallSurface(tester);
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container.read(prototypeRecordsProvider.notifier).seed(const {});

        await tester.pumpWidget(
          _wrap(
            container,
            const MappedFeatureScreen(
              featureId: 'cadastrar-area',
              profile: FeatureProfile.operational,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
            'O cadastro desta rotina é feito no sistema web. Assim que '
            'sincronizar, os registros aparecem aqui.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Os registros operacionais desta sessão aparecerão aqui.'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Abastecimentos percorre lista, validação, sucesso e novo registro',
      (tester) async {
        await setTallSurface(tester);
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          _wrap(
            container,
            const MappedFeatureScreen(
              featureId: 'abastecimentos',
              profile: FeatureProfile.operational,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Registros'), findsOneWidget);
        expect(find.text('Novo abastecimento'), findsOneWidget);

        await tester.tap(find.text('Novo abastecimento'));
        await tester.pumpAndSettle();

        expect(find.text('Dados do registro'), findsOneWidget);
        expect(find.text('Veículo / equipamento'), findsOneWidget);
        expect(find.text('Quantidade (L)'), findsOneWidget);

        await tester.ensureVisible(findCta('Registrar abastecimento'));
        await tester.tap(findCta('Registrar abastecimento'));
        await tester.pumpAndSettle();

        // fidelidade-campos (onda 5): `items.*.measurement_uuid` é required
        // em `/supplies` e faltava — 7+1=8 obrigatórios. Ver
        // docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 5.
        expect(find.text('Campo obrigatório.'), findsNWidgets(8));
        expect(tester.takeException(), isNull);

        await _selectFieldOption(tester, 'Responsável', 'João Oliveira');
        await _enterFieldText(tester, 'Data', '2026-08-16');
        await _selectFieldOption(
          tester,
          'Veículo / equipamento',
          'Trator John Deere 6110',
        );
        await _selectFieldOption(tester, 'Combustível', 'Diesel S10');
        await _enterFieldText(tester, 'Quantidade (L)', '120');
        // O campo único "Hodômetro / horímetro" virou tipo + leitura: quem
        // anotava o número não dizia qual dos dois medidores era.
        await _selectFieldOption(tester, 'Tipo de medidor', 'Horímetro');
        await _enterFieldText(tester, 'Leitura do medidor', '5400');
        await _selectFieldOption(tester, 'Unidade', 'L');
        await _enterFieldText(tester, 'Posto / tanque de origem', 'Posto A');
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(findCta('Registrar abastecimento'));
        await tester.tap(findCta('Registrar abastecimento'));
        await tester.pumpAndSettle();

        expect(find.text('Trator John Deere 6110 salvo'), findsOneWidget);
        expect(find.text('Ver registros'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Ver registros'));
        await tester.pumpAndSettle();

        expect(find.text('Trator John Deere 6110'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('consulta administrativa lê registro criado no operacional', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(prototypeRecordsProvider.notifier)
          .addRecord(
            featureId: 'cadastrar-area',
            title: 'Talhão Integração',
            description: 'Agricultura · 24 ha',
            status: PrototypeRecordStatus.active,
            details: const {'Localização': 'Setor Sul'},
          );

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'areas',
            profile: FeatureProfile.administration,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Talhão Integração'), findsOneWidget);
      expect(find.text('Agricultura · 24 ha'), findsOneWidget);
      expect(find.text('Novo registro'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
