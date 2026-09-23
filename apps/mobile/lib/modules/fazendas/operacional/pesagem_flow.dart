import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Pesagem (spec §5.1): leitura manual do peso (app não lê a balança) +
/// registra pesagem do dia. Espelha `PesagemFlow.tsx`.
class PesagemFlow extends ConsumerStatefulWidget {
  const PesagemFlow({super.key});

  @override
  ConsumerState<PesagemFlow> createState() => _PesagemFlowState();
}

class _PesagemFlowState extends ConsumerState<PesagemFlow> {
  String? _lote;
  String? _animal;
  String _peso = '';
  String? _deposito;
  bool? _queued;

  /// `true` só depois de uma primeira tentativa de confirmar — os campos não
  /// nascem "errados" antes de a pessoa tentar enviar (ver plano de UX).
  bool _attempted = false;

  double get _pesoKg => double.tryParse(_peso.replaceAll(',', '.')) ?? 0;
  bool get _pesoValido => _pesoKg > 0;

  /// Acima disso quase sempre é erro de digitação (um zero a mais). Avisa,
  /// sem bloquear — o operador confere e confirma.
  static const _pesoMaximoEsperado = 1200;
  bool get _valid =>
      _lote != null && _animal != null && _pesoValido && _deposito != null;

  void _confirmar() {
    if (!_valid) {
      setState(() => _attempted = true);
      return;
    }
    ref.read(fazendasStoreProvider.notifier).registrarPesagemDoDia();
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      final loteLabel = lotesOpcoes
          .firstWhere((l) => l.value == _lote, orElse: () => lotesOpcoes.first)
          .label;
      final animalOpcoes = animaisPorLote[_lote] ?? const [];
      final animalLabel = animalOpcoes
          .firstWhere(
            (a) => a.value == _animal,
            orElse: () => animalOpcoes.isNotEmpty
                ? animalOpcoes.first
                : const AppSearchSelectOption(value: '', label: ''),
          )
          .label;
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'pes-$_lote-$_animal',
              label: 'Pesagem $loteLabel · $animalLabel',
              detail: '$_peso kg',
              kind: ActivityKind.pesagem,
            ),
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
        effects: 'O peso foi salvo na ficha do animal.',
        // Pesagem é em série: mantém lote e armazém e já abre o próximo.
        nextLabel: 'Pesar próximo animal',
        onNext: () => setState(() {
          _queued = null;
          _animal = null;
          _peso = '';
          _attempted = false;
        }),
      );
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return FlowShell(
      title: 'Pesagem',
      primaryLabel: 'Registrar pesagem',
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
              label: 'Lote',
              onChanged: (v) => setState(() {
                _lote = v;
                _animal = null;
              }),
              placeholder: 'Buscar lote...',
            ),
          ),
          if (_lote != null) ...[
            const SizedBox(height: AppSpacing.space4),
            AppFormField(
              label: 'Animal',
              required: true,
              error: _attempted && _animal == null
                  ? 'Selecione o animal.'
                  : null,
              child: AppSearchSelect(
                options: animaisPorLote[_lote] ?? const [],
                value: _animal,
                label: 'Animal',
                onChanged: (v) => setState(() => _animal = v),
                placeholder: 'Número do brinco',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          const AppSectionTitle(child: Text('Peso')),
          const SizedBox(height: AppSpacing.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSpacing.space16,
                  child: AppTextInput(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => setState(() => _peso = v),
                    placeholder: '0',
                    invalid: _attempted && !_pesoValido,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.space4,
                  left: AppSpacing.space2,
                ),
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
          if (_attempted && !_pesoValido) ...[
            const SizedBox(height: AppSpacing.space2),
            Row(
              children: [
                AppIcon(
                  AppIcons.alertCircle,
                  size: AppSize.iconXs,
                  color: semantic.toneRedFg,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  'Informe um peso maior que zero.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: AppTypography.sm,
                    fontWeight: AppTypography.weightMedium,
                    color: semantic.toneRedFg,
                  ),
                ),
              ],
            ),
          ] else if (_pesoKg > _pesoMaximoEsperado) ...[
            const SizedBox(height: AppSpacing.space2),
            const AppBanner(
              tone: AppBannerTone.warning,
              icon: AppIcon(AppIcons.alertTriangle, size: AppSize.iconXs),
              child: Text(
                'Peso acima de 1.200 kg. Confira se não sobrou um zero.',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          AppFormField(
            label: 'Armazém de destino',
            required: true,
            error: _attempted && _deposito == null
                ? 'Selecione o armazém.'
                : null,
            child: AppFormSelect(
              options: depositos,
              value: _deposito,
              onChanged: (v) => setState(() => _deposito = v),
              placeholder: 'Selecione o armazém',
            ),
          ),
        ],
      ),
    );
  }
}
