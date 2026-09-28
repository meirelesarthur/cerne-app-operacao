import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/functional_catalog.dart';
import 'package:cerne_app/modules/fazendas/operational_groups.dart';
import 'package:cerne_app/shell/module_config.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

void main() {
  group('module_config', () {
    test('Fazendas é o único módulo, com bottomTabs não vazios', () {
      expect(modules.map((m) => m.id), ['fazendas']);
      for (final m in modules) {
        expect(m.bottomTabs, isNotEmpty);
      }
    });

    test('getModule resolve por id e retorna null para desconhecido/nulo', () {
      expect(getModule('fazendas')?.label, 'Fazendas');
      expect(getModule('inexistente'), isNull);
      expect(getModule(null), isNull);
    });

    test(
      'índice das rotinas de Fazendas lista os grupos do catálogo num grupo só',
      () {
        final sections = operationalMenuSections();

        expect(sections.map((s) => s.title), ['Menu']);
        final labels = sections.single.items.map((i) => i.label).toList();
        // O índice é completo: repete o que está na navbar, com o
        // Início primeiro e a lista completa de OS logo depois.
        final items = sections.single.items;
        expect(labels.first, 'Início');
        expect(items.first.route, '/fazendas/operacional');
        expect(items.first.push, isFalse);
        expect(labels[1], 'Ordens de serviço');
        expect(items[1].route, '/fazendas/campo/minhas-os');
        expect(items[1].push, isTrue);
        expect(labels[2], 'Confinamento');
        expect(
          labels,
          containsAll(['Pecuária', 'Agricultura', 'Sincronizar aplicativo']),
        );
        // Grupo de uma função só abre a funcionalidade empilhada (tem
        // "Voltar" próprio); os demais trocam para a central do grupo.
        final sync = sections.single.items.firstWhere(
          (i) => i.label == 'Sincronizar aplicativo',
        );
        expect(sync.push, isTrue);
        final confinamento = sections.single.items[2];
        expect(confinamento.push, isFalse);
        expect(confinamento.route, '/fazendas/operacional/grupo/confinamento');
      },
    );

    test(
      'navbar operacional: Início, Pecuária, [+], Agricultura e Confinamento',
      () {
        expect(operationalBottomTabs.map((t) => t.label), [
          'Início',
          'Pecuária',
          'Adicionar',
          'Agricultura',
          'Confinamento',
        ]);
        // O "+" fica no centro e é ação, não aba.
        expect(operationalBottomTabs[2].action, quickAddAction);
        // Sem menu lateral: a última posição navega para o Confinamento.
        expect(operationalBottomTabs.last.action, isNull);
        expect(
          operationalBottomTabs.last.path,
          'operacional/grupo/confinamento',
        );
      },
    );

    test('adição rápida: até cinco rotinas, com destino do catálogo', () {
      final atalhos = operationalQuickAdds();
      expect(atalhos.map((a) => a.label), [
        'Apontamento',
        'Pesagem',
        'Trato diário',
        'Leitura de cocho',
        'Manejo sanitário',
      ]);
      expect(atalhos.length, lessThanOrEqualTo(5));
      for (final atalho in atalhos) {
        final feature = operationalFeatures.firstWhere(
          (f) => f.id == atalho.id,
        );
        expect(atalho.route, operationalFeatureRoute(feature));
        expect(atalho.push, isTrue, reason: atalho.label);
      }
    });

    test('Fazendas só entrega a aba operacional (perfil único do app)', () {
      final fazendas = getModule('fazendas')!;
      final tabs = visibleBottomTabs(fazendas, UserAccessProfile.operational);

      expect(tabs.where((tab) => tab.action == null).map((tab) => tab.label), [
        'Rotinas',
      ]);
    });
  });
}
