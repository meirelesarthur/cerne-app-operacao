import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';
import 'dashboard_screen.dart';

/// Dashboard único de Confinamento (spec de Confinamento — Cadastro +
/// Nutrição), lido pelo perfil ADM.
///
/// Decisão de perfil confirmada com o time: o ADM só **visualiza** — todo
/// cadastro (Pátio/Setor/Curral, Dieta, Fases) é feito pelo app web, que
/// divide o mesmo banco. Por isso esta tela nunca cria/edita nada; é a versão
/// completa (4 seções) do que antes era só "Lotação de Currais".
class DashConfinamento extends ConsumerStatefulWidget {
  const DashConfinamento({super.key});

  @override
  ConsumerState<DashConfinamento> createState() => _DashConfinamentoState();
}

class _DashConfinamentoState extends ConsumerState<DashConfinamento> {
  int _tab = 0;

  static const _labels = ['Visão geral', 'Mapa', 'Nutrição', 'Relatórios'];

  @override
  Widget build(BuildContext context) {
    final confinamento = ref.watch(confinamentoStoreProvider);

    return DashboardScreen(
      title: 'Confinamento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedTabs(
            labels: _labels,
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.space5),
          switch (_tab) {
            0 => _VisaoGeral(currais: confinamento.currais),
            1 => _Mapa(currais: confinamento.currais),
            2 => const _Nutricao(),
            _ => _Relatorios(
              bateladas: confinamento.bateladas,
              tratos: confinamento.tratosDiarios,
              leituras: confinamento.leiturasCocho,
            ),
          },
        ],
      ),
    );
  }
}

/* ---------------------------- Visão geral ---------------------------- */

class _VisaoGeral extends StatelessWidget {
  const _VisaoGeral({required this.currais});

  final List<CurralInfo> currais;

  @override
  Widget build(BuildContext context) {
    final ocupados = currais.where((c) => c.ocupado).toList();
    final totalCap = currais.fold<int>(0, (s, c) => s + c.capacidade);
    final totalAtual = ocupados.fold<int>(0, (s, c) => s + c.ocupacaoAtual);
    final ocupacaoPct = totalCap == 0
        ? 0
        : ((totalAtual / totalCap) * 100).round();

    final custosPorKg = confinamento_mocks.dietas
        .map((d) => d.custoPorKg)
        .where((v) => v > 0)
        .toList();
    final custoMedioKg = custosPorKg.isEmpty
        ? 0.0
        : custosPorKg.reduce((a, b) => a + b) / custosPorKg.length;

    final gmds = ocupados
        .map((c) => c.indicadores?.gmdKg)
        .whereType<double>()
        .toList();
    final gmdMedio = gmds.isEmpty
        ? 0.0
        : gmds.reduce((a, b) => a + b) / gmds.length;

    final ocorrenciasAbertas = confinamento_mocks.leituraCochoRecente.avaliacoes
        .expand((a) => a.ocorrencias)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.space2,
          crossAxisSpacing: AppSpacing.space2,
          childAspectRatio: 1.5,
          children: [
            AppKpiStatCard(
              label: 'Ocupação',
              value: '$ocupacaoPct%',
              tone: ocupacaoPct >= 80
                  ? AppKpiStatTone.warning
                  : AppKpiStatTone.positive,
            ),
            AppKpiStatCard(
              label: 'Custo médio/kg',
              value: 'R\$ ${custoMedioKg.toStringAsFixed(2)}',
            ),
            AppKpiStatCard(
              label: 'GMD médio',
              value: '${gmdMedio.toStringAsFixed(2)} kg/dia',
            ),
            AppKpiStatCard(
              label: 'Ocorrências abertas',
              value: '$ocorrenciasAbertas',
              tone: ocorrenciasAbertas > 0
                  ? AppKpiStatTone.negative
                  : AppKpiStatTone.neutral,
            ),
          ],
        ),
      ],
    );
  }
}

/* -------------------------------- Mapa -------------------------------- */

class _Mapa extends StatelessWidget {
  const _Mapa({required this.currais});

  final List<CurralInfo> currais;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final patio in confinamento_mocks.patios) ...[
          AppSectionTitle(child: Text(patio.nome)),
          const SizedBox(height: AppSpacing.space2),
          for (final setor in confinamento_mocks.setores.where(
            (s) => s.patioId == patio.id,
          )) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Text(
                setor.nome,
                style: const TextStyle(
                  fontSize: AppTypography.sm,
                  fontWeight: AppTypography.weightSemibold,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.space3,
              crossAxisSpacing: AppSpacing.space3,
              childAspectRatio: 1.1,
              children: [
                for (final c in currais.where((c) => c.setorId == setor.id))
                  _CurralTile(curral: c),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
        ],
      ],
    );
  }
}

AppChipTone _situacaoTone(CurralSituacao s) => switch (s) {
  CurralSituacao.ocupado => AppChipTone.brand,
  CurralSituacao.vazio => AppChipTone.neutral,
  CurralSituacao.vazioSanitario || CurralSituacao.limpeza => AppChipTone.blue,
  CurralSituacao.manutencao || CurralSituacao.enfermaria => AppChipTone.amber,
  CurralSituacao.interditado => AppChipTone.red,
};

class _CurralTile extends StatelessWidget {
  const _CurralTile({required this.curral});

  final CurralInfo curral;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ind = curral.indicadores;

