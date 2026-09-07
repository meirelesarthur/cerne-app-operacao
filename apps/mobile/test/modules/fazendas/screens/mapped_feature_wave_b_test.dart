import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';
import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';

void main() {
  group('MappedFeatureScreen — Onda B', () {
    test('os 11 contratos de pecuária e reprodução estão executáveis', () {
      // reprodução (simplificação de grupo): `lotes-reproducao` saiu do
      // catálogo — Reprodução tem só `monta-natural` (Acasalamento) e
      // `diagnostico-gestacao`. Ver `functional_catalog_test.dart`.
      // `pastagens` saiu do operacional — virou consulta administrativa
      // (`readOnly`, grupo Consultas e auditoria), coberta pelos testes
      // genéricos de consulta somente leitura, não por este grupo.
      const ids = {
        'rebanho-inicial',
        'lote-animais',
        'registrar-animal',
        'transferencia-lote-area',
        'sanitario',
        'desmama',
        'estacao-monta',
        'material-reprodutivo',
        'protocolos-estacao',
        'monta-natural',
        'diagnostico-gestacao',
      };

      for (final id in ids) {
        final feature = featureById(id);
        expect(feature, isNotNull, reason: id);
        expect(feature?.profile, FeatureProfile.operational, reason: id);
        expect(feature?.status, FeatureStatus.ready, reason: id);
        expect(feature?.fields, isNotEmpty, reason: id);
        expect(feature?.primaryAction, isNotEmpty, reason: id);
      }
    });

    test(
      'estação de monta rejeita período invertido e salva como programada',
      () {
        final feature = featureById('estacao-monta')!;
        final controller = FunctionalJourneyController(feature)..startForm();

        for (final field in feature.fields.where((field) => field.isRequired)) {
          final value = field.options.isNotEmpty
              ? field.options.first
              : field.type == FeatureFieldType.number
              ? '1'
              : 'Dado de teste';
          controller.setValue(field.id, value);
        }
        controller
          ..setValue('nome', 'Estação 2026/2027')
          ..setValue('inicio', '2026-10-01')
          ..setValue('fim', '2026-01-31');

        expect(controller.submit(), isNull);
        expect(
          featureFieldError(feature, feature.fields[3], controller.form.values),
          'A data final deve ser posterior à data inicial.',
        );

        controller.setValue('fim', '2027-01-31');
        final draft = controller.submit();

        expect(draft?.title, 'Estação 2026/2027');
        expect(draft?.status, PrototypeRecordStatus.scheduled);
      },
    );
  });
}
