import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';

/// Login do Shell (mock, sem autenticação real) — espelha `Login.tsx`: arte de
/// campo em tela cheia como fundo fixo, véu escuro só no topo para a marca
/// clara, e cartão de boas-vindas com o formulário flutuando sobre a arte.
/// Qualquer entrada leva ao superapp (`/inicio`).
///
/// Desvio do React: `logo-min-white.svg` não é renderizável sem `flutter_svg`
/// (fora do escopo desta mudança — ver relatório da tarefa). No lugar da marca
/// SVG, usa-se o fallback tokenizado já adotado por `AppIllustrationSlot`
/// (bolha `ink` + ícone do catálogo).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _manterConectado = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

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
                          child: Icon(LucideIcons.sprout, size: 32, color: semantic.ctaBg),
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
                            style: TextStyle(color: semantic.fgInverse.withValues(alpha: 0.7)),
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppCheckbox(
                                checked: _manterConectado,
                                onChanged: (v) => setState(() => _manterConectado = v),
                                label: 'Manter conectado',
                              ),
                              // Mock — recuperação de senha fora do escopo do protótipo.
                              AppButton(variant: AppButtonVariant.link, onPressed: () {}, child: const Text('Esqueceu a senha?')),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          AppButton(
                            fullWidth: true,
                            size: AppButtonSize.lg,
                            onPressed: () => context.go('/inicio'),
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
                      style: TextStyle(fontSize: 11, color: semantic.fgInverse.withValues(alpha: 0.7)),
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
