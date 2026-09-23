import 'package:flutter/material.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import 'models.dart';

/// Peças visuais compartilhadas por `MinhasOsScreen` (Operacional) e
/// `DashOrdemServico` (Administrativo) — Lei 2 do CLAUDE.md: as duas telas
/// mostram a mesma OS com a mesma fidelidade, só a lista de ações muda por
/// perfil.

AppChipTone osStatusTone(OrdemServicoStatus status) => switch (status) {
  OrdemServicoStatus.aguardando => AppChipTone.neutral,
  OrdemServicoStatus.emExecucao => AppChipTone.blue,
  OrdemServicoStatus.pausada => AppChipTone.amber,
  OrdemServicoStatus.entregue => AppChipTone.brand,
  OrdemServicoStatus.refeita => AppChipTone.red,
  OrdemServicoStatus.cancelada => AppChipTone.red,
};

AppChipTone osPrioridadeTone(PrioridadeOs prioridade) => switch (prioridade) {
  PrioridadeOs.baixa => AppChipTone.neutral,
  PrioridadeOs.media => AppChipTone.blue,
  PrioridadeOs.alta => AppChipTone.amber,
  PrioridadeOs.urgente => AppChipTone.red,
};

String _fmtData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtDataCurta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String _fmtDataHora(DateTime d) =>
    '${_fmtData(d)} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Duração legível para a linha de situação: "40 min", "2h15", "3 dias".
String osDuracao(Duration d) {
  if (d.isNegative) return '0 min';
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  if (d.inHours < 24) {
    final min = d.inMinutes % 60;
    return min == 0
        ? '${d.inHours}h'
        : '${d.inHours}h${min.toString().padLeft(2, '0')}';
  }
  final dias = d.inDays;
  return dias == 1 ? '1 dia' : '$dias dias';
}

String _dias(int n) => n == 1 ? '1 dia' : '$n dias';

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// A situação mais importante da OS *agora*, para a linha de rodapé do card.
/// Uma só, por precedência (ver docs do mapeamento de situações):
///
/// 1. Cancelada · motivo — decisão do escritório, encerra a OS.
/// 2. Refeita · justificativa.
/// 3. Entregue em dd/mm — no prazo ou com N dias de atraso.
/// 4. Atrasada há N dias — em andamento com o prazo vencido.
/// 5. Pausada há X · motivo.
/// 6. Vence hoje / Vence amanhã.
/// 7. Em execução há X.
/// 8. Liberada há X — aguardando início desde a autorização.
AppStatusCardSituation osSituacao(OrdemServico os, DateTime agora) {
  final hoje = _dia(agora);
  final prazo = _dia(os.prazo);
  final diasParaPrazo = prazo.difference(hoje).inDays;

  switch (os.status) {
    case OrdemServicoStatus.cancelada:
      return AppStatusCardSituation(
        icon: AppIcons.alertCircle,
        label: os.motivoCancelamento == null
            ? 'Cancelada pelo escritório'
            : 'Cancelada · ${os.motivoCancelamento}',
        tone: AppStatusCardTone.danger,
      );
    case OrdemServicoStatus.refeita:
      return AppStatusCardSituation(
        icon: AppIcons.alertCircle,
        label: os.justificativaRefazer == null
            ? 'Precisa ser refeita'
            : 'Refeita · ${os.justificativaRefazer}',
        tone: AppStatusCardTone.danger,
      );
    case OrdemServicoStatus.entregue:
      final entrega = os.dataEntrega;
      if (entrega == null) {
        return const AppStatusCardSituation(
          icon: AppIcons.checkCircle2,
          label: 'Entregue',
          tone: AppStatusCardTone.success,
        );
      }
      final atraso = _dia(entrega).difference(prazo).inDays;
      return atraso > 0
          ? AppStatusCardSituation(
              icon: AppIcons.alertTriangle,
              label:
                  'Entregue em ${_fmtData(entrega)} · ${_dias(atraso)} de atraso',
              tone: AppStatusCardTone.danger,
            )
          : AppStatusCardSituation(
              icon: AppIcons.checkCircle2,
              label: 'Entregue em ${_fmtData(entrega)} · no prazo',
              tone: AppStatusCardTone.success,
            );
    case OrdemServicoStatus.aguardando:
    case OrdemServicoStatus.emExecucao:
    case OrdemServicoStatus.pausada:
      break;
  }

  if (diasParaPrazo < 0) {
    return AppStatusCardSituation(
      icon: AppIcons.alertTriangle,
      label: 'Atrasada há ${_dias(-diasParaPrazo)}',
      tone: AppStatusCardTone.danger,
    );
  }
  if (os.status == OrdemServicoStatus.pausada) {
    final desde = os.dataPausa;
    final tempo = desde == null
        ? 'Pausada'
        : 'Pausada há ${osDuracao(agora.difference(desde))}';
    return AppStatusCardSituation(
      icon: AppIcons.pause,
      label: os.motivoPausa == null ? tempo : '$tempo · ${os.motivoPausa}',
      tone: AppStatusCardTone.warning,
    );
  }
  if (diasParaPrazo <= 1) {
    return AppStatusCardSituation(
      icon: AppIcons.calendar,
      label: diasParaPrazo == 0 ? 'Vence hoje' : 'Vence amanhã',
      tone: AppStatusCardTone.warning,
    );
  }
  if (os.status == OrdemServicoStatus.emExecucao) {
    final desde = os.dataInicio;
    return AppStatusCardSituation(
      icon: AppIcons.clock,
      label: desde == null
          ? 'Em execução'
          : 'Em execução há ${osDuracao(agora.difference(desde))}',
      tone: AppStatusCardTone.info,
    );
  }
  return AppStatusCardSituation(
    icon: AppIcons.clock,
    label: 'Liberada há ${osDuracao(agora.difference(os.dataAutorizacao))}',
  );
}

