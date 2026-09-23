import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/router/app_router.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

void main() {
  group('política funcional de acesso', () {
    const signedOut = PrototypeSessionState.signedOut();
    const operational = PrototypeSessionState.signedIn(
      UserAccessProfile.operational,
    );

    test('sem sessão só login e onboarding permanecem públicos', () {
      expect(redirectForSession('/login', signedOut), isNull);
      expect(redirectForSession('/onboarding', signedOut), isNull);

      for (final path in [
        '/',
        '/perfil',
        '/notificacoes',
        '/fazendas/operacional',
        '/fazendas/operacional/carga',
      ]) {
        expect(redirectForSession(path, signedOut), '/login', reason: path);
      }
    });

    test('rotas operacionais e de campo continuam livres com sessão ativa', () {
      for (final path in [
        '/fazendas/operacional',
        '/fazendas/operacional/carga',
        '/fazendas/campo/pesagem',
        '/fazendas/campo/sincronizacao',
      ]) {
        expect(redirectForSession(path, operational), isNull, reason: path);
      }
    });

    test('raiz e login retornam à central do perfil', () {
      const profile = UserAccessProfile.operational;
      const session = operational;
      for (final path in ['/', '/login']) {
        expect(
          redirectForSession(path, session),
          profile.landingRoute,
          reason: path,
        );
      }
      expect(
        redirectForSession('/fazendas', session),
        profile.homeRoute,
        reason: '/fazendas',
      );
      expect(
        redirectForSession('/fazendas/mais', session),
        profile.homeRoute,
        reason: '/fazendas/mais',
      );
    });
  });
}
