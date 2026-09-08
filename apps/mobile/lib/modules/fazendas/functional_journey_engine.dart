import 'functional_catalog.dart';
import 'state/prototype_records_store.dart';

enum FunctionalJourneyMode { list, form, success }

class FunctionalJourneyController {
  FunctionalJourneyController(this.feature);

  final FeatureDefinition feature;
  FunctionalJourneyMode mode = FunctionalJourneyMode.list;
  FunctionalFormState form = const FunctionalFormState();

  /// Etapa atual quando a funcionalidade declara [FeatureDefinition.steps].
  /// Sem etapas declaradas fica sempre em zero e o formulário é de rolagem
  /// única — comportamento anterior à onda 0 da esteira de fidelidade.
  int stepIndex = 0;

  bool get hasSteps => feature.steps.isNotEmpty;

  int get stepCount => hasSteps ? feature.steps.length : 1;

  FeatureFormStep? get currentStep =>
      hasSteps ? feature.steps[stepIndex.clamp(0, stepCount - 1)] : null;

  bool get isFirstStep => stepIndex <= 0;

  bool get isLastStep => stepIndex >= stepCount - 1;

  void startForm() {
    mode = FunctionalJourneyMode.form;
    form = const FunctionalFormState();
    stepIndex = 0;
  }

  void setValue(String fieldId, String value) {
    form = form.setValue(fieldId, value);
  }

  void addGroupItem(String group) {
    form = form.addGroupItem(group);
  }

  /// Avança uma etapa. Devolve `false` quando a etapa atual tem pendência —
  /// a tela mostra os erros e não sai do lugar. Na última etapa não avança:
  /// quem conclui o fluxo é [submit].
  bool advanceStep() {
    if (!hasSteps || isLastStep) return false;
    form = form.markAttempted();
    if (!isFeatureStepValid(feature, form, stepIndex)) return false;
    stepIndex += 1;
    form = form.clearAttempted();
    return true;
  }

  bool retreatStep() {
    if (!hasSteps || isFirstStep) return false;
    stepIndex -= 1;
    form = form.clearAttempted();
    return true;
  }

  PrototypeRecordDraft? submit() {
    form = form.markAttempted();
    if (!isFeatureFormValid(feature, form)) {
      // Formulário em etapas: volta para a primeira etapa com pendência, para
      // que o erro apareça na tela em que a pessoa consegue corrigi-lo.
      if (hasSteps) {
        for (var index = 0; index < stepCount; index++) {
          if (!isFeatureStepValid(feature, form, index)) {
            stepIndex = index;
            break;
          }
        }
      }
      return null;
    }
    mode = FunctionalJourneyMode.success;
    return buildPrototypeRecordDraft(feature, form);
  }

  void showList() {
    mode = FunctionalJourneyMode.list;
    stepIndex = 0;
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

  FunctionalFormState clearAttempted() => FunctionalFormState(
    values: values,
    groupCounts: groupCounts,
  );
}

/// Campos de uma etapa, na ordem declarada. Campos citados na etapa que não
/// existem em [FeatureDefinition.fields] são ignorados (a invariante de
/// catálogo cobre esse caso em teste).
List<FeatureField> featureStepFields(FeatureDefinition feature, int index) {
  if (feature.steps.isEmpty) return feature.fields;
  final step = feature.steps[index.clamp(0, feature.steps.length - 1)];
  final byId = {for (final field in feature.fields) field.id: field};
  return [
    for (final id in step.fields)
      if (byId[id] case final field?) field,
  ];
}

/// Coleções de uma etapa. Sem etapas declaradas, todas as coleções da
/// funcionalidade aparecem juntas, como antes.
List<String> featureStepSections(FeatureDefinition feature, int index) {
  if (feature.steps.isEmpty) return feature.sections;
  final step = feature.steps[index.clamp(0, feature.steps.length - 1)];
  return [
    for (final section in step.sections)
      if (feature.sections.contains(section)) section,
  ];
}

/// A etapa sem campos e sem coleções é a revisão do que foi preenchido.
bool isFeatureReviewStep(FeatureDefinition feature, int index) {
  if (feature.steps.isEmpty) return false;
  return featureStepFields(feature, index).isEmpty &&
      featureStepSections(feature, index).isEmpty;
}

/// Obrigatoriedade efetiva do campo. Sai de [FeatureField.isRequired] na
/// maioria dos casos, mas o contrato real também tem obrigatoriedade
/// condicional — em `/pastures` o destino é `area_uuid` XOR `grazing_uuid`, e
/// qual dos dois é exigido depende da escolha em `destino`. A tela usa isto
/// para o asterisco, e [featureFieldError] para a mensagem.
bool isFeatureFieldRequired(
  FeatureDefinition feature,
  FeatureField field,
  Map<String, String> values,
) {
  if (field.isRequired) return true;
  if (feature.id == 'pastagens') {
    final destino = values['destino']?.trim() ?? '';
    if (field.id == 'area') return destino == 'Área';
    if (field.id == 'piquete') return destino == 'Piquete';
  }
  return false;
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
  // fidelidade-campos (onda 1): em `/pastures` o destino do manejo é um XOR —
  // `area_uuid` **ou** `grazing_uuid`, nunca os dois e nunca nenhum. Nenhum
  // dos dois pode ser `isRequired` no catálogo (senão os dois seriam sempre
  // exigidos); a obrigatoriedade nasce da escolha em `destino`.
  if (feature.id == 'pastagens' && value.isEmpty) {
    final destino = values['destino']?.trim() ?? '';
    if (field.id == 'area' && destino == 'Área') {
      return 'Selecione a área do manejo.';
    }
    if (field.id == 'piquete' && destino == 'Piquete') {
      return 'Selecione o piquete do manejo.';
    }
  }
  return null;
}

/// Pendência de coleção obrigatória (`min:1` no contrato real). Devolve a
/// primeira coleção vazia entre as declaradas em
/// [FeatureDefinition.requiredSections].
String? featureCollectionError(
  FeatureDefinition feature,
  FunctionalFormState state,
) {
  for (final section in feature.requiredSections) {
    if ((state.groupCounts[section] ?? 0) < 1) {
      return 'Adicione ao menos um item em "$section".';
    }
  }
  return null;
}

bool isFeatureStepValid(
  FeatureDefinition feature,
  FunctionalFormState state,
  int index,
) {
  final fieldsValid = featureStepFields(feature, index).every(
    (field) => featureFieldError(feature, field, state.values) == null,
  );
  if (!fieldsValid) return false;
  final sections = featureStepSections(feature, index);
  for (final section in feature.requiredSections) {
    if (sections.contains(section) && (state.groupCounts[section] ?? 0) < 1) {
      return false;
    }
  }
  // A simulação de hardware vive na primeira etapa, junto do campo-alvo.
  if (index == 0 && featureSimulationError(feature, state) != null) {
    return false;
  }
  return true;
}

bool isFeatureFormValid(FeatureDefinition feature, FunctionalFormState state) {
  final fieldsValid = feature.fields.every(
    (field) => featureFieldError(feature, field, state.values) == null,
  );
  if (!fieldsValid) return false;
  if (featureCollectionError(feature, state) != null) return false;
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
