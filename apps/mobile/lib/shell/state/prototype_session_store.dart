import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Perfil disponível na sessão demonstrativa do protótipo — só o Operacional,
/// única entrada do CERNE Operação.
enum UserAccessProfile { operational }

extension UserAccessProfileLabels on UserAccessProfile {
  String get label => 'Operacional';

  String get roleLabel => 'Operador';

  String get homeRoute => '/fazendas/operacional';

  /// Primeira tela depois do login escolhido na pasta de apps: a central de
  /// campo.
  String get landingRoute => homeRoute;
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
