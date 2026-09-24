import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../design/generated/app_typography.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../confinamento/mocks.dart' show patios, setores;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';

/// Tela de operação dos currais cadastrados pelo escritório no app web.
/// No mobile, o time de campo consulta os dados e registra as ações do dia.
class MeusCurraisScreen extends ConsumerStatefulWidget {
  const MeusCurraisScreen({super.key});

  @override
  ConsumerState<MeusCurraisScreen> createState() => _MeusCurraisScreenState();
}

class _MeusCurraisScreenState extends ConsumerState<MeusCurraisScreen> {
  int _filtroSelecionado = 0;

  @override
  Widget build(BuildContext context) {
    final currais = ref.watch(
      confinamentoStoreProvider.select((s) => s.currais),
    );
    final ordens = ref.watch(
      confinamentoStoreProvider.select((s) => s.ordensPendentes),
    );
    final totalCabecas = currais.fold<int>(
      0,
      (total, c) => total + c.ocupacaoAtual,
    );
    final capacidadeTotal = currais.fold<int>(
      0,
      (total, c) => total + c.capacidade,
    );
    final curraisAtencao = currais.where(_precisaAtencao).toList();
    final curraisComVagas = currais
        .where((curral) => curral.ocupacaoAtual < curral.capacidade)
        .toList();
    final filtrados = switch (_filtroSelecionado) {
      1 => curraisAtencao,
      2 => curraisComVagas,
      _ => currais,
    };

    return Column(
      children: [
        const SubPageHeader(title: 'Currais'),
        Expanded(
          child: AppContentSheet(
            padded: false,
            child: currais.isEmpty
                ? const Center(
                    child: AppEmptyState(
                      icon: AppIcons.barns,
                      tone: AppEmptyStateTone.brand,
                      title: 'Nenhum curral por aqui',
                      description:
                          'Os currais da fazenda ativa aparecem aqui assim que '
                          'forem sincronizados com o escritório.',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    children: [
                      _OcupacaoResumo(
                        quantidadeCurrais: currais.length,
                        totalCabecas: totalCabecas,
                        capacidadeTotal: capacidadeTotal,
                      ),
                      const SizedBox(height: AppSpacing.space6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Seus currais',
                              style: TextStyle(
                                fontSize: AppTypography.lg,
                                fontWeight: AppTypography.weightSemibold,
                                color: Theme.of(
                                  context,
                                ).extension<AppSemanticColors>()!.fgDefault,
                              ),
                            ),
                          ),
                          Text(
                            '${filtrados.length} ${filtrados.length == 1 ? 'resultado' : 'resultados'}',
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              color: Theme.of(
                                context,
                              ).extension<AppSemanticColors>()!.fgMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      AppSegmentedTabs(
                        labels: [
                          'Todos · ${currais.length}',
                          'Atenção · ${curraisAtencao.length}',
                          'Com vagas · ${curraisComVagas.length}',
                        ],
                        selectedIndex: _filtroSelecionado,
                        onChanged: (index) =>
                            setState(() => _filtroSelecionado = index),
                        scrollable: true,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      if (filtrados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.space8,
                          ),
                          child: AppEmptyState(
                            icon: AppIcons.barns,
                            tone: AppEmptyStateTone.brand,
                            title: 'Nenhum curral neste filtro',
                            description:
                                'Os currais cadastrados aparecerão aqui quando '
                                'corresponderem a esta seleção.',
                          ),
                        )
                      else
                        for (
                          var index = 0;
                          index < filtrados.length;
                          index++
                        ) ...[
                          if (index > 0)
                            const SizedBox(height: AppSpacing.space3),
                          _CurralCard(
                            curral: filtrados[index],
                            ordensPendentes: ordens
                                .where(
                                  (ordem) =>
                                      ordem.status == OrdemStatus.pendente &&
                                      ordem.curralOrigemId ==
                                          filtrados[index].id,
                                )
                                .toList(),
                          ),
                        ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

bool _precisaAtencao(CurralInfo curral) =>
    curral.situacao == CurralSituacao.manutencao ||
    curral.situacao == CurralSituacao.enfermaria ||
    curral.situacao == CurralSituacao.interditado ||
    curral.ocupacaoAtual > curral.capacidade;

class _OcupacaoResumo extends StatelessWidget {
  const _OcupacaoResumo({
    required this.quantidadeCurrais,
    required this.totalCabecas,
    required this.capacidadeTotal,
  });

  final int quantidadeCurrais;
  final int totalCabecas;
  final int capacidadeTotal;

  @override
  Widget build(BuildContext context) {
    final ocupacao = capacidadeTotal == 0
        ? 0
        : (totalCabecas / capacidadeTotal * 100).round();

    return AppCard(
      variant: AppCardVariant.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ocupação dos currais',
                      style: TextStyle(
                        fontSize: AppTypography.lg,
                        fontWeight: AppTypography.weightSemibold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      '$quantidadeCurrais ${quantidadeCurrais == 1 ? 'curral cadastrado' : 'currais cadastrados'}',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: Theme.of(
                          context,
                        ).extension<AppSemanticColors>()!.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Text(
                '$ocupacao%',
                style: const TextStyle(
                  fontSize: AppTypography.display,
                  fontWeight: AppTypography.weightBold,
                  height: AppTypography.lineHeightSnug,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          AppProgressBar(
            value: totalCabecas.toDouble(),
            max: capacidadeTotal.toDouble(),
          ),
          const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$totalCabecas cabeças alojadas',
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: Theme.of(
                      context,
                    ).extension<AppSemanticColors>()!.inkMuted,
                  ),
                ),
              ),
              Text(
                '$capacidadeTotal vagas',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: Theme.of(
                    context,
                  ).extension<AppSemanticColors>()!.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurralCard extends ConsumerWidget {
  const _CurralCard({required this.curral, required this.ordensPendentes});

  final CurralInfo curral;
  final List<OrdemPendente> ordensPendentes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ocupacao = curral.capacidade == 0
        ? 0
        : (curral.ocupacaoAtual / curral.capacidade * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            curral.nome,
            style: TextStyle(
              fontSize: AppTypography.xl,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgDefault,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          AppRecordMetaGrid(
            meta: [
              AppRecordMeta(
                icon: AppIcons.mapPin,
                label: _localizacaoCurral(curral.setorId),
              ),
              AppRecordMeta(
                icon: AppIcons.beef,
                label: '${curral.capacidade} vagas',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          AppChip(
            tone: switch (curral.situacao) {
              CurralSituacao.ocupado => AppChipTone.brand,
              CurralSituacao.vazio => AppChipTone.neutral,
              CurralSituacao.vazioSanitario ||
              CurralSituacao.limpeza => AppChipTone.blue,
              CurralSituacao.manutencao ||
              CurralSituacao.enfermaria => AppChipTone.amber,
              CurralSituacao.interditado => AppChipTone.red,
            },
            child: Text(curral.situacao.label),
          ),
          if (ordensPendentes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space3),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space2),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  AppIcon(
                    AppIcons.bellRing,
                    size: AppSpacing.space4,
                    color: semantic.fgMuted,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Text(
                      ordensPendentes.length == 1
                          ? '1 ordem pendente do escritório para este curral'
                          : '${ordensPendentes.length} ordens pendentes do escritório para este curral',
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ),
                  AppButton(
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        context.push('/fazendas/campo/ordens-pendentes'),
                    child: const Text('Ver'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${curral.ocupacaoAtual}',
                style: TextStyle(
                  fontSize: AppTypography.xl3,
                  fontWeight: AppTypography.weightMedium,
                  color: semantic.fgDefault,
                ),
              ),
              Text(
                ' / ${curral.capacidade}',
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgMuted,
                ),
              ),
              const Spacer(),
              Text(
                'cabeças · $ocupacao% ocupado',
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          AppProgressBar(
            value: curral.ocupacaoAtual.toDouble(),
            max: curral.capacidade.toDouble(),
            colorByOccupancy: true,
          ),
          const SizedBox(height: AppSpacing.space3),
          Divider(height: 1, color: semantic.borderDefault),
          const SizedBox(height: AppSpacing.space3),
          _AcoesCurral(curral: curral),
        ],
      ),
    );
  }
}

class _AcoesCurral extends ConsumerWidget {
  const _AcoesCurral({required this.curral});

  final CurralInfo curral;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget botao({
      required AppIconData icon,
      required String label,
      required VoidCallback onPressed,
      bool principal = false,
    }) => AppButton(
      fullWidth: true,
      height: AppSpacing.space12,
      size: AppButtonSize.sm,
      variant: principal
          ? AppButtonVariant.primary
          : AppButtonVariant.secondary,
      leftIcon: AppIcon(
        icon,
        size: AppSpacing.space5,
        color: principal ? semantic.ctaFg : semantic.fgDefault,
      ),
      onPressed: onPressed,
      child: Text(label),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: botao(
                icon: AppIcons.clipboardList,
                label: 'Registrar evento',
                principal: true,
                onPressed: () => context.push('/fazendas/campo/ciclo'),
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: botao(
                icon: AppIcons.arrowLeftRight,
                label: 'Alterar situação',
                onPressed: () => _abrirAlterarSituacao(context, ref, curral),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space2),
        Row(
          children: [
            Expanded(
              child: botao(
                icon: AppIcons.scale,
                label: 'Pesagem',
                onPressed: () => context.push('/fazendas/campo/pesagem'),
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Expanded(
              child: botao(
                icon: AppIcons.heartPulse,
                label: 'Sanitário',
                onPressed: () =>
                    context.push('/fazendas/operacional/sanitario'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _localizacaoCurral(String setorId) {
  for (final setor in setores) {
    if (setor.id != setorId) continue;
    for (final patio in patios) {
      if (patio.id == setor.patioId) return '${patio.nome} · ${setor.nome}';
    }
    return setor.nome;
  }
  return 'Localização não informada';
}

void _abrirAlterarSituacao(
  BuildContext context,
  WidgetRef ref,
  CurralInfo curral,
) {
  var situacao = curral.situacao;

  showAppBottomSheet<void>(
    context,
    title: 'Alterar situação — ${curral.nome}',
    child: StatefulBuilder(
      builder: (context, setSheetState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Situação',
              required: true,
              child: AppFormSelect(
                options: [
                  for (final s in CurralSituacao.values)
                    AppFormSelectOption(value: s.name, label: s.label),
                ],
                value: situacao.name,
                onChanged: (v) => setSheetState(
                  () => situacao = CurralSituacao.values.firstWhere(
                    (s) => s.name == v,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            AppButton(
              fullWidth: true,
              onPressed: () {
                ref
                    .read(confinamentoStoreProvider.notifier)
                    .alterarSituacaoCurral(curral.id, situacao);
                Navigator.of(context).pop();
              },
              child: const Text('Salvar situação'),
            ),
          ],
        );
      },
    ),
  );
}
