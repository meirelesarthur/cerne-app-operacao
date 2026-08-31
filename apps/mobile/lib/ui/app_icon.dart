import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:widgetbook/widgetbook.dart';

import '../design/generated/app_colors.dart';
import '../design/generated/app_layout.dart';
import '../design/generated/app_spacing.dart';
import '../design/generated/app_typography.dart';
import '../design/theme/app_theme_extension.dart';

/// Dado de um ícone do sistema.
///
/// Hugeicons não entrega `IconData`: entrega a estrutura JSON de um SVG (lista de
/// pares `[tag, atributos]`) que `HugeIcon` monta em runtime. É exatamente isso
/// que permite sobrescrever a espessura do traço — o set gratuito nasce em 1.5 e
/// o app inteiro desenha em [AppSize.iconStroke] (1.2). Uma fonte de ícones
/// congelaria a espessura no binário e não teria essa folga.
///
/// O apelido existe para que o tipo do pacote não vaze na assinatura de nenhum
/// componente do catálogo (Lei 2): componentes e telas falam `AppIconData`.
typedef AppIconData = List<List<dynamic>>;

/// Catálogo semântico de ícones do GB CERNE — **fonte única** (Lei 2).
///
/// Toda a aplicação desenha a partir daqui; nenhum arquivo fora de `lib/ui/`
/// importa `package:hugeicons/hugeicons.dart`. Trocar o desenho de um conceito é
/// uma linha neste arquivo, não uma varredura por 98 telas.
///
/// O mapa de origem (Lucide → Hugeicons, 132 entradas validadas contra os 5 159
/// nomes do pacote) está versionado em `scripts/icon-map.json` e justificado em
/// `docs/ESTEIRA-PADRAO-GLOBAL-HUGEICONS.md`, §3.4.
class AppIcons {
  AppIcons._();

  // --- Setas e navegacao direcional ----------------------------------------
  static const AppIconData arrowRight = HugeIcons.strokeRoundedArrowRight01;
  static const AppIconData arrowLeft = HugeIcons.strokeRoundedArrowLeft01;
  static const AppIconData arrowUpRight = HugeIcons.strokeRoundedArrowUpRight01;
  static const AppIconData arrowDownLeft = HugeIcons.strokeRoundedArrowDownLeft01;
  static const AppIconData arrowLeftRight = HugeIcons.strokeRoundedArrowDataTransferHorizontal;
  static const AppIconData chevronRight = HugeIcons.strokeRoundedArrowRight01;
  static const AppIconData chevronLeft = HugeIcons.strokeRoundedArrowLeft01;
  static const AppIconData chevronDown = HugeIcons.strokeRoundedArrowDown01;

  // --- Estado, validacao e feedback ----------------------------------------
  static const AppIconData check = HugeIcons.strokeRoundedTick02;
  static const AppIconData checkCircle2 = HugeIcons.strokeRoundedCheckmarkCircle02;
  static const AppIconData circle = HugeIcons.strokeRoundedCircle;
  static const AppIconData circleAlert = HugeIcons.strokeRoundedAlertCircle;
  static const AppIconData alertCircle = HugeIcons.strokeRoundedAlertCircle;
  static const AppIconData triangleAlert = HugeIcons.strokeRoundedAlert02;
  static const AppIconData alertTriangle = HugeIcons.strokeRoundedAlert02;
  static const AppIconData shieldAlert = HugeIcons.strokeRoundedShieldEnergy;
  static const AppIconData info = HugeIcons.strokeRoundedInformationCircle;
  static const AppIconData helpCircle = HugeIcons.strokeRoundedHelpCircle;
  static const AppIconData x = HugeIcons.strokeRoundedCancel01;
  static const AppIconData plus = HugeIcons.strokeRoundedAdd01;
  static const AppIconData minus = HugeIcons.strokeRoundedMinusSign;
  static const AppIconData frown = HugeIcons.strokeRoundedSad01;
  static const AppIconData partyPopper = HugeIcons.strokeRoundedParty;

