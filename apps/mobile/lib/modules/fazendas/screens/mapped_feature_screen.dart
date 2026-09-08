import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../ui/ui.dart';
import '../functional_catalog.dart';
import '../functional_journey_engine.dart';
import '../state/prototype_records_store.dart';

class MappedFeatureScreen extends StatelessWidget {
  const MappedFeatureScreen({
    super.key,
    required this.featureId,
    required this.profile,
    this.centerRoute,
  });

  final String featureId;
  final FeatureProfile profile;
  final String? centerRoute;

  @override
  Widget build(BuildContext context) {
    final feature = featureById(featureId);
    final fallbackCenterRoute = profile == FeatureProfile.administration
        ? '/fazendas/administracao'
        : '/fazendas/operacional';
    final resolvedCenterRoute = centerRoute ?? fallbackCenterRoute;

    if (feature == null || feature.profile != profile) {
      return AppEmptyState(
        icon: AppIcons.shieldAlert,
        title: 'Funcionalidade fora deste perfil',
        description:
            'Volte ao ambiente correspondente para acessar esta responsabilidade.',
        action: AppButton(
          onPressed: () => context.go(resolvedCenterRoute),
          child: const Text('Voltar ao ambiente'),
        ),
      );
    }

    return _MappedFeatureJourney(
      key: ValueKey('${profile.name}/${feature.id}'),
      feature: feature,
      centerRoute: resolvedCenterRoute,
    );
  }
}

class _MappedFeatureJourney extends ConsumerStatefulWidget {
  const _MappedFeatureJourney({
    super.key,
    required this.feature,
    required this.centerRoute,
  });

  final FeatureDefinition feature;
  final String centerRoute;

  @override
  ConsumerState<_MappedFeatureJourney> createState() =>
      _MappedFeatureJourneyState();
}

class _MappedFeatureJourneyState extends ConsumerState<_MappedFeatureJourney> {
  late final FunctionalJourneyController _journey;
  PrototypeRecord? _lastCreated;

  FeatureDefinition get feature => widget.feature;
  String get dataSourceId => feature.dataSourceId ?? feature.id;

  @override
  void initState() {
    super.initState();
    _journey = FunctionalJourneyController(feature);
  }

  void _startForm() => setState(_journey.startForm);

  void _showList() => setState(_journey.showList);

  /// CTA do rodapé em formulário com etapas: avança enquanto houver etapa e
  /// só salva na última. Sem etapas declaradas, salva direto — o botão do
  /// arquétipo *bottom fixed* continua sendo "Salvar".
  void _advance() {
    if (_journey.hasSteps && !_journey.isLastStep) {
      setState(() {
        _journey.advanceStep();
      });
      return;
    }
    _submit();
  }

  void _retreat() => setState(() {
    _journey.retreatStep();
  });

  void _setValue(String fieldId, String value) {
    setState(() => _journey.setValue(fieldId, value));
  }

  void _removeCollectionItem(String group, int index) =>
      setState(() => _journey.removeGroupItem(group, index));

