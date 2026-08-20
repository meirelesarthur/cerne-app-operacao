import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../mocks/operacional.dart';
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';
import 'success_screen.dart';

/// Arraçoamento / Nutrição (spec §5.3): registro simples de quantidade.
/// Rateio/apropriação de custo está em LACUNA no recorte — NÃO implementado
/// aqui. Espelha `ArracoamentoFlow.tsx`.
class ArracoamentoFlow extends ConsumerStatefulWidget {
  const ArracoamentoFlow({super.key});

  @override
  ConsumerState<ArracoamentoFlow> createState() => _ArracoamentoFlowState();
}

class _ArracoamentoFlowState extends ConsumerState<ArracoamentoFlow> {
  String? _lote;
  String? _dieta;
  num _qtd = 500;
  String? _deposito;
  bool? _queued;
  bool _attempted = false;

  bool get _valid =>
      _lote != null && _dieta != null && _deposito != null && _qtd > 0;

  void _confirmar() {
    if (!_valid) {
      setState(() => _attempted = true);
      return;
    }
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'arr-$_lote',
              label: 'Arraçoamento',
              detail: '$_qtd kg',
              kind: ActivityKind.arracoamento,
            ),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Arraçoamento registrado',
        queued: _queued!,
        effects:
            'A quantidade fornecida será baixada do estoque do depósito de origem.',
      );
    }

    return FlowShell(
      title: 'Arraçoamento',
      primaryLabel: 'Registrar arraçoamento',
      onPrimary: _confirmar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Lote',
            required: true,
            error: _attempted && _lote == null ? 'Selecione o lote.' : null,
            child: AppSearchSelect(
              options: lotesOpcoes,
              value: _lote,
              onChanged: (v) => setState(() => _lote = v),
              placeholder: 'Buscar lote...',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Dieta / produto',
            required: true,
            error: _attempted && _dieta == null ? 'Selecione a dieta.' : null,
            child: AppFormSelect(
              options: dietas,
              value: _dieta,
              onChanged: (v) => setState(() => _dieta = v),
              placeholder: 'Selecione a dieta',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Quantidade fornecida',
            required: true,
            hint: 'Sem cálculo de rateio de custo nesta fase.',
            error: _attempted && _qtd <= 0
                ? 'Informe uma quantidade maior que zero.'
                : null,
            child: AppStepper(
              value: _qtd,
              onChanged: (v) => setState(() => _qtd = v),
              step: 50,
              suffix: 'kg',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Depósito de origem',
            required: true,
            error: _attempted && _deposito == null
                ? 'Selecione o depósito.'
                : null,
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
