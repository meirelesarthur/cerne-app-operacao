import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import 'models.dart';
import 'state/ordem_servico_store.dart';
import 'widgets.dart';

/// Ciclo de execução da OS pelo Operacional, aberto em tela cheia a partir de
/// qualquer lista de OS (tela inicial e "Minhas OS"): detalhe completo com
/// iniciar, pausar/retomar, entregar ou sinalizar que precisa refazer (com motivo ou
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
/// depender de rolar até o fim. O CTA é o avanço natural do ciclo; "Refazer
/// serviço" é a saída em contorno vermelho; a alternativa não destrutiva
/// (pausar, ou entregar direto de uma pausa) vai na faixa acima do CTA.
class OsDetailPage extends ConsumerWidget {
  const OsDetailPage({super.key, required this.osId});

  final String osId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(ordemServicoStoreProvider.select((s) => s.ordens));
    final os = ref.read(ordemServicoStoreProvider.notifier).byId(osId);

    final actionBar = switch (os.status) {
      OrdemServicoStatus.aguardando => AppActionBar(
        primaryLabel: 'Iniciar execução',
        onPrimary: () => confirmarIniciarOs(context, ref, os),
      ),
      OrdemServicoStatus.emExecucao => AppActionBar(
        alternativeLabel: 'Pausar execução',
        onAlternative: () => abrirPausarOs(context, ref, os.id),
        primaryLabel: 'Entregar serviço',
        onPrimary: () => confirmarEntregarOs(context, ref, os),
        secondaryLabel: 'Refazer serviço',
        onSecondary: () => abrirRefazerOs(context, ref, os.id),
      ),
      OrdemServicoStatus.pausada => AppActionBar(
        alternativeLabel: 'Entregar serviço',
        onAlternative: () => confirmarEntregarOs(context, ref, os),
        primaryLabel: 'Retomar execução',
        onPrimary: () => confirmarRetomarOs(context, ref, os),
        secondaryLabel: 'Refazer serviço',
        onSecondary: () => abrirRefazerOs(context, ref, os.id),
      ),
      _ => null,
    };

    return AppPageScaffold(
      title: 'Ordem de serviço',
      onBack: () => Navigator.of(context).maybePop(),
      actionBar: actionBar,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space6),
        child: OsDetailBody(os: os),
      ),
    );
  }
}

void abrirPausarOs(BuildContext context, WidgetRef ref, String osId) {
  final notifier = ref.read(ordemServicoStoreProvider.notifier);

  showAppBottomSheet<void>(
    context,
    title: 'Pausar a ${notifier.byId(osId).codigo}?',
    // Com motivo sendo digitado, tocar fora não descarta o texto.
    dismissible: false,
    child: _MotivoSheet(
      opcoes: motivosPausa,
      rotuloCampo: 'Por que vai pausar?',
      rotuloOutro: 'Conte o motivo',
      placeholderOutro: 'Ex.: chegou uma ordem mais urgente',
      erroSemEscolha: 'Escolha o motivo da pausa para continuar.',
      erroOutroVazio: 'Escreva o motivo da pausa para continuar.',
      confirmar: 'Confirmar pausa',
      onConfirmar: (motivo) {
        final atual = notifier.byId(osId);
        notifier.pausar(osId, autor: atual.responsavelExecucao, motivo: motivo);
      },
    ),
  );
}

void abrirRefazerOs(BuildContext context, WidgetRef ref, String osId) {
  final notifier = ref.read(ordemServicoStoreProvider.notifier);

  showAppBottomSheet<void>(
    context,
    title: 'A ${notifier.byId(osId).codigo} precisa ser refeita?',
    dismissible: false,
    child: _MotivoSheet(
      rotuloOutro: 'Por que precisa refazer?',
      placeholderOutro: 'Ex.: a cerca ficou torta no trecho perto da porteira',
      erroOutroVazio: 'Escreva por que o serviço precisa ser refeito.',
      confirmar: 'Confirmar',
      perigo: true,
      onConfirmar: (justificativa) {
        final atual = notifier.byId(osId);
        notifier.marcarRefeita(
          osId,
          autor: atual.responsavelExecucao,
          justificativa: justificativa,
        );
      },
    ),
  );
}

/// Motivos prontos da pausa: tocar é mais rápido e mais seguro que digitar de
/// luva. "Outro motivo" abre o campo de texto.
const motivosPausa = [
  'Chuva ou tempo ruim',
  'Falta de insumo ou material',
  'Máquina ou equipamento quebrado',
  'Parada para refeição',
];

const _outroMotivo = 'Outro motivo';

/// Corpo das docks de motivo (pausar e refazer). Com [opcoes], a pessoa toca
/// num motivo pronto e só digita em "Outro motivo"; sem [opcoes], o texto é o
/// próprio motivo. Confirmar sem motivo mostra o erro no campo em vez de não
/// fazer nada.
class _MotivoSheet extends StatefulWidget {
  const _MotivoSheet({
    this.opcoes = const [],
    this.rotuloCampo,
    required this.rotuloOutro,
    required this.placeholderOutro,
    this.erroSemEscolha,
    required this.erroOutroVazio,
    required this.confirmar,
    required this.onConfirmar,
    this.perigo = false,
  });