  // --- Chrome do app: busca, menu, sessao ----------------------------------
  static const AppIconData menu = HugeIcons.strokeRoundedMenu01;
  static const AppIconData moreHorizontal = HugeIcons.strokeRoundedMoreHorizontal;
  static const AppIconData ellipsis = HugeIcons.strokeRoundedMoreHorizontal;
  static const AppIconData search = HugeIcons.strokeRoundedSearch01;
  static const AppIconData searchX = HugeIcons.strokeRoundedSearchRemove;
  static const AppIconData aiSearch = HugeIcons.strokeRoundedAiSearch;
  static const AppIconData filter = HugeIcons.strokeRoundedFilterHorizontal;
  static const AppIconData slidersHorizontal = HugeIcons.strokeRoundedFilterHorizontal;
  static const AppIconData layoutGrid = HugeIcons.strokeRoundedDashboardSquare01;
  static const AppIconData layoutDashboard = HugeIcons.strokeRoundedDashboardSpeed01;
  static const AppIconData layers = HugeIcons.strokeRoundedLayers01;
  static const AppIconData bell = HugeIcons.strokeRoundedNotification02;
  static const AppIconData bellRing = HugeIcons.strokeRoundedNotificationSquare;
  static const AppIconData bellOff = HugeIcons.strokeRoundedNotificationOff02;
  static const AppIconData settings = HugeIcons.strokeRoundedSettings01;
  static const AppIconData logOut = HugeIcons.strokeRoundedLogout01;
  static const AppIconData user = HugeIcons.strokeRoundedUser;
  static const AppIconData users = HugeIcons.strokeRoundedUserGroup;
  static const AppIconData eye = HugeIcons.strokeRoundedView;
  static const AppIconData eyeOff = HugeIcons.strokeRoundedViewOff;
  static const AppIconData lock = HugeIcons.strokeRoundedSquareLock01;
  static const AppIconData shield = HugeIcons.strokeRoundedShield01;
  static const AppIconData shieldCheck = HugeIcons.strokeRoundedCheckmarkBadge01;
  static const AppIconData home = HugeIcons.strokeRoundedHome01;

  // --- Financeiro: Banking, Credito e indicadores --------------------------
  static const AppIconData wallet = HugeIcons.strokeRoundedWallet01;
  static const AppIconData landmark = HugeIcons.strokeRoundedBank;
  static const AppIconData creditCard = HugeIcons.strokeRoundedCreditCard;
  static const AppIconData creditCardAccept = HugeIcons.strokeRoundedCreditCardAccept;
  static const AppIconData cash = HugeIcons.strokeRoundedCash02;
  static const AppIconData handCoins = HugeIcons.strokeRoundedHandCoins;
  static const AppIconData receipt = HugeIcons.strokeRoundedInvoice01;
  static const AppIconData calculator = HugeIcons.strokeRoundedCalculator;
  static const AppIconData trendingUp = HugeIcons.strokeRoundedChartUp;
  static const AppIconData trendingDown = HugeIcons.strokeRoundedChartDown;
  static const AppIconData lineChart = HugeIcons.strokeRoundedChartLineData01;
  static const AppIconData barChart3 = HugeIcons.strokeRoundedChartAverage;
  static const AppIconData activity = HugeIcons.strokeRoundedActivity01;
  static const AppIconData scale = HugeIcons.strokeRoundedWeightScale01;

  // --- Documentos, tarefas e registro --------------------------------------
  static const AppIconData fileText = HugeIcons.strokeRoundedFile01;
  static const AppIconData fileCheck2 = HugeIcons.strokeRoundedDocumentValidation;
  static const AppIconData fileSignature = HugeIcons.strokeRoundedLegalDocument01;
  static const AppIconData fileBarChart = HugeIcons.strokeRoundedDocumentCode;
  static const AppIconData clipboardList = HugeIcons.strokeRoundedTask01;
  static const AppIconData clipboardCheck = HugeIcons.strokeRoundedTaskDone01;
  static const AppIconData bookOpen = HugeIcons.strokeRoundedBookOpen01;
  static const AppIconData bookSearch = HugeIcons.strokeRoundedBookSearch;
  static const AppIconData listOrdered = HugeIcons.strokeRoundedLeftToRightListNumber;
  static const AppIconData pencil = HugeIcons.strokeRoundedPencilEdit01;
  static const AppIconData copy = HugeIcons.strokeRoundedCopy01;
  static const AppIconData trash2 = HugeIcons.strokeRoundedDelete02;
  static const AppIconData download = HugeIcons.strokeRoundedDownload01;
  static const AppIconData uploadCloud = HugeIcons.strokeRoundedCloudUpload;
  static const AppIconData send = HugeIcons.strokeRoundedSent;
  static const AppIconData saveAll = HugeIcons.strokeRoundedSaveEnergy01;