  /// Formulário de **um item** da coleção, na folha inferior. É o que faltava
  /// para a coleção deixar de ser um contador: cada "Adicionar" abre os campos
  /// que o contrato define para o item e a linha entra na lista com o dado
  /// verdadeiro. Coleção sem campos declarados continua só contando.
  void _addCollectionItem(BuildContext context, FeatureCollection collection) {
    if (collection.fields.isEmpty) {
      setState(() => _journey.addGroupItem(collection.name));
      return;
    }

    final values = <String, String>{};
    var attempted = false;

    showAppBottomSheet<void>(
      context,
      title: collection.itemLabel ?? collection.name,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < collection.fields.length; index++) ...[
              _FeatureFieldControl(
                field: collection.fields[index],
                value: values[collection.fields[index].id] ?? '',
                isRequired: collection.fields[index].isRequired,
                error: attempted
                    ? featureItemFieldError(collection.fields[index], values)
                    : null,
                onChanged: (value) => setSheetState(() {
                  values[collection.fields[index].id] = value;
                }),
              ),
              if (index < collection.fields.length - 1)
                const SizedBox(height: AppSpacing.space3),
            ],
            const SizedBox(height: AppSpacing.space4),
            // Sem botão em beco sem saída (mesma regra de `FlowShell`): o
            // toque sempre responde, e o que falta aparece nos campos.
            AppButton(
              fullWidth: true,
              onPressed: () {
                if (!isCollectionItemValid(collection, values)) {
                  setSheetState(() => attempted = true);
                  return;
                }
                setState(
                  () => _journey.addGroupItem(collection.name, {...values}),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final draft = _journey.submit();
    if (draft == null) {
      setState(() {});
      return;
    }
    _lastCreated = ref
        .read(prototypeRecordsProvider.notifier)
        .addRecord(
          featureId: dataSourceId,
          title: draft.title,
          description: draft.description,
          status: draft.status,
          details: draft.details,
        );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_journey.mode == FunctionalJourneyMode.success) {
      return AppSuccessPanel(
        title:
            feature.successTitle ??
            '${_lastCreated?.title ?? feature.title} salvo',
        description: Text(
          feature.successDescription ??
              'O registro foi incluído no protótipo e já está disponível nesta sessão.',
        ),
        actions: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (feature.listMode) ...[
              AppButton(
                fullWidth: true,
                onPressed: _showList,
                child: const Text('Ver registros'),
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
            AppButton(
              fullWidth: true,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go(widget.centerRoute),
              child: const Text('Voltar à central'),
            ),
          ],
        ),
      );
    }

    final isForm = _journey.mode == FunctionalJourneyMode.form;
    // Dentro de um formulário em etapas, o voltar do cabeçalho recua uma etapa
    // em vez de abandonar o preenchimento: sair perdendo tudo o que já foi
    // digitado é o pior desfecho possível num cadastro longo.
    final inStep = isForm && _journey.hasSteps && !_journey.isFirstStep;
    final backToRecords = isForm && feature.listMode && !inStep;
    final step = isForm ? _journey.currentStep : null;

    // Título e voltar vivem na faixa de 64 px sobre o canvas, a régua de
    // etapas dentro da folha branca e o rodapé colado na base: a anatomia
    // inteira vem de [AppPageBody] — a mesma peça dos fluxos operacionais e do
    // Bank —, sem `Scaffold` porque o shell já resolveu a área segura.
    return AppPageBody(
      title: _journey.mode == FunctionalJourneyMode.form
          ? feature.createAction ?? feature.title
          : feature.title,
      onBack: inStep
          ? _retreat
          : backToRecords
          ? _showList
          : () => context.go(widget.centerRoute),
      actionIcon: isForm ? AppIcons.moreVertical : null,
      actionLabel: isForm ? 'Mais opções' : null,
      onAction: isForm ? () => _showFormDetails(context) : null,
      totalSteps: step != null ? _journey.stepCount : null,
      currentStep: _journey.stepIndex + 1,
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      actionBar: isForm
          ? AppActionBar(
              primaryLabel: _journey.isLastStep
                  ? feature.primaryAction ?? 'Salvar registro'
                  : 'Continuar',
              primaryIcon: _journey.isLastStep
                  ? AppIcons.saveAll
                  : AppIcons.arrowRight,
              onPrimary: _advance,
              secondaryLabel: inStep
                  ? 'Voltar'
                  : feature.listMode
                  ? 'Cancelar'
                  : null,
              onSecondary: inStep
                  ? _retreat
                  : feature.listMode
                  ? _showList
                  : null,
            )
          : null,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          if (!isForm) ...[
            _FeatureIntroduction(feature: feature),
            const SizedBox(height: AppSpacing.space4),
          ],
          // O card "Recursos envolvidos" (Bluetooth/RFID/Balança...) saiu
          // daqui (ver plano de UX): quando a função usa hardware simulado, o
          // próprio `AppHardwareSimulator` já mostra isso mais abaixo, na hora
          // de usar — listar de novo antes, em termos técnicos, só adiantava
          // jargão sem ajudar a decisão.
          if (feature.auditExport case final auditExport?)
            _AuditExportJourney(kind: auditExport)
          else if (feature.listMode &&
              _journey.mode == FunctionalJourneyMode.list)
            _RecordsList(
              feature: feature,
              records: ref
                  .watch(prototypeRecordsProvider)
                  .recordsFor(dataSourceId),
              // banco-real: administração pode criar quando a própria tela
              // declara campos (ex.: Produtos) — deixou de ser exclusivo do
              // perfil operacional. Ver
              // docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md.
              // banco-real (onda 1): `readOnly` bloqueia a criação mesmo com
              // `fields` preenchidos — cadastro estruturante ou decisão que
              // pertence ao desktop, o app só consulta. Ver
              // docs/ESTEIRA-FRONTEIRA-OPERACIONAL.md, Onda 1.
              canCreate: feature.fields.isNotEmpty && !feature.readOnly,
              onCreate: _startForm,
            )
          else
            _FeatureForm(
              feature: feature,
              journey: _journey,
              onValueChanged: _setValue,
              onAddCollectionItem: (collection) =>
                  _addCollectionItem(context, collection),
              onRemoveCollectionItem: _removeCollectionItem,
            ),
        ],
      ),
    );
  }

