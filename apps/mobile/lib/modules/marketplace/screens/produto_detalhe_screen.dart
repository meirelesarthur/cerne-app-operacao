import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import '../mocks/produtos.dart';
import 'package:cerne_app/design/generated/app_typography.dart';

/// Página do Produto (PDP) do Marketplace — acessada a partir do card na Home.
/// Espelha `ProdutoDetalhe.tsx`.
class ProdutoDetalheScreen extends StatefulWidget {
  const ProdutoDetalheScreen({super.key, required this.produtoId});

  final String produtoId;

  @override
  State<ProdutoDetalheScreen> createState() => _ProdutoDetalheScreenState();
}

class _ProdutoDetalheScreenState extends State<ProdutoDetalheScreen> {
  bool _adicionado = false;

  Produto? get _produto {
    for (final p in produtos) {
      if (p.id == widget.produtoId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final produto = _produto;

    if (produto == null) {
      return const Column(
        children: [
          SubPageHeader(title: 'Produto'),
          Expanded(
            child: AppEmptyState(
              icon: LucideIcons.packageSearch,
              title: 'Produto não encontrado',
              description:
                  'Este produto pode ter sido removido do catálogo. Volte e tente outro item.',
            ),
          ),
        ],
      );
    }

    Categoria? categoria;
    for (final c in categorias) {
      if (c.id == produto.categoriaId) {
        categoria = c;
        break;
      }
    }

    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Column(
      children: [
        SubPageHeader(title: produto.nome),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            children: [
              Container(
                height: 160,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: semantic.accentSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: categoria != null
                    ? Icon(
                        categoria.icon,
                        size: 48,
                        color: semantic.accentDefault,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.space5),

              if (categoria != null) AppTag(child: Text(categoria.label)),
              const SizedBox(height: AppSpacing.space1),
              AppHeading(child: Text(produto.nome)),
              const SizedBox(height: AppSpacing.space1),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: AppTypography.display,
                    fontWeight: AppTypography.weightBold,
                    color: semantic.fgDefault,
                  ),
                  children: [
                    TextSpan(text: produto.preco),
                    TextSpan(
                      text: ' /${produto.unidade}',
                      style: TextStyle(
                        fontSize: AppTypography.md,
                        fontWeight: AppTypography.weightNormal,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (produto.freteGratis || produto.desconto != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.space1),
                  child: Wrap(
                    spacing: AppSpacing.space1,
                    runSpacing: AppSpacing.space1,
                    children: [
                      if (produto.freteGratis)
                        const AppTag(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.truck, size: 11),
                              SizedBox(width: AppSpacing.space1),
                              Text('Frete grátis'),
                            ],
                          ),
                        ),
                      if (produto.desconto != null)
                        AppChip(
                          tone: AppChipTone.brand,
                          child: Text(produto.desconto!),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.space5),

              Container(
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: semantic.bgSurface,
                  border: Border.all(color: semantic.borderDefault),
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: Row(
                  children: [
                    AppAvatar(name: produto.vendedor),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            produto.vendedor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: AppTypography.weightSemibold,
                              color: semantic.fgDefault,
                            ),
                          ),
                          const AppChip(child: Text('Vendedor do catálogo')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space5),

              const AppSectionTitle(child: Text('Descrição')),
              const SizedBox(height: AppSpacing.space2),
              Text(
                produto.descricao,
                style: TextStyle(
                  fontSize: AppTypography.md,
                  color: semantic.fgMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.space5),

              Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: semantic.bgSubtle,
                  border: Border.all(color: semantic.borderDefault),
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSectionTitle(child: Text('Especificações')),
                    const SizedBox(height: AppSpacing.space3),
                    for (final spec in produto.especificacoes)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spec.label,
                              style: TextStyle(
                                fontSize: AppTypography.md,
                                color: semantic.fgMuted,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Flexible(
                              child: Text(
                                spec.valor,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppTypography.md,
                                  fontWeight: AppTypography.weightSemibold,
                                  color: semantic.fgDefault,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space5),

              if (_adicionado) ...[
                const AppBanner(
                  tone: AppBannerTone.success,
                  icon: Icon(LucideIcons.check, size: 14),
                  child: Text('Produto adicionado ao pedido (protótipo).'),
                ),
                const SizedBox(height: AppSpacing.space5),
              ],

              AppButton(
                fullWidth: true,
                size: AppButtonSize.lg,
                onPressed: _adicionado
                    ? null
                    : () => setState(() => _adicionado = true),
                leftIcon: Icon(
                  _adicionado ? LucideIcons.check : LucideIcons.shoppingCart,
                  size: 18,
                ),
                child: Text(
                  _adicionado ? 'Adicionado ao pedido' : 'Adicionar ao pedido',
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                'Finalização de compra integrada em uma próxima fase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTypography.sm,
                  color: semantic.fgSubtle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
