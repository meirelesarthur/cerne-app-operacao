import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';
import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';

void main() {
  group('MappedFeatureScreen — Onda B', () {
    test('os 12 contratos de pecuária e reprodução estão executáveis', () {
      // reprodução (simplificação de grupo): `lotes-reproducao` saiu do
      // catálogo — Reprodução tem só `monta-natural` (Acasalamento) e
      // `diagnostico-gestacao`. Ver `functional_catalog_test.dart`.
      // fidelidade-campos (onda 1): `pastagens` voltou ao operacional, com
      // formulário completo — volta a este grupo. `lotes-reproducao` (onda 4)
      // voltou ao catálogo do lado administrativo e somente leitura, então
      // continua fora daqui, coberta pelos testes genéricos de consulta.
      const ids = {
        'pastagens',
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

    // fidelidade-campos (onda 1): a pastagem era o cadastro mais incompleto
    // da auditoria — responsável e dois armazéns contra um contrato de 6
    // escalares e 5 coleções. Este teste guarda o tamanho do que voltou.
    test('pastagens declara os escalares e as 5 coleções do contrato', () {
      final feature = featureById('pastagens')!;
      final ids = feature.fields.map((field) => field.id).toSet();

      expect(feature.profile, FeatureProfile.operational);
      expect(feature.readOnly, isFalse);
      expect(
        ids,
        containsAll(<String>[
          'data',
          'destino',
          'area',
          'piquete',
          'operacao',
          'atividade',
          'lote',
          'animal',
        ]),
      );
      expect(feature.sections, [
        'Máquinas / Equipamentos',
        'Insumos',
        'Produção',
        'Serviços',
        'Ocorrências',
      ]);
      expect(feature.steps, hasLength(5));
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
              : field.type == FeatureFieldType.date
              ? '2026-08-16'
              : 'Dado de teste';
          controller.setValue(field.id, value);
        }
        controller
          ..setValue('nome', 'Estação 2026/2027')
          ..setValue('inicio', '2026-10-01')
          ..setValue('fim', '2026-01-31');

        expect(controller.submit(), isNull);
        // fidelidade-campos (onda 4): `codigo` e `data` entraram depois de
        // `nome`, então o campo `fim` deixou de ser o índice 3 — a busca
        // passa a ser por id, que não se move quando o contrato cresce.
        final fim = feature.fields.firstWhere((field) => field.id == 'fim');
        expect(
          featureFieldError(feature, fim, controller.form.values),
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
