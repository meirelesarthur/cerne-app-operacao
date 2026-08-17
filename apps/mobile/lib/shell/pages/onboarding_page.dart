import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_motion.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.image,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String image;
  final String title;
  final String desc;
}

/// Slides do onboarding — ilustrações em `assets/images/` (ícones ficam como fallback).
const _slides = [
  _OnboardingSlide(
    icon: LucideIcons.sprout,
    image: 'assets/images/onboard1.png',
    title: 'Sua fazenda na palma da mão',
    desc:
        'Dashboards gerenciais e lançamentos de campo, mesmo sem sinal — tudo sincroniza quando a conexão volta.',
  ),
  _OnboardingSlide(
    icon: LucideIcons.landmark,
    image: 'assets/images/onboard2.png',
    title: 'Banco e crédito do produtor',
    desc:
        'Conta digital, Pix, pagamentos e crédito pré-aprovado para a safra, direto no app.',
  ),
  _OnboardingSlide(
    icon: LucideIcons.shoppingBag,
    image: 'assets/images/onboard3.png',
    title: 'Compre, venda e armazene',
    desc:
        'Marketplace de insumos e gestão do armazém integrados à operação, sem sair do superapp.',
  ),
];

/// Onboarding do Shell — espelha `Onboarding.tsx`: carrossel de 3 telas
/// (ilustração + título + descrição), com dots, Pular e Próximo; o último
/// slide convida a começar. Suporta swipe via `PageView`.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _slide = 0;

  bool get _isLast => _slide == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => context.go('/login');

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(duration: AppMotion.medium, curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Scaffold(
      backgroundColor: semantic.bgCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space6,
            AppSpacing.space10,
            AppSpacing.space6,
            AppSpacing.space8,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _slide = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return SingleChildScrollView(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIllustrationSlot(
                              alt: slide.title,
                              icon: slide.icon,
                              src: slide.image,
                            ),
                            const SizedBox(height: AppSpacing.space8),
                            AppPageDots(
                              count: _slides.length,
                              active: _slide,
                              onSelect: (i) => _controller.animateToPage(
                                i,
                                duration: AppMotion.medium,
                                curve: Curves.easeOut,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: AppHeading(
                                level: AppHeadingLevel.h1,
                                child: Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                slide.desc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: semantic.fgMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: _next,
                child: Text(_isLast ? 'Começar' : 'Próximo'),
              ),
              if (!_isLast) ...[
                const SizedBox(height: AppSpacing.space2),
                AppButton(
                  fullWidth: true,
                  size: AppButtonSize.lg,
                  variant: AppButtonVariant.ghost,
                  onPressed: _finish,
                  child: const Text('Pular'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
