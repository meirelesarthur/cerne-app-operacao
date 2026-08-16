import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
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
        icon: LucideIcons.shieldAlert,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOperational) const ContextBadge(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            children: [
              AppButton(
                variant: AppButtonVariant.ghost,
                leftIcon: const Icon(
                  LucideIcons.arrowLeft,
                  size: AppSpacing.space4,
                ),
                onPressed:
                    _journey.mode == FunctionalJourneyMode.form &&
                        feature.listMode
                    ? _showList
                    : () => context.go(widget.centerRoute),
                child: Text(
                  _journey.mode == FunctionalJourneyMode.form
                      ? 'Voltar aos registros'
                      : 'Voltar ao ambiente',
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              _FeatureIntroduction(
                feature: feature,
                formMode: _journey.mode == FunctionalJourneyMode.form,
              ),
              const SizedBox(height: AppSpacing.space4),
              if (feature.capabilities.isNotEmpty) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle(child: Text('Recursos envolvidos')),
                      const SizedBox(height: AppSpacing.space3),
                      Wrap(
                        spacing: AppSpacing.space2,
                        runSpacing: AppSpacing.space2,
                        children: [
                          for (final capability in feature.capabilities)
                            AppTag(child: Text(capability)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
              ],
              if (feature.listMode &&
                  _journey.mode == FunctionalJourneyMode.list)
                _RecordsList(
                  feature: feature,
                  records: ref
                      .watch(prototypeRecordsProvider)
                      .recordsFor(dataSourceId),
                  canCreate: isOperational && feature.fields.isNotEmpty,
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
    );
  }
}

class _FeatureIntroduction extends StatelessWidget {
  const _FeatureIntroduction({required this.feature, required this.formMode});

  final FeatureDefinition feature;
  final bool formMode;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final administration = feature.profile == FeatureProfile.administration;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            AppChip(
              tone: administration ? AppChipTone.blue : AppChipTone.brand,
              child: Text(administration ? 'Administração' : 'Operação'),
            ),
            AppChip(
              tone: feature.status == FeatureStatus.hardware
                  ? AppChipTone.amber
                  : AppChipTone.brand,
              child: Text(
                feature.status == FeatureStatus.hardware
                    ? 'Simulação de hardware'
                    : 'Funcional no protótipo',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        AppHeading(
          child: Text(
            formMode ? feature.createAction ?? feature.title : feature.title,
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(feature.objective, style: TextStyle(color: semantic.fgMuted)),
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
    required this.onCreate,
  });

  final FeatureDefinition feature;
  final List<PrototypeRecord> records;
  final bool canCreate;
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
                  icon: LucideIcons.clipboardCheck,
                  title: feature.emptyLabel ?? 'Nenhum registro encontrado',
                  description: canCreate
                      ? 'Use a ação abaixo para criar o primeiro registro desta rotina.'
                      : 'Os registros operacionais desta sessão aparecerão aqui.',
                )
              else
                for (var index = 0; index < records.length; index++) ...[
                  AppMenuItem(
                    icon: LucideIcons.fileCheck2,
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
            leftIcon: const Icon(LucideIcons.plus, size: AppSpacing.space5),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (feature.fields.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSectionTitle(child: Text('Dados do registro')),
                const SizedBox(height: AppSpacing.space4),
                for (var index = 0; index < feature.fields.length; index++) ...[
                  _FeatureFieldControl(
                    feature: feature,
                    field: feature.fields[index],
                    journey: journey,
                    onChanged: (value) =>
                        onValueChanged(feature.fields[index].id, value),
                  ),
                  if (index < feature.fields.length - 1)
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
