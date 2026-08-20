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

enum _Lancamento { aplicacao, ocorrencia }

/// Aplicação de Insumos / Ocorrências Agrícolas (spec §5.6) — status PARCIAL.
/// Sem validações cruzadas complexas: apenas campos obrigatórios básicos
/// (talhão, data, tipo). Espelha `InsumosFlow.tsx`.
class InsumosFlow extends ConsumerStatefulWidget {
  const InsumosFlow({super.key});

  @override
  ConsumerState<InsumosFlow> createState() => _InsumosFlowState();
}

class _InsumosFlowState extends ConsumerState<InsumosFlow> {
  String? _talhao;
  String? _ciclo;
  _Lancamento _tipo = _Lancamento.aplicacao;
  String _data = '';
  String? _insumo;
  String _qtd = '';
  String _descricao = '';
  bool? _queued;
  bool _attempted = false;

  bool get _valid => _talhao != null && _data.isNotEmpty;

  void _confirmar() {
    if (!_valid) {
      setState(() => _attempted = true);
      return;
    }
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      final detalhe = [
        'Talhão $_talhao',
        ?_insumo,
        if (_qtd.isNotEmpty) _qtd,
        if (_descricao.isNotEmpty) _descricao,
      ].join(' · ');
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'ins-$_talhao',
              label: 'Insumo (${_tipo.name})',
              detail: detalhe,
              kind: ActivityKind.insumo,
            ),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Lançamento registrado',
        queued: _queued!,
        effects:
            'A ocorrência/aplicação será vinculada ao talhão e ciclo de produção.',
      );
    }

    return FlowShell(
      title: 'Insumos / Ocorrências',
      primaryLabel: 'Registrar',
      onPrimary: _confirmar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Área / talhão',
            required: true,
            error: _attempted && _talhao == null ? 'Selecione o talhão.' : null,
            child: AppFormSelect(
              options: talhoes,
              value: _talhao,
              onChanged: (v) => setState(() => _talhao = v),
              placeholder: 'Selecione o talhão',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Ciclo de produção',
            child: AppFormSelect(
              options: ciclos,
              value: _ciclo,
              onChanged: (v) => setState(() => _ciclo = v),
              placeholder: 'Selecione o ciclo',
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Tipo de lançamento',
            required: true,
            child: Row(
              children: [
                for (final op in _Lancamento.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: op == _Lancamento.aplicacao
                            ? AppSpacing.space2
                            : AppSpacing.space0,
                      ),
                      child: _TipoButton(
                        label: op == _Lancamento.aplicacao
                            ? 'Aplicação'
                            : 'Ocorrência',
                        selected: _tipo == op,
                        onTap: () => setState(() => _tipo = op),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Data',
            required: true,
            error: _attempted && _data.isEmpty ? 'Informe a data.' : null,
            child: AppTextInput(
              onChanged: (v) => setState(() => _data = v),
              placeholder: 'dd/mm/aaaa',
              invalid: _attempted && _data.isEmpty,
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          if (_tipo == _Lancamento.aplicacao) ...[
            AppFormField(
              label: 'Produto / insumo',
              child: AppFormSelect(
                options: insumos,
                value: _insumo,
                onChanged: (v) => setState(() => _insumo = v),
                placeholder: 'Selecione o insumo',
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            AppFormField(
              label: 'Quantidade',
              child: AppTextInput(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => setState(() => _qtd = v),
                placeholder: 'Quantidade aplicada',
              ),
            ),
          ] else
            AppFormField(
              label: 'Descrição da ocorrência',
              child: AppTextarea(
                onChanged: (v) => setState(() => _descricao = v),
                placeholder: 'Descreva a ocorrência...',
              ),
            ),
        ],
      ),
    );
  }
}

class _TipoButton extends StatelessWidget {
  const _TipoButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: label,
      selected: selected,
      onPressed: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? semantic.ctaBg : semantic.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? semantic.ctaBg : semantic.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: AppTypography.md,
            fontWeight: AppTypography.weightSemibold,
            color: selected ? semantic.ctaFg : semantic.fgMuted,
          ),
        ),
      ),
    );
  }
}
