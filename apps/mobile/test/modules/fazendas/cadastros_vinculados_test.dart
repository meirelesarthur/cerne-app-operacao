import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/cadastros_vinculados.dart';
import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/functional_journey_engine.dart';

/// banco-real (onda 5 — cadastros vinculados): nenhuma opção de catálogo
/// existe sem o cadastro que ela carrega, e o motor genérico propaga esse
/// cadastro para os campos derivados.
void main() {
  group('Invariantes dos cadastros vinculados', () {
    test('todo produto tem unidade, armazém padrão e custo médio', () {
      for (final produto in catalogoProdutos) {
        expect(unidadePorProduto, contains(produto), reason: produto);
        expect(armazemPadraoPorProduto, contains(produto), reason: produto);
        expect(custoMedioPorProduto, contains(produto), reason: produto);
        expect(estoquesPorProduto, contains(produto), reason: produto);
        expect(catalogoUnidades, contains(unidadePorProduto[produto]));
        expect(catalogoArmazens, contains(armazemPadraoPorProduto[produto]));
      }
    });

    test('o catálogo de itens de estoque espelha o cadastro de estoque', () {
      expect(catalogoItensEstoque, [
        for (final item in cadastroItensEstoque) item.rotulo,
      ]);
      for (final item in cadastroItensEstoque) {
        expect(catalogoProdutos, contains(item.produto));
        expect(catalogoArmazens, contains(item.armazem));
        expect(armazemPorItemEstoque[item.rotulo], item.armazem);
        expect(unidadePorItemEstoque[item.rotulo], item.unidade);
        expect(estoquesPorProduto[item.produto], contains(item.rotulo));
      }
      final agrupados = estoquesPorProduto.values.expand((e) => e).toList();
      expect(agrupados.toSet(), catalogoItensEstoque.toSet());
    });

    test('o catálogo de equipamentos espelha o cadastro de frota', () {
      expect(catalogoEquipamentos, [
        for (final equipamento in cadastroEquipamentos) equipamento.nome,
      ]);
      for (final equipamento in cadastroEquipamentos) {
        expect(
          unidadeUsoPorEquipamento[equipamento.nome],
          equipamento.unidadeUso,
        );
        final motorizado = equipamento.combustivel != null;
        expect(
          catalogoEquipamentosMotorizados.contains(equipamento.nome),
          motorizado,
        );
        if (motorizado) {
          expect(
            combustivelPorEquipamento[equipamento.nome],
            equipamento.combustivel,
          );
        }
        switch (equipamento.medidor) {
          case MedidorEquipamento.horimetro:
            expect(horimetroAtualPorEquipamento, contains(equipamento.nome));
          case MedidorEquipamento.hodometro:
            expect(hodometroAtualPorEquipamento, contains(equipamento.nome));
            expect(equipamento.placa, isNotNull);
          case MedidorEquipamento.nenhum:
            expect(
              horimetroAtualPorEquipamento,
              isNot(contains(equipamento.nome)),
            );
        }
      }
    });

    test('todo lote agrícola tem talhão com área produtiva ≤ área total', () {
      for (final lote in cadastroLotesAgricolas) {
        expect(lote.talhoes, isNotEmpty, reason: lote.rotulo);
        for (final talhao in lote.talhoes) {
          expect(talhao.areaProdutiva, lessThanOrEqualTo(talhao.areaTotal));
          expect(talhao.areaProdutiva, greaterThan(0));
        }
      }
    });

    test('toda atividade de operação existe no domínio de atividades', () {
      expect(atividadesPorOperacao, isNotEmpty);
      for (final atividades in atividadesPorOperacao.values) {
        expect(atividades, isNotEmpty);
      }
    });

    test('toda derivação e filtro do catálogo aponta para um campo irmão', () {
      for (final feature in operationalFeatures) {
        final escopos = <List<FeatureField>>[
          feature.fields,
          for (final collection in feature.collections) collection.fields,
        ];
        for (final campos in escopos) {
          final ids = {for (final campo in campos) campo.id};
          for (final campo in campos) {
            if (campo.derivedFrom case final derivacao?) {
              expect(
                ids,
                contains(derivacao.source),
                reason: '${feature.id}.${campo.id}',
              );
            }
            if (campo.optionsFrom case final filtro?) {
              expect(
                ids,
                contains(filtro.source),
                reason: '${feature.id}.${campo.id}',
              );
            }
          }
        }
      }
    });
  });

  group('Motor — campos derivados', () {
    test('escolher o veículo sugere combustível e trava a unidade', () {
      final controller = FunctionalJourneyController(
        featureById('abastecimentos')!,
      )..startForm();

      controller.setValue('veiculo', 'Caminhão Boiadeiro');

      expect(controller.form.values['combustivel'], 'Diesel S500');
      expect(controller.form.values['unidade'], 'L');

      final unidade = controller.feature.fields.firstWhere(
        (f) => f.id == 'unidade',
      );
      final combustivel = controller.feature.fields.firstWhere(
        (f) => f.id == 'combustivel',
      );
      expect(
        isFieldLockedByDerivation(unidade, controller.form.values),
        isTrue,
      );
      // Combustível é sugestão: continua editável.
      expect(
        isFieldLockedByDerivation(combustivel, controller.form.values),
        isFalse,
      );

      // A pessoa troca o combustível — a sugestão não volta por cima.
      controller.setValue('combustivel', 'Diesel S10');
      expect(controller.form.values['combustivel'], 'Diesel S10');
      expect(controller.form.values['unidade'], 'L');
    });

    test('o estoque é filtrado pelo produto e traz armazém e unidade', () {
      final feature = featureById('sanitario')!;
      final itens = feature.collectionByName('Itens de estoque')!;
      final estoque = itens.fields.firstWhere((f) => f.id == 'estoque');

      var valores = <String, String>{'produto': 'Vermífugo Injetável'};
      valores = applyFieldDerivations(itens.fields, valores, 'produto');

      expect(valores['unidade'], 'L');
      expect(effectiveFieldOptions(estoque, valores), [
        'Vermífugo Injetável — Lote 2026-05-B',
      ]);

      valores = applyFieldDerivations(itens.fields, {
        ...valores,
        'estoque': 'Vermífugo Injetável — Lote 2026-05-B',
      }, 'estoque');
      expect(valores['armazem'], 'Farmácia');

      // Trocar o produto invalida o estoque do produto anterior — e o armazém
      // que vinha dele.
      valores = applyFieldDerivations(itens.fields, {
        ...valores,
        'produto': 'Vacina Aftosa',
      }, 'produto');
      expect(valores.containsKey('estoque'), isFalse);
      expect(valores.containsKey('armazem'), isFalse);
      expect(valores['unidade'], 'Unidade');
    });

    test('o hint diz de qual cadastro o valor veio', () {
      final feature = featureById('abastecimentos')!;
      final unidade = feature.fields.firstWhere((f) => f.id == 'unidade');
      final combustivel = feature.fields.firstWhere(
        (f) => f.id == 'combustivel',
      );
      const valores = {'veiculo': 'Pulverizador', 'combustivel': 'Diesel S10'};

      expect(
        fieldDerivationHint(unidade, feature.fields, valores),
        'Preenchido pelo cadastro de “Combustível”.',
      );
      expect(
        fieldDerivationHint(combustivel, feature.fields, valores),
        'Sugerido pelo cadastro de “Veículo / equipamento” — ajuste se '
        'necessário.',
      );
    });
  });
}