  // --- Logistica, estoque e marketplace ------------------------------------
  static const AppIconData package = HugeIcons.strokeRoundedPackage;
  static const AppIconData packageCheck = HugeIcons.strokeRoundedPackageDelivered;
  static const AppIconData packageSearch = HugeIcons.strokeRoundedPackageSearch;
  static const AppIconData boxes = HugeIcons.strokeRoundedCube;
  static const AppIconData warehouse = HugeIcons.strokeRoundedWarehouse;
  static const AppIconData inbox = HugeIcons.strokeRoundedInbox;
  static const AppIconData truck = HugeIcons.strokeRoundedTruck;
  static const AppIconData store = HugeIcons.strokeRoundedStore01;
  static const AppIconData store02 = HugeIcons.strokeRoundedStore02;
  static const AppIconData shoppingBag = HugeIcons.strokeRoundedShoppingBag01;
  static const AppIconData shoppingCart = HugeIcons.strokeRoundedShoppingCart01;

  // --- Agro: dominio da operacao de campo ----------------------------------
  static const AppIconData sprout = HugeIcons.strokeRoundedPlant01;
  static const AppIconData leaf = HugeIcons.strokeRoundedLeaf01;
  static const AppIconData wheat = HugeIcons.strokeRoundedWheat;
  static const AppIconData tractor = HugeIcons.strokeRoundedTractor;
  static const AppIconData barns = HugeIcons.strokeRoundedBarns;
  static const AppIconData greenHouse = HugeIcons.strokeRoundedGreenHouse;
  static const AppIconData beef = HugeIcons.strokeRoundedSteak;
  static const AppIconData milk = HugeIcons.strokeRoundedMilkBottle;
  static const AppIconData egg = HugeIcons.strokeRoundedEgg;
  static const AppIconData heart = HugeIcons.strokeRoundedFavouriteCircle;
  static const AppIconData heartPulse = HugeIcons.strokeRoundedHeartCheck;
  static const AppIconData heartCrack = HugeIcons.strokeRoundedSad02;
  static const AppIconData scanHeart = HugeIcons.strokeRoundedScanHeart;
  static const AppIconData baby = HugeIcons.strokeRoundedBaby01;
  static const AppIconData flaskConical = HugeIcons.strokeRoundedTestTube01;

  // --- Operacao, hardware e conectividade ----------------------------------
  static const AppIconData wrench = HugeIcons.strokeRoundedWrench01;
  static const AppIconData construction = HugeIcons.strokeRoundedRepair;
  static const AppIconData zap = HugeIcons.strokeRoundedFlash;
  static const AppIconData scanLine = HugeIcons.strokeRoundedBarcodeScan;
  static const AppIconData qrCode = HugeIcons.strokeRoundedQrCode;
  static const AppIconData mapPin = HugeIcons.strokeRoundedLocation01;
  static const AppIconData mapPinned = HugeIcons.strokeRoundedLocation04;
  static const AppIconData clock = HugeIcons.strokeRoundedClock01;
  static const AppIconData refreshCw = HugeIcons.strokeRoundedReload;
  static const AppIconData rotateCw = HugeIcons.strokeRoundedRefresh;
  static const AppIconData cloudSync = HugeIcons.strokeRoundedCloudSavingDone01;
  static const AppIconData cloudOff = HugeIcons.strokeRoundedCloudOff;
  static const AppIconData cloudSun = HugeIcons.strokeRoundedSunCloud01;
  static const AppIconData sun = HugeIcons.strokeRoundedSun01;
  static const AppIconData moon = HugeIcons.strokeRoundedMoon02;
  static const AppIconData wifi = HugeIcons.strokeRoundedWifi01;
  static const AppIconData wifiOff = HugeIcons.strokeRoundedWifiOff01;
  static const AppIconData bluetooth = HugeIcons.strokeRoundedBluetooth;
  static const AppIconData battery = HugeIcons.strokeRoundedBatteryMedium01;
  static const AppIconData signal = HugeIcons.strokeRoundedSignal;
  static const AppIconData smartphone = HugeIcons.strokeRoundedSmartPhone01;
  static const AppIconData camera = HugeIcons.strokeRoundedCamera01;
  static const AppIconData phone = HugeIcons.strokeRoundedCall;
  static const AppIconData globe = HugeIcons.strokeRoundedGlobe;
  static const AppIconData radio = HugeIcons.strokeRoundedRadio;
  static const AppIconData headset = HugeIcons.strokeRoundedCustomerSupport;
  static const AppIconData handshake = HugeIcons.strokeRoundedAgreement01;
  static const AppIconData messageCircle = HugeIcons.strokeRoundedMessage01;
  static const AppIconData connect = HugeIcons.strokeRoundedConnect;

  // --- Apelidos de domínio -----------------------------------------------
  // Nomeiam o conceito do agronegócio, não o desenho. São os nomes que as telas
  // de Fazendas e o padrão global do Figma devem usar: quando o desenho de
  // "pecuária" mudar, muda aqui — e só aqui.

