import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shared/rise_in.dart';
import '../../../shell/state/prototype_session_store.dart';
import '../../../ui/ui.dart';
import '../components/activity_detail_sheet.dart';
import '../components/activity_list_item.dart';
import '../components/context_badge.dart';
import '../components/credito_banner.dart';
import '../components/shortcut_grid.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../mocks/atividades.dart';
import '../mocks/dashboards_mocks.dart';
import '../state/fazendas_store.dart';
import '../types.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Home do módulo Fazendas (aba Dashboard) — espelha `FazendasHome.tsx`:
/// O conteúdo é definido exclusivamente pelo perfil da sessão demonstrativa.
class FazendasHome extends ConsumerWidget {
  const FazendasHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(prototypeSessionProvider).profile;
    return profile == UserAccessProfile.operational
        ? const _HomeCampo()
        : const _HomeGerencial();
  }
}

/// Home do perfil administrativo — torre de controle.
///
/// Era: título, cinco atalhos, banner de crédito, três cartões (receita, custo
/// e margem com **os mesmos valores** do painel de Pecuária) e uma lista de
/// atividades. Passou a ser a leitura de decisão do dia, na ordem em que ela é
/// feita: primeiro o que está fora do lugar (faixa de alertas), depois o mapa
/// dos painéis, depois o melhor gráfico de cada um.
///
/// Regra desta tela: cada bloco reusa o **mesmo widget** do painel de origem —
/// `AppChartCard(compact: true)` sobre o mesmo gráfico. Nenhum gráfico é
/// reimplementado aqui (Lei 2). Ver docs/ESTEIRA-DASHBOARDS-ADM.md, seção 3.
class _HomeGerencial extends StatelessWidget {
  const _HomeGerencial();

  static const _resultado = '/fazendas/dashboards/resultado';
  static const _confinamento = '/fazendas/dashboards/confinamento';
  static const _suprimentos = '/fazendas/dashboards/suprimentos';
  static const _ativos = '/fazendas/dashboards/ativos';
  static const _uso = '/fazendas/dashboards/uso';

