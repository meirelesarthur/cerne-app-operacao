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
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

/// `AppSearchSelect` (`FeatureFieldType.searchSelect` — fidelidade-esteira:
/// todo campo de domínio massivo, como lote/produto/armazém/centro de custo,
/// é dropdown com busca) abre um dock em bottom sheet em vez de mostrar a
/// lista inline — localiza o campo pelo rótulo, toca para abrir o dock e
/// toca na opção já visível na lista.
Future<void> _selectSearchFieldOption(
  WidgetTester tester,
  String label,
  String option,
) async {
  final field = find.descendant(
    of: _fieldByLabel(label),
    matching: find.byType(AppSearchSelect),
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  // O dock só constrói os itens dentro da área visível (lista virtualizada) —
  // filtrar pela própria busca do dock garante que a opção esteja visível.
  await tester.enterText(find.byType(TextField).last, option);
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
        // fidelidade-esteira: o CTA de criar migrou para o rodapé flutuante
        // fixo (`AppActionBar`), que espelha o rótulo em caixa alta — mesma
        // regra do resto do app (formulários), agora também nas listagens.
        expect(find.text('NOVO ABASTECIMENTO'), findsOneWidget);

        await tester.tap(find.text('NOVO ABASTECIMENTO'));
        await tester.pumpAndSettle();

        expect(find.text('Dados do registro'), findsOneWidget);
        expect(find.text('Veículo / equipamento'), findsOneWidget);
        expect(find.text('Quantidade (L)'), findsOneWidget);

        await tester.ensureVisible(findCta('Registrar abastecimento'));
        await tester.tap(findCta('Registrar abastecimento'));
        await tester.pumpAndSettle();

        // fidelidade-contrato (re-auditoria 3ª avaliação): horímetro/hodômetro
        // saíram do cabeçalho para a coleção "Itens do abastecimento"
        // (contrato `SupplyRequest`, `items.*`); os 7 obrigatórios do
        // cabeçalho seguem iguais (os medidores sempre foram opcionais).
        expect(find.text('Campo obrigatório.'), findsNWidgets(7));
        expect(tester.takeException(), isNull);

        await _selectFieldOption(tester, 'Responsável', 'João Oliveira');
        await _enterFieldText(tester, 'Data', '2026-08-16');
        await _selectSearchFieldOption(
          tester,
          'Veículo / equipamento',
          'Trator John Deere 6110',
        );
        await _selectFieldOption(tester, 'Combustível', 'Diesel S10');
        await _enterFieldText(tester, 'Quantidade (L)', '120');
        await _selectFieldOption(tester, 'Unidade', 'L');
        await _enterFieldText(tester, 'Posto / tanque de origem', 'Posto A');
        expect(tester.takeException(), isNull);

        // fidelidade-contrato (re-auditoria 3ª avaliação): items é min:1 no
        // SupplyRequest — adiciona um item de abastecimento (finders escopados
        // ao sheet, já que item e cabeçalho compartilham rótulos).
        await tester.tap(
          find.descendant(
            of: find.byType(AppAddableGroupList).first,
            matching: find.text('Adicionar'),
          ),
        );
        await tester.pumpAndSettle();
        Finder itemField(String label) => find.ancestor(
          of: find.text(label).last,
          matching: find.byType(AppFormField),
        );
        await tester.tap(
          find.descendant(
            of: itemField('Veículo / equipamento'),
            matching: find.byType(AppSearchSelect),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, 'Pulverizador');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pulverizador').last);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: itemField('Combustível'),
            matching: find.byType(DropdownButtonFormField<String>),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Diesel S10').last);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: itemField('Quantidade'),
            matching: find.byType(TextFormField),
          ),
          '80',
        );
        await tester.tap(
          find.descendant(
            of: itemField('Unidade'),
            matching: find.byType(DropdownButtonFormField<String>),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('L').last);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Adicionar').last);
        await tester.tap(find.text('Adicionar').last);
        await tester.pumpAndSettle();

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

    // fidelidade-campos (onda 8): a prova de que a coleção deixou de ser
    // contador — o item entra pela folha inferior com os campos do contrato,
    // aparece na lista com o dado verdadeiro, sai de lá, e chega à revisão e
    // ao registro salvo. Ver docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 8.
    testWidgets('Pastagens lança um insumo real na coleção e salva', (
      tester,
    ) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'pastagens',
            profile: FeatureProfile.operational,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // fidelidade-esteira: CTA no rodapé flutuante fixo, rótulo em caixa alta.
      await tester.tap(find.text('NOVO MANEJO DE PASTAGEM'));
      await tester.pumpAndSettle();

      // Etapa 1 — identificação. A área é escolhida antes do destino: com o
      // destino já em "Área", o rótulo do campo e o valor do select passam a
      // ter o mesmo texto na árvore.
      expect(find.text('Identificação'), findsOneWidget);
      await _selectFieldOption(tester, 'Responsável', 'João Oliveira');
      await _enterFieldText(tester, 'Data do manejo', '2026-09-08');
      await _selectFieldOption(tester, 'Área', 'Pasto Norte');
      await _selectFieldOption(tester, 'Local do manejo', 'Área');
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();

      // Etapa 2 — manejo.
      await _selectFieldOption(tester, 'Operação', 'Manutenção de pastagem');
      await _selectFieldOption(tester, 'Atividade', 'Roçada');
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();

      // Etapa 3 — estoque.
      await _selectSearchFieldOption(tester, 'Armazém de insumos', 'Armazém A');
      await _selectSearchFieldOption(
        tester,
        'Armazém de produção',
        'Depósito B',
      );
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();

      // Etapa 4 — as cinco coleções de `/pastures`, ainda vazias.
      expect(find.text('Itens vinculados'), findsOneWidget);
      expect(find.text('Nenhum item adicionado'), findsNWidgets(5));

      // Insumos é a segunda coleção; cada uma compõe um AppAddableGroupList.
      await tester.tap(
        find.descendant(
          of: find.byType(AppAddableGroupList).at(1),
          matching: find.text('Adicionar'),
        ),
      );
      await tester.pumpAndSettle();

      // A folha abre com o rótulo do item, não com o nome da coleção.
      expect(find.text('Insumo'), findsOneWidget);
      await _selectSearchFieldOption(tester, 'Produto', 'Ração Engorda 18%');
      // fidelidade-campos (onda 9 — re-auditoria 11/09): `estoque` entrou
      // como required (`inputs.*.stock_uuid`).
      await _selectFieldOption(
        tester,
        'Item de estoque',
        'Ração Engorda 18% — Lote 2026-07-A',
      );
      await _enterFieldText(tester, 'Quantidade', '20');
      await _selectFieldOption(tester, 'Unidade', 'kg');
      await tester.ensureVisible(find.text('Adicionar').last);
      await tester.tap(find.text('Adicionar').last);
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda 18%'), findsOneWidget);
      expect(find.text('20 · kg'), findsOneWidget);
      expect(find.text('1 item(ns) adicionado(s)'), findsOneWidget);

      // Etapa 5 — revisão: a coleção aparece por extenso, item a item, na
      // mesma caixa da etapa de preenchimento — não mais um resumo achatado.
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('Revisão'), findsWidgets);
      expect(find.text('Insumos'), findsOneWidget);
      expect(find.text('Ração Engorda 18%'), findsOneWidget);
      expect(find.text('20 · kg'), findsOneWidget);
      expect(find.text('Roçada'), findsOneWidget);

      await tester.tap(findCta('Salvar pastagem'));
      await tester.pumpAndSettle();
      expect(find.text('Roçada salvo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Pastagens remove o item lançado na coleção', (tester) async {
      await setTallSurface(tester);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const MappedFeatureScreen(
            featureId: 'pastagens',
            profile: FeatureProfile.operational,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // fidelidade-esteira: CTA no rodapé flutuante fixo, rótulo em caixa alta.
      await tester.tap(find.text('NOVO MANEJO DE PASTAGEM'));
      await tester.pumpAndSettle();
      await _selectFieldOption(tester, 'Responsável', 'João Oliveira');
      await _enterFieldText(tester, 'Data do manejo', '2026-09-08');
      await _selectFieldOption(tester, 'Área', 'Pasto Norte');
      await _selectFieldOption(tester, 'Local do manejo', 'Área');
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();
      await _selectFieldOption(tester, 'Operação', 'Manutenção de pastagem');
      await _selectFieldOption(tester, 'Atividade', 'Roçada');
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();
      await _selectSearchFieldOption(tester, 'Armazém de insumos', 'Armazém A');
      await _selectSearchFieldOption(
        tester,
        'Armazém de produção',
        'Depósito B',
      );
      await tester.tap(findCta('Continuar'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppAddableGroupList).at(1),
          matching: find.text('Adicionar'),
        ),
      );
      await tester.pumpAndSettle();
      await _selectSearchFieldOption(tester, 'Produto', 'Ração Engorda 18%');
      await _selectFieldOption(
        tester,
        'Item de estoque',
        'Ração Engorda 18% — Lote 2026-07-A',
      );
      await _enterFieldText(tester, 'Quantidade', '20');
      await _selectFieldOption(tester, 'Unidade', 'kg');
      await tester.ensureVisible(find.text('Adicionar').last);
      await tester.tap(find.text('Adicionar').last);
      await tester.pumpAndSettle();
      expect(find.text('Ração Engorda 18%'), findsOneWidget);

      await tester.tap(find.byTooltip('Remover item'));
      await tester.pumpAndSettle();

      expect(find.text('Ração Engorda 18%'), findsNothing);
      expect(find.text('Nenhum item adicionado'), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });
  });

  group('MappedFeatureScreen — etapas viram abas na visualização', () {
    // `marcacao` declara etapas ("Identificação", "Marcação", "Safra e
    // custo", "Revisão") — o detalhe do registro precisa separar os campos
    // de volta pelas mesmas etapas em vez de despejar tudo numa lista só.
    testWidgets(
      'o detalhe do registro agrupa os campos pelas etapas do cadastro',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container
            .read(prototypeRecordsProvider.notifier)
            .addRecord(
              featureId: 'marcacao',
              title: 'Marcação em Pasto Sul',
              description: 'Registro de teste',
              status: PrototypeRecordStatus.active,
              details: const {
                'Responsável': 'João Oliveira',
                'Tipo de marcação': 'Amostragem',
                'Centro de custo': 'Centro Agrícola',
              },
            );

        await tester.pumpWidget(
          _wrap(
            container,
            const MappedFeatureScreen(
              featureId: 'marcacao',
              profile: FeatureProfile.operational,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Marcação em Pasto Sul'));
        await tester.pumpAndSettle();

        // As três etapas com conteúdo viram abas; a revisão (sem campo
        // próprio) não aparece.
        expect(find.text('Identificação'), findsOneWidget);
        expect(find.text('Marcação'), findsOneWidget);
        expect(find.text('Safra e custo'), findsOneWidget);
        expect(find.text('Revisão'), findsNothing);

        // Aba inicial: só o campo da primeira etapa está visível.
        expect(find.text('João Oliveira'), findsOneWidget);
        expect(find.text('Amostragem'), findsNothing);
        expect(find.text('Centro Agrícola'), findsNothing);

        await tester.tap(find.text('Marcação'));
        await tester.pumpAndSettle();
        expect(find.text('Amostragem'), findsOneWidget);
        expect(find.text('João Oliveira'), findsNothing);
        expect(find.text('Centro Agrícola'), findsNothing);

        await tester.tap(find.text('Safra e custo'));
        await tester.pumpAndSettle();
        expect(find.text('Centro Agrícola'), findsOneWidget);
        expect(find.text('Amostragem'), findsNothing);

        expect(tester.takeException(), isNull);
      },
    );
  });
}
