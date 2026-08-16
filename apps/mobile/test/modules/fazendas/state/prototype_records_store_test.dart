import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/state/prototype_records_store.dart';

void main() {
  test('adiciona, ordena e limpa registros por funcionalidade', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(prototypeRecordsProvider.notifier);

    final first = notifier.addRecord(
      featureId: 'cadastrar-area',
      title: 'Talhão 01',
      description: '42 ha',
      status: PrototypeRecordStatus.active,
    );
    final second = notifier.addRecord(
      featureId: 'cadastrar-area',
      title: 'Pasto Norte',
      description: '68 ha',
      status: PrototypeRecordStatus.active,
    );

    expect(first.id, 'cadastrar-area-100');
    expect(second.id, 'cadastrar-area-101');
    expect(
      container.read(prototypeRecordsProvider).recordsFor('cadastrar-area'),
      [second, first],
    );

    notifier.clear();
    expect(container.read(prototypeRecordsProvider).recordsByFeature, isEmpty);
  });

  test('seed copia as listas recebidas', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(prototypeRecordsProvider.notifier);
    final mutable = <PrototypeRecord>[
      const PrototypeRecord(
        id: 'saldo-1',
        title: 'Ração',
        description: '12.400 kg',
        status: PrototypeRecordStatus.active,
      ),
    ];

    notifier.seed({'saldo-estoque': mutable});
    mutable.clear();

    expect(
      container.read(prototypeRecordsProvider).recordsFor('saldo-estoque'),
      hasLength(1),
    );
  });
}
