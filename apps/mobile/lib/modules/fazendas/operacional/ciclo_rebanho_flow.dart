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

enum _EventType { nascimento, desmame, transferencia, morte }

class _EventDef {
  const _EventDef({
    required this.type,
    required this.label,
    required this.icon,
    required this.desc,
  });

  final _EventType type;
  final String label;
  final IconData icon;
  final String desc;
}

const _events = <_EventDef>[
  _EventDef(
    type: _EventType.nascimento,
    label: 'Nascimento',
    icon: LucideIcons.baby,
    desc: 'Registrar bezerro',
  ),
  _EventDef(
    type: _EventType.desmame,
    label: 'Desmame',
    icon: LucideIcons.milk,
    desc: 'Desmame de animal',
  ),
  _EventDef(
    type: _EventType.transferencia,
    label: 'Transferência',
    icon: LucideIcons.arrowLeftRight,
    desc: 'Entre lotes',
  ),
  _EventDef(
    type: _EventType.morte,
    label: 'Morte / Perda',
    icon: LucideIcons.heartCrack,
    desc: 'Baixa de animal',
  ),
];

/// Eventos de Ciclo do Rebanho (spec §5.2) — formulário dinâmico por tipo de
/// evento. Espelha `CicloRebanhoFlow.tsx`.
class CicloRebanhoFlow extends ConsumerStatefulWidget {
  const CicloRebanhoFlow({super.key});

  @override
  ConsumerState<CicloRebanhoFlow> createState() => _CicloRebanhoFlowState();
}

class _CicloRebanhoFlowState extends ConsumerState<CicloRebanhoFlow> {
  _EventType? _type;
  bool? _queued;

  String? _lote;
  String? _loteDestino;
  String _data = '';
  String _qtd = '';
  String? _causa;
  String _obs = '';
  bool _attempted = false;

  void _confirmar(bool valid) {
    if (!valid) {
      setState(() => _attempted = true);
      return;
    }
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      final detalhe = [
        'Ciclo do rebanho',
        if (_lote != null) 'Lote $_lote',
        if (_loteDestino != null) 'destino $_loteDestino',
        if (_obs.isNotEmpty) _obs,
      ].join(' · ');
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'evt-${_type!.name}',
              label: 'Evento: ${_type!.name}',
              detail: detalhe,
              kind: ActivityKind.evento,
            ),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Evento registrado',
        queued: _queued!,
        effects:
            'Isso vai atualizar a máquina de estados do animal e a base de venda/SISBOV.',
      );
    }

    if (_type == null) {
      return FlowShell(
        title: 'Eventos do rebanho',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.space3),
              child: Text('Escolha o tipo de evento a registrar.'),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space3,
              crossAxisSpacing: AppSpacing.space3,
              childAspectRatio: 1.1,
              children: [
                for (final e in _events)
                  _EventTile(
                    e: e,
                    onTap: () => setState(() {
                      _type = e.type;
                      _attempted = false;
                    }),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final isTransfer = _type == _EventType.transferencia;
    final pesagemDoDiaFeita = ref
        .watch(fazendasStoreProvider)
        .pesagemDoDiaFeita;
    final transferBlocked = isTransfer && !pesagemDoDiaFeita;

    final valid = switch (_type!) {
      _EventType.nascimento => _lote != null && _data.isNotEmpty,
      _EventType.desmame => _lote != null && _data.isNotEmpty,
      _EventType.transferencia =>
        _lote != null &&
            _loteDestino != null &&
            _qtd.isNotEmpty &&
            !transferBlocked,
      _EventType.morte => _lote != null && _data.isNotEmpty && _causa != null,
    };

    final label = _events.firstWhere((e) => e.type == _type).label;

    return FlowShell(
      title: label,
      primaryLabel: 'Registrar evento',
      onPrimary: () => _confirmar(valid),
      onBack: () => setState(() {
        _type = null;
        _attempted = false;
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (transferBlocked)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.space5),
              child: AppBanner(
                tone: AppBannerTone.error,
                icon: Icon(LucideIcons.alertTriangle, size: 14),
                child: Text(
                  'Transferência bloqueada: é necessário registrar a pesagem do dia antes de transferir o lote (DUV-179).',
                ),
              ),
            ),
          AppFormField(
            label: isTransfer
                ? 'Lote de origem'
                : (_type == _EventType.nascimento
                      ? 'Animal-mãe / lote'
                      : 'Animal / lote'),
            required: true,
            error: _attempted && _lote == null ? 'Selecione o lote.' : null,
            child: AppSearchSelect(
              options: lotesOpcoes,
              value: _lote,
              onChanged: (v) => setState(() => _lote = v),
            ),
          ),
          if (isTransfer) ...[
            const SizedBox(height: AppSpacing.space5),
            AppFormField(
              label: 'Lote de destino',
              required: true,
              error: _attempted && _loteDestino == null
                  ? 'Selecione o lote de destino.'
                  : null,
              child: AppSearchSelect(
                options: lotesOpcoes.where((l) => l.value != _lote).toList(),
                value: _loteDestino,
                onChanged: (v) => setState(() => _loteDestino = v),
                placeholder: 'Buscar lote de destino...',
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            AppFormField(
              label: 'Quantidade',
              required: true,
              error: _attempted && _qtd.isEmpty
                  ? 'Informe a quantidade.'
                  : null,
              child: AppTextInput(
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _qtd = v),
                placeholder: 'Nº de animais',
                invalid: _attempted && _qtd.isEmpty,
              ),
            ),
          ],
          if (_type != _EventType.transferencia) ...[
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
          ],
          if (_type == _EventType.nascimento) ...[
            const SizedBox(height: AppSpacing.space5),
            AppFormField(
              label: 'Peso ao nascer',
              hint: 'Opcional',
              child: AppTextInput(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => setState(() => _qtd = v),
                placeholder: 'kg',
              ),
            ),
          ],
          if (_type == _EventType.morte) ...[
            const SizedBox(height: AppSpacing.space5),
            AppFormField(
              label: 'Causa',
              required: true,
              error: _attempted && _causa == null ? 'Selecione a causa.' : null,
              child: AppFormSelect(
                options: causasMorte,
                value: _causa,
                onChanged: (v) => setState(() => _causa = v),
                placeholder: 'Selecione a causa',
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            AppFormField(
              label: 'Observação',
              child: AppTextarea(
                onChanged: (v) => setState(() => _obs = v),
                placeholder: 'Detalhes adicionais...',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.e, required this.onTap});

  final _EventDef e;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppPressable(
      semanticLabel: '${e.label}: ${e.desc}',
      onPressed: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl3),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: semantic.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl3),
          border: Border.all(color: semantic.borderDefault),
          boxShadow: semantic.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: semantic.accentSubtle,
              ),
              child: Icon(e.icon, size: 22, color: semantic.accentDefault),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              e.label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.md,
                fontWeight: AppTypography.weightSemibold,
                color: semantic.fgDefault,
              ),
            ),
            Text(
              e.desc,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
