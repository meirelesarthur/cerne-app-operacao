import 'package:flutter/material.dart';

import '../screens/em_section.dart';
import 'dash_ativos.dart';
import 'dash_confinamento.dart';
import 'dash_consultas.dart';
import 'dash_financeiro.dart';
import 'dash_pecuaria.dart';
import 'dash_suprimentos.dart';
import 'dash_uso.dart';

/// Resolve o dashboard administrativo pelo `dashId` da rota
/// `/fazendas/dashboards/:dashId` (spec §4). Espelha `AdminDashboard.tsx`.
Widget buildAdminDashboard(String dashId) {
  return switch (dashId) {
    'financeiro' => const DashFinanceiro(),
    'pecuaria' => const DashPecuaria(),
    'confinamento' => const DashConfinamento(),
    'ativos' => const DashAtivos(),
    'suprimentos' => const DashSuprimentos(),
    'uso' => const DashUso(),
    'consultas' => const DashConsultas(),
    _ => const EmSection(title: 'Dashboard'),
  };
}