  /// Só entra na faixa o que pede decisão hoje — e cada cápsula leva ao painel
  /// que explica o número. Indicador dentro do esperado não vira alerta: vira
  /// gráfico mais abaixo.
  List<AppAlertItem> _alertas(BuildContext context) {
    final currais = confinamento_mocks.currais;
    final lotados = currais
        .where(
          (c) =>
              c.ocupado &&
              c.capacidade > 0 &&
              c.ocupacaoAtual / c.capacidade >= 0.9,
        )
        .length;
    final ocorrencias = confinamento_mocks.leituraCochoRecente.avaliacoes
        .expand((a) => a.ocorrencias)
        .length;
    final emManutencao = ativos
        .where((a) => a.estado == AtivoEstado.manutencao)
        .length;
    final aguardando = cotacoes
        .where((c) => c.status == CotacaoStatus.cotacao)
        .length;

    return [
      AppAlertItem(
        label: 'vencidos',
        value: FinanceiroKpis.atrasados,
        icon: AppIcons.circleAlert,
        tone: AppAlertTone.critical,
        onTap: () => context.go(_resultado),
      ),
      if (ocorrencias > 0)
        AppAlertItem(
          label: 'ocorrências no cocho',
          value: '$ocorrencias',
          icon: AppIcons.triangleAlert,
          onTap: () => context.go(_confinamento),
        ),
      if (lotados > 0)
        AppAlertItem(
          label: 'currais acima de 90%',
          value: '$lotados',
          icon: AppIcons.warehouse,
          onTap: () => context.go(_confinamento),
        ),
      if (aguardando > 0)
        AppAlertItem(
          label: 'cotações a decidir',
          value: '$aguardando',
          icon: AppIcons.receipt,
          tone: AppAlertTone.info,
          onTap: () => context.go(_suprimentos),
        ),
      if (emManutencao > 0)
        AppAlertItem(
          label: 'ativos em manutenção',
          value: '$emManutencao',
          icon: AppIcons.wrench,
          tone: AppAlertTone.info,
          onTap: () => context.go(_ativos),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final adminShortcuts = [
      Shortcut(
        id: 'resultado',
        label: 'Resultado',
        icon: AppIcons.wallet,
        onTap: () => context.go(_resultado),
      ),
      Shortcut(
        id: 'confinamento',
        label: 'Rebanho',
        icon: AppIcons.warehouse,
        onTap: () => context.go(_confinamento),
      ),
      Shortcut(
        id: 'suprimentos',
        label: 'Compras',
        icon: AppIcons.boxes,
        onTap: () => context.go(_suprimentos),
      ),
      Shortcut(
        id: 'ativos',
        label: 'Ativos',
        icon: AppIcons.package,
        onTap: () => context.go(_ativos),
      ),
      Shortcut(
        id: 'mais',
        label: 'Mais',
        icon: AppIcons.moreHorizontal,
        onTap: () => context.go('/fazendas/mais'),
      ),
    ];

    final currais = confinamento_mocks.currais;
    final ocupados = currais.where((c) => c.ocupado).toList();
    final capacidade = currais.fold<int>(0, (s, c) => s + c.capacidade);
    final alojados = ocupados.fold<int>(0, (s, c) => s + c.ocupacaoAtual);
    final ocupacaoPct = capacidade == 0 ? 0.0 : (alojados / capacidade) * 100;
    final indicadores = ocupados
        .map((c) => c.indicadores)
        .whereType<IndicadoresLote>()
        .toList();
    final gmd = indicadores.isEmpty
        ? 0.0
        : indicadores.map((i) => i.gmdKg).reduce((a, b) => a + b) /
              indicadores.length;
    final gmdPrevisto = indicadores.isEmpty
        ? 0.0
        : indicadores.map((i) => i.gmdPrevistoKg).reduce((a, b) => a + b) /
              indicadores.length;

    final patrimonio = <String, double>{};
    for (final a in ativos) {
      patrimonio[a.categoria] = (patrimonio[a.categoria] ?? 0) + a.aquisicaoMil;
    }

    return _ActivityAwareList(
      builder: (context, onActivityTap) => ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          const RiseIn(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppHeading(
                  level: AppHeadingLevel.h3,
                  child: Text('Resumo da safra'),
                ),
                _SafraPill(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(index: 1, child: AppAlertStrip(items: _alertas(context))),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 2,
            child: ShortcutGrid(items: adminShortcuts, columns: 5),
          ),
          const SizedBox(height: AppSpacing.space4),
          const RiseIn(index: 3, child: CreditoBanner()),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 4,
            child: AppChartCard(
              title: 'Resultado',
              period: '6 meses',
              compact: true,
              onExpand: () => context.go(_resultado),
              footnote:
                  'Margem do mês: ${formatMilhares(resultadoMeses.last.margem)}.',
              child: AppLineChart(
                compact: true,
                labels: [for (final m in resultadoMeses) m.label],
                series: [
                  AppLineSeries(
                    label: 'Receita',
                    points: [for (final m in resultadoMeses) m.receita],
                    filled: true,
                  ),
                  AppLineSeries(
                    label: 'Custo',
                    points: [for (final m in resultadoMeses) m.custo],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 5,
            child: AppChartCard(
              title: 'Ocupação e GMD',
              compact: true,
              onExpand: () => context.go(_confinamento),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppGauge(value: ocupacaoPct, label: 'ocupação'),
                  AppGauge(
                    value: gmd,
                    max: gmdPrevisto == 0 ? 1 : gmdPrevisto * 1.2,
                    target: gmdPrevisto,
                    valueLabel: gmd.toStringAsFixed(2),
                    label: 'GMD kg/dia',
                    tone: gmd >= gmdPrevisto
                        ? AppGaugeTone.positive
                        : AppGaugeTone.warning,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 6,
            child: AppChartCard(
              title: 'Despesa por centro de custo',
              compact: true,
              onExpand: () => context.go(_resultado),
              child: AppBarChart(
                showGrid: false,
                data: [
                  for (final c in centrosCusto.take(4))
                    AppBarDatum(label: c.label, value: c.value),
                ],
                formatValue: (v) => '${v.toStringAsFixed(0)}k',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 7,
            child: AppChartCard(
              title: 'Patrimônio por categoria',
              compact: true,
              onExpand: () => context.go(_ativos),
              child: Center(
                child: AppDonutChart(
                  centerValue: AtivosResumo.total,
                  centerLabel: 'aquisição',
                  data: [
                    for (final entry in patrimonio.entries)
                      AppDonutSlice(label: entry.key, value: entry.value),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          RiseIn(
            index: 8,
            child: AppChartCard(
              title: 'Adoção por fazenda',
              compact: true,
              onExpand: () => context.go(_uso),
              child: AppBulletChart(
                targetLabel: 'cadastrados',
                data: [
                  for (final f in usoFazendas)
                    AppBulletDatum(
                      label: f.nome,
                      value: f.online.toDouble(),
                      target: f.usuarios.length.toDouble(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          RiseIn(
            index: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppSectionTitle(child: Text('Atividades recentes')),
                    AppButton(
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      rightIcon: const AppIcon(AppIcons.arrowRight, size: 13),
                      onPressed: () => context.go('/fazendas/atividades'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                Builder(
                  builder: (context) {
                    final semantic = Theme.of(
                      context,
                    ).extension<AppSemanticColors>()!;
                    final recentes = atividades.take(4).toList();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                      ),
                      decoration: BoxDecoration(
                        color: semantic.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.xl3),
                        border: Border.all(color: semantic.borderDefault),
                      ),
                      child: Column(
                        children: [
                          for (final a in recentes)
                            ActivityListItem(
                              activity: a,
                              showDivider: a != recentes.last,
                              onTap: () => onActivityTap(a),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encapsula o acionamento do `ActivityDetailSheet` — equivalente ao
/// `useState<Activity | null>` do React, sem precisar de `StatefulWidget` na
/// tela inteira (o bottom sheet já é a fonte de estado "aberto/fechado").
class _ActivityAwareList extends StatelessWidget {
  const _ActivityAwareList({required this.builder});

  final Widget Function(
    BuildContext context,
    void Function(Activity activity) onActivityTap,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      (activity) => showActivityDetailSheet(context, activity: activity),
    );
  }
}

class _SafraPill extends StatelessWidget {
  const _SafraPill();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: semantic.borderDefault),
        color: semantic.bgSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Safra 24/25',
            style: TextStyle(
              fontWeight: AppTypography.weightSemibold,
              fontSize: AppTypography.base,
              color: semantic.fgDefault,
            ),
          ),
          const SizedBox(width: AppSpacing.space1),
          AppIcon(AppIcons.chevronDown, size: 14, color: semantic.fgDefault),
        ],
      ),
    );
  }
}

class _HomeCampo extends ConsumerWidget {
  const _HomeCampo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncQueue = ref.watch(
      fazendasStoreProvider.select((s) => s.syncQueue),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ContextBadge(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            children: [
              RiseIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeading(
                      level: AppHeadingLevel.h3,
                      child: Text('Lançamentos de campo'),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Builder(
                      builder: (context) => Text(
                        'Escolha o tipo de registro para começar.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).extension<AppSemanticColors>()!.fgMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space5),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                children: [
                  RiseIn(
                    child: AppBentoTile(
                      icon: AppIcons.scale,
                      label: 'Pesagem',
                      caption: 'Balança conectada',
                      onTap: () => context.go('/fazendas/campo/pesagem'),
                    ),
                  ),
                  RiseIn(
                    index: 1,
                    child: AppBentoTile(
                      icon: AppIcons.arrowLeftRight,
                      label: 'Ciclo rebanho',
                      caption: 'Entradas e saídas',
                      onTap: () => context.go('/fazendas/campo/ciclo'),
                    ),
                  ),
                  RiseIn(
                    index: 2,
                    child: AppBentoTile(
                      icon: AppIcons.wheat,
                      label: 'Arraçoamento',
                      caption: 'Trato do dia',
                      onTap: () => context.go('/fazendas/campo/arracoamento'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              // Sem `stretch`: cada tile tem altura própria (com `iconSize:
              // lg`, "Venda" naturalmente fica um pouco mais alto que
              // "Entrada NF-e") — `stretch` num Row dentro de um ListView
              // (altura vertical não limitada) pede altura infinita e quebra
              // o layout.
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RiseIn(
                      index: 3,
                      child: AppBentoTile(
                        icon: AppIcons.truck,
                        label: 'Venda',
                        caption: 'GTA, romaneio e frete',
                        iconSize: AppBentoTileIconSize.lg,
                        onTap: () => context.go('/fazendas/campo/venda'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: RiseIn(
                      index: 4,
                      child: AppBentoTile(
                        icon: AppIcons.fileText,
                        label: 'Entrada NF-e',
                        caption: 'Importar XML',
                        variant: AppBentoTileVariant.accent,
                        onTap: () => context.go('/fazendas/campo/recebimento'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RiseIn(
                      index: 5,
                      child: AppBentoTile(
                        icon: AppIcons.sprout,
                        label: 'Insumos',
                        caption: 'Aplicações e retiradas',
                        onTap: () => context.go('/fazendas/campo/insumos'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    flex: 2,
                    child: RiseIn(
                      index: 6,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: AppSectionTitle(
                                    child: Text(
                                      'Fila de sincronização',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                AppChip(
                                  tone: syncQueue.isEmpty
                                      ? AppChipTone.brand
                                      : AppChipTone.amber,
                                  child: Text(
                                    syncQueue.isEmpty
                                        ? 'Tudo sincronizado'
                                        : '${syncQueue.length} pendente(s)',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Builder(
                              builder: (context) => Text(
                                syncQueue.isEmpty
                                    ? 'Nenhum lançamento aguardando envio.'
                                    : 'Lançamentos feitos offline serão enviados quando a conexão voltar.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).extension<AppSemanticColors>()!.fgMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
