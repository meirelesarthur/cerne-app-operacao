import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

/// Contagem de cabeças por lote (mock) — usado para validar que a contagem
/// bate com o lote selecionado (spec §5.5). Local a este fluxo (não faz parte
/// do catálogo compartilhado de `mocks/operacional.dart`).
const _loteCabecas = <String, int>{
  'l42': 128,
  'l19': 96,
  'l07': 150,
  'l33': 64,
  'l51': 110,
  'l88': 82,
};

/// Venda de Animais (spec §5.5): mês congelado bloqueia edição; total > 0;
/// contagem deve bater. Espelha `VendaFlow.tsx`.
class VendaFlow extends ConsumerStatefulWidget {
  const VendaFlow({super.key});

  @override
  ConsumerState<VendaFlow> createState() => _VendaFlowState();
}

class _VendaFlowState extends ConsumerState<VendaFlow> {
  String? _lote;
  String _cliente = '';
  String? _cond;
  String _dataEmbarque = '';
  num _qtd = 0;
  String _total = '';
  bool? _queued;

  int get _esperado => _lote != null ? (_loteCabecas[_lote] ?? 0) : 0;
  bool get _contagemBate => _lote == null || _qtd == _esperado;
  bool get _totalValido =>
      (double.tryParse(_total.replaceAll(',', '.')) ?? 0) > 0;
  bool get _valid =>
      _lote != null &&
      _cliente.isNotEmpty &&
      _cond != null &&
      _dataEmbarque.isNotEmpty &&
      _contagemBate &&
      _totalValido;

  void _confirmar() {
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'venda-$_lote',
              label: 'Venda de animais',
              detail: _cliente,
              kind: ActivityKind.venda,
            ),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Venda registrada',
        queued: _queued!,
        effects: 'Isso vai gerar NF-e + GTA e um título a receber.',
      );
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return FlowShell(
      title: 'Venda de animais',
      primaryLabel: 'Confirmar venda',
      onPrimary: _confirmar,
      primaryDisabled: !_valid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Demonstração de mês congelado — venda de mês fechado bloqueada para edição.
          const AppSectionTitle(child: Text('Mês anterior (fechado)')),
          const SizedBox(height: AppSpacing.space2),
          Opacity(
            opacity: 0.9,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: semantic.borderDefault),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: semantic.bgSurface,
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      size: 16,
                      color: semantic.fgSubtle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Venda #3382 · Frigorífico Central',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: AppTypography.weightMedium,
                            color: semantic.fgMuted,
                          ),
                        ),
                        Text(
                          'Junho/2026 · R\$ 420.000',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: AppTypography.sm,
                            color: semantic.fgSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppTooltip(
                    content: 'Mês congelado — edição bloqueada',
                    child: Icon(
                      LucideIcons.lock,
                      size: 16,
                      color: semantic.fgSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          const AppSectionTitle(child: Text('Nova venda')),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Lote / animais',
            required: true,
            child: AppSearchSelect(
              options: lotesOpcoes,
              value: _lote,
              onChanged: (v) => setState(() {
                _lote = v;
                _qtd = _loteCabecas[v] ?? 0;
              }),
              placeholder: 'Buscar lote...',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Quantidade de animais',
            required: true,
            error: !_contagemBate
                ? 'A contagem deve bater com o lote ($_esperado cabeças).'
                : null,
            child: AppStepper(
              value: _qtd,
              onChanged: (v) => setState(() => _qtd = v),
              max: _esperado > 0 ? _esperado : 999,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Cliente',
            required: true,
            child: AppTextInput(
              onChanged: (v) => setState(() => _cliente = v),
              placeholder: 'Nome do comprador',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Condição de pagamento',
            required: true,
            child: AppFormSelect(
              options: condPagamento,
              value: _cond,
              onChanged: (v) => setState(() => _cond = v),
              placeholder: 'Selecione',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Data de embarque',
            required: true,
            child: AppTextInput(
              onChanged: (v) => setState(() => _dataEmbarque = v),
              placeholder: 'dd/mm/aaaa',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Valor total (R\$)',
            required: true,
            error: _total.isNotEmpty && !_totalValido
                ? 'O total deve ser maior que zero.'
                : null,
            child: AppTextInput(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (v) => setState(() => _total = v),
              placeholder: '0,00',
              invalid: _total.isNotEmpty && !_totalValido,
            ),
          ),
        ],
      ),
    );
  }
}
