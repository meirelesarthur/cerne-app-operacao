import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../state/prototype_session_store.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Login do Shell (mock, sem autenticação real) — espelha `Login.tsx`: arte de
/// campo em tela cheia como fundo fixo, véu escuro só no topo para a marca
/// clara, e cartão de boas-vindas com o formulário flutuando sobre a arte.
/// Qualquer entrada leva ao superapp (`/inicio`).
///
/// Desvio do React: `logo-min-white.svg` não é renderizável sem `flutter_svg`
/// (fora do escopo desta mudança — ver relatório da tarefa). No lugar da marca
/// SVG, usa-se o fallback tokenizado já adotado por `AppIllustrationSlot`
/// (bolha `ink` + ícone do catálogo).
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
    context.go(profile.homeRoute);
  }

  /// Ambiente sinalizado pela pasta "CRN App" da home Android (`?ambiente=
  /// administracao|operacional`) — reforça visualmente a separação dos dois
  /// apps sem remover a etapa de login compartilhada (decisão já validada).
  UserAccessProfile? get _ambienteFromQuery {
    final value = GoRouterState.of(context).uri.queryParameters['ambiente'];
    return switch (value) {
      'administracao' => UserAccessProfile.administration,
      'operacional' => UserAccessProfile.operational,
      _ => null,
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
                        Container(
                          width: AppSpacing.space16,
                          height: AppSpacing.space16,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: semantic.inkBg,
                            borderRadius: BorderRadius.circular(AppRadius.xl2),
                            boxShadow: semantic.shadowModal,
                          ),
                          child: Icon(
                            LucideIcons.sprout,
                            size: 32,
                            color: semantic.ctaBg,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        AppHeading(
                          level: AppHeadingLevel.h1,
                          style: TextStyle(color: semantic.fgInverse),
                          child: const Text('GB CERNE'),
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
                            switch (ambiente) {
                              UserAccessProfile.administration =>
                                'Abrindo CRN ADM.',
                              UserAccessProfile.operational =>
                                'Abrindo CRN Operação.',
                              null =>
                                'Escolha o ambiente para esta sessão demonstrativa.',
                            },
                            textAlign: TextAlign.center,
                            style: TextStyle(color: semantic.fgMuted),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Quando a tela chega sinalizada pela pasta
                              // "CRN App" (`ambiente`), destaca o botão do
                              // ambiente escolhido e reduz o outro a
                              // secundário — reforça a separação dos dois
                              // apps mesmo compartilhando o mesmo formulário.
                              final administrationButton = AppButton(
                                fullWidth: true,
                                size: AppButtonSize.lg,
                                variant:
                                    ambiente == UserAccessProfile.operational
                                    ? AppButtonVariant.ghost
                                    : AppButtonVariant.primary,
                                onPressed: () =>
                                    _loginAs(UserAccessProfile.administration),
                                child: const Text('Login Administração'),
                              );
                              final operationalButton = AppButton(
                                fullWidth: true,
                                size: AppButtonSize.lg,
                                variant:
                                    ambiente == UserAccessProfile.administration
                                    ? AppButtonVariant.ghost
                                    : AppButtonVariant.secondary,
                                onPressed: () =>
                                    _loginAs(UserAccessProfile.operational),
                                child: const Text('Login Operacional'),
                              );

                              if (constraints.maxWidth > AppSize.phone) {
                                return Row(
                                  children: [
                                    Expanded(child: administrationButton),
                                    const SizedBox(width: AppSpacing.space3),
                                    Expanded(child: operationalButton),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  administrationButton,
                                  const SizedBox(height: AppSpacing.space3),
                                  operationalButton,
                                ],
                              );
                            },
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
