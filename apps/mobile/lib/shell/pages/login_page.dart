import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../state/prototype_session_store.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Login do Shell (mock, sem autenticação real) — espelha `Login.tsx`: arte de
/// campo em tela cheia como fundo fixo, véu escuro só no topo para a marca
/// clara, e cartão de boas-vindas com o formulário flutuando sobre a arte.
/// A tela é compartilhada pelos dois apps, mas o destino é definido pelo
/// ambiente enviado pela pasta `CRN App`: Administração abre o hub Banking e
/// Operação abre a central de campo. Não há duas ações de login nesta tela.
///
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _manterConectado = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _loginAs(UserAccessProfile profile) {
    ref.read(prototypeSessionProvider.notifier).loginAs(profile);
    context.go(profile.landingRoute);
  }

  /// Ambiente sinalizado pela pasta "CRN App" (`?ambiente=administracao|
  /// operacional`). Um `/login` direto cai no administrativo, que é a porta
  /// padrão do superapp.
  UserAccessProfile get _ambienteFromQuery {
    final value = GoRouterState.of(context).uri.queryParameters['ambiente'];
    return switch (value) {
      'administracao' => UserAccessProfile.administration,
      'operacional' => UserAccessProfile.operational,
      _ => UserAccessProfile.administration,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final ambiente = _ambienteFromQuery;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arte de fundo integral — fixa; o conteúdo rola por cima.
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.4, 0.68],
                colors: [
                  AppComponentColors.loginHeroScrimFrom,
                  AppComponentColors.loginHeroScrimMid,
                  AppComponentColors.loginHeroScrimTo,
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bloco da marca sobre a arte.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space6,
                      AppSpacing.space10,
                      AppSpacing.space6,
                      AppSpacing.space10,
                    ),
                    child: Column(
                      children: [
                        const AppBrandLogo(
                          variant: AppBrandLogoVariant.onDark,
                          height: AppSpacing.space10,
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            'Fazendas, banco, crédito e mercado — o agro inteiro em um só app.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: semantic.fgInverse.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cartão do formulário flutuando sobre a arte.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space5,
                      0,
                      AppSpacing.space5,
                      AppSpacing.space8,
                    ),
                    child: AppCard(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              const AppHeading(child: Text('Bem-vindo!')),
                              const SizedBox(height: AppSpacing.space1),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('Primeira vez por aqui?'),
                                  AppButton(
                                    variant: AppButtonVariant.link,
                                    onPressed: () => context.go('/onboarding'),
                                    child: const Text('Conhecer o app'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space6),
                          AppFormField(
                            label: 'E-mail',
                            child: AppTextInput(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              placeholder: 'seu@email.com',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          AppFormField(
                            label: 'Senha',
                            child: AppTextInput(
                              controller: _senhaController,
                              obscureText: true,
                              placeholder: 'Digite sua senha',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: AppSpacing.space1,
                            children: [
                              AppCheckbox(
                                checked: _manterConectado,
                                onChanged: (v) =>
                                    setState(() => _manterConectado = v),
                                label: 'Manter conectado',
                              ),
                              // Mock — recuperação de senha fora do escopo do protótipo.
                              AppButton(
                                variant: AppButtonVariant.link,
                                onPressed: () {},
                                child: const Text('Esqueceu a senha?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          Text(
                            ambiente == UserAccessProfile.administration
                                ? 'Acesso administrativo'
                                : 'Acesso operacional',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: semantic.fgMuted),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          AppButton(
                            fullWidth: true,
                            size: AppButtonSize.lg,
                            onPressed: () => _loginAs(ambiente),
                            child: const Text('Entrar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space6),
                    child: Text(
                      'GB CERNE · Superapp corporativo do agronegócio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        color: semantic.fgInverse.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
