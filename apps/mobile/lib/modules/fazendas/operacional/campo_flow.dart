import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import 'arracoamento_flow.dart';
import 'ciclo_rebanho_flow.dart';
import 'insumos_flow.dart';
import 'pesagem_flow.dart';
import 'recebimento_xml_flow.dart';
import 'venda_flow.dart';

/// Resolve o fluxo operacional de campo pelo `flowId` (spec §5) — espelha
/// `CampoFlow.tsx` (lá resolvido via rota `/fazendas/campo/:flowId`).
Widget buildCampoFlow(String flowId) {
  return switch (flowId) {
    'pesagem' => const PesagemFlow(),
    'ciclo' => const CicloRebanhoFlow(),
    'arracoamento' => const ArracoamentoFlow(),
    'venda' => const VendaFlow(),
    'recebimento' => const RecebimentoXmlFlow(),
    'insumos' => const InsumosFlow(),
    _ => const Scaffold(body: Center(child: AppEmptyState(title: 'Lançamento'))),
  };
}
