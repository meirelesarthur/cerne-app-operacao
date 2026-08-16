import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../design/theme/theme_provider.dart';
import '../../ui/ui.dart';
import '../components/sub_page_header.dart';
import '../state/shell_store.dart';
import '../state/prototype_session_store.dart';

/// Perfil / Configurações do Shell — espelha `PerfilConfig.tsx`: hero `ink` com
/// avatar central + lista de itens-cápsula. Conta + tema light/gbMode
/// continuam funções do Shell (aqui via `themeVariantProvider`).
class PerfilConfigPage extends ConsumerWidget {
  const PerfilConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final user = ref.watch(shellStoreProvider).user;
    final profile = ref.watch(prototypeSessionProvider).profile;
    final isGbMode = ref.watch(themeVariantProvider) == AppThemeVariant.gbMode;
    final roleLabel = profile?.roleLabel ?? 'Sessão não iniciada';

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            const SubPageHeader(title: 'Perfil'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  AppCard(
                    variant: AppCardVariant.ink,
                    child: Column(
                      children: [
                        AppAvatar(
                          name: user.name,
                          initials: user.initials,
                          size: AppAvatarSize.lg,
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        AppHeading(
                          level: AppHeadingLevel.h1,
                          child: Text(user.name, textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          '$roleLabel · GB CERNE',
                          style: TextStyle(color: semantic.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  AppMenuItem(
                    icon: LucideIcons.user,
                    label: 'Editar perfil',
                    description: 'Atualize seus dados',
                    onTap: () => context.go('/perfil'),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  AppMenuItem(
                    icon: LucideIcons.bell,
                    label: 'Notificações',
                    description: 'Gerencie seus avisos',
                    onTap: () => context.go('/notificacoes'),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  AppMenuItem(
                    icon: isGbMode ? LucideIcons.moon : LucideIcons.sun,
                    label: 'Tema',
                    description: isGbMode
                        ? 'GB Mode (escuro)'
                        : 'Light (claro)',
                    onTap: () =>
                        ref.read(themeVariantProvider.notifier).toggle(),
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  AppMenuItem(
                    icon: LucideIcons.logOut,
                    label: 'Sair',
                    tone: AppMenuItemTone.danger,
                    onTap: () {
                      ref.read(prototypeSessionProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
