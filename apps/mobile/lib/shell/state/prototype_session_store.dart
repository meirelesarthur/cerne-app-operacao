import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Perfis disponíveis na sessão demonstrativa do protótipo.
enum UserAccessProfile { administration, operational }

extension UserAccessProfileLabels on UserAccessProfile {
  String get label => switch (this) {
    UserAccessProfile.administration => 'Administração',
    UserAccessProfile.operational => 'Operacional',
  };

  String get roleLabel => switch (this) {
    UserAccessProfile.administration => 'Administrador',
    UserAccessProfile.operational => 'Operador',
  };

  String get homeRoute => switch (this) {
    UserAccessProfile.administration => '/fazendas/administracao',
    UserAccessProfile.operational => '/fazendas/operacional',
  };
}

class PrototypeSessionState {
  const PrototypeSessionState._({this.profile});

  const PrototypeSessionState.signedOut() : this._();

  const PrototypeSessionState.signedIn(UserAccessProfile profile)
    : this._(profile: profile);

  final UserAccessProfile? profile;

  bool get isAuthenticated => profile != null;
}

final prototypeSessionProvider =
    NotifierProvider<PrototypeSessionNotifier, PrototypeSessionState>(
      PrototypeSessionNotifier.new,
    );

class PrototypeSessionNotifier extends Notifier<PrototypeSessionState> {
  @override
  PrototypeSessionState build() => const PrototypeSessionState.signedOut();

  void loginAs(UserAccessProfile profile) {
    state = PrototypeSessionState.signedIn(profile);
  }

  void logout() {
    state = const PrototypeSessionState.signedOut();
  }
}
