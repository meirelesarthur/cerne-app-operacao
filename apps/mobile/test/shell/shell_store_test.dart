import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/shell/state/shell_store.dart';

void main() {
  group('ShellStoreNotifier', () {
    test('estado inicial', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(shellStoreProvider);
      expect(state.isOnline, isTrue);
      expect(state.unreadCount, 3);
    });

    test('toggleOnline inverte o estado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(shellStoreProvider.notifier);

      notifier.toggleOnline();
      expect(container.read(shellStoreProvider).isOnline, isFalse);
    });

    test('markAllRead zera o unreadCount', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(shellStoreProvider.notifier);

      notifier.markAllRead();
      expect(container.read(shellStoreProvider).unreadCount, 0);
    });
  });
}
