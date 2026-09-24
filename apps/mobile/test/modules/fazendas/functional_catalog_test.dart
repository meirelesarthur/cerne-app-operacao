import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';

void main() {
  group('catálogo funcional AGRO365', () {
    test('preserva as 38 funcionalidades, todas do perfil operacional', () {
      // Repo CERNE Operação: o perfil Administração e o catálogo
      // `adminFeatures` (17 funcionalidades administrativas) foram removidos
      // por completo — só resta o catálogo operacional.
      expect(operationalFeatures, hasLength(38));
      expect(allFeatures, hasLength(38));
      expect(allFeatures, same(operationalFeatures));

      expect(
        operationalFeatures.every(
          (feature) => feature.profile == FeatureProfile.operational,
        ),
        isTrue,
      );
    });

    test('mantém IDs únicos e permite consulta pelo identificador', () {
      final ids = allFeatures.map((feature) => feature.id).toSet();

      expect(ids, hasLength(allFeatures.length));
      for (final feature in allFeatures) {
        expect(featureById(feature.id), same(feature));
      }
      expect(featureById('funcionalidade-inexistente'), isNull);
    });

    test('preserva a maturidade 32 ready, 6 hardware e zero mapped', () {
      // Catálogo só operacional (repo CERNE Operação): 32 funcionalidades
      // `ready`, 6 `hardware`, nenhuma `mapped`.
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.ready),
        hasLength(32),
      );
      expect(
        allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ),
        hasLength(6),
      );
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.mapped),
        isEmpty,
      );
    });

    test('preserva as invariantes estruturais do catálogo congelado', () {
      final fields = allFeatures.expand((feature) => feature.fields).toList();

      expect(fields, hasLength(223));
      expect(fields.where((field) => field.isRequired), hasLength(158));
      expect(allFeatures.where((feature) => feature.listMode), hasLength(23));
      expect(
        allFeatures.where((feature) => feature.existingRoute != null),
        hasLength(12),
      );
      expect(allFeatures.expand((feature) => feature.sections), hasLength(27));
      expect(
        allFeatures.expand((feature) => feature.capabilities),
        hasLength(23),
      );
    });

    // fidelidade-campos (onda 0): um formulário em etapas pode esconder um
    // campo para sempre se ele não constar de nenhuma etapa — e o motor não
    // tem como perceber, porque o campo continua no contrato e continua sendo
    // validado no `submit`. Esta é a invariante que impede isso.
    test('as etapas alcançam todo campo e toda coleção do cadastro', () {
      final comEtapas = allFeatures
          .where((feature) => feature.steps.isNotEmpty)
          .toList(growable: false);

      // Pastagens, marcação, registrar animal, rebanho inicial, sanitário,
      // acasalamento, diagnóstico de gestação e manutenção — os formulários
      // de 11 campos ou mais. Abastecimentos ficou de fora de propósito: com
      // 10 campos, uma tela só é mais rápida em campo do que quatro.
      expect(comEtapas, hasLength(8));

      for (final feature in comEtapas) {
        final camposEmEtapas = [
          for (final step in feature.steps) ...step.fields,
        ];
        expect(
          camposEmEtapas.toSet(),
          hasLength(camposEmEtapas.length),
          reason: 'campo repetido em duas etapas de ${feature.id}',
        );
        expect(
          camposEmEtapas.toSet(),
          feature.fields.map((field) => field.id).toSet(),
          reason: 'campo fora de qualquer etapa em ${feature.id}',
        );

        final colecoesEmEtapas = [
          for (final step in feature.steps) ...step.sections,
        ];
        expect(
          colecoesEmEtapas.toSet(),
          feature.sections.toSet(),
          reason: 'coleção fora de qualquer etapa em ${feature.id}',
        );

        // A etapa sem campo e sem coleção é a revisão: existe uma só, e é a
        // última — do contrário o motor mostraria uma tela vazia no meio.
        final vazias = [
          for (var index = 0; index < feature.steps.length; index++)
            if (feature.steps[index].fields.isEmpty &&
                feature.steps[index].sections.isEmpty)
              index,
        ];
        expect(vazias, [feature.steps.length - 1], reason: feature.id);

        final simulationTargetField = feature.simulationTargetField;
        if (simulationTargetField != null) {
          expect(
            feature.steps.first.fields,
            contains(simulationTargetField),
            reason: 'simulação fora da 1a etapa em ${feature.id}',
          );
        }
      }
    });

    // fidelidade-campos (onda 8): a coleção deixou de ser um nome numa lista
    // de `String` e passou a declarar o que **um item** é. Estas são as
    // invariantes que impedem uma coleção de voltar ao estado de contador sem
    // que alguém decida isso.
    test('coleção com campos descreve o item por inteiro', () {
      final colecoes = [
        for (final feature in allFeatures)
          for (final collection in feature.collections)
            (feature: feature, collection: collection),
      ];

      expect(colecoes, hasLength(27));

      final comCampos = colecoes
          .where((par) => par.collection.fields.isNotEmpty)
          .toList(growable: false);
      // Todas as coleções do catálogo operacional declaram os campos do item
      // — nenhuma ficou no modelo antigo de contador puro.
      expect(comCampos, hasLength(27));
      expect(
        colecoes
            .where((par) => par.collection.fields.isEmpty)
            .map((par) => par.feature.id)
            .toSet(),
        isEmpty,
      );
      expect(
        comCampos.fold<int>(
          0,
          (total, par) => total + par.collection.fields.length,
        ),
        115,
      );

      for (final par in comCampos) {
        final onde = '${par.feature.id}/${par.collection.name}';
        final ids = par.collection.fields
            .map((field) => field.id)
            .toList(growable: false);

        expect(ids.toSet(), hasLength(ids.length), reason: onde);
        // Sem rótulo do item, a folha do formulário abriria com o nome da
        // coleção no plural ("Insumos") para cadastrar um só.
        expect(par.collection.itemLabel, isNotNull, reason: onde);
        expect(ids, contains(par.collection.titleField), reason: onde);
        for (final campo in par.collection.subtitleFields) {
          expect(ids, contains(campo), reason: onde);
        }
        // Um item sem nenhum campo obrigatório entraria vazio na lista.
        expect(
          par.collection.fields.any((field) => field.isRequired),
          isTrue,
          reason: onde,
        );
      }
    });

    test('coleção obrigatória sempre existe entre as coleções da tela', () {
      for (final feature in allFeatures) {
        for (final section in feature.requiredSections) {
          expect(feature.sections, contains(section), reason: feature.id);
        }
      }

      // `protocolos-estacao.items[]`, `diagnostico-gestacao.animals[]`,
      // `lote-animais.category_uuids[]` e `apartacao.batches[]` são coleções
      // `min:1` do contrato real: em todos os casos a coleção **é** o
      // registro (ou parte essencial dele), e salvar sem nenhum item não
      // registra nada.
      expect(
        {
          for (final feature in allFeatures)
            if (feature.requiredSections.isNotEmpty)
              feature.id: feature.requiredSections,
        },
        {
          'sanitario': ['Animais alvo', 'Itens de estoque'],
          'formulacoes': ['Matérias-primas'],
          'batidas': ['Itens da batida'],
          'protocolos-estacao': ['Etapas do protocolo'],
          'diagnostico-gestacao': ['Animais diagnosticados'],
          'desmama': ['Identificações adicionais'],
          'lote-animais': ['Categorias do lote'],
          'apartacao': ['Lotes de origem'],
          'transferencia-animal': ['Animais transferidos'],
          'abastecimentos': ['Itens do abastecimento'],
          'manutencao-frota': ['Peças / Insumos'],
        },
      );
    });

    test('referências internas apontam para contratos e campos existentes', () {
      final featuresById = {
        for (final feature in allFeatures) feature.id: feature,
      };

      for (final feature in allFeatures) {
        final fieldIds = feature.fields.map((field) => field.id).toSet();
        expect(
          fieldIds,
          hasLength(feature.fields.length),
          reason: 'IDs de campo duplicados em ${feature.id}',
        );

        final dataSourceId = feature.dataSourceId;
        if (dataSourceId != null) {
          expect(
            featuresById[dataSourceId]?.profile,
            FeatureProfile.operational,
            reason: 'Fonte operacional inválida em ${feature.id}',
          );
        }

        final recordTitleField = feature.recordTitleField;
        if (recordTitleField != null) {
          expect(
            fieldIds,
            contains(recordTitleField),
            reason: 'Título de registro inválido em ${feature.id}',
          );
        }

        for (final descriptionField in feature.recordDescriptionFields) {
          expect(
            fieldIds,
            contains(descriptionField),
            reason: 'Descrição de registro inválida em ${feature.id}',
          );
        }

        final simulationTargetField = feature.simulationTargetField;
        if (simulationTargetField != null) {
          // fidelidade-esteira (onda 13): quando a captura empilha numa
          // coleção (`simulationCollectionName`), o campo-alvo é o `id` de
          // um campo **do item**, não de `feature.fields` — o cabeçalho não
          // tem mais esse campo escalar.
          final simulationCollectionName = feature.simulationCollectionName;
          final targetIds = simulationCollectionName == null
              ? fieldIds
              : feature
                    .collectionByName(simulationCollectionName)!
                    .fields
                    .map((field) => field.id)
                    .toSet();
          expect(
            targetIds,
            contains(simulationTargetField),
            reason: 'Campo-alvo da simulação inválido em ${feature.id}',
          );
        }
      }
    });

    test('todo item de hardware declara uma simulação frontend', () {
      final hardware = {
        for (final feature in allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ))
          feature.id: feature.simulation,
      };

      expect(hardware, {
        'conexao-aparelhos': HardwareSimulationKind.devices,
        'conexao-aparelhos-pecuaria': HardwareSimulationKind.devices,
        'transferencia-animal': HardwareSimulationKind.rfid,
        'scanner-sisbov': HardwareSimulationKind.scanner,
        'perdas': HardwareSimulationKind.rfid,
        'localizar-animal': HardwareSimulationKind.rfid,
      });
    });

    test('não conserva funcionalidades administrativas ou legadas', () {
      // O perfil Administração e o catálogo `adminFeatures` foram removidos
      // por completo deste repo (CERNE Operação): nenhuma consulta/exportação
      // administrativa sobrevive no catálogo.
      expect(featureById('areas'), isNull);
      expect(featureById('lotes-reproducao'), isNull);
      expect(featureById('compras-animais'), isNull);
      expect(featureById('vendas'), isNull);
      expect(featureById('processamentos'), isNull);
      expect(featureById('exportar-log-estoque'), isNull);
      expect(featureById('exportar-log-pecuaria'), isNull);
      // confinamento (onda 2): `carga`, `descarga`, `balanca` e `nota-cocho`
      // saíram do catálogo — o Confinamento absorveu o que restava do
      // Misturador. Ver comentário em `functional_catalog.dart`.
      expect(featureById('carga'), isNull);
      expect(featureById('descarga'), isNull);
      expect(featureById('balanca'), isNull);
      expect(featureById('nota-cocho'), isNull);
    });
  });

  test('estação de monta é escolhida do cadastro WEB, nunca digitada', () {
    // Acasalamento e material reprodutivo vinculam a estação cadastrada no
    // sistema WEB — o campo é busca na lista, como nos protocolos.
    for (final id in ['monta-natural', 'material-reprodutivo']) {
      final campo = featureById(
        id,
      )!.fields.firstWhere((f) => f.id == 'estacao-monta');
      expect(campo.type, FeatureFieldType.searchSelect, reason: id);
      expect(campo.options, catalogoEstacoesMonta, reason: id);
    }
  });
}