  /// Confinamento — ladrilho da home de Operação.
  static const AppIconData confinamento = barns;

  /// Pecuária de corte. Ver §3.3 da esteira: o set gratuito não tem bovino.
  static const AppIconData pecuaria = beef;

  /// Agricultura.
  static const AppIconData agricultura = sprout;

  /// Ordem de serviço.
  static const AppIconData ordemServico = fileText;

  /// Misturador / batelada de dieta.
  static const AppIconData misturador = flaskConical;

  /// Reprodução.
  static const AppIconData reproducao = scanHeart;

  /// Consultas gerenciais.
  static const AppIconData consultas = bookSearch;

  /// Gestão de frota.
  static const AppIconData gestaoFrota = tractor;

  /// Sincronizar aplicativo.
  static const AppIconData sincronizar = cloudSync;

  /// Fazenda — seletor de contexto do cabeçalho global.
  static const AppIconData fazenda = barns;

  /// Gestão de estoque / Armazém.
  static const AppIconData estoque = boxes;

  /// Marketplace.
  static const AppIconData marketplace = store02;

  /// Open Finance.
  static const AppIconData openFinance = connect;

  /// Conta GB Banking.
  static const AppIconData banking = landmark;
}

/// Renderizador único de ícone do sistema.
///
/// Substitui `Icon(IconData)` em todo o app. Três responsabilidades, todas em um
/// lugar só:
///
/// 1. **Espessura.** Aplica [AppSize.iconStroke] (1.2) a todo ícone. Nenhuma tela
///    passa espessura própria — é o que mantém o traço uniforme.
/// 2. **Herança.** Reproduz o contrato de `Icon`: sem [size]/[color] explícitos,
///    herda do `IconTheme` do contexto (botões, listas e barras já pintam seus
///    ícones por lá), caindo em 24 px e na cor de texto padrão do tema.
/// 3. **Semântica.** [semanticLabel] chega ao leitor de tela; ícone sem rótulo
///    permanece decorativo, como em `Icon`.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// Entrada do catálogo — sempre `AppIcons.xxx`.
  final AppIconData icon;

  /// Aresta do ícone em pixels lógicos. Prefira a escala gerada
  /// (`AppSize.iconXs` … `AppSize.iconXl`). Quando nulo, herda o `IconTheme`.
  final double? size;

  /// Cor do traço. Quando nula, herda o `IconTheme` do contexto.
  final Color? color;

  /// Rótulo para leitores de tela. Nulo mantém o ícone decorativo.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final semantic = Theme.of(context).extension<AppSemanticColors>();
    final resolvedSize = size ?? iconTheme.size ?? AppSize.iconLg;
    final resolvedColor =
        color ??
        iconTheme.color ??
        semantic?.fgDefault ??
        AppColorsLight.fgDefault;

    final glyph = SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: HugeIcon(
        icon: icon,
        size: resolvedSize,
        color: resolvedColor,
        strokeWidth: AppSize.iconStroke,
      ),
    );

    if (semanticLabel == null) return glyph;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: glyph),
    );
  }
}

WidgetbookComponent buildAppIconWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Icon',
    useCases: [
      WidgetbookUseCase(
        name: 'Escala',
        builder: (context) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final entry in const <(String, double)>[
                ('xs', AppSize.iconXs),
                ('sm', AppSize.iconSm),
                ('md', AppSize.iconMd),
                ('lg', AppSize.iconLg),
                ('xl', AppSize.iconXl),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(AppIcons.tractor, size: entry.$2),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        entry.$1,
                        style: const TextStyle(fontSize: AppTypography.xs),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      WidgetbookUseCase(
        name: 'Domínio agro',
        builder: (context) => Center(
          child: Wrap(
            spacing: AppSpacing.space5,
            runSpacing: AppSpacing.space5,
            alignment: WrapAlignment.center,
            children: [
              for (final entry in const <(String, AppIconData)>[
                ('Confinamento', AppIcons.confinamento),
                ('Pecuária', AppIcons.pecuaria),
                ('Agricultura', AppIcons.agricultura),
                ('Ordem de serviço', AppIcons.ordemServico),
                ('Misturador', AppIcons.misturador),
                ('Reprodução', AppIcons.reproducao),
                ('Consultas', AppIcons.consultas),
                ('Gestão de frota', AppIcons.gestaoFrota),
                ('Sincronizar', AppIcons.sincronizar),
              ])
                SizedBox(
                  width: 96,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(entry.$2, size: AppSize.iconLg),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        entry.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: AppTypography.xs),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}
