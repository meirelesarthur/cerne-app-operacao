import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/generated/app_typography.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../mocks/operacional.dart';
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';
import 'success_screen.dart';
import '../../../design/generated/app_layout.dart';

/// Recebimento / Entrada por XML (NF-e) (spec §5.4): upload + conferência de
/// itens. Espelha `RecebimentoXmlFlow.tsx`.
class RecebimentoXmlFlow extends ConsumerStatefulWidget {
  const RecebimentoXmlFlow({super.key});

  @override
  ConsumerState<RecebimentoXmlFlow> createState() => _RecebimentoXmlFlowState();
}

class _RecebimentoXmlFlowState extends ConsumerState<RecebimentoXmlFlow> {
  String? _file;
  final Map<String, bool> _conferidos = {};
  bool? _queued;

  int get _totalConferidos =>
      nfeItens.where((i) => _conferidos[i.id] == true).length;

  void _toggle(String id) =>
      setState(() => _conferidos[id] = !(_conferidos[id] ?? false));

  void _confirmar() {
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'nfe-${nfeCabecalho.numero}',
              label: 'NF-e #${nfeCabecalho.numero}',
              detail: nfeCabecalho.fornecedor,
              kind: ActivityKind.nfe,
            ),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Entrada processada',
        queued: _queued!,
        effects:
            'Movimento de compra será processado e um título a pagar será gerado no financeiro.',
      );
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return FlowShell(
      title: 'Entrada por XML (NF-e)',
      primaryLabel: _file != null ? 'Confirmar entrada' : null,
      onPrimary: _confirmar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSectionTitle(child: Text('Arquivo da nota')),
          const SizedBox(height: AppSpacing.space2),
          AppFileUpload(
            value: _file,
            onChanged: (v) => setState(() => _file = v),
          ),
          if (_file != null) ...[
            const SizedBox(height: AppSpacing.space4),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: semantic.accentSubtle,
                    ),
                    child: AppIcon(
                      AppIcons.fileText,
                      size: AppSize.iconMd,
                      color: semantic.accentDefault,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nfeCabecalho.fornecedor,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: AppTypography.weightSemibold,
                            color: semantic.fgDefault,
                          ),
                        ),
                        Text(
                          'NF-e #${nfeCabecalho.numero}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.sm,
                            color: semantic.fgMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    nfeCabecalho.total,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: AppTypography.lg,
                      fontWeight: AppTypography.weightBold,
                      color: semantic.fgDefault,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppSectionTitle(child: Text('Itens da nota')),
                Text(
                  '$_totalConferidos/${nfeItens.length} conferidos',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.xs,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Container(
              decoration: BoxDecoration(
                color: semantic.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.xl3),
                border: Border.all(color: semantic.borderDefault),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in nfeItens)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space4,
                        vertical: AppSpacing.space3,
                      ),
                      decoration: item == nfeItens.last
                          ? null
                          : BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: semantic.borderDefault,
                                ),
                              ),
                            ),
                      child: Row(
                        children: [
                          AppCheckbox(
                            checked: _conferidos[item.id] ?? false,
                            onChanged: (_) => _toggle(item.id),
                            semanticLabel: 'Conferir ${item.descricao}',
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.descricao,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontWeight: AppTypography.weightMedium,
                                    color: semantic.fgDefault,
                                  ),
                                ),
                                Text(
                                  item.qtd,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: AppTypography.sm,
                                    color: semantic.fgMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.valor,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: AppTypography.sm,
                              fontWeight: AppTypography.weightSemibold,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
