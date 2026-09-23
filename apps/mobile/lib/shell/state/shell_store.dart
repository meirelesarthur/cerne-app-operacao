import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store do Shell — espelha `shellStore.ts` (spec §7.3). Estado global do app,
/// tudo em memória (sem persistência local, restrição do protótipo).

class UserProfile {
  const UserProfile({required this.name, required this.initials});

  final String name;
  final String initials;
}

/// Tipo da notificação — decide ícone e cor na tela (`NotificacoesPage`).
enum TipoNotificacao {
  /// Lançamento concluído em campo (pesagem, trato, apontamento).
  lancamento,

  /// Ordem de serviço atribuída ou atualizada.
  ordemServico,

  /// Algo pede atenção (estoque baixo, prazo vencendo).
  alerta,

  /// Cancelamento ou falha (OS cancelada pelo escritório, envio falhou).
  cancelamento,

  /// Sincronização com o servidor.
  sincronizacao,

  /// Novidade do aplicativo.
  novidade,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.tipo,
    required this.title,
    required this.detail,
    required this.dataHora,
    required this.read,
    this.route,
  });

  final String id;
  final TipoNotificacao tipo;
  final String title;
  final String detail;

  /// Quando aconteceu — agrupa por dia e vira "há 5 min" na tela.
  final DateTime dataHora;
  final bool read;

  /// Tela aberta ao tocar; sem rota, o toque só marca como lida.
  final String? route;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    tipo: tipo,
    title: title,
    detail: detail,
    dataHora: dataHora,
    read: read ?? this.read,
    route: route,
  );
}

/// Notificações de exemplo, datadas a partir de [agora] para os grupos
/// "Hoje", "Ontem" e dias anteriores fazerem sentido em qualquer data.
///
/// banco-real (onda 2): tipos inspirados nos alertas mais frequentes do dump
/// gbcerne (estoque abaixo do mínimo, vencimento de protocolo) — dado
/// sintético. Três não lidas, cobertas por `shell_store_test.dart`.
List<AppNotification> _mockNotifications(DateTime agora) => [
  AppNotification(
    id: 'n1',
    tipo: TipoNotificacao.lancamento,
    title: 'Pesagem registrada',
    detail: 'Lote 42 · Fazenda São Pedro',
    dataHora: agora.subtract(const Duration(minutes: 5)),
    read: false,
    route: '/fazendas/campo/pesagem',
  ),
  AppNotification(
    id: 'n2',
    tipo: TipoNotificacao.ordemServico,
    title: 'Nova ordem de serviço atribuída',
    detail: 'OS #2201 · Reparo de cerca do Talhão 04',
    dataHora: agora.subtract(const Duration(hours: 1)),
    read: false,
    route: '/fazendas/campo/minhas-os',
  ),
  AppNotification(
    id: 'n3',
    tipo: TipoNotificacao.alerta,
    title: 'Estoque abaixo do mínimo',
    detail: 'Sal Mineral Proteinado · Armazém A',
    dataHora: agora.subtract(const Duration(hours: 3)),
    read: false,
  ),
  AppNotification(
    id: 'n4',
    tipo: TipoNotificacao.sincronizacao,
    title: 'Lançamentos sincronizados',
    detail: '12 registros enviados ao servidor',
    dataHora: agora.subtract(const Duration(days: 1, hours: 2)),
    read: true,
    route: '/fazendas/campo/sincronizacao',
  ),
  AppNotification(
    id: 'n5',
    tipo: TipoNotificacao.cancelamento,
    title: 'OS cancelada pelo escritório',
    detail: 'OS #2160 · Contenção de gado solto',
    dataHora: agora.subtract(const Duration(days: 1, hours: 5)),
    read: true,
    route: '/fazendas/campo/minhas-os',
  ),
  AppNotification(
    id: 'n6',
    tipo: TipoNotificacao.novidade,
    title: 'Novidade no aplicativo',
    detail: 'Agora dá para iniciar, pausar e retomar a OS direto do card.',
    dataHora: agora.subtract(const Duration(days: 3)),
    read: true,
  ),
];

class ShellState {
  const ShellState({
    required this.user,
    required this.notifications,
    required this.isOnline,
    required this.menuOpen,
  });

  final UserProfile user;
  final List<AppNotification> notifications;

  /// Toggle de dev — simula perda de conexão para demonstrar banners de sync.
  final bool isOnline;

  /// Menu "reveal" global (aba Mais/Menu).
  final bool menuOpen;

  int get unreadCount => notifications.where((n) => !n.read).length;

  ShellState copyWith({
    UserProfile? user,
    List<AppNotification>? notifications,
    bool? isOnline,
    bool? menuOpen,
  }) {
    return ShellState(
      user: user ?? this.user,
      notifications: notifications ?? this.notifications,
      isOnline: isOnline ?? this.isOnline,
      menuOpen: menuOpen ?? this.menuOpen,
    );
  }
}

final shellStoreProvider = NotifierProvider<ShellStoreNotifier, ShellState>(
  ShellStoreNotifier.new,
);

class ShellStoreNotifier extends Notifier<ShellState> {
  @override
  ShellState build() {
    return ShellState(
      user: const UserProfile(name: 'Silvio Ventura', initials: 'SV'),
      notifications: _mockNotifications(DateTime.now()),
      isOnline: true,
      menuOpen: false,
    );
  }

  void setOnline(bool value) => state = state.copyWith(isOnline: value);

  void toggleOnline() => state = state.copyWith(isOnline: !state.isOnline);

  void markRead(String id) {
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications)
          if (n.id == id) n.copyWith(read: true) else n,
      ],
    );
  }

  void markAllRead() {
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications) n.copyWith(read: true),
      ],
    );
  }

  void openMenu() => state = state.copyWith(menuOpen: true);

  void closeMenu() => state = state.copyWith(menuOpen: false);

  void toggleMenu() => state = state.copyWith(menuOpen: !state.menuOpen);
}
