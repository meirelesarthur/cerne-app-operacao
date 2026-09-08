import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';
import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';

void main() {
  test('valida obrigatoriedade e números positivos', () {
    final feature = featureById('cadastrar-area')!;
    final name = feature.fields.firstWhere((field) => field.id == 'nome');
    final area = feature.fields.firstWhere((field) => field.id == 'area-total');

    expect(featureFieldError(feature, name, const {}), 'Campo obrigatório.');
    expect(
      featureFieldError(feature, area, const {'area-total': '0'}),
      'Informe um valor maior que zero.',
    );
    expect(
      featureFieldError(feature, area, const {'area-total': '42,5'}),
      isNull,
    );
  });

  test('hardware exige captura mesmo quando não há campo-alvo', () {
    final feature = featureById('conexao-aparelhos')!;

    expect(isFeatureFormValid(feature, const FunctionalFormState()), isFalse);
    expect(
      isFeatureFormValid(
        feature,
        const FunctionalFormState(values: {'_hardware': '482,6 kg'}),
      ),
      isTrue,
    );
  });

  test('monta rascunho com detalhes e grupos vinculados', () {
    final feature = featureById('formulacoes')!;
    const state = FunctionalFormState(
      values: {'produto': 'Ração 18%', 'quantidade': '1000', 'unidade': 'kg'},
      // Onda 8: a coleção guarda os itens, não uma contagem — a contagem
      // passou a ser derivada (`groupCounts`).
      groupItems: {
        'Matérias-primas': [
          {'materia-prima': 'Milho moído'},
          {'materia-prima': 'Farelo de soja'},
        ],
      },
    );

    final draft = buildPrototypeRecordDraft(feature, state);

    expect(draft.title, 'Ração 18%');
    expect(draft.description, contains('1000'));
    // Onda 8: o detalhe do registro cita o que foi lançado — a contagem
    // sozinha não dizia se a pessoa pôs a matéria-prima certa.
    expect(
      draft.details['Matérias-primas'],
      '2 item(ns) · Milho moído, Farelo de soja',
    );
    expect(draft.status, PrototypeRecordStatus.active);
  });

  test('percorre lista, formulário, validação e sucesso', () {
    final controller = FunctionalJourneyController(
      featureById('cadastrar-area')!,
    )..startForm();

    expect(controller.submit(), isNull);
    expect(controller.form.attempted, isTrue);
    expect(controller.mode, FunctionalJourneyMode.form);

    controller
      ..setValue('nome', 'Talhão 03')
      ..setValue('tipo', 'Agricultura')
      ..setValue('area-total', '24')
      ..setValue('unidade', 'ha')
      ..setValue('localizacao', 'Setor Sul')
      // fidelidade-campos (onda 3): `color` é required em `/areas` — a cor
      // com que a área aparece no mapa. Ver
      // docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 3.
      ..setValue('cor', 'Verde');
    final draft = controller.submit();

    expect(draft?.title, 'Talhão 03');
    expect(controller.mode, FunctionalJourneyMode.success);

    controller.showList();
    expect(controller.mode, FunctionalJourneyMode.list);
  });

  // fidelidade-campos (onda 0): motor de etapas. Ver
  // docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 0.
  test('formulário em etapas valida etapa a etapa e só salva na última', () {
    final feature = featureById('pastagens')!;
    final controller = FunctionalJourneyController(feature)..startForm();

    expect(controller.hasSteps, isTrue);
    expect(controller.stepCount, 5);
    expect(controller.currentStep?.title, 'Identificação');

    // Etapa incompleta não avança — e não deixa o erro para o fim.
    expect(controller.advanceStep(), isFalse);
    expect(controller.stepIndex, 0);
    expect(controller.form.attempted, isTrue);

    controller
      ..setValue('responsavel', 'João Oliveira')
      ..setValue('data', '2026-09-08')
      ..setValue('destino', 'Área');

    // XOR de `/pastures`: escolher "Área" torna `area` obrigatório, embora o
    // campo não seja `isRequired` no catálogo (senão área e piquete seriam
    // exigidos ao mesmo tempo e nada submeteria).
    expect(controller.advanceStep(), isFalse);
    final area = feature.fields.firstWhere((field) => field.id == 'area');
    expect(
      isFeatureFieldRequired(feature, area, controller.form.values),
      isTrue,
    );

    controller.setValue('area', 'Pasto Norte');
    expect(controller.advanceStep(), isTrue);
    expect(controller.stepIndex, 1);
    // Avançar limpa o "já tentei": a etapa nova começa sem erro em vermelho.
    expect(controller.form.attempted, isFalse);

    controller
      ..setValue('operacao', 'Manutenção de pastagem')
      ..setValue('atividade', 'Roçada');
    expect(controller.advanceStep(), isTrue);

    controller
      ..setValue('armazem-insumos', 'Armazém A')
      ..setValue('armazem-producao', 'Armazém A');
    expect(controller.advanceStep(), isTrue);
    expect(controller.stepIndex, 3);

    // Nenhuma das 5 coleções de pastagem é `min:1` no contrato.
    expect(controller.advanceStep(), isTrue);
    expect(controller.isLastStep, isTrue);
    expect(isFeatureReviewStep(feature, controller.stepIndex), isTrue);
    expect(controller.advanceStep(), isFalse);

    final salvo = controller.submit();
    expect(salvo?.title, 'Roçada');
    expect(controller.mode, FunctionalJourneyMode.success);
  });

  test('voltar uma etapa preserva o preenchido e apaga os erros', () {
    final controller = FunctionalJourneyController(featureById('pastagens')!)
      ..startForm()
      ..setValue('responsavel', 'Maria Souza')
      ..setValue('data', '2026-09-08')
      ..setValue('destino', 'Piquete')
      ..setValue('piquete', 'Piquete 02');

    expect(controller.advanceStep(), isTrue);
    expect(controller.retreatStep(), isTrue);
    expect(controller.stepIndex, 0);
    expect(controller.form.values['piquete'], 'Piquete 02');
    expect(controller.form.attempted, isFalse);
    expect(controller.retreatStep(), isFalse);
  });

  // fidelidade-campos (onda 8): item de coleção com dado de verdade.
  test('item de coleção entra com os campos do contrato e pode sair', () {
    final feature = featureById('pastagens')!;
    final insumos = feature.collectionByName('Insumos')!;
    final controller = FunctionalJourneyController(feature)..startForm();

    expect(insumos.itemLabel, 'Insumo');
    // Item sem os obrigatórios não entra na lista.
    expect(isCollectionItemValid(insumos, const {}), isFalse);
    expect(
      featureItemFieldError(insumos.fields.first, const {}),
      'Campo obrigatório.',
    );

    const item = {
      'produto': 'Ração Engorda 18%',
      'quantidade': '20',
      'unidade': 'kg',
    };
    expect(isCollectionItemValid(insumos, item), isTrue);

    controller.addGroupItem('Insumos', item);
    expect(controller.form.itemsOf('Insumos'), hasLength(1));
    expect(controller.form.groupCounts['Insumos'], 1);
    expect(collectionItemTitle(insumos, item), 'Ração Engorda 18%');
    expect(collectionItemSubtitle(insumos, item), '20 · kg');

    controller.addGroupItem('Insumos', const {
      'produto': 'Sal Mineral Proteinado',
      'quantidade': '50',
      'unidade': 'kg',
    });
    expect(controller.form.groupCounts['Insumos'], 2);

    controller.removeGroupItem('Insumos', 0);
    expect(controller.form.itemsOf('Insumos'), hasLength(1));
    expect(
      controller.form.itemsOf('Insumos').first['produto'],
      'Sal Mineral Proteinado',
    );
    // Índice fora da lista não mexe em nada — nem lança.
    controller.removeGroupItem('Insumos', 9);
    expect(controller.form.itemsOf('Insumos'), hasLength(1));
  });

  test('coleção obrigatória bloqueia o salvamento e aponta a etapa', () {
    final feature = featureById('diagnostico-gestacao')!;
    final controller = FunctionalJourneyController(feature)..startForm();

    for (final field in feature.fields.where((field) => field.isRequired)) {
      controller.setValue(
        field.id,
        field.options.isNotEmpty
            ? field.options.first
            : field.type == FeatureFieldType.number
            ? '1'
            : field.type == FeatureFieldType.date
            ? '2026-09-08'
            : 'Dado de teste',
      );
    }

    // Todos os escalares preenchidos e ainda assim não salva: no contrato o
    // registro **é** o array de animais diagnosticados (`min:1`).
    expect(controller.submit(), isNull);
    expect(
      featureCollectionError(feature, controller.form),
      'Adicione ao menos um item em "Animais diagnosticados".',
    );
    // E leva de volta à etapa onde a pendência pode ser resolvida.
    expect(controller.stepIndex, 2);

    // Onda 8: quem satisfaz o `min:1` é um item de verdade, com a técnica e
    // o resultado por animal que o contrato pede.
    controller.addGroupItem('Animais diagnosticados', const {
      'identificacao': 'BR 1042',
      'tecnica': 'Ultrassonografia',
      'resultado': 'Prenhe',
      'dias-gestacao': '45',
    });
    final salvo = controller.submit();
    expect(salvo, isNotNull);
    expect(
      salvo!.details['Animais diagnosticados'],
      '1 item(ns) · BR 1042',
    );
  });
}