  void _showFormDetails(BuildContext context) {
    showAppBottomSheet<void>(
      context,
      title: feature.title,
      child: Text(feature.objective),
    );
  }
}

class _AuditExportJourney extends StatelessWidget {
  const _AuditExportJourney({required this.kind});

  final AuditExportKind kind;

  @override
  Widget build(BuildContext context) {
    return AppAuditExportPanel(
      filename: kind == AuditExportKind.estoque
          ? 'auditoria-estoque'
          : 'auditoria-pecuaria',
      rows: switch (kind) {
        AuditExportKind.estoque => _stockAuditRows,
        AuditExportKind.pecuaria => _livestockAuditRows,
      },
      downloadFile: true,
      onExport: (_) {},
    );
  }
}

const _stockAuditRows = <Map<String, String>>[
  {
    'data': '2026-08-16 08:42',
    'usuário': 'João Oliveira',
    'ação': 'Batida registrada',
    'entidade': 'Ração engorda',
    'quantidade': '1.000 kg',
  },
  {
    'data': '2026-08-15 17:18',
    'usuário': 'Maria Souza',
    'ação': 'Estoque ajustado',
    'entidade': 'Sal mineral',
    'quantidade': '120 kg',
  },
  {
    'data': '2026-08-14 14:05',
    'usuário': 'Carlos Dias',
    'ação': 'Entrada confirmada',
    'entidade': 'Milho moído',
    'quantidade': '4.500 kg',
  },
];

const _livestockAuditRows = <Map<String, String>>[
  {
    'data': '2026-08-16 09:15',
    'usuário': 'Maria Souza',
    'ação': 'Diagnóstico registrado',
    'entidade': 'Lote Matrizes 01',
    'resultado': '94 prenhes',
  },
  {
    'data': '2026-08-15 16:20',
    'usuário': 'João Oliveira',
    'ação': 'Transferência concluída',
    'entidade': 'RFID 982000123456120',
    'resultado': 'Lote 42',
  },
  {
    'data': '2026-08-14 11:30',
    'usuário': 'Carlos Dias',
    'ação': 'Pesagem registrada',
    'entidade': 'Lote Recria 02',
    'resultado': '318 kg médio',
  },
];

/// Abertura da função dentro da folha: o objetivo em uma linha.
///
/// As chips de perfil ("Operação"/"Administração") e de status ("Funcional no
/// protótipo") já tinham saído daqui — a primeira repetia o ambiente em que a
/// pessoa entrou, a segunda é informação de desenvolvimento. Os detalhes de
/// fonte/premissa também são internos e não aparecem na jornada. Agora o título
/// e o voltar também saíram: viraram a barra superior fixa do padrão global,
/// acima da folha.
class _FeatureIntroduction extends StatelessWidget {
  const _FeatureIntroduction({required this.feature});

