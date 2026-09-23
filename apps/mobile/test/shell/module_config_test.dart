import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/module_config.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';
import 'package:cerne_app/ui/app_icon.dart';

void main() {
  group('module_config', () {
    test('todos os 3 módulos existem com bottomTabs não vazios', () {
      expect(modules.length, 3);
      for (final m in modules) {
        expect(m.bottomTabs, isNotEmpty);
      }
    });

    test('getModule resolve por id e retorna null para desconhecido/nulo', () {
      expect(getModule('fazendas')?.label, 'Fazendas');
      expect(getModule('inexistente'), isNull);
      expect(getModule(null), isNull);
    });

    test('dock operacional mantém apenas os atalhos prioritários', () {
      expect(
        visibleModulesFor(
          UserAccessProfile.operational,
        ).map((module) => module.id),
        ['inicio', 'fazendas', 'armazem'],
      );
      expect(modules.map((module) => module.id), hasLength(3));
    });

    test(
      'getMenuSections cai no fallback derivado das bottomTabs quando ausente',
      () {
        // Nenhum dos 3 módulos reais deixa `menuSections` ausente hoje (ver
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
      'Início não repete as próprias abas no menu "Mais" (ver plano de UX)',
      () {
        // `menuSections: []` — o menu "reveal" do Início vira só a seção
        // CONTA (perfil/tema/conexão/sair), sem duplicar as abas do topo.
        expect(getMenuSections(getModule('inicio')!), isEmpty);
      },
    );

    test(
      'menu lateral de Fazendas lista os grupos do catálogo em Lançamentos',
      () {
        final sections = getMenuSections(getModule('fazendas')!);

        expect(sections.map((s) => s.title), ['Lançamentos']);
        final labels = sections.single.items.map((i) => i.label).toList();
        // A tela inicial já é a de OS: o grupo não se repete no menu.
        expect(labels, isNot(contains('Ordem de Serviço')));
        expect(labels.first, 'Confinamento');
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
        final confinamento = sections.single.items.first;
        expect(confinamento.push, isFalse);
        expect(confinamento.route, '/fazendas/operacional/grupo/confinamento');
      },
    );

    test('navbar operacional: OSs, Pecuária, Agricultura e Menu', () {
      expect(operationalBottomTabs.map((t) => t.label), [
        'OSs',
        'Pecuária',
        'Agricultura',
        'Menu',
      ]);
      expect(operationalBottomTabs.last.action, 'menu');
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
