import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_motion.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.desc,
  });

  /// Fallback do hero enquanto a foto do slide não existe — ver
  /// `AppIllustrationSlot(fullBleed: true)`.
  final AppIconData icon;
  final String title;
  final String desc;
}

/// Slides do onboarding — hero full-bleed em `assets/images/`, ainda por
/// gerar (fotos fotorealistas); até lá cada slide cai no fallback tokenizado
/// (ícone sobre `AppSemanticColors.inkBg`). Caminho de imagem pretendido, na
/// ordem: `onboard_campo.png`, `onboard_paineis.png`, `onboard_bank.png`,
/// `onboard_credito.png`, `onboard_marketplace.png` — wire via `src:` em
/// `AppIllustrationSlot` assim que as fotos existirem.
///
/// Cinco slides, um por capacidade mais atrativa do superapp (levantamento de
/// 15/09/2026): campo offline-first, painéis de decisão, banco, crédito e
/// marketplace/armazém. Substitui o carrossel anterior de 3 slides, que
/// fundia banco+crédito e marketplace+armazém e não cobria os painéis
/// administrativos.
const _slides = [
  _OnboardingSlide(
    icon: AppIcons.sprout,
    title: 'Sua fazenda na palma da mão',
    desc:
        'Lance arraçoamento, pesagem e manejo direto do curral — mesmo sem sinal, tudo sincroniza quando a conexão voltar.',
  ),
  _OnboardingSlide(
    icon: AppIcons.layoutDashboard,
    title: 'Decisão na tela, não na planilha',
    desc:
        'Resultado, confinamento, suprimentos e ativos consolidados em painéis que viram decisão na hora.',
  ),
  _OnboardingSlide(
    icon: AppIcons.landmark,
    title: 'Seu banco, dentro da fazenda',
    desc:
        'Conta digital, Pix, pagamentos e cartões do produtor — sem trocar de app para cuidar do financeiro.',
  ),
  _OnboardingSlide(
    icon: AppIcons.handCoins,
    title: 'Crédito sob medida pra sua safra',
    desc:
        'Simule e contrate crédito pré-aprovado, acompanhe propostas e contratos direto pelo celular.',
  ),
  _OnboardingSlide(
    icon: AppIcons.shoppingBag,
    title: 'Compre, venda e armazene sem sair do app',
    desc:
        'Marketplace de insumos e máquinas integrado ao controle de estoque e logística do armazém.',
  ),
];

/// Onboarding do Shell: carrossel de 5 telas (hero full-bleed + título +
/// descrição), com dots, Pular e Próximo; o último slide convida a começar.
/// Suporta swipe via `PageView`. A imagem encosta nas bordas — inclusive sob
/// a status bar — só com raio nos cantos inferiores; texto e ações ficam na
/// folha abaixo, dentro da área segura.
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _slide = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Column(
                  children: [
                    // Full-bleed: encosta no topo real da tela (sob a status
                    // bar), não na área segura — só a folha de texto abaixo
                    // respeita o SafeArea.
                    Expanded(
                      flex: 6,
                      child: AppIllustrationSlot(
                        alt: slide.title,
                        icon: slide.icon,
                        fullBleed: true,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space6,
                            vertical: AppSpacing.space4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                constraints: const BoxConstraints(
                                  maxWidth: 300,
                                ),
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
                                constraints: const BoxConstraints(
                                  maxWidth: 320,
                                ),
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
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space6,
                0,
                AppSpacing.space6,
                AppSpacing.space6,
              ),
              child: Column(
                children: [
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
        ],
      ),
    );
  }
}
