import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../mocks/bank_mocks.dart';
import '../../../shared/rise_in.dart';
import '../../../shared/simulated_load.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../components/bank_card_visual.dart';
import 'package:cerne_app/design/generated/app_colors.dart';

/// Home do módulo GB Bank (New-UI): saldo, ações rápidas, cartão corporativo,
/// deep-link para Crédito e últimas movimentações — experiência completa do
/// Banking (a versão condensada vive na Carteira do hub Início). Espelha
/// `BankHome.tsx`.
class BankHomeScreen extends ConsumerWidget {
  const BankHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shell = ref.watch(shellStoreProvider);
    final balanceHidden = shell.balanceHidden;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      children: [
        RiseIn(
          child: SimulatedLoad(
            duration: const Duration(milliseconds: 700),
            builder: (context, loading) => AppBalanceCard(
              value: Saldo.valor,
              accountLabel: Saldo.conta,
              hidden: balanceHidden,
              onToggleHidden: () =>
                  ref.read(shellStoreProvider.notifier).toggleBalanceHidden(),
              loading: loading,
              footer: Row(
                children: [
                  Expanded(
                    child: AppBalanceSummaryItem(
                      icon: const AppIcon(AppIcons.arrowDownLeft, size: 14),
                      label: 'Entradas no mês',
                      value: ResumoMes.entradas,
                      hidden: balanceHidden,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppBalanceSummaryItem(
                      icon: const AppIcon(AppIcons.arrowUpRight, size: 14),
                      label: 'Saídas no mês',
                      value: ResumoMes.saidas,
                      hidden: balanceHidden,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Ações rápidas.
        RiseIn(
          index: 1,
          child: Row(
            children: [
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.zap,
                  label: 'Pix',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.scanLine,
                  label: 'Pagar',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.arrowLeftRight,
                  label: 'Transferir',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
              Expanded(
                child: AppQuickAction(
                  icon: AppIcons.handCoins,
                  label: 'Cobrar',
                  onPressed: () => context.go('/bank/pagamentos'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Cartão corporativo.
        RiseIn(
          index: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Meu cartão')),
              const SizedBox(height: AppSpacing.space2),
              AppCard(
                padded: false,
                interactive: true,
                onTap: () => context.go('/bank/cartoes'),
                child: Column(
                  children: [
                    const BankCardVisual(),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Limite disponível'),
                              Text(
                                '${balanceHidden ? '••••' : Cartao.limiteDisponivel} / ${balanceHidden ? '••••' : Cartao.limiteTotal}',
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          AppProgressBar(
                            value: Cartao.usoPct.toDouble(),
                            colorByOccupancy: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Deep-link para o módulo Crédito.
        RiseIn(
          index: 3,
          child: AppCard(
            interactive: true,
            onTap: () => context.go('/credito'),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: semantic.accentDefault,
                  ),
                  child: const AppIcon(
                    AppIcons.trendingUp,
                    size: 22,
                    color: AppColors.neutral0,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Antecipe recebíveis da safra',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Simule no módulo Crédito',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  AppIcons.arrowRight,
                  size: 18,
                  color: semantic.accentDefault,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space6),

        // Últimas movimentações.
        RiseIn(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(child: Text('Últimas movimentações')),
              const SizedBox(height: AppSpacing.space2),
              AppCard(
                padded: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  child: Column(
                    children: [
                      for (final tx in transacoes.take(3))
                        AppTransactionListItem(
                          transaction: tx,
                          onTap: () => showAppTransactionDetailSheet(
                            context,
                            transaction: tx,
                            hidden: balanceHidden,
                          ),
                          showDivider: tx != transacoes.take(3).last,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              AppButton(
                variant: AppButtonVariant.ghost,
                fullWidth: true,
                onPressed: () => context.go('/bank/extrato'),
                child: const Text('Ver extrato'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
