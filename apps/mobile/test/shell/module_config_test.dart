import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/module_config.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

void main() {
  group('module_config', () {
    test('todos os 6 módulos existem com bottomTabs não vazios', () {
      expect(modules.length, 6);
      for (final m in modules) {
        expect(m.bottomTabs, isNotEmpty);
      }
    });

    test('getModule resolve por id e retorna null para desconhecido/nulo', () {
      expect(getModule('fazendas')?.label, 'Fazendas');
      expect(getModule('inexistente'), isNull);
      expect(getModule(null), isNull);
    });

    test('getMenuSections usa menuSections quando definido', () {
      final bank = getModule('bank')!;
      final sections = getMenuSections(bank);
      expect(
        sections.map((s) => s.title),
        contains('Pagamentos e transferências'),
      );
    });

    test(
      'getMenuSections cai no fallback derivado das bottomTabs quando ausente',
      () {
        final inicio = getModule('inicio')!;
        final sections = getMenuSections(inicio);
        expect(sections, hasLength(1));
        expect(sections.first.title, 'Funcionalidades');
        // 'menu' tem action e é excluído; '' (home) também é excluído por path vazio.
        expect(
          sections.first.items.map((i) => i.id),
          containsAll(['apps', 'carteira']),
        );
        expect(sections.first.items.map((i) => i.id), isNot(contains('menu')));
      },
    );

    test('Fazendas filtra abas e menus pelo perfil da sessão', () {
      final fazendas = getModule('fazendas')!;
      final adminTabs = visibleBottomTabs(
        fazendas,
        UserAccessProfile.administration,
      );
      final operationalTabs = visibleBottomTabs(
        fazendas,
        UserAccessProfile.operational,
      );

      expect(adminTabs.map((tab) => tab.id), contains('dashboard'));
      expect(adminTabs.map((tab) => tab.id), isNot(contains('rotinas')));
      expect(operationalTabs.map((tab) => tab.id), contains('rotinas'));
      expect(
        operationalTabs.map((tab) => tab.id),
        isNot(contains('dashboard')),
      );

      final operationalItems = getMenuSections(
        fazendas,
        profile: UserAccessProfile.operational,
      ).expand((section) => section.items);
      expect(
        operationalItems.map((item) => item.route),
        isNot(contains('/fazendas/dashboards/financeiro')),
      );
    });
  });
}
