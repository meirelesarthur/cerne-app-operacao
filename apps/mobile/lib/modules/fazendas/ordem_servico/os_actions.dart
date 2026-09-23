import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import 'models.dart';
import 'state/ordem_servico_store.dart';
import 'widgets.dart';

/// Ciclo de execução da OS pelo Operacional, aberto em tela cheia a partir de
/// qualquer lista de OS (tela inicial e "Minhas OS"): detalhe completo com
/// iniciar, pausar/retomar, entregar ou marcar como refeita (com motivo ou
/// justificativa obrigatórios). Fonte única — Lei 2 — para as duas telas
/// conduzirem a OS do mesmo jeito.

/// Abre o detalhe da OS em **tela cheia** (padrão das visualizações: a folha
/// inferior fica só para escolhas e entradas curtas). Empilhado no navigator
/// raiz, cobre a navbar; o "Voltar" devolve à lista de origem.
void abrirDetalheOs(BuildContext context, WidgetRef ref, OrdemServico os) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(builder: (_) => OsDetailPage(osId: os.id)),
  );
}

/// Tela cheia do detalhe da OS. Observa o store: iniciar, pausar ou entregar
/// atualiza o status e as ações do rodapé no lugar, sem fechar a tela.
///
/// As ações ficam no rodapé fixo (`AppActionBar`), não no fim do conteúdo — o
/// detalhe é longo e o próximo passo (iniciar, entregar, retomar) não pode
/// depender de rolar até o fim. O CTA é o avanço natural do ciclo; "Marcar
/// como refeita" é a saída em contorno vermelho; a alternativa não destrutiva
/// (pausar, ou entregar direto de uma pausa) vai na faixa acima do CTA.
class OsDetailPage extends ConsumerWidget {
  const OsDetailPage({super.key, required this.osId});

  final String osId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final notifier = ref.read(ordemServicoStoreProvider.notifier);
    final os = notifier.byId(osId);
    final autor = os.responsavelExecucao;

    Widget alternativa(String label, VoidCallback onPressed) => AppButton(
      variant: AppButtonVariant.secondary,
      fullWidth: true,
      onPressed: onPressed,
      child: Text(label),
    );

    final actionBar = switch (os.status) {
      OrdemServicoStatus.aguardando => AppActionBar(
        primaryLabel: 'Iniciar execução',
        onPrimary: () => notifier.iniciar(os.id, autor: autor),
      ),
      OrdemServicoStatus.emExecucao => AppActionBar(
        summary: alternativa(
          'Pausar execução',
          () => _abrirPausar(context, ref, os.id),
        ),
        primaryLabel: 'Marcar como entregue',
        onPrimary: () => notifier.marcarEntregue(os.id, autor: autor),
        secondaryLabel: 'Marcar como refeita',
        onSecondary: () => _abrirRefazer(context, ref, os.id),
      ),
      OrdemServicoStatus.pausada => AppActionBar(
        summary: alternativa(
          'Marcar como entregue',
          () => notifier.marcarEntregue(os.id, autor: autor),
        ),
        primaryLabel: 'Retomar execução',
        onPrimary: () => notifier.retomar(os.id, autor: autor),
        secondaryLabel: 'Marcar como refeita',
        onSecondary: () => _abrirRefazer(context, ref, os.id),
      ),
      _ => null,
    };

    return AppPageScaffold(
      title: 'Detalhe da OS',
      onBack: () => Navigator.of(context).maybePop(),
      actionBar: actionBar,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space6),
        child: OsDetailBody(os: os),
      ),
    );
  }
}

void _abrirPausar(BuildContext context, WidgetRef ref, String osId) {
  final notifier = ref.read(ordemServicoStoreProvider.notifier);
  final controller = TextEditingController();

  showAppBottomSheet<void>(
    context,
    title: 'Pausar execução',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          label: 'Motivo da pausa',
          required: true,
          child: AppTextarea(
            controller: controller,
            placeholder: 'Ex.: falta de insumo, condição climática...',
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          fullWidth: true,
          onPressed: () {
            final motivo = controller.text.trim();
            if (motivo.isEmpty) return;
            final atual = notifier.byId(osId);
            notifier.pausar(
              osId,
              autor: atual.responsavelExecucao,
              motivo: motivo,
            );
            // Fecha só a dock: o detalhe em tela cheia continua aberto e
            // mostra o novo status.
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar pausa'),
        ),
      ],
    ),
  );
}

void _abrirRefazer(BuildContext context, WidgetRef ref, String osId) {
  final notifier = ref.read(ordemServicoStoreProvider.notifier);
  final controller = TextEditingController();

  showAppBottomSheet<void>(
    context,
    title: 'Marcar como refeita',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          label: 'Justificativa',
          required: true,
          hint: 'Explique por que o serviço precisa ser refeito.',
          child: AppTextarea(
            controller: controller,
            placeholder: 'Descreva o que impediu a conclusão...',
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          fullWidth: true,
          variant: AppButtonVariant.danger,
          onPressed: () {
            final justificativa = controller.text.trim();
            if (justificativa.isEmpty) return;
            final atual = notifier.byId(osId);
            notifier.marcarRefeita(
              osId,
              autor: atual.responsavelExecucao,
              justificativa: justificativa,
            );
            // Fecha só a dock: o detalhe em tela cheia continua aberto e
            // mostra o novo status.
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar retrabalho'),
        ),
      ],
    ),
  );
}
