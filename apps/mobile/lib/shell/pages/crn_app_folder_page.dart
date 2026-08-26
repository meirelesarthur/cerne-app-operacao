import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_colors.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Simula abrir a pasta "CRN App" na tela inicial Android — mostra os dois
/// apps que compõem o protótipo, com responsabilidades **extremamente
/// separadas** desde a entrada: **CRN ADM** (administração/gestão) e
/// **CRN Operação** (rotinas de campo).
///
/// Cada ícone leva ao login existente (decisão já validada com o time — não
/// pula a etapa de login), com o ambiente escolhido sinalizado por query
/// param (`?ambiente=administracao|operacional`) para o login já abrir
/// destacando o botão correspondente. Usa `context.push` (não `go`) — mantém
/// esta tela na pilha para o voltar (gesto/botão do sistema) retornar aqui em
/// vez de pular direto para a home Android.
class CrnAppFolderPage extends StatelessWidget {
  const CrnAppFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.5, 0.82],
                colors: [
                  AppComponentColors.loginHeroScrimFrom,
                  AppComponentColors.loginHeroScrimMid,
                  AppComponentColors.loginHeroScrimTo,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.space2,
                    AppSpacing.space2,
                    AppSpacing.space5,
                    0,
                  ),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: const Icon(LucideIcons.chevronLeft),
                        label: 'Voltar',
                        variant: AppIconButtonVariant.onDark,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space6,
                    vertical: AppSpacing.space8,
                  ),
                  decoration: BoxDecoration(
                    color: semantic.inkBg.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadius.xl4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CRN App',
                        style: TextStyle(
                          fontSize: AppTypography.md,
                          fontWeight: AppTypography.weightSemibold,
                          color: semantic.fgInverse.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      Text(
                        'Escolha o ambiente para abrir',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTypography.sm,
                          color: semantic.fgInverse.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppAppIconTile(
                            icon: LucideIcons.shieldCheck,
                            label: 'CRN ADM',
                            onTap: () =>
                                context.push('/login?ambiente=administracao'),
                          ),
                          AppAppIconTile(
                            icon: LucideIcons.tractor,
                            label: 'CRN Operação',
                            onTap: () =>
                                context.push('/login?ambiente=operacional'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