    return AppCard(
      interactive: true,
      padded: false,
      onTap: () => _showCurralDetail(context, curral),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    curral.nome,
                    style: TextStyle(
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                ),
                AppChip(
                  tone: _situacaoTone(curral.situacao),
                  child: Text(curral.situacao.label),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            if (ind != null) ...[
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: AppTypography.md,
                    color: semantic.fgDefault,
                  ),
                  children: [
                    TextSpan(text: '${ind.totalAnimais}'),
                    TextSpan(
                      text: '/${curral.capacidade}',
                      style: TextStyle(color: semantic.fgSubtle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              AppProgressBar(
                value: ind.totalAnimais.toDouble(),
                max: curral.capacidade.toDouble(),
                colorByOccupancy: true,
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'GMD ${ind.gmdKg.toStringAsFixed(2)} kg · desempenho ${ind.indicadorDesempenhoPct}%',
                style: TextStyle(
                  fontSize: AppTypography.xs,
                  color: semantic.fgMuted,
                ),
              ),
            ] else
              Text(
                curral.liberacaoEm != null
                    ? 'Liberação prevista'
                    : 'Sem lote alocado',
                style: TextStyle(
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

void _showCurralDetail(BuildContext context, CurralInfo curral) {
  showAppBottomSheet<void>(
    context,
    title: curral.nome,
    child: Builder(
      builder: (context) {
        final semantic = Theme.of(context).extension<AppSemanticColors>()!;
        final ind = curral.indicadores;
        Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: semantic.fgMuted)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
            ],
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            row('Situação', curral.situacao.label),
            if (ind != null) ...[
              row('Cabeças', '${ind.totalAnimais}/${curral.capacidade}'),
              row(
                'Peso médio',
                '${ind.pesoMedioAtualKg.toStringAsFixed(0)} kg',
              ),
              row('Dias de confinamento', '${ind.diasConfinamento}'),
              row('GMD', '${ind.gmdKg.toStringAsFixed(2)} kg/dia'),
              row(
                'Peso previsto pós-confinamento',
                '${ind.pesoPrevistoPosConfinamentoKg.toStringAsFixed(0)} kg',
              ),
              row('Desempenho', '${ind.indicadorDesempenhoPct}%'),
            ] else if (curral.liberacaoEm != null)
              row(
                'Liberação em',
                '${curral.liberacaoEm!.day}/${curral.liberacaoEm!.month}/${curral.liberacaoEm!.year}',
              ),
          ],
        );
      },
    ),
  );
}

/* ------------------------------ Nutrição ------------------------------ */

class _Nutricao extends StatelessWidget {
  const _Nutricao();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(child: Text('Dietas')),
        const SizedBox(height: AppSpacing.space2),
        for (final d in confinamento_mocks.dietas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        d.produto,
                        style: TextStyle(
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgDefault,
                        ),
                      ),
                      AppChip(child: Text(d.objetivo.label)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    'Custo/kg R\$ ${d.custoPorKg.toStringAsFixed(2)} · '
                    'Média MS ${d.mediaMsPct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppSectionTitle(
          child: Text('Plano de fases — ${confinamento_mocks.planoFases.nome}'),
        ),
        const SizedBox(height: AppSpacing.space2),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final etapa in confinamento_mocks.planoFases.etapas)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                  child: Row(
                    children: [
                      AppChip(child: Text('${etapa.ordem}ª etapa')),
                      const SizedBox(width: AppSpacing.space2),
                      Expanded(
                        child: Text(
                          '${confinamento_mocks.dietas.firstWhere((d) => d.id == etapa.dietaId).produto} · '
                          '${etapa.inicio.toInt()}–${etapa.fim.toInt()} '
                          '${etapa.regra == RegraTroca.porDias ? 'dias' : 'kg'}',
                          style: TextStyle(color: semantic.fgDefault),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ----------------------------- Relatórios ------------------------------ */

class _Relatorios extends StatelessWidget {
  const _Relatorios({
    required this.bateladas,
    required this.tratos,
    required this.leituras,
  });

  final List<Batelada> bateladas;
  final List<TratoDiario> tratos;
  final List<LeituraCocho> leituras;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ocorrencias = leituras
        .expand((l) => l.avaliacoes)
        .expand((a) => a.ocorrencias.map((o) => (avaliacao: a, ocorrencia: o)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(child: Text('Bateladas')),
        const SizedBox(height: AppSpacing.space2),
        for (final b in bateladas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Batelada ${b.id.toUpperCase()}'),
                  AppChip(
                    tone: b.precisaoPct >= 95
                        ? AppChipTone.brand
                        : AppChipTone.amber,
                    child: Text('Precisão ${b.precisaoPct}%'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space5),
        const AppSectionTitle(child: Text('Trato diário')),
        const SizedBox(height: AppSpacing.space2),
        for (final t in tratos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${t.currentConcluidos}/${t.lancamentos.length} currais concluídos',
                  ),
                  Text(
                    '${t.totalFornecido.toStringAsFixed(0)} kg fornecidos',
                    style: TextStyle(color: semantic.fgMuted),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.space5),
        const AppSectionTitle(child: Text('Ocorrências abertas')),
        const SizedBox(height: AppSpacing.space2),
        if (ocorrencias.isEmpty)
          const AppEmptyState(title: 'Nenhuma ocorrência em aberto')
        else
          for (final item in ocorrencias)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppChip(
                      tone: switch (item.ocorrencia.prioridade) {
                        OcorrenciaPrioridade.alta => AppChipTone.red,
                        OcorrenciaPrioridade.media => AppChipTone.amber,
                        OcorrenciaPrioridade.baixa => AppChipTone.neutral,
                      },
                      child: Text(item.ocorrencia.prioridade.name),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        item.ocorrencia.descricao,
                        style: TextStyle(color: semantic.fgDefault),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