/// Ação rápida do card por status — o próximo passo reversível: iniciar,
/// pausar ou retomar. Entregar e refazer encerram a OS e ficam só no
/// detalhe; OS encerradas não têm botão.
({String label, AppIconData icon, bool primary})? osAcaoRapida(
  OrdemServicoStatus status,
) => switch (status) {
  OrdemServicoStatus.aguardando => (
    label: 'Iniciar',
    icon: AppIcons.play,
    primary: true,
  ),
  OrdemServicoStatus.emExecucao => (
    label: 'Pausar',
    icon: AppIcons.pause,
    primary: false,
  ),
  OrdemServicoStatus.pausada => (
    label: 'Retomar',
    icon: AppIcons.play,
    primary: true,
  ),
  _ => null,
};

/// Card resumido da OS para as listas: o `AppStatusCard` do catálogo com o
/// status no topo, o código em destaque, o título do serviço e o local
/// abaixo, prazo e prioridade à direita, e no rodapé a situação do momento
/// ([osSituacao]) com a ação rápida do status ([osAcaoRapida]).
class OsSummaryCard extends StatelessWidget {
  const OsSummaryCard({
    super.key,
    required this.os,
    required this.agora,
    required this.onTap,
    this.onAcaoRapida,
  });

  final OrdemServico os;

  /// "Agora" de referência da situação — vem do `osRelogioProvider`.
  final DateTime agora;
  final VoidCallback onTap;

  /// Disparada pelo botão do rodapé; sem ela, o card não mostra botão.
  final VoidCallback? onAcaoRapida;

  @override
  Widget build(BuildContext context) {
    final acao = onAcaoRapida == null ? null : osAcaoRapida(os.status);
    return AppStatusCard(
      statusLabel: os.avaliacao != null
          ? '${os.status.label} · avaliada ${os.avaliacao!.nota}/5'
          : os.status.label,
      statusTone: osStatusTone(os.status),
      title: os.codigo,
      subtitle: os.titulo,
      caption: os.areaOuTalhao,
      meta: [
        AppStatusCardMeta(label: 'Prazo', value: _fmtDataCurta(os.prazo)),
        AppStatusCardMeta(
          label: 'Prioridade',
          value: os.prioridade.label,
          highlight:
              os.prioridade == PrioridadeOs.alta ||
              os.prioridade == PrioridadeOs.urgente,
        ),
      ],
      situation: osSituacao(os, agora),
      action: acao == null
          ? null
          : AppStatusCardAction(
              label: acao.label,
              icon: acao.icon,
              primary: acao.primary,
              onPressed: onAcaoRapida!,
            ),
      onTap: onTap,
    );
  }
}

