import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/mocks.dart' as confinamento_mocks;
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';
import 'success_screen.dart';

const _responsaveis = <AppFormSelectOption>[
  AppFormSelectOption(value: 'João Oliveira', label: 'João Oliveira'),
  AppFormSelectOption(value: 'Maria Souza', label: 'Maria Souza'),
  AppFormSelectOption(value: 'Carlos Dias', label: 'Carlos Dias'),
];

const _aspectos = <AppFormSelectOption>[
  AppFormSelectOption(value: 'fresco', label: 'Fresco'),
  AppFormSelectOption(value: 'umido', label: 'Úmido'),
  AppFormSelectOption(value: 'ressecado', label: 'Ressecado'),
  AppFormSelectOption(value: 'mofado', label: 'Mofado'),
  AppFormSelectOption(value: 'selecionado', label: 'Selecionado'),
  AppFormSelectOption(value: 'contaminado', label: 'Contaminado'),
];

const _comportamentos = <AppFormSelectOption>[
  AppFormSelectOption(value: 'calmos', label: 'Calmos'),
  AppFormSelectOption(value: 'agitadosFamintos', label: 'Agitados/Famintos'),
  AppFormSelectOption(value: 'esperandoNoCocho', label: 'Esperando no cocho'),
  AppFormSelectOption(value: 'indiferentes', label: 'Indiferentes'),
  AppFormSelectOption(value: 'apaticos', label: 'Apáticos'),
  AppFormSelectOption(value: 'sinaisDesconforto', label: 'Sinais de desconforto'),
];

const _tiposOcorrencia = <AppFormSelectOption>[
  AppFormSelectOption(value: 'animal', label: 'Animal'),
  AppFormSelectOption(value: 'infraestrutura', label: 'Infraestrutura'),
  AppFormSelectOption(value: 'ambiente', label: 'Ambiente'),
  AppFormSelectOption(value: 'outro', label: 'Outro'),
];

const _prioridades = <AppFormSelectOption>[
  AppFormSelectOption(value: 'baixa', label: 'Baixa'),
  AppFormSelectOption(value: 'media', label: 'Média'),
  AppFormSelectOption(value: 'alta', label: 'Alta'),
];

T _byValue<T>(List<T> values, String value) =>
    values.firstWhere((v) => (v as dynamic).name == value);

/// Rascunho mutável de uma avaliação de curral dentro da leitura em
/// andamento — os models de domínio (`AvaliacaoCurral`/`Ocorrencia`) são
/// imutáveis, então o formulário acumula aqui e só converte ao salvar.
class _AvaliacaoDraft {
  _AvaliacaoDraft(this.curralId)
    : escore = EscoreCocho.ideal,
      ajustePct = EscoreCocho.ideal.ajusteSugeridoPct;

  final String curralId;
  EscoreCocho escore;
  double ajustePct;
  num sobrasKg = 0;
  num sobrasPct = 0;
  AspectoSobras? aspecto;
  ComportamentoAnimal? comportamento;
  String observacoes = '';
  final List<Ocorrencia> ocorrencias = [];

  AvaliacaoCurral toModel() => AvaliacaoCurral(
    curralId: curralId,
    escore: escore,
    ajusteProximoTratoPct: ajustePct,
    sobrasKg: sobrasKg.toDouble(),
    sobrasPct: sobrasPct.toDouble(),
    aspecto: aspecto,
    comportamento: comportamento,
    observacoes: observacoes.isEmpty ? null : observacoes,
    ocorrencias: List.of(ocorrencias),
  );
}

/// Leitura de Cocho (spec §4.5): multi-curral, escore 0–4 com ajuste sugerido
/// automático (editável), sobras, aspecto, comportamento e ocorrências com
/// foto.
class LeituraCochoFlow extends ConsumerStatefulWidget {
  const LeituraCochoFlow({super.key});

  @override
  ConsumerState<LeituraCochoFlow> createState() => _LeituraCochoFlowState();
}

