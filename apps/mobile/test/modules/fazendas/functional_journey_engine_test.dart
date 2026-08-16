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
    final feature = featureById('balanca')!;

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
      groupCounts: {'Matérias-primas': 2},
    );

    final draft = buildPrototypeRecordDraft(feature, state);

    expect(draft.title, 'Ração 18%');
    expect(draft.description, contains('1000'));
    expect(draft.details['Matérias-primas'], '2 item(ns)');
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
      ..setValue('localizacao', 'Setor Sul');
    final draft = controller.submit();

    expect(draft?.title, 'Talhão 03');
    expect(controller.mode, FunctionalJourneyMode.success);

    controller.showList();
    expect(controller.mode, FunctionalJourneyMode.list);
  });
}