  final FeatureDefinition feature;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feature.objective, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _RecordsList extends StatefulWidget {
  const _RecordsList({
    required this.feature,
    required this.records,
    required this.canCreate,
    required this.onCreate,
  });

  final FeatureDefinition feature;
  final List<PrototypeRecord> records;
  final bool canCreate;
  final VoidCallback onCreate;

  @override
  State<_RecordsList> createState() => _RecordsListState();
}

class _RecordsListState extends State<_RecordsList> {
  static const _pageSize = 5;
  late final TextEditingController _searchController;
  var _query = '';
  var _page = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() {
    _query = value;
    _page = 0;
  });

  @override
  Widget build(BuildContext context) {
    final records = _recordsWithMinimumSample(widget.feature, widget.records);
    final query = _query.trim().toLowerCase();
    final filteredRecords = query.isEmpty
        ? records
        : records
              .where((record) {
                final searchable = [
                  record.title,
                  record.description,
                  ...record.details.keys,
                  ...record.details.values,
                ].join(' ').toLowerCase();
                return searchable.contains(query);
              })
              .toList(growable: false);
    final pageCount = (filteredRecords.length / _pageSize).ceil().clamp(1, 999);
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, filteredRecords.length);
    final visibleRecords = filteredRecords.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: AppSectionTitle(child: Text('Registros')),
                  ),
                  AppChip(child: Text('${records.length}')),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Buscar registros',
                child: AppTextInput(
                  controller: _searchController,
                  placeholder: 'Nome, situação ou detalhe',
                  prefixIcon: const AppIcon(AppIcons.aiSearch),
                  onChanged: _setQuery,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              if (filteredRecords.isEmpty)
                // banco-real (correção de regressão): a busca (`dbec5b7`)
                // trocou a mensagem de vazio por uma única, genérica — sem
                // diferenciar "a busca não achou nada" (`records` existe,
                // só o filtro zerou) de "não há registro nenhum". A segunda
                // precisa continuar dizendo a verdade por perfil (criar vs.
                // somente leitura vs. genérico), senão uma consulta
                // somente leitura sem dado sincronizado passa a impressão
                // de que o app perdeu o cadastro. Ver
                // `mapped_feature_screen_test.dart`, "Áreas mostra estado
                // vazio honesto...".
                AppEmptyState(
                  icon: query.isNotEmpty
                      ? AppIcons.search
                      : AppIcons.clipboardCheck,
                  title: widget.feature.emptyLabel ?? 'Nenhum registro encontrado',
                  description: query.isNotEmpty
                      ? 'Ajuste a busca para encontrar outro cadastro.'
                      : widget.canCreate
                      ? 'Use a ação abaixo para criar o primeiro registro desta rotina.'
                      : widget.feature.readOnly
                      ? 'O cadastro desta rotina é feito no sistema web. Assim que sincronizar, os registros aparecem aqui.'
                      : 'Os registros operacionais desta sessão aparecerão aqui.',
                )
              else
                for (var index = 0; index < visibleRecords.length; index++) ...[
                  AppMenuItem(
                    icon: AppIcons.fileCheck2,
                    label: visibleRecords[index].title,
                    description: visibleRecords[index].description,
                    trailing: AppChip(
                      tone:
                          visibleRecords[index].status ==
                              PrototypeRecordStatus.scheduled
                          ? AppChipTone.blue
                          : AppChipTone.brand,
                      child: Text(_statusLabel(visibleRecords[index].status)),
                    ),
                    onTap: () => _showRecord(context, visibleRecords[index]),
                  ),
                  if (index < visibleRecords.length - 1)
                    const SizedBox(height: AppSpacing.space2),
                ],
              if (filteredRecords.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space3),
                AppPagination(
                  page: page,
                  totalItems: filteredRecords.length,
                  pageSize: _pageSize,
                  onPageChanged: (nextPage) => setState(() => _page = nextPage),
                ),
              ],
            ],
          ),
        ),
        if (widget.canCreate) ...[
          const SizedBox(height: AppSpacing.space4),
          AppButton(
            fullWidth: true,
            size: AppButtonSize.lg,
            leftIcon: const AppIcon(AppIcons.plus, size: AppSpacing.space5),
            onPressed: widget.onCreate,
            child: Text(widget.feature.createAction ?? 'Novo registro'),
          ),
        ],
      ],
    );
  }

  String _statusLabel(PrototypeRecordStatus status) => switch (status) {
    PrototypeRecordStatus.active => 'Ativo',
    PrototypeRecordStatus.completed => 'Concluído',
    PrototypeRecordStatus.scheduled => 'Programado',
  };

  void _showRecord(BuildContext context, PrototypeRecord record) {
    showAppBottomSheet<void>(
      context,
      title: record.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppChip(child: Text(_statusLabel(record.status))),
          ),
          const SizedBox(height: AppSpacing.space3),
          for (final entry in record.details.entries)
            AppMenuItem(label: entry.key, description: entry.value),
          const SizedBox(height: AppSpacing.space3),
          AppButton(
            fullWidth: true,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

List<PrototypeRecord> _recordsWithMinimumSample(
  FeatureDefinition feature,
  List<PrototypeRecord> records,
) {
  const minimumRecords = 6;
  // banco-real (correção de regressão): uma consulta somente leitura sem
  // nenhum registro sincronizado precisa continuar genuinamente vazia — é
  // o único jeito de mostrar o aviso honesto de que o cadastro vem do
  // sistema web, em vez de fabricar 6 registros fingindo que já
  // sincronizou algo que nunca existiu nesta sessão. Ver
  // `mapped_feature_screen_test.dart`, "Áreas mostra estado vazio
  // honesto...".
  if (records.isEmpty && feature.readOnly) return records;
  if (records.length >= minimumRecords) return records;

  final samples = List<PrototypeRecord>.of(records);
  for (var index = samples.length; index < minimumRecords; index++) {
    final number = index + 1;
    final status = PrototypeRecordStatus
        .values[index % PrototypeRecordStatus.values.length];
    samples.add(
      PrototypeRecord(
        id: '${feature.id}-sample-$number',
        title: '${feature.title} · Registro $number',
        description: 'Fazenda Agro Pillathi · atualizado recentemente',
        status: status,
        details: {
          'Fazenda': 'Fazenda Agro Pillathi',
          'Situação': switch (status) {
            PrototypeRecordStatus.active => 'Ativo',
            PrototypeRecordStatus.completed => 'Concluído',
            PrototypeRecordStatus.scheduled => 'Programado',
          },
          'Atualização': '$number dia${number == 1 ? '' : 's'} atrás',
        },
      ),
    );
  }
  return samples;
}

class _FeatureForm extends StatelessWidget {
  const _FeatureForm({
    required this.feature,
    required this.journey,
    required this.onValueChanged,
    required this.onAddCollectionItem,
    required this.onRemoveCollectionItem,
  });

  final FeatureDefinition feature;
  final FunctionalJourneyController journey;
  final void Function(String fieldId, String value) onValueChanged;
  final ValueChanged<FeatureCollection> onAddCollectionItem;
  final void Function(String group, int index) onRemoveCollectionItem;

  @override
  Widget build(BuildContext context) {
    final simulationTarget = feature.simulationTargetField;
    final stepIndex = journey.stepIndex;
    final step = journey.currentStep;
    final visibleFields = featureStepFields(feature, stepIndex)
        .where((field) => field.id != simulationTarget)
        .toList(growable: false);
    final sections = featureStepSections(feature, stepIndex);
    final isReview = isFeatureReviewStep(feature, stepIndex);
    // A simulação de hardware acompanha o campo-alvo, que por invariante de
    // catálogo vive na primeira etapa — repetir o simulador em cada etapa
    // convidaria a capturar duas vezes o mesmo brinco.
    final simulation = journey.isFirstStep ? feature.simulation : null;
    final simulationValue = simulation == null
        ? null
        : journey.form.values[simulationTarget ?? '_hardware'] ?? '';
    final simulationError = journey.form.attempted
        ? featureSimulationError(feature, journey.form)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (simulation != null) ...[
          AppHardwareSimulator(
            kind: _simulationKind(simulation),
            value: simulationValue,
            error: simulationError,
            manualEntryLabel: simulationTarget == null
                ? null
                : feature.fields
                      .firstWhere((field) => field.id == simulationTarget)
                      .label,
            manualEntryPlaceholder: simulationTarget == null
                ? null
                : feature.fields
                      .firstWhere((field) => field.id == simulationTarget)
                      .placeholder,
            onCapture: (value) =>
                onValueChanged(simulationTarget ?? '_hardware', value),
          ),
          if (visibleFields.isNotEmpty || sections.isNotEmpty)
            const SizedBox(height: AppSpacing.space4),
        ],
        if (visibleFields.isNotEmpty)
          AppCard(
            padded: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSectionTitle(
                    child: Text(step?.title ?? 'Dados do registro'),
                  ),
                  if (step?.hint case final hint?) ...[
                    const SizedBox(height: AppSpacing.space1),
                    Text(hint, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: AppSpacing.space4),
                  for (
                    var index = 0;
                    index < visibleFields.length;
                    index++
                  ) ...[
                    _FeatureFieldControl(
                      field: visibleFields[index],
                      value: journey.form.values[visibleFields[index].id] ?? '',
                      isRequired: isFeatureFieldRequired(
                        feature,
                        visibleFields[index],
                        journey.form.values,
                      ),
                      error: _fieldError(feature, visibleFields[index], journey),
                      onChanged: (value) =>
                          onValueChanged(visibleFields[index].id, value),
                    ),
                    if (index < visibleFields.length - 1)
                      const SizedBox(height: AppSpacing.space4),
                  ],
                ],
              ),
            ),
          ),
        if (sections.isNotEmpty) ...[
          if (visibleFields.isNotEmpty || simulation != null)
            const SizedBox(height: AppSpacing.space4),
          AppCard(
            child: AppFormField(
              label: 'Itens vinculados',
              // fidelidade-campos (onda 0): coleção `min:1` no contrato real
              // agora aparece como campo obrigatório de verdade — antes toda
              // coleção era opcional e um protocolo sem etapa nenhuma podia
              // ser salvo. Ver docs/ESTEIRA-FIDELIDADE-CAMPOS.md, Onda 0.
              required: sections.any(feature.requiredSections.contains),
              error: journey.form.attempted
                  ? _sectionError(feature, journey, sections)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < sections.length; index++) ...[
                    if (index > 0) const SizedBox(height: AppSpacing.space4),
                    if (feature.collectionByName(sections[index])
                        case final collection?)
                      AppCollectionList(
                        name: collection.name,
                        items: [
                          for (final item in journey.form.itemsOf(
                            collection.name,
                          ))
                            AppCollectionItemView(
                              title: collectionItemTitle(collection, item),
                              subtitle: collectionItemSubtitle(
                                collection,
                                item,
                              ),
                            ),
                        ],
                        onAdd: () => onAddCollectionItem(collection),
                        onRemove: (item) =>
                            onRemoveCollectionItem(collection.name, item),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (isReview) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSectionTitle(child: Text(step?.title ?? 'Revisão')),
                if (step?.hint case final hint?) ...[
                  const SizedBox(height: AppSpacing.space1),
                  Text(hint, style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: AppSpacing.space3),
                AppReviewList(items: _reviewItems(feature, journey)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Erro do campo, exibido depois da primeira tentativa ou quando já há valor.
String? _fieldError(
  FeatureDefinition feature,
  FeatureField field,
  FunctionalJourneyController journey,
) {
  final value = journey.form.values[field.id] ?? '';
  if (!journey.form.attempted && value.isEmpty) return null;
  return featureFieldError(feature, field, journey.form.values);
}

/// Na revisão, a coleção mostra quantos itens e quais — a contagem sozinha não
/// diz se a pessoa lançou o insumo certo.
String _resumoRevisao(
  FeatureCollection collection,
  FunctionalJourneyController journey,
) {
  final itens = journey.form.itemsOf(collection.name);
  final contagem = '${itens.length} item(ns)';
  if (collection.fields.isEmpty) return contagem;
  final titulos = itens
      .map((item) => collectionItemTitle(collection, item))
      .join(', ');
  return '$contagem · $titulos';
}

/// Primeira coleção obrigatória vazia entre as visíveis nesta etapa.
String? _sectionError(
  FeatureDefinition feature,
  FunctionalJourneyController journey,
  List<String> sections,
) {
  for (final section in feature.requiredSections) {
    if (!sections.contains(section)) continue;
    if ((journey.form.groupCounts[section] ?? 0) < 1) {
      return 'Adicione ao menos um item em "$section".';
    }
  }
  return null;
}

/// O que a pessoa já respondeu, na ordem do catálogo — campos preenchidos
/// primeiro, coleções depois (destacadas, porque são o que mais se esquece de
/// conferir antes de salvar).
List<AppReviewItem> _reviewItems(
  FeatureDefinition feature,
  FunctionalJourneyController journey,
) {
  final values = journey.form.values;
  return [
    for (final field in feature.fields)
      if ((values[field.id]?.trim() ?? '').isNotEmpty)
        AppReviewItem(label: field.label, value: values[field.id]!.trim()),
    for (final collection in feature.collections)
      if (journey.form.itemsOf(collection.name).isNotEmpty)
        AppReviewItem(
          label: collection.name,
          value: _resumoRevisao(collection, journey),
          emphasis: true,
        ),
  ];
}

AppHardwareSimulationKind _simulationKind(HardwareSimulationKind kind) =>
    switch (kind) {
      HardwareSimulationKind.devices => AppHardwareSimulationKind.devices,
      HardwareSimulationKind.scale => AppHardwareSimulationKind.scale,
      HardwareSimulationKind.rfid => AppHardwareSimulationKind.rfid,
      HardwareSimulationKind.scanner => AppHardwareSimulationKind.scanner,
    };

/// Um controle de campo do catálogo. Recebe valor, erro e obrigatoriedade já
/// resolvidos porque serve dois contextos: o formulário do cadastro (onde eles
/// vêm do `FunctionalJourneyController`) e o formulário de **um item de
/// coleção** na folha inferior, que não tem jornada por trás.
class _FeatureFieldControl extends StatelessWidget {
  const _FeatureFieldControl({
    required this.field,
    required this.value,
    required this.isRequired,
    required this.onChanged,
    this.error,
  });

  final FeatureField field;
  final String value;
  final bool isRequired;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      label: field.label,
      required: isRequired,
      error: error,
      child: switch (field.type) {
        FeatureFieldType.select => AppFormSelect(
          value: value.isEmpty ? null : value,
          placeholder: 'Selecione',
          options: [
            for (final option in field.options)
              AppFormSelectOption(value: option, label: option),
          ],
          onChanged: (next) => onChanged(next ?? ''),
        ),
        FeatureFieldType.textarea => AppTextarea(
          initialValue: value,
          placeholder: field.placeholder,
          onChanged: onChanged,
        ),
        FeatureFieldType.number => AppTextInput(
          initialValue: value,
          placeholder: field.placeholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          invalid: error != null,
          onChanged: onChanged,
        ),
        FeatureFieldType.date => AppDateInput(
          initialValue: value.isEmpty ? null : value,
          invalid: error != null,
          onChanged: onChanged,
        ),
        FeatureFieldType.text || null => AppTextInput(
          initialValue: value,
          placeholder: field.placeholder,
          invalid: error != null,
          onChanged: onChanged,
        ),
      },
    );
  }
}