/// Corpo completo da OS (aberto num bottom sheet) — todos os campos vindos da
/// solicitação/autorização, alocação de recursos, execução e histórico.
/// `actions` é a lista de botões específica de cada perfil.
class OsDetailBody extends StatelessWidget {
  const OsDetailBody({super.key, required this.os, this.actions = const []});

  final OrdemServico os;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.xs,
              fontWeight: AppTypography.weightSemibold,
              color: semantic.fgMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          child,
        ],
      ),
    );

    Widget kv(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgDefault,
              ),
            ),
          ),
        ],
      ),
    );

    Widget bulletList(List<String> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space1),
            child: Text(
              '· $item',
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgDefault,
              ),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${os.codigo} · ${os.titulo}',
                style: TextStyle(
                  fontSize: AppTypography.lg,
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
            ),
            AppChip(
              tone: osStatusTone(os.status),
              child: Text(os.status.label),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(
          os.descricao,
          style: TextStyle(fontSize: AppTypography.sm, color: semantic.fgMuted),
        ),
        section(
          'Solicitação e autorização',
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: semantic.bgSubtle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kv('Tipo de serviço', os.tipo.label),
                kv('Fazenda', os.fazenda),
                kv('Área / talhão', os.areaOuTalhao),
                kv('Solicitante', os.solicitante),
                kv('Data da solicitação', _fmtDataHora(os.dataSolicitacao)),
                kv('Autorizador', os.autorizador),
                kv('Data da autorização', _fmtDataHora(os.dataAutorizacao)),
                kv('Prioridade', os.prioridade.label),
                kv('Prazo', _fmtData(os.prazo)),
                kv('Responsável', os.responsavelExecucao),
              ],
            ),
          ),
        ),
        section(
          'Instruções de segurança',
          Text(
            os.instrucoesSeguranca,
            style: TextStyle(
              fontSize: AppTypography.sm,
              color: semantic.fgDefault,
            ),
          ),
        ),
        section('Mão de obra alocada', bulletList(os.maoDeObra)),
        section('Máquinas alocadas', bulletList(os.maquinas)),
        section('Insumos alocados', bulletList(os.insumos)),
        section('EPIs obrigatórios', bulletList(os.epis)),
        if (os.evidencias.isNotEmpty)
          section(
            'Evidências da execução',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final ev in os.evidencias)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcon(
                          AppIcons.camera,
                          size: AppSize.iconXs,
                          color: semantic.fgMuted,
                        ),
                        const SizedBox(width: AppSpacing.space2),
                        Expanded(
                          child: Text(
                            '${ev.legenda} — ${_fmtDataHora(ev.dataHora)}',
                            style: TextStyle(
                              fontSize: AppTypography.sm,
                              color: semantic.fgDefault,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (os.motivoPausa != null)
          section(
            'Motivo da pausa',
            Text(
              os.motivoPausa!,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgDefault,
              ),
            ),
          ),
        if (os.justificativaRefazer != null)
          section(
            'Justificativa do retrabalho',
            Text(
              os.justificativaRefazer!,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgDefault,
              ),
            ),
          ),
        if (os.motivoCancelamento != null)
          section(
            'Motivo do cancelamento',
            Text(
              os.motivoCancelamento!,
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgDefault,
              ),
            ),
          ),
        if (os.avaliacao != null)
          section(
            'Avaliação do escritório',
            Container(
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nota ${os.avaliacao!.nota}/5 · ${os.avaliacao!.avaliador}',
                    style: TextStyle(
                      fontWeight: AppTypography.weightSemibold,
                      color: semantic.fgDefault,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    os.avaliacao!.comentario,
                    style: TextStyle(
                      fontSize: AppTypography.sm,
                      color: semantic.fgMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Text(
                    _fmtDataHora(os.avaliacao!.dataHora),
                    style: TextStyle(
                      fontSize: AppTypography.xs,
                      color: semantic.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        section(
          'Histórico',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final evento in os.historico)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${evento.acao} — ${evento.autor}',
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgDefault,
                        ),
                      ),
                      Text(
                        _fmtDataHora(evento.dataHora),
                        style: TextStyle(
                          fontSize: AppTypography.xs,
                          color: semantic.fgMuted,
                        ),
                      ),
                      if (evento.observacao != null)
                        Text(
                          evento.observacao!,
                          style: TextStyle(
                            fontSize: AppTypography.xs,
                            color: semantic.fgMuted,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: actions,
          ),
        ],
      ],
    );
  }
}
