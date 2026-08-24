import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';

void main() {
  group('catálogo funcional AGRO365', () {
    test('preserva as 59 funcionalidades e a divisão por perfil', () {
      // banco-real (onda 2): +1 funcionalidade administrativa ("Produtos" —
      // consulta ao catálogo real de products, 543.983 linhas no dump gbcerne).
      // Ver docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md.
      // confinamento (onda 1): +5 funcionalidades operacionais do submódulo de
      // Confinamento (Meus currais, Produzir batelada, Trato diário, Leitura
      // de cocho, Ordens pendentes) — ver docs/ESTEIRA-PERFIS-AGRO365.md.
      expect(adminFeatures, hasLength(13));
      expect(operationalFeatures, hasLength(46));
      expect(allFeatures, hasLength(59));

      expect(
        adminFeatures.every(
          (feature) => feature.profile == FeatureProfile.administration,
        ),
        isTrue,
      );
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

    test('preserva a maturidade 52 ready, 7 hardware e zero mapped', () {
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.ready),
        hasLength(52),
      );
      expect(
        allFeatures.where(
          (feature) => feature.status == FeatureStatus.hardware,
        ),
        hasLength(7),
      );
      expect(
        allFeatures.where((feature) => feature.status == FeatureStatus.mapped),
        isEmpty,
      );
    });

    test('preserva as invariantes estruturais do catálogo congelado', () {
      final fields = allFeatures.expand((feature) => feature.fields).toList();

      // banco-real (onda 1): +11 campos opcionais para alinhar o catálogo ao
      // schema real do dump gbcerne. banco-real (produto-busca): +4 campos em
      // consulta-produtos (a única criação em campo livre; +3 obrigatórios)
      // para virar a fonte de busca dos demais campos "produto". Ver
      // docs/ajustes-banco-real/00-ESTEIRA-AJUSTES-BANCO-REAL.md.
      expect(fields, hasLength(183));
      expect(fields.where((field) => field.isRequired), hasLength(159));
      expect(allFeatures.where((feature) => feature.listMode), hasLength(33));
      expect(
        allFeatures.where((feature) => feature.existingRoute != null),
        hasLength(18),
      );
      expect(allFeatures.expand((feature) => feature.sections), hasLength(15));
      expect(
        allFeatures.expand((feature) => feature.capabilities),
        hasLength(25),
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
          expect(
            fieldIds,
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
        'balanca': HardwareSimulationKind.scale,
        'conexao-aparelhos-pecuaria': HardwareSimulationKind.devices,
        'transferencia-animal': HardwareSimulationKind.rfid,
        'scanner-sisbov': HardwareSimulationKind.scanner,
        'perdas': HardwareSimulationKind.rfid,
        'localizar-animal': HardwareSimulationKind.rfid,
      });
    });

    test('preserva consultas compartilhadas e exportações de auditoria', () {
      expect(featureById('areas')?.dataSourceId, 'cadastrar-area');
      expect(
        featureById('exportar-log-estoque')?.auditExport,
        AuditExportKind.estoque,
      );
      expect(
        featureById('exportar-log-pecuaria')?.auditExport,
        AuditExportKind.pecuaria,
      );
    });
  });
}
