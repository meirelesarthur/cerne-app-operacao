import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../ui/mini_app_tile.dart' show AppMiniAppTileBadge;

/// Catálogo de mini-apps do hub — espelha `src/modules/hub/mocks/apps.ts`. O contrato
/// (ícone, nome, descrição, rota, selo) permite injetar novos apps sem alterar as telas do hub.

class HubApp {
  const HubApp({
    required this.id,
    required this.icon,
    required this.name,
    required this.description,
    this.route,
    this.badge,
  });

  final String id;
  final IconData icon;
  final String name;
  final String description;
  final String? route;
  final AppMiniAppTileBadge? badge;
}

const List<HubApp> hubApps = [
  HubApp(
    id: 'fazendas',
    icon: LucideIcons.sprout,
    name: 'Fazendas',
    description: 'Gestão da operação e lançamentos de campo',
    route: '/fazendas',
  ),
  HubApp(
    id: 'bank',
    icon: LucideIcons.landmark,
    name: 'GB Bank',
    description: 'Conta, Pix, pagamentos e cartões',
    route: '/bank',
    badge: AppMiniAppTileBadge.novo,
  ),
  HubApp(
    id: 'credito',
    icon: LucideIcons.handCoins,
    name: 'Crédito',
    description: 'Simule e contrate crédito para a safra',
    route: '/credito',
  ),
  HubApp(
    id: 'marketplace',
    icon: LucideIcons.shoppingBag,
    name: 'Marketplace',
    description: 'Insumos, máquinas e serviços',
    route: '/marketplace',
  ),
  HubApp(
    id: 'armazem',
    icon: LucideIcons.warehouse,
    name: 'Armazém',
    description: 'Estoque, movimentações e logística',
    route: '/armazem',
  ),
];

const List<HubApp> appsEmBreve = [
  HubApp(
    id: 'clima',
    icon: LucideIcons.cloudSun,
    name: 'Clima',
    description: 'Previsão hiperlocal por talhão',
    badge: AppMiniAppTileBadge.breve,
  ),
  HubApp(
    id: 'cotacoes',
    icon: LucideIcons.lineChart,
    name: 'Cotações',
    description: 'Boi gordo, soja e milho em tempo real',
    badge: AppMiniAppTileBadge.breve,
  ),
  HubApp(
    id: 'consultoria',
    icon: LucideIcons.headset,
    name: 'Consultoria',
    description: 'Especialistas GB a um toque',
    badge: AppMiniAppTileBadge.breve,
  ),
  HubApp(
    id: 'seguros',
    icon: LucideIcons.shieldCheck,
    name: 'Seguros',
    description: 'Proteção de safra e patrimônio',
    badge: AppMiniAppTileBadge.breve,
  ),
];