  final List<String> opcoes;
  final String? rotuloCampo;
  final String rotuloOutro;
  final String placeholderOutro;
  final String? erroSemEscolha;
  final String erroOutroVazio;
  final String confirmar;
  final ValueChanged<String> onConfirmar;
  final bool perigo;

  @override
  State<_MotivoSheet> createState() => _MotivoSheetState();
}

class _MotivoSheetState extends State<_MotivoSheet> {
  final _controller = TextEditingController();
  String? _escolha;
  String? _erroEscolha;
  String? _erroTexto;

  bool get _comOpcoes => widget.opcoes.isNotEmpty;
  bool get _digita => !_comOpcoes || _escolha == _outroMotivo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_comOpcoes && _escolha == null) {
      setState(() => _erroEscolha = widget.erroSemEscolha);
      return;
    }
    final texto = _controller.text.trim();
    if (_digita && texto.isEmpty) {
      setState(() => _erroTexto = widget.erroOutroVazio);
      return;
    }
    widget.onConfirmar(_digita ? texto : _escolha!);
    // Fecha só a dock: o detalhe em tela cheia continua aberto e mostra o
    // novo status.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_comOpcoes)
          AppFormField(
            label: widget.rotuloCampo ?? '',
            required: true,
            error: _erroEscolha,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final opcao in [...widget.opcoes, _outroMotivo]) ...[
                  AppMenuItem(
                    label: opcao,
                    active: _escolha == opcao,
                    surface: AppMenuItemSurface.subtle,
                    showShadow: false,
                    trailing: _escolha == opcao
                        ? const AppIcon(AppIcons.check, size: AppSize.iconMd)
                        : const SizedBox.shrink(),
                    onTap: () => setState(() {
                      _escolha = opcao;
                      _erroEscolha = null;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ],
            ),
          ),
        if (_digita) ...[
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: widget.rotuloOutro,
            required: true,
            error: _erroTexto,
            hint: _registroHistorico,
            child: AppTextarea(
              controller: _controller,
              minLines: 3,
              placeholder: widget.placeholderOutro,
              onChanged: (_) {
                if (_erroTexto != null) setState(() => _erroTexto = null);
              },
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.space1),
            child: Text(_registroHistorico),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppButton(
          fullWidth: true,
          size: AppButtonSize.lg,
          variant: widget.perigo
              ? AppButtonVariant.danger
              : AppButtonVariant.primary,
          onPressed: _confirmar,
          child: Text(widget.confirmar),
        ),
        const SizedBox(height: AppSpacing.space2),
        AppButton(
          fullWidth: true,
          size: AppButtonSize.lg,
          variant: AppButtonVariant.subtle,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

const _registroHistorico =
    'Fica registrado no histórico da OS com data, hora e o seu nome.';

/// Confirmação obrigatória antes de iniciar: a ação gera histórico e o
/// trabalho é braçal — toque acidental é esperado, não exceção.
Future<void> confirmarIniciarOs(
  BuildContext context,
  WidgetRef ref,
  OrdemServico os,
) async {
  final ok = await showAppConfirm(
    context,
    title: 'Iniciar a ${os.codigo}?',
    message: '${os.titulo}.\n\n$_registroHistorico',
    confirmLabel: 'Iniciar execução',
  );
  if (!ok) return;
  ref
      .read(ordemServicoStoreProvider.notifier)
      .iniciar(os.id, autor: os.responsavelExecucao);
}

Future<void> confirmarRetomarOs(
  BuildContext context,
  WidgetRef ref,
  OrdemServico os,
) async {
  final ok = await showAppConfirm(
    context,
    title: 'Retomar a ${os.codigo}?',
    message: '${os.titulo}.\n\n$_registroHistorico',
    confirmLabel: 'Retomar execução',
  );
  if (!ok) return;
  ref
      .read(ordemServicoStoreProvider.notifier)
      .retomar(os.id, autor: os.responsavelExecucao);
}

Future<void> confirmarEntregarOs(
  BuildContext context,
  WidgetRef ref,
  OrdemServico os,
) async {
  final ok = await showAppConfirm(
    context,
    title: 'Entregar a ${os.codigo}?',
    message:
        '${os.titulo}.\n\nIsso encerra a OS e não dá para desfazer pelo '
        'aplicativo. $_registroHistorico',
    confirmLabel: 'Entregar serviço',
  );
  if (!ok) return;
  ref
      .read(ordemServicoStoreProvider.notifier)
      .marcarEntregue(os.id, autor: os.responsavelExecucao);
}

/// Ação rápida do card ([osAcaoRapida]): sempre passa pela confirmação —
/// iniciar e retomar abrem a caixa de confirmação; pausar abre a dock do
/// motivo, que só registra com "Confirmar pausa".
void executarAcaoRapidaOs(
  BuildContext context,
  WidgetRef ref,
  OrdemServico os,
) {
  switch (os.status) {
    case OrdemServicoStatus.aguardando:
      confirmarIniciarOs(context, ref, os);
    case OrdemServicoStatus.emExecucao:
      abrirPausarOs(context, ref, os.id);
    case OrdemServicoStatus.pausada:
      confirmarRetomarOs(context, ref, os);
    default:
      break;
  }
}
