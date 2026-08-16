import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/design/theme/theme_provider.dart';
import 'package:cerne_app/main.dart';

void main() {
  testWidgets('CerneApp abre no módulo Início (rota /inicio) sem exceções', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CerneApp()));
    // `pumpAndSettle` só continua pumpando enquanto frames são agendados — um
    // `Future.delayed` isolado (SimulatedLoad/RiseIn da HubHomeScreen) não
    // agenda frame algum até disparar, então pode ficar pendente se não
    // avançarmos o relógio explicitamente antes.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('ThemeVariantNotifier alterna entre light e gbMode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeVariantProvider), AppThemeVariant.light);

    container.read(themeVariantProvider.notifier).toggle();
    expect(container.read(themeVariantProvider), AppThemeVariant.gbMode);
  });
}
