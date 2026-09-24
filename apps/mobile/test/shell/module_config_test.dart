import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/module_config.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/app_icon.dart';

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
      'getMenuSections cai no fallback derivado das bottomTabs quando ausente',
      () {
        // O módulo real não deixa `menuSections` ausente hoje (ver
        // teste abaixo) — o fallback só existe como rede de segurança para um
        // módulo futuro sem seção própria. Testado aqui com um `ModuleDef`
        // sintético, não com um módulo real.
        const synthetic = ModuleDef(
          id: 'sintetico',
          label: 'Sintético',
          icon: AppIcons.circle,
          homeRoute: '/sintetico',
          bottomTabs: [
            BottomTab(
              id: 'home',
              label: 'Início',
              icon: AppIcons.home,
              path: '',
            ),
            BottomTab(
              id: 'apps',
              label: 'Apps',
              icon: AppIcons.layoutGrid,
              path: 'apps',
            ),
            BottomTab(
              id: 'estoque',
              label: 'Estoque',
              icon: AppIcons.boxes,
              path: 'estoque',
            ),
            BottomTab(
              id: 'menu',
              label: 'Menu',
              icon: AppIcons.menu,
              path: 'menu',
              action: 'menu',
            ),
          ],
        );
        final sections = getMenuSections(synthetic);
        expect(sections, hasLength(1));
        expect(sections.first.title, 'Funcionalidades');
        // 'menu' tem action e é excluído; '' (home) também é excluído por path vazio.
        expect(
          sections.first.items.map((i) => i.id),
          containsAll(['apps', 'estoque']),
        );
        expect(sections.first.items.map((i) => i.id), isNot(contains('menu')));
      },
    );

    test(
      'menu lateral de Fazendas lista os grupos do catálogo num grupo só',
      () {
        final sections = getMenuSections(getModule('fazendas')!);

        expect(sections.map((s) => s.title), ['Menu']);
        final labels = sections.single.items.map((i) => i.label).toList();
        // O menu é o índice completo: repete o que está na navbar, com o
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
      'navbar operacional: Início, Pecuária, Agricultura, Confinamento e Menu',
      () {
        expect(operationalBottomTabs.map((t) => t.label), [
          'Início',
          'Pecuária',
          'Agricultura',
          'Confinamento',
          'Menu',
        ]);
        expect(operationalBottomTabs.last.action, 'menu');
      },
    );

    test('Fazendas só entrega a aba operacional (perfil único do app)', () {
      final fazendas = getModule('fazendas')!;
      final tabs = visibleBottomTabs(fazendas, UserAccessProfile.operational);

      expect(tabs.where((tab) => tab.action == null).map((tab) => tab.label), [
        'Rotinas',
      ]);
    });
  });
}
