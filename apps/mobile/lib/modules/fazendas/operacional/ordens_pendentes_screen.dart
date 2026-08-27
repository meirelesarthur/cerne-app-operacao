import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';

/// Ordens pendentes (spec §4.6, ações "Alterar Dieta"/"Transferir Lote") —
/// o ADM cria a ordem no app web (banco compartilhado); o Operacional só
/// confirma a execução em campo, nunca decide essas duas ações livremente
/// (decisão de perfil confirmada com o time).
class OrdensPendentesScreen extends ConsumerWidget {
  const OrdensPendentesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordens = ref.watch(
      confinamentoStoreProvider.select((s) => s.ordensPendentes),
    );
    final notifier = ref.read(confinamentoStoreProvider.notifier);

    return Column(
      children: [
        const SubPageHeader(title: 'Ordens pendentes'),
        Expanded(
          child: ordens.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    icon: LucideIcons.inbox,
                    title: 'Nenhuma ordem pendente',
                    description:
                        'Transferências de lote e trocas de dieta criadas pelo ADM aparecem aqui.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  itemCount: ordens.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(height: AppSpacing.space3),
                  itemBuilder: (context, index) => _OrdemCard(
                    ordem: ordens[index],
                    onConfirmar: notifier.confirmarOrdemPendente,
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrdemCard extends StatelessWidget {
  const _OrdemCard({required this.ordem, required this.onConfirmar});

  final OrdemPendente ordem;
  final void Function(String id) onConfirmar;

  String _curralNome(String id) =>
      confinamento_mocks.currais.firstWhere((c) => c.id == id).nome;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final confirmada = ordem.status == OrdemStatus.confirmada;

    final descricao = switch (ordem.tipo) {
      OrdemTipo.transferenciaLote =>
        'Transferir lote de ${_curralNome(ordem.curralOrigemId)} para '
            '${_curralNome(ordem.curralDestinoId!)}',
      OrdemTipo.trocaDieta =>
        'Trocar dieta de ${_curralNome(ordem.curralOrigemId)} para '
            '${confinamento_mocks.dietas.firstWhere((d) => d.id == ordem.novaDietaId).produto}',
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppChip(
                tone: ordem.tipo == OrdemTipo.transferenciaLote
                    ? AppChipTone.blue
                    : AppChipTone.amber,
                child: Text(
                  ordem.tipo == OrdemTipo.transferenciaLote
                      ? 'Transferência de lote'
                      : 'Troca de dieta',
                ),
              ),
              AppChip(
                tone: confirmada ? AppChipTone.brand : AppChipTone.neutral,
                child: Text(confirmada ? 'Confirmada' : 'Pendente'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(descricao, style: TextStyle(color: semantic.fgDefault)),
          if (ordem.observacao != null) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(
              ordem.observacao!,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
          ],
          if (!confirmada) ...[
            const SizedBox(height: AppSpacing.space3),
            AppButton(
              fullWidth: true,
              onPressed: () => onConfirmar(ordem.id),
              child: const Text('Confirmar execução'),
            ),
          ],
        ],
      ),
    );
  }
}
