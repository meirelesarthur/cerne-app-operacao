import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_spacing.dart';
import '../../design/generated/app_layout.dart';
import '../../design/generated/app_typography.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';

/// Padrão "Estados vazios" (Widgetbook → Padrões).
///
/// Uma referência por variação encontrada na varredura do app. Todas usam o
/// mesmo `AppEmptyState` — o que muda é o par ícone + selo, o tom e o texto.
/// A regra de escolha:
///
/// | Cenário              | Ícone / selo              | Tom      |
/// |----------------------|---------------------------|----------|
/// | Nada ainda           | objeto da tela            | brand    |
/// | Em dia / concluído   | objeto + check            | success  |
/// | Busca sem resultado  | lupa + x                  | info     |
/// | Filtro zerado        | objeto + funil            | brand    |
/// | Regra excluiu tudo   | objeto + x                | warning  |
/// | Sem conexão          | nuvem riscada             | warning  |
/// | Acesso restrito      | escudo + cadeado          | danger   |
/// | Histórico / sem dado | relógio / gráfico         | neutral  |
///
/// `compact` vale dentro de folhas, seletores, cards e abas de detalhe.
WidgetbookComponent buildEmptyStatePatternWidgetbookComponent() {
  WidgetbookUseCase caso(
    String name, {
    required String tela,
    required String origem,
    required AppEmptyState vazio,
  }) => WidgetbookUseCase(
    name: name,
    builder: (context) => _Referencia(tela: tela, origem: origem, child: vazio),
  );

  return WidgetbookComponent(
    name: 'Estados vazios',
    useCases: [
      caso(
        'Notificações — nenhuma ainda',
        tela: 'Notificações',
        origem: 'shell/pages/notificacoes_page.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.inbox,
          badgeIcon: AppIcons.check,
          tone: AppEmptyStateTone.brand,
          title: 'Nenhuma notificação ainda',
          description:
              'Suas notificações aparecem aqui assim que você recebê-las.',
        ),
      ),
      caso(
        'Notificações — em dia',
        tela: 'Notificações',
        origem: 'shell/pages/notificacoes_page.dart',
        vazio: AppEmptyState(
          icon: AppIcons.bell,
          badgeIcon: AppIcons.check,
          tone: AppEmptyStateTone.success,
          title: 'Você está em dia',
          description:
              'Nenhuma notificação nova. As próximas aparecem aqui assim que '
              'chegarem.',
          hint: 'Procurando uma notificação antiga?',
          hintActionLabel: 'Ver histórico de notificações',
          onHintAction: () {},
        ),
      ),
      caso(
        'Notificações — histórico vazio',
        tela: 'Notificações',
        origem: 'shell/pages/notificacoes_page.dart',
        vazio: AppEmptyState(
          icon: AppIcons.clock,
          title: 'Histórico vazio',
          description: 'As notificações que você abrir ficam guardadas aqui.',
          hint: 'Você tem 2 notificações novas.',
          hintActionLabel: 'Ver novidades',
          onHintAction: () {},
        ),
      ),
      caso(
        'Busca sem resultado',
        tela: 'Busca',
        origem:
            'screens/busca_global_screen.dart · components/farm_picker.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.search,
          badgeIcon: AppIcons.x,
          tone: AppEmptyStateTone.info,
          title: 'Nenhuma função encontrada',
          description: 'Tente outro termo — o nome do módulo também vale.',
        ),
      ),
      caso(
        'Seletor — nada encontrado',
        tela: 'Selecionar produto',
        origem: 'ui/search_select.dart',
        vazio: const AppEmptyState(
          size: AppEmptyStateSize.compact,
          icon: AppIcons.search,
          badgeIcon: AppIcons.x,
          tone: AppEmptyStateTone.info,
          title: 'Nada encontrado',
          description: 'Tente outro termo de busca.',
        ),
      ),
      caso(
        'Seletor — sem opções',
        tela: 'Selecionar item de estoque',
        origem: 'ui/search_select.dart',
        vazio: const AppEmptyState(
          size: AppEmptyStateSize.compact,
          icon: AppIcons.inbox,
          title: 'Nenhuma opção disponível',
          description: 'Não há itens cadastrados para esta escolha.',
        ),
      ),
      caso(
        'Filtro zerado',
        tela: 'Minhas OS',
        origem: 'operacional/minhas_os_screen.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.fileText,
          badgeIcon: AppIcons.filter,
          tone: AppEmptyStateTone.brand,
          title: 'Nenhuma OS neste filtro',
          description:
              'Ordens de serviço atribuídas ao funcionário e à fazenda ativa '
              'aparecem aqui.',
        ),
      ),
      caso(
        'Tudo concluído',
        tela: 'Ordens pendentes',
        origem: 'operacional/ordens_pendentes_screen.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.clipboardCheck,
          badgeIcon: AppIcons.check,
          tone: AppEmptyStateTone.success,
          title: 'Nenhuma ordem pendente',
          description:
              'Transferências de lote e trocas de dieta criadas pelo '
              'escritório aparecem aqui.',
        ),
      ),
      caso(
        'Primeiro uso — com ação',
        tela: 'Rotina de campo',
        origem: 'screens/mapped_feature_screen.dart',
        vazio: AppEmptyState(
          icon: AppIcons.clipboardList,
          badgeIcon: AppIcons.plus,
          tone: AppEmptyStateTone.brand,
          title: 'Nenhum abastecimento registrado.',
          description:
              'Use a ação abaixo para criar o primeiro registro desta rotina.',
          action: AppButton(
            onPressed: () {},
            leftIcon: const AppIcon(AppIcons.plus, size: AppSize.iconSmPlus),
            child: const Text('Novo registro'),
          ),
        ),
      ),
      caso(
        'Somente leitura — aguardando sincronização',
        tela: 'Consulta',
        origem: 'screens/mapped_feature_screen.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.clipboardList,
          badgeIcon: AppIcons.cloudSync,
          title: 'Nenhum registro encontrado',
          description:
              'O cadastro desta rotina é feito no sistema web. Assim que '
              'sincronizar, os registros aparecem aqui.',
        ),
      ),
      caso(
        'Regra excluiu tudo',
        tela: 'Trato diário',
        origem: 'operacional/trato_diario_flow.dart',
        vazio: const AppEmptyState(
          size: AppEmptyStateSize.compact,
          icon: AppIcons.barns,
          badgeIcon: AppIcons.x,
          tone: AppEmptyStateTone.warning,
          title: 'Nenhum curral elegível',
          description:
              'Nenhum curral ocupado está, hoje, na fase que corresponde a '
              'esta dieta.',
        ),
      ),
      caso(
        'Lista nunca preenchida',
        tela: 'Meus currais',
        origem: 'operacional/meus_currais_screen.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.barns,
          tone: AppEmptyStateTone.brand,
          title: 'Nenhum curral por aqui',
          description:
              'Os currais da fazenda ativa aparecem aqui assim que forem '
              'sincronizados com o escritório.',
        ),
      ),
      caso(
        'Coleção vazia',
        tela: 'Mão de obra',
        origem: 'ui/collection_manager_sheet.dart',
        vazio: const AppEmptyState(
          size: AppEmptyStateSize.compact,
          icon: AppIcons.layers,
          badgeIcon: AppIcons.plus,
          tone: AppEmptyStateTone.brand,
          title: 'Nenhum item incluído',
          description: 'Use "Adicionar" para incluir o primeiro.',
        ),
      ),
      caso(
        'Histórico da OS vazio',
        tela: 'Detalhe da OS',
        origem: 'ordem_servico/widgets.dart',
        vazio: const AppEmptyState(
          size: AppEmptyStateSize.compact,
          icon: AppIcons.clock,
          title: 'Sem histórico ainda',
          description:
              'Início, pausas, retomadas e a entrega da OS ficam registrados '
              'aqui.',
        ),
      ),
      caso(
        'Módulo sem funções',
        tela: 'Módulo',
        origem: 'screens/group_features_screen.dart',
        vazio: const AppEmptyState(
          icon: AppIcons.layoutGrid,
          title: 'Nada por aqui',
          description: 'Este módulo ainda não tem funções mapeadas.',
        ),
      ),
      caso(
        'Acesso restrito',
        tela: 'Funcionalidade',
        origem: 'screens/mapped_feature_screen.dart',
        vazio: AppEmptyState(
          icon: AppIcons.shield,
          badgeIcon: AppIcons.lock,
          tone: AppEmptyStateTone.danger,
          title: 'Funcionalidade fora deste perfil',
          description:
              'Volte ao ambiente correspondente para acessar esta '
              'responsabilidade.',
          action: AppButton(
            onPressed: () {},
            child: const Text('Voltar ao ambiente'),
          ),
        ),
      ),
      caso(
        'Sem conexão (proposta)',
        tela: 'Sincronização',
        origem: 'operacional/sincronizacao_flow.dart — ainda não aplicado',
        vazio: AppEmptyState(
          icon: AppIcons.cloudOff,
          tone: AppEmptyStateTone.warning,
          title: 'Sem conexão',
          description:
              'Os lançamentos ficam guardados no aparelho e sobem assim que a '
              'internet voltar.',
          action: AppButton(
            variant: AppButtonVariant.secondary,
            onPressed: () {},
            child: const Text('Tentar novamente'),
          ),
        ),
      ),
      caso(
        'Sem dados no período (proposta)',
        tela: 'Gráficos',
        origem: 'ui/bar_chart.dart · line_chart.dart — ainda não aplicado',
        vazio: const AppEmptyState(
          size: AppEmptyStateSize.compact,
          icon: AppIcons.barChart3,
          title: 'Sem dados no período',
          description: 'Escolha outro intervalo para ver o gráfico.',
        ),
      ),
    ],
  );
}

/// Moldura de tela para a referência: faixa cinza com o título da tela,
/// folha branca com o vazio centralizado e, no rodapé, o arquivo de origem.
class _Referencia extends StatelessWidget {
  const _Referencia({
    required this.tela,
    required this.origem,
    required this.child,
  });

  final String tela;
  final String origem;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ColoredBox(
      color: semantic.bgCanvas,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Center(
              child: AppHeading(level: AppHeadingLevel.h3, child: Text(tela)),
            ),
          ),
          Expanded(
            child: AppContentSheet(
              padded: false,
              child: Column(
                children: [
                  Expanded(
                    child: Center(child: SingleChildScrollView(child: child)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: Text(
                      'Origem: $origem',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.sm,
                        color: semantic.fgSubtle,
                      ),
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
