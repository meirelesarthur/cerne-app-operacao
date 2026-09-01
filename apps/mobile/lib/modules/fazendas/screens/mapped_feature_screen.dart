import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../components/context_badge.dart';
import '../functional_catalog.dart';
import '../functional_journey_engine.dart';
import '../state/prototype_records_store.dart';

class MappedFeatureScreen extends StatelessWidget {
  const MappedFeatureScreen({
    super.key,
    required this.featureId,
    required this.profile,
  });

  final String featureId;
  final FeatureProfile profile;

  @override
  Widget build(BuildContext context) {
    final feature = featureById(featureId);
    final centerRoute = profile == FeatureProfile.administration
        ? '/fazendas/administracao'
        : '/fazendas/operacional';

    if (feature == null || feature.profile != profile) {
      return AppEmptyState(
        icon: AppIcons.shieldAlert,
        title: 'Funcionalidade fora deste perfil',
        description:
            'Volte ao ambiente correspondente para acessar esta responsabilidade.',
        action: AppButton(
          onPressed: () => context.go(centerRoute),
          child: const Text('Voltar ao ambiente'),
        ),
      );
    }

    return _MappedFeatureJourney(
      key: ValueKey('${profile.name}/${feature.id}'),
      feature: feature,
      centerRoute: centerRoute,
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
  bool get isOperational => feature.profile == FeatureProfile.operational;
  String get dataSourceId => feature.dataSourceId ?? feature.id;

  @override
  void initState() {
    super.initState();
    _journey = FunctionalJourneyController(feature);
  }

  void _startForm() => setState(_journey.startForm);

  void _showList() => setState(_journey.showList);

  void _setValue(String fieldId, String value) {
    setState(() => _journey.setValue(fieldId, value));
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

    final backToRecords =
        _journey.mode == FunctionalJourneyMode.form && feature.listMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título e voltar sobem para a barra superior, sobre o canvas: no
        // arquétipo de cadastro do Figma eles são cromo fixo, e antes rolavam
        // junto com o formulário — quem descia a tela perdia de vista tanto o
        // nome da função quanto a saída.
        SubPageHeader(
          title: _journey.mode == FunctionalJourneyMode.form
              ? feature.createAction ?? feature.title
              : feature.title,
          onBack: backToRecords
              ? _showList
              : () => context.go(widget.centerRoute),
        ),
        Expanded(
          child: AppContentSheet(
            padded: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isOperational) const ContextBadge(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    children: [
                      _FeatureIntroduction(feature: feature),
                      const SizedBox(height: AppSpacing.space4),
                      // O card "Recursos envolvidos" (Bluetooth/RFID/Balança...) saiu
                      // daqui (ver plano de UX): quando a função usa hardware
                      // simulado, o próprio `AppHardwareSimulator` já mostra isso
                      // mais abaixo, na hora de usar — listar de novo antes, em
                      // termos técnicos, só adiantava jargão sem ajudar a decisão.
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
                          canCreate:
                              feature.fields.isNotEmpty && !feature.readOnly,
                          readOnly: feature.readOnly,
                          onCreate: _startForm,
                        )
                      else
                        _FeatureForm(
                          feature: feature,
                          journey: _journey,
                          onValueChanged: _setValue,
                          onAddGroup: (group) =>
                              setState(() => _journey.addGroupItem(group)),
                          onSubmit: _submit,
                          onCancel: feature.listMode ? _showList : null,
                        ),
                    ],
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

/// Abertura da função dentro da folha: o objetivo em uma linha e, quando
/// existe, o aviso de origem do dado.
///
/// As chips de perfil ("Operação"/"Administração") e de status ("Funcional no
/// protótipo") já tinham saído daqui — a primeira repetia o ambiente em que a
/// pessoa entrou, a segunda é informação de desenvolvimento. Agora o título e o
/// voltar também saíram: viraram a barra superior fixa do padrão global, acima
/// da folha.
class _FeatureIntroduction extends StatelessWidget {
  const _FeatureIntroduction({required this.feature});

  final FeatureDefinition feature;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(feature.objective, style: Theme.of(context).textTheme.bodyMedium),
        if (feature.sourceDetail case final detail?) ...[
          const SizedBox(height: AppSpacing.space3),
          AppBanner(child: Text(detail)),
        ],
      ],
    );
  }
}

class _RecordsList extends StatelessWidget {
  const _RecordsList({
    required this.feature,
    required this.records,
    required this.canCreate,
    required this.readOnly,
    required this.onCreate,
  });

  final FeatureDefinition feature;
  final List<PrototypeRecord> records;
  final bool canCreate;
  final bool readOnly;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
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
              if (records.isEmpty)
                AppEmptyState(
                  icon: AppIcons.clipboardCheck,
                  title: feature.emptyLabel ?? 'Nenhum registro encontrado',
                  description: canCreate
                      ? 'Use a ação abaixo para criar o primeiro registro desta rotina.'
                      : readOnly
                      ? 'O cadastro desta rotina é feito no sistema web. Assim que sincronizar, os registros aparecem aqui.'
                      : 'Os registros operacionais desta sessão aparecerão aqui.',
                )
              else
                for (var index = 0; index < records.length; index++) ...[
                  AppMenuItem(
                    icon: AppIcons.fileCheck2,
                    label: records[index].title,
                    description: records[index].description,
                    trailing: AppChip(
                      tone:
                          records[index].status ==
                              PrototypeRecordStatus.scheduled
                          ? AppChipTone.blue
                          : AppChipTone.brand,
                      child: Text(_statusLabel(records[index].status)),
                    ),
                    onTap: () => _showRecord(context, records[index]),
                  ),
                  if (index < records.length - 1)
                    const SizedBox(height: AppSpacing.space2),
                ],
            ],
          ),
        ),
        if (canCreate) ...[
          const SizedBox(height: AppSpacing.space4),
          AppButton(
            fullWidth: true,
            size: AppButtonSize.lg,
            leftIcon: const AppIcon(AppIcons.plus, size: AppSpacing.space5),
            onPressed: onCreate,
            child: Text(feature.createAction ?? 'Novo registro'),
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

class _FeatureForm extends StatelessWidget {
  const _FeatureForm({
    required this.feature,
    required this.journey,
    required this.onValueChanged,
    required this.onAddGroup,
    required this.onSubmit,
    this.onCancel,
  });

  final FeatureDefinition feature;
  final FunctionalJourneyController journey;
  final void Function(String fieldId, String value) onValueChanged;
  final ValueChanged<String> onAddGroup;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final simulationTarget = feature.simulationTargetField;
    final visibleFields = feature.fields
        .where((field) => field.id != simulationTarget)
        .toList(growable: false);
    final simulation = feature.simulation;
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
          if (visibleFields.isNotEmpty || feature.sections.isNotEmpty)
            const SizedBox(height: AppSpacing.space4),
        ],
        if (visibleFields.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionTitle(child: Text('Dados do registro')),
                const SizedBox(height: AppSpacing.space4),
                for (var index = 0; index < visibleFields.length; index++) ...[
                  _FeatureFieldControl(
                    feature: feature,
                    field: visibleFields[index],
                    journey: journey,
                    onChanged: (value) =>
                        onValueChanged(visibleFields[index].id, value),
                  ),
                  if (index < visibleFields.length - 1)
                    const SizedBox(height: AppSpacing.space4),
                ],
              ],
            ),
          ),
        if (feature.sections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space4),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionTitle(child: Text('Itens vinculados')),
                const SizedBox(height: AppSpacing.space3),
                AppAddableGroupList(
                  groups: feature.sections,
                  counts: journey.form.groupCounts,
                  onAdd: onAddGroup,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space4),
        AppButton(
          fullWidth: true,
          size: AppButtonSize.lg,
          onPressed: onSubmit,
          child: Text(feature.primaryAction ?? 'Salvar registro'),
        ),
        if (onCancel != null) ...[
          const SizedBox(height: AppSpacing.space2),
          AppButton(
            fullWidth: true,
            size: AppButtonSize.lg,
            variant: AppButtonVariant.ghost,
            onPressed: onCancel,
            child: const Text('Cancelar'),
          ),
        ],
      ],
    );
  }
}

AppHardwareSimulationKind _simulationKind(HardwareSimulationKind kind) =>
    switch (kind) {
      HardwareSimulationKind.devices => AppHardwareSimulationKind.devices,
      HardwareSimulationKind.scale => AppHardwareSimulationKind.scale,
      HardwareSimulationKind.rfid => AppHardwareSimulationKind.rfid,
      HardwareSimulationKind.scanner => AppHardwareSimulationKind.scanner,
    };

class _FeatureFieldControl extends StatelessWidget {
  const _FeatureFieldControl({
    required this.feature,
    required this.field,
    required this.journey,
    required this.onChanged,
  });

  final FeatureDefinition feature;
  final FeatureField field;
  final FunctionalJourneyController journey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = journey.form.values[field.id] ?? '';
    final error = journey.form.attempted || value.isNotEmpty
        ? featureFieldError(feature, field, journey.form.values)
        : null;

    return AppFormField(
      label: field.label,
      required: field.isRequired,
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
        FeatureFieldType.date => AppTextInput(
          initialValue: value,
          placeholder: field.placeholder ?? 'AAAA-MM-DD',
          keyboardType: TextInputType.datetime,
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
