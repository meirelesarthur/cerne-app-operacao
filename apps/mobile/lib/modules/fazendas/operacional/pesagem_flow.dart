import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

/// Pesagem (spec §5.1): leitura manual do peso (app não lê a balança) +
/// registra pesagem do dia. Espelha `PesagemFlow.tsx`.
class PesagemFlow extends ConsumerStatefulWidget {
  const PesagemFlow({super.key});

  @override
  ConsumerState<PesagemFlow> createState() => _PesagemFlowState();
}

class _PesagemFlowState extends ConsumerState<PesagemFlow> {
  String? _lote;
  String _peso = '';
  String? _deposito;
  bool? _queued;

  bool get _valid => _lote != null && (double.tryParse(_peso.replaceAll(',', '.')) ?? 0) > 0 && _deposito != null;

  void _confirmar() {
    ref.read(fazendasStoreProvider.notifier).registrarPesagemDoDia();
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      final loteLabel = lotesOpcoes.firstWhere((l) => l.value == _lote, orElse: () => lotesOpcoes.first).label;
      ref.read(fazendasStoreProvider.notifier).enqueueSync(
            SyncItem(id: 'pes-$_lote', label: 'Pesagem $loteLabel', detail: '$_peso kg', kind: ActivityKind.pesagem),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Pesagem registrada',
        queued: _queued!,
        effects: 'Isso vai atualizar o estoque e pode gerar NF-e/transferência.',
      );
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return FlowShell(
      title: 'Pesagem',
      primaryLabel: 'Registrar pesagem',
      onPrimary: _confirmar,
      primaryDisabled: !_valid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Lote / carga',
            required: true,
            child: AppSearchSelect(
              options: lotesOpcoes,
              value: _lote,
              onChanged: (v) => setState(() => _lote = v),
              placeholder: 'Buscar lote...',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Peso')),
          const SizedBox(height: AppSpacing.space2),
          const AppBanner(
            icon: Icon(LucideIcons.info, size: 14),
            child: Text(
              'Leitura da balança não disponível neste app — informe o peso manualmente ou use um leitor Bluetooth quando integrado.',
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSpacing.space16,
                  child: AppTextInput(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => setState(() => _peso = v),
                    placeholder: '0',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space4, left: AppSpacing.space2),
                child: Text(
                  'kg',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.lg,
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Depósito de destino',
            required: true,
            child: AppFormSelect(
              options: depositos,
              value: _deposito,
              onChanged: (v) => setState(() => _deposito = v),
              placeholder: 'Selecione o depósito',
            ),
          ),
        ],
      ),
    );
  }
}
