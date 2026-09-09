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

  /// Acrescenta um item à coleção. Sem [item], entra um item vazio — é o
  /// comportamento de contador das coleções que ainda não declaram campos.
  void addGroupItem(String group, [Map<String, String> item = const {}]) {
    form = form.addGroupItem(group, item);
  }

  void removeGroupItem(String group, int index) {
    form = form.removeGroupItem(group, index);
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
    this.groupItems = const {},
    this.attempted = false,
  });

  final Map<String, String> values;

  /// Itens de cada coleção, na ordem em que foram adicionados. Cada item é um
  /// mapa `id do campo → valor`. Até a onda 8 aqui havia só uma contagem: a
  /// coleção existia na tela mas não guardava o que continha.
  final Map<String, List<Map<String, String>>> groupItems;

  final bool attempted;

  /// Quantos itens por coleção — a leitura que o resto do app já fazia.
  Map<String, int> get groupCounts => {
    for (final entry in groupItems.entries) entry.key: entry.value.length,
  };

  List<Map<String, String>> itemsOf(String group) =>
      groupItems[group] ?? const [];

  FunctionalFormState setValue(String fieldId, String value) =>
      FunctionalFormState(
        values: {...values, fieldId: value},
        groupItems: groupItems,
        attempted: attempted,
      );

  FunctionalFormState addGroupItem(
    String group, [
    Map<String, String> item = const {},
  ]) => FunctionalFormState(
    values: values,
    groupItems: {
      ...groupItems,
      group: [...itemsOf(group), item],
    },
    attempted: attempted,
  );

  FunctionalFormState removeGroupItem(String group, int index) {
    final atuais = [...itemsOf(group)];
    if (index < 0 || index >= atuais.length) return this;
    atuais.removeAt(index);
    return FunctionalFormState(
      values: values,
      groupItems: {...groupItems, group: atuais},
      attempted: attempted,
    );
  }

  FunctionalFormState markAttempted() => FunctionalFormState(
    values: values,
    groupItems: groupItems,
    attempted: true,
  );

  FunctionalFormState clearAttempted() => FunctionalFormState(
    values: values,
    groupItems: groupItems,
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
    for (final id in step.fields) ?byId[id],
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

/// Validação que não depende do cadastro: obrigatoriedade e número positivo.
/// Serve tanto para o campo do formulário principal quanto para o campo de um
/// **item de coleção**, que não tem `FeatureDefinition` por trás.
String? featureItemFieldError(FeatureField field, Map<String, String> values) {
  final value = values[field.id]?.trim() ?? '';
  if (field.isRequired && value.isEmpty) return 'Campo obrigatório.';
  if (field.type == FeatureFieldType.number && value.isNotEmpty) {
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return 'Informe um valor maior que zero.';
    }
  }
  return null;
}

/// O item de coleção só entra na lista quando seus obrigatórios estão de pé.
bool isCollectionItemValid(
  FeatureCollection collection,
  Map<String, String> values,
) => collection.fields.every(
  (field) => featureItemFieldError(field, values) == null,
);

/// Título da linha de um item já adicionado.
String collectionItemTitle(
  FeatureCollection collection,
  Map<String, String> item,
) {
  final id =
      collection.titleField ??
      (collection.fields.isEmpty ? null : collection.fields.first.id);
  final value = id == null ? '' : item[id]?.trim() ?? '';
  return value.isEmpty ? collection.itemLabel ?? collection.name : value;
}

/// Resumo da linha — os campos de [FeatureCollection.subtitleFields] que a
/// pessoa preencheu, na ordem declarada.
String? collectionItemSubtitle(
  FeatureCollection collection,
  Map<String, String> item,
) {
  final partes = [
    for (final id in collection.subtitleFields)
      if ((item[id]?.trim() ?? '').isNotEmpty) item[id]!.trim(),
  ];
  return partes.isEmpty ? null : partes.join(' · ');
}

String? featureFieldError(
  FeatureDefinition feature,
  FeatureField field,
  Map<String, String> values,
) {
  final generico = featureItemFieldError(field, values);
  if (generico != null) return generico;
  final value = values[field.id]?.trim() ?? '';
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
    // Onda 8: a coleção deixou de ser um número no detalhe do registro — o
    // resumo passa a citar o que foi lançado, que é o que a pessoa confere.
    for (final collection in feature.collections)
      if (state.itemsOf(collection.name).isNotEmpty)
        collection.name: _resumoColecao(
          collection,
          state.itemsOf(collection.name),
        ),
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

String _resumoColecao(
  FeatureCollection collection,
  List<Map<String, String>> itens,
) {
  final contagem = '${itens.length} item(ns)';
  if (collection.fields.isEmpty) return contagem;
  final titulos = itens
      .map((item) => collectionItemTitle(collection, item))
      .toList(growable: false);
  return '$contagem · ${titulos.join(', ')}';
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
