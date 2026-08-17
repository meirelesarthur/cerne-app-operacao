import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/router/app_router.dart';
import 'package:cerne_app/shell/state/prototype_session_store.dart';

void main() {
  group('política funcional de acesso', () {
    const signedOut = PrototypeSessionState.signedOut();
    const administration = PrototypeSessionState.signedIn(
      UserAccessProfile.administration,
    );
    const operational = PrototypeSessionState.signedIn(
      UserAccessProfile.operational,
    );

    test('sem sessão só login e onboarding permanecem públicos', () {
      expect(redirectForSession('/login', signedOut), isNull);
      expect(redirectForSession('/onboarding', signedOut), isNull);

      for (final path in [
        '/',
        '/inicio',
        '/bank/extrato',
        '/perfil',
        '/notificacoes',
        '/fazendas/administracao',
        '/fazendas/operacional/carga',
      ]) {
        expect(redirectForSession(path, signedOut), '/login', reason: path);
      }
    });

    test('administração bloqueia todas as famílias de entrada operacional', () {
      for (final path in [
        '/fazendas/operacional',
        '/fazendas/operacional/carga',
        '/fazendas/campo/pesagem',
        '/fazendas/mais/sync',
      ]) {
        expect(
          redirectForSession(path, administration),
          UserAccessProfile.administration.homeRoute,
          reason: path,
        );
      }

      expect(
        redirectForSession('/fazendas/dashboards/financeiro', administration),
        isNull,
      );
      expect(redirectForSession('/bank/extrato', administration), isNull);
    });

    test('operação bloqueia todas as famílias de supervisão', () {
      for (final path in [
        '/fazendas/administracao',
        '/fazendas/administracao/saldo-estoque',
        '/fazendas/dashboards/financeiro',
        '/fazendas/financeiro',
      ]) {
        expect(
          redirectForSession(path, operational),
          UserAccessProfile.operational.homeRoute,
          reason: path,
        );
      }

      expect(
        redirectForSession('/fazendas/operacional/carga', operational),
        isNull,
      );
      expect(
        redirectForSession('/fazendas/campo/pesagem', operational),
        isNull,
      );
    });

    test('raiz, login e atalhos neutros retornam à central do perfil', () {
      for (final profile in UserAccessProfile.values) {
        final session = PrototypeSessionState.signedIn(profile);
        for (final path in ['/', '/login', '/fazendas', '/fazendas/mais']) {
          expect(
            redirectForSession(path, session),
            profile.homeRoute,
            reason: '${profile.name}: $path',
          );
        }
      }
    });
  });
}
