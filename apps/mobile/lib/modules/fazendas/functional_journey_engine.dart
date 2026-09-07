import 'functional_catalog.dart';
import 'state/prototype_records_store.dart';

enum FunctionalJourneyMode { list, form, success }

class FunctionalJourneyController {
  FunctionalJourneyController(this.feature);

  final FeatureDefinition feature;
  FunctionalJourneyMode mode = FunctionalJourneyMode.list;
  FunctionalFormState form = const FunctionalFormState();

  void startForm() {
    mode = FunctionalJourneyMode.form;
    form = const FunctionalFormState();
  }

  void setValue(String fieldId, String value) {
    form = form.setValue(fieldId, value);
  }

  void addGroupItem(String group) {
    form = form.addGroupItem(group);
  }

  PrototypeRecordDraft? submit() {
    form = form.markAttempted();
    if (!isFeatureFormValid(feature, form)) return null;
    mode = FunctionalJourneyMode.success;
    return buildPrototypeRecordDraft(feature, form);
  }

  void showList() {
    mode = FunctionalJourneyMode.list;
  }
}

class FunctionalFormState {
  const FunctionalFormState({
    this.values = const {},
    this.groupCounts = const {},
    this.attempted = false,
  });

  final Map<String, String> values;
  final Map<String, int> groupCounts;
  final bool attempted;

  FunctionalFormState setValue(String fieldId, String value) =>
      FunctionalFormState(
        values: {...values, fieldId: value},
        groupCounts: groupCounts,
        attempted: attempted,
      );

  FunctionalFormState addGroupItem(String group) => FunctionalFormState(
    values: values,
    groupCounts: {...groupCounts, group: (groupCounts[group] ?? 0) + 1},
    attempted: attempted,
  );

  FunctionalFormState markAttempted() => FunctionalFormState(
    values: values,
    groupCounts: groupCounts,
    attempted: true,
  );
}

String? featureFieldError(
  FeatureDefinition feature,
  FeatureField field,
  Map<String, String> values,
) {
  final value = values[field.id]?.trim() ?? '';
  if (field.isRequired && value.isEmpty) return 'Campo obrigatório.';
  if (field.type == FeatureFieldType.number && value.isNotEmpty) {
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero.';
    }
  }
  if (feature.id == 'estacao-monta' &&
      field.id == 'fim' &&
      value.isNotEmpty &&
      (values['inicio']?.isNotEmpty ?? false) &&
      value.compareTo(values['inicio']!) < 0) {
    return 'A data final deve ser posterior à data inicial.';
  }
  return null;
}

bool isFeatureFormValid(FeatureDefinition feature, FunctionalFormState state) {
  final fieldsValid = feature.fields.every(
    (field) => featureFieldError(feature, field, state.values) == null,
  );
  if (!fieldsValid) return false;
  return featureSimulationError(feature, state) == null;
}

String? featureSimulationError(
  FeatureDefinition feature,
  FunctionalFormState state,
) {
  if (feature.simulation == null) return null;
  final target = feature.simulationTargetField ?? '_hardware';
  if (state.values[target]?.trim().isNotEmpty ?? false) return null;
  return feature.simulationTargetField == null
      ? 'Conclua a simulação para continuar.'
      : 'Capture ou informe a identificação manualmente.';
}

PrototypeRecordDraft buildPrototypeRecordDraft(
  FeatureDefinition feature,
  FunctionalFormState state,
) {
  final labels = {for (final field in feature.fields) field.id: field.label};
  final details = <String, String>{
    for (final entry in state.values.entries)
      if (entry.value.trim().isNotEmpty)
        labels[entry.key] ?? entry.key: entry.value.trim(),
    for (final entry in state.groupCounts.entries)
      if (entry.value > 0) entry.key: '${entry.value} item(ns)',
  };
  final titleField = feature.recordTitleField ?? 'nome';
  final title = state.values[titleField]?.trim();
  final description = feature.recordDescriptionFields
      .map((id) => state.values[id]?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .join(' · ');

  return PrototypeRecordDraft(
    title: title?.isNotEmpty ?? false ? title! : feature.title,
    description: description.isEmpty ? 'Registro criado agora' : description,
    status: _statusFor(feature.id),
    details: details,
  );
}

PrototypeRecordStatus _statusFor(String featureId) {
  const active = {
    'cadastrar-area',
    'formulacoes',
    'rebanho-inicial',
    'lote-animais',
    'registrar-animal',
    'material-reprodutivo',
    'configuracoes-misturador',
    'marcacao',
  };
  const scheduled = {
    'manutencao-frota',
    'estacao-monta',
    'protocolos-estacao',
  };
  if (scheduled.contains(featureId)) return PrototypeRecordStatus.scheduled;
  if (active.contains(featureId)) return PrototypeRecordStatus.active;
  return PrototypeRecordStatus.completed;
}

class PrototypeRecordDraft {
  const PrototypeRecordDraft({
    required this.title,
    required this.description,
    required this.status,
    required this.details,
  });

  final String title;
  final String description;
  final PrototypeRecordStatus status;
  final Map<String, String> details;
}
