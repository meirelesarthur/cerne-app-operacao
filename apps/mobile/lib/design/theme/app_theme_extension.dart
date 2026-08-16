import 'package:flutter/material.dart';

import '../generated/app_colors.dart';
import '../generated/app_shadows.dart';

/// Cores e sombras semânticas (light | gbMode), equivalente às CSS vars
/// trocadas via `data-theme` no protótipo React (`src/styles/tokens.css`).
///
/// Consumir via `Theme.of(context).extension<AppSemanticColors>()!`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.fgDefault,
    required this.fgMuted,
    required this.fgSubtle,
    required this.fgInverse,
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSubtle,
    required this.bgRaised,
    required this.bgKpi,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderSubtle,
    required this.borderTint,
    required this.accentDefault,
    required this.accentHover,
    required this.accentSubtle,
    required this.accentContrast,
    required this.inkBg,
    required this.inkFg,
    required this.inkMuted,
    required this.inkSubtle,
    required this.inkBubble,
    required this.inkLine,
    required this.ctaBg,
    required this.ctaHover,
    required this.ctaFg,
    required this.navBg,
    required this.navFg,
    required this.navActive,
    required this.navBorder,
    required this.shadowCard,
    required this.shadowCardHover,
    required this.shadowModal,
  });

  final Color fgDefault;
  final Color fgMuted;
  final Color fgSubtle;
  final Color fgInverse;
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSubtle;
  final Color bgRaised;
  final Color bgKpi;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderSubtle;
  final Color borderTint;
  final Color accentDefault;
  final Color accentHover;
  final Color accentSubtle;
  final Color accentContrast;
  final Color inkBg;
  final Color inkFg;
  final Color inkMuted;
  final Color inkSubtle;
  final Color inkBubble;
  final Color inkLine;
  final Color ctaBg;
  final Color ctaHover;
  final Color ctaFg;
  final Color navBg;
  final Color navFg;
  final Color navActive;
  final Color navBorder;
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowCardHover;
  final List<BoxShadow> shadowModal;

  static const light = AppSemanticColors(
    fgDefault: AppColorsLight.fgDefault,
    fgMuted: AppColorsLight.fgMuted,
    fgSubtle: AppColorsLight.fgSubtle,
    fgInverse: AppColorsLight.fgInverse,
    bgCanvas: AppColorsLight.bgCanvas,
    bgSurface: AppColorsLight.bgSurface,
    bgSubtle: AppColorsLight.bgSubtle,
    bgRaised: AppColorsLight.bgRaised,
    bgKpi: AppColorsLight.bgKpi,
    borderDefault: AppColorsLight.borderDefault,
    borderStrong: AppColorsLight.borderStrong,
    borderSubtle: AppColorsLight.borderSubtle,
    borderTint: AppColorsLight.borderTint,
    accentDefault: AppColorsLight.accentDefault,
    accentHover: AppColorsLight.accentHover,
    accentSubtle: AppColorsLight.accentSubtle,
    accentContrast: AppColorsLight.accentContrast,
    inkBg: AppColorsLight.inkBg,
    inkFg: AppColorsLight.inkFg,
    inkMuted: AppColorsLight.inkMuted,
    inkSubtle: AppColorsLight.inkSubtle,
    inkBubble: AppColorsLight.inkBubble,
    inkLine: AppColorsLight.inkLine,
    ctaBg: AppColorsLight.ctaBg,
    ctaHover: AppColorsLight.ctaHover,
    ctaFg: AppColorsLight.ctaFg,
    navBg: AppColorsLight.navBg,
    navFg: AppColorsLight.navFg,
    navActive: AppColorsLight.navActive,
    navBorder: AppColorsLight.navBorder,
    shadowCard: AppShadowsLight.card,
    shadowCardHover: AppShadowsLight.cardHover,
    shadowModal: AppShadowsLight.modal,
  );

  static const gbMode = AppSemanticColors(
    fgDefault: AppColorsGbMode.fgDefault,
    fgMuted: AppColorsGbMode.fgMuted,
    fgSubtle: AppColorsGbMode.fgSubtle,
    fgInverse: AppColorsGbMode.fgInverse,
    bgCanvas: AppColorsGbMode.bgCanvas,
    bgSurface: AppColorsGbMode.bgSurface,
    bgSubtle: AppColorsGbMode.bgSubtle,
    bgRaised: AppColorsGbMode.bgRaised,
    bgKpi: AppColorsGbMode.bgKpi,
    borderDefault: AppColorsGbMode.borderDefault,
    borderStrong: AppColorsGbMode.borderStrong,
    borderSubtle: AppColorsGbMode.borderSubtle,
    borderTint: AppColorsGbMode.borderTint,
    accentDefault: AppColorsGbMode.accentDefault,
    accentHover: AppColorsGbMode.accentHover,
    accentSubtle: AppColorsGbMode.accentSubtle,
    accentContrast: AppColorsGbMode.accentContrast,
    inkBg: AppColorsGbMode.inkBg,
    inkFg: AppColorsGbMode.inkFg,
    inkMuted: AppColorsGbMode.inkMuted,
    inkSubtle: AppColorsGbMode.inkSubtle,
    inkBubble: AppColorsGbMode.inkBubble,
    inkLine: AppColorsGbMode.inkLine,
    ctaBg: AppColorsGbMode.ctaBg,
    ctaHover: AppColorsGbMode.ctaHover,
    ctaFg: AppColorsGbMode.ctaFg,
    navBg: AppColorsGbMode.navBg,
    navFg: AppColorsGbMode.navFg,
    navActive: AppColorsGbMode.navActive,
    navBorder: AppColorsGbMode.navBorder,
    shadowCard: AppShadowsGbMode.card,
    shadowCardHover: AppShadowsGbMode.cardHover,
    shadowModal: AppShadowsGbMode.modal,
  );

  @override
  AppSemanticColors copyWith({
    Color? fgDefault,
    Color? fgMuted,
    Color? fgSubtle,
    Color? fgInverse,
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgSubtle,
    Color? bgRaised,
    Color? bgKpi,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderSubtle,
    Color? borderTint,
    Color? accentDefault,
    Color? accentHover,
    Color? accentSubtle,
    Color? accentContrast,
    Color? inkBg,
    Color? inkFg,
    Color? inkMuted,
    Color? inkSubtle,
    Color? inkBubble,
    Color? inkLine,
    Color? ctaBg,
    Color? ctaHover,
    Color? ctaFg,
    Color? navBg,
    Color? navFg,
    Color? navActive,
    Color? navBorder,
    List<BoxShadow>? shadowCard,
    List<BoxShadow>? shadowCardHover,
    List<BoxShadow>? shadowModal,
  }) {
    return AppSemanticColors(
      fgDefault: fgDefault ?? this.fgDefault,
      fgMuted: fgMuted ?? this.fgMuted,
      fgSubtle: fgSubtle ?? this.fgSubtle,
      fgInverse: fgInverse ?? this.fgInverse,
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      bgRaised: bgRaised ?? this.bgRaised,
      bgKpi: bgKpi ?? this.bgKpi,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderTint: borderTint ?? this.borderTint,
      accentDefault: accentDefault ?? this.accentDefault,
      accentHover: accentHover ?? this.accentHover,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      accentContrast: accentContrast ?? this.accentContrast,
      inkBg: inkBg ?? this.inkBg,
      inkFg: inkFg ?? this.inkFg,
      inkMuted: inkMuted ?? this.inkMuted,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      inkBubble: inkBubble ?? this.inkBubble,
      inkLine: inkLine ?? this.inkLine,
      ctaBg: ctaBg ?? this.ctaBg,
      ctaHover: ctaHover ?? this.ctaHover,
      ctaFg: ctaFg ?? this.ctaFg,
      navBg: navBg ?? this.navBg,
      navFg: navFg ?? this.navFg,
      navActive: navActive ?? this.navActive,
      navBorder: navBorder ?? this.navBorder,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowCardHover: shadowCardHover ?? this.shadowCardHover,
      shadowModal: shadowModal ?? this.shadowModal,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppSemanticColors(
      fgDefault: c(fgDefault, other.fgDefault),
      fgMuted: c(fgMuted, other.fgMuted),
      fgSubtle: c(fgSubtle, other.fgSubtle),
      fgInverse: c(fgInverse, other.fgInverse),
      bgCanvas: c(bgCanvas, other.bgCanvas),
      bgSurface: c(bgSurface, other.bgSurface),
      bgSubtle: c(bgSubtle, other.bgSubtle),
      bgRaised: c(bgRaised, other.bgRaised),
      bgKpi: c(bgKpi, other.bgKpi),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      borderSubtle: c(borderSubtle, other.borderSubtle),
      borderTint: c(borderTint, other.borderTint),
      accentDefault: c(accentDefault, other.accentDefault),
      accentHover: c(accentHover, other.accentHover),
      accentSubtle: c(accentSubtle, other.accentSubtle),
      accentContrast: c(accentContrast, other.accentContrast),
      inkBg: c(inkBg, other.inkBg),
      inkFg: c(inkFg, other.inkFg),
      inkMuted: c(inkMuted, other.inkMuted),
      inkSubtle: c(inkSubtle, other.inkSubtle),
      inkBubble: c(inkBubble, other.inkBubble),
      inkLine: c(inkLine, other.inkLine),
      ctaBg: c(ctaBg, other.ctaBg),
      ctaHover: c(ctaHover, other.ctaHover),
      ctaFg: c(ctaFg, other.ctaFg),
      navBg: c(navBg, other.navBg),
      navFg: c(navFg, other.navFg),
      navActive: c(navActive, other.navActive),
      navBorder: c(navBorder, other.navBorder),
      // Sombras não interpolam bem elemento-a-elemento; troca discreta no ponto médio.
      shadowCard: t < 0.5 ? shadowCard : other.shadowCard,
      shadowCardHover: t < 0.5 ? shadowCardHover : other.shadowCardHover,
      shadowModal: t < 0.5 ? shadowModal : other.shadowModal,
    );
  }
}
