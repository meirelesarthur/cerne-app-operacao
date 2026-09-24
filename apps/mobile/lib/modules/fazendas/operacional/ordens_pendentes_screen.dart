import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';

/// Ordens pendentes (spec §4.6, ações "Alterar Dieta"/"Transferir Lote") —
/// o escritório cria a ordem no app web (banco compartilhado); o Operacional só
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
          child: AppContentSheet(
            padded: false,
            child: ordens.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      icon: AppIcons.clipboardCheck,
                      badgeIcon: AppIcons.check,
                      tone: AppEmptyStateTone.success,
                      title: 'Nenhuma ordem pendente',
                      description:
                          'Transferências de lote e trocas de dieta criadas pelo escritório aparecem aqui.',
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
          Text(
            descricao,
            style: TextStyle(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.weightMedium,
              color: semantic.fgDefault,
            ),
          ),
          if (ordem.observacao != null) ...[
            const SizedBox(height: AppSpacing.space1),
            AppRecordMetaGrid(
              meta: [
                AppRecordMeta(
                  icon: AppIcons.messageCircle,
                  label: ordem.observacao!,
                ),
              ],
            ),
          ],
          // Tipo e situação embaixo do texto (padrão de listagem).
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
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
          if (!confirmada) ...[
            const SizedBox(height: AppSpacing.space3),
            AppButton(
              fullWidth: true,
              // Confirmação explícita: a ordem some da lista e o escritório
              // passa a contar com o curral mudado.
              onPressed: () async {
                final ok = await showAppConfirm(
                  context,
                  title: 'Você já fez isso no curral?',
                  message:
                      '$descricao.\n\nConfirme só depois de terminar o '
                      'serviço no curral.',
                  confirmLabel: 'Concluir',
                );
                if (ok) onConfirmar(ordem.id);
              },
              child: const Text('Concluir ordem'),
            ),
          ],
        ],
      ),
    );
  }
}