class _LeituraCochoFlowState extends ConsumerState<LeituraCochoFlow> {
  String? _responsavel;
  final List<_AvaliacaoDraft> _avaliacoes = [];
  bool? _queued;
  bool _attempted = false;

  bool get _valid => _responsavel != null && _avaliacoes.isNotEmpty;

  void _confirmar() {
    if (!_valid) {
      setState(() => _attempted = true);
      return;
    }
    final leitura = LeituraCocho(
      id: 'lc-${DateTime.now().microsecondsSinceEpoch}',
      dataHora: DateTime.now(),
      responsavel: _responsavel!,
      avaliacoes: [for (final d in _avaliacoes) d.toModel()],
    );
    ref.read(confinamentoStoreProvider.notifier).registrarLeituraCocho(leitura);

    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: leitura.id,
              label: 'Leitura de cocho',
              detail: '${_avaliacoes.length} currais avaliados',
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
        title: 'Leitura de cocho salva',
        queued: _queued!,
        effects: 'O ajuste sugerido entra como referência no próximo trato.',
      );
    }

    final currais = ref.watch(
      confinamentoStoreProvider.select((s) => s.currais),
    );
    final adicionados = _avaliacoes.map((a) => a.curralId).toSet();
    final disponiveis = currais.where((c) => !adicionados.contains(c.id));

    return FlowShell(
      title: 'Leitura de cocho',
      primaryLabel: 'Salvar leitura',
      onPrimary: _confirmar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: 'Responsável',
            required: true,
            error: _attempted && _responsavel == null
                ? 'Selecione o responsável.'
                : null,
            child: AppFormSelect(
              options: _responsaveis,
              value: _responsavel,
              placeholder: 'Selecione',
              onChanged: (v) => setState(() => _responsavel = v),
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          AppFormField(
            label: 'Adicionar curral',
            error: _attempted && _avaliacoes.isEmpty
                ? 'Adicione ao menos um curral.'
                : null,
            child: AppFormSelect(
              // Força recriação do DropdownButtonFormField a cada curral
              // adicionado: sem isso, seu estado interno mantém o valor
              // recém-selecionado mesmo depois de sair de `options`
              // (removido de `disponiveis`), quebrando a invariante do
              // Flutter de "value só pode ser um item existente na lista".
              key: ValueKey(_avaliacoes.length),
              options: [
                for (final c in disponiveis)
                  AppFormSelectOption(value: c.id, label: c.nome),
              ],
              placeholder: 'Selecione o curral',
              onChanged: (v) {
                if (v == null) return;
                setState(() => _avaliacoes.add(_AvaliacaoDraft(v)));
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space5),
          for (final draft in _avaliacoes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
              child: _AvaliacaoCard(
                draft: draft,
                curralNome: confinamento_mocks.currais
                    .firstWhere((c) => c.id == draft.curralId)
                    .nome,
                onChanged: () => setState(() {}),
                onRemover: () => setState(() => _avaliacoes.remove(draft)),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvaliacaoCard extends StatelessWidget {
  const _AvaliacaoCard({
    required this.draft,
    required this.curralNome,
    required this.onChanged,
    required this.onRemover,
  });

  final _AvaliacaoDraft draft;
  final String curralNome;
  final VoidCallback onChanged;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                curralNome,
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              AppIconButton(
                icon: const Icon(LucideIcons.x, size: 16),
                label: 'Remover $curralNome desta leitura',
                onPressed: onRemover,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Escore',
            required: true,
            child: AppFormSelect(
              options: [
                for (final e in EscoreCocho.values)
                  AppFormSelectOption(value: e.name, label: e.label),
              ],
              value: draft.escore.name,
              onChanged: (v) {
                final escore = _byValue(EscoreCocho.values, v!);
                draft.escore = escore;
                draft.ajustePct = escore.ajusteSugeridoPct;
                onChanged();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Ajuste próx. trato (%)',
            hint: 'Sugerido pelo escore — pode ser ajustado.',
            child: AppStepper(
              value: draft.ajustePct,
              onChanged: (v) {
                draft.ajustePct = v.toDouble();
                onChanged();
              },
              min: -100,
              max: 100,
              suffix: '%',
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Expanded(
                child: AppFormField(
                  label: 'Sobras (kg)',
                  child: AppStepper(
                    value: draft.sobrasKg,
                    onChanged: (v) {
                      draft.sobrasKg = v;
                      onChanged();
                    },
                    suffix: 'kg',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: AppFormField(
                  label: 'Sobras (%)',
                  child: AppStepper(
                    value: draft.sobrasPct,
                    onChanged: (v) {
                      draft.sobrasPct = v;
                      onChanged();
                    },
                    max: 100,
                    suffix: '%',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Aspecto das sobras',
            child: AppFormSelect(
              options: _aspectos,
              value: draft.aspecto?.name,
              placeholder: 'Selecione',
              onChanged: (v) {
                draft.aspecto = v == null ? null : _byValue(AspectoSobras.values, v);
                onChanged();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Comportamento animal',
            child: AppFormSelect(
              options: _comportamentos,
              value: draft.comportamento?.name,
              placeholder: 'Selecione',
              onChanged: (v) {
                draft.comportamento =
                    v == null ? null : _byValue(ComportamentoAnimal.values, v);
                onChanged();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppFormField(
            label: 'Observações gerais',
            child: AppTextarea(
              initialValue: draft.observacoes,
              onChanged: (v) {
                draft.observacoes = v;
              },
              minLines: 2,
              maxLines: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppAddableGroupList(
            groups: const ['Ocorrências'],
            counts: {'Ocorrências': draft.ocorrencias.length},
            onAdd: (_) => _adicionarOcorrencia(context, draft, onChanged),
          ),
          for (final o in draft.ocorrencias)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppChip(
                    tone: switch (o.prioridade) {
                      OcorrenciaPrioridade.alta => AppChipTone.red,
                      OcorrenciaPrioridade.media => AppChipTone.amber,
                      OcorrenciaPrioridade.baixa => AppChipTone.neutral,
                    },
                    child: Text(o.prioridade.name),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Text(
                      o.descricao,
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
    );
  }
}

void _adicionarOcorrencia(
  BuildContext context,
  _AvaliacaoDraft draft,
  VoidCallback onChanged,
) {
  OcorrenciaTipo tipo = OcorrenciaTipo.animal;
  OcorrenciaPrioridade prioridade = OcorrenciaPrioridade.media;
  var descricao = '';
  String? foto;

  showAppBottomSheet<void>(
    context,
    title: 'Nova ocorrência',
    child: StatefulBuilder(
      builder: (context, setSheetState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Tipo de ocorrência',
              required: true,
              child: AppFormSelect(
                options: _tiposOcorrencia,
                value: tipo.name,
                onChanged: (v) =>
                    setSheetState(() => tipo = _byValue(OcorrenciaTipo.values, v!)),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Prioridade',
              required: true,
              child: AppFormSelect(
                options: _prioridades,
                value: prioridade.name,
                onChanged: (v) => setSheetState(
                  () => prioridade = _byValue(OcorrenciaPrioridade.values, v!),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Descrição / recomendação',
              child: AppTextarea(
                onChanged: (v) => descricao = v,
                minLines: 2,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Foto',
              child: AppFileUpload(
                value: foto,
                accept: '.jpg,.png',
                hint: 'Toque para anexar foto da ocorrência',
                onChanged: (v) => setSheetState(() => foto = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            AppButton(
              fullWidth: true,
              onPressed: () {
                draft.ocorrencias.add(
                  Ocorrencia(
                    tipo: tipo,
                    prioridade: prioridade,
                    descricao: descricao,
                    fotoPath: foto,
                  ),
                );
                onChanged();
                Navigator.of(context).pop();
              },
              child: const Text('Adicionar ocorrência'),
            ),
          ],
        );
      },
    ),
  );
}
