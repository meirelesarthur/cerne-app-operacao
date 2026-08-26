import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';
import '../mocks/operacional.dart' show depositos;
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';
import 'success_screen.dart';

const _vagoes = <AppFormSelectOption>[
  AppFormSelectOption(value: 'v1', label: 'Vagão Misturador 01'),
  AppFormSelectOption(value: 'v2', label: 'Vagão Misturador 02'),
];

/// Produzir Batelada (spec §4.3): escolhida a Dieta e a quantidade a
/// produzir, o app escala automaticamente cada ingrediente
/// (`quantidade original × produzida ÷ referência`) — o operador só confirma
/// o armazém de retirada e a quantidade realmente pesada por ingrediente.
class BateladaFlow extends ConsumerStatefulWidget {
  const BateladaFlow({super.key});

  @override
  ConsumerState<BateladaFlow> createState() => _BateladaFlowState();
}

class _BateladaFlowState extends ConsumerState<BateladaFlow> {
  String? _dietaId;
  String? _vagao;
  num _quantidadeProduzida = 1000;

  /// Por produto: armazém escolhido e quantidade realizada digitada.
  final Map<String, String?> _armazens = {};
  final Map<String, num?> _realizados = {};

  bool? _queued;
  bool _attempted = false;

  Dieta? get _dieta => _dietaId == null
      ? null
      : confinamento_mocks.dietas.firstWhere((d) => d.id == _dietaId);

  List<ItemBatelada> get _itens {
    final dieta = _dieta;
    if (dieta == null) return const [];
    final escala = _quantidadeProduzida / dieta.quantidadeReferencia;
    return [
      for (final ing in dieta.ingredientes)
        ItemBatelada(
          produto: ing.produto,
          armazem: _armazens[ing.produto] ?? '',
          quantidadePrevista: ing.quantidade * escala,
          quantidadeRealizada: _realizados[ing.produto]?.toDouble(),
        ),
    ];
  }

  bool get _valid =>
      _dietaId != null &&
      _vagao != null &&
      _quantidadeProduzida > 0 &&
      _dieta!.ingredientes.every(
        (ing) =>
            _armazens[ing.produto] != null && _realizados[ing.produto] != null,
      );

  void _confirmar() {
    if (!_valid) {
      setState(() => _attempted = true);
      return;
    }
    final batelada = Batelada(
      id: 'bt-${DateTime.now().microsecondsSinceEpoch}',
      dietaId: _dietaId!,
      vagaoDestino: _vagoes.firstWhere((v) => v.value == _vagao).label,
      quantidadeProduzida: _quantidadeProduzida.toDouble(),
      itens: _itens,
    );
    ref.read(confinamentoStoreProvider.notifier).registrarBatelada(batelada);

    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: batelada.id,
              label: 'Batelada',
              detail: '${_quantidadeProduzida.toStringAsFixed(0)} kg',
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
        title: 'Batelada registrada',
        queued: _queued!,
        effects:
            'O estoque dos armazéns informados será baixado pelas quantidades realizadas.',
      );
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final dieta = _dieta;

    return FlowShell(
      title: 'Produzir batelada',
      primaryLabel: 'Registrar batelada',
      onPrimary: _confirmar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Dieta',
            required: true,
            error: _attempted && _dietaId == null ? 'Selecione a dieta.' : null,
            child: AppFormSelect(
              options: [
                for (final d in confinamento_mocks.dietas)
                  AppFormSelectOption(value: d.id, label: d.produto),
              ],
              value: _dietaId,
              placeholder: 'Selecione a dieta',
              onChanged: (v) => setState(() {
                _dietaId = v;
                _armazens.clear();
                _realizados.clear();
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Vagão destino',
            required: true,
            error: _attempted && _vagao == null ? 'Selecione o vagão.' : null,
            child: AppFormSelect(
              options: _vagoes,
              value: _vagao,
              placeholder: 'Selecione o vagão',
              onChanged: (v) => setState(() => _vagao = v),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Quantidade produzida',
            required: true,
            child: AppStepper(
              value: _quantidadeProduzida,
              onChanged: (v) => setState(() => _quantidadeProduzida = v),
              step: 100,
              suffix: dieta?.unidade ?? 'kg',
            ),
          ),
          if (dieta != null) ...[
            const SizedBox(height: AppSpacing.space5),
            const AppSectionTitle(child: Text('Ingredientes')),
            const SizedBox(height: AppSpacing.space2),
            for (final ing in dieta.ingredientes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ing.produto,
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        'Previsto: ${(ing.quantidade * _quantidadeProduzida / dieta.quantidadeReferencia).toStringAsFixed(1)} ${dieta.unidade}',
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      AppFormField(
                        label: 'Armazém de retirada',
                        required: true,
                        error: _attempted && _armazens[ing.produto] == null
                            ? 'Selecione o armazém.'
                            : null,
                        child: AppFormSelect(
                          options: depositos,
                          value: _armazens[ing.produto],
                          placeholder: 'Selecione o armazém',
                          onChanged: (v) =>
                              setState(() => _armazens[ing.produto] = v),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      AppFormField(
                        label: 'Quantidade realizada',
                        required: true,
                        child: AppStepper(
                          value: _realizados[ing.produto] ?? 0,
                          onChanged: (v) =>
                              setState(() => _realizados[ing.produto] = v),
                          step: 10,
                          suffix: dieta.unidade,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
