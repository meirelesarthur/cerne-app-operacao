import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../state/fazendas_store.dart';

/// Troca de fazenda (tenant) do módulo — fonte única da folha de seleção.
///
/// Existe como função de módulo, e não dentro de um widget, porque dois pontos
/// da interface abrem a mesma folha: a faixa `ContextBadge` da home legada e o
/// `AppFarmSelector` do cabeçalho das centrais. Antes a folha morava privada no
/// `ContextBadge`; o segundo consumidor teria que copiá-la (Lei 2).
void openFarmPicker(BuildContext context, WidgetRef ref) {
  final state = ref.read(fazendasStoreProvider);
  final notifier = ref.read(fazendasStoreProvider.notifier);

  showAppBottomSheet<void>(
    context,
    title: 'Trocar de fazenda',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final farm in state.farms)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppMenuItem(
              icon: AppIcons.mapPin,
              label: farm.name,
              description: '${farm.city} · ${farm.uf}',
              trailing: farm.id == state.activeFarmId
                  ? const AppChip(child: Text('Ativa'))
                  : null,
              onTap: () {
                notifier.setActiveFarm(farm.id);
                Navigator.of(context).pop();
              },
            ),
          ),
      ],
    ),
  );
}
