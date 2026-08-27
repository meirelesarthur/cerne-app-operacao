import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../design/generated/app_radius.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/components/sub_page_header.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../confinamento/models.dart';
import '../confinamento/state/confinamento_store.dart';

/// "Meus currais" (spec §4.6/§5) — o que o Operacional lança curral a curral:
/// alterar situação, pesagem, sanitário, óbito, e confirmar ordens que o ADM
/// já criou no web (transferência de lote, troca de dieta — decisão de
/// perfil: o Operacional nunca decide essas duas ações livremente).
///
/// Simplificação assumida no protótipo: não há hoje um vínculo real de
/// "setor do usuário logado" — a tela lista todos os currais. Quando o RBAC de
/// backend existir, o filtro por setor/responsável entra aqui sem mudar a UI.
class MeusCurraisScreen extends ConsumerWidget {
  const MeusCurraisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currais = ref.watch(
      confinamentoStoreProvider.select((s) => s.currais),
    );
    final ordens = ref.watch(
      confinamentoStoreProvider.select((s) => s.ordensPendentes),
    );

    return Column(
      children: [
        const SubPageHeader(title: 'Meus currais'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: currais.length,
            separatorBuilder: (context, _) =>
                const SizedBox(height: AppSpacing.space3),
            itemBuilder: (context, index) {
              final curral = currais[index];
              final ordemPendente = ordens
                  .where(
                    (o) =>
                        o.status == OrdemStatus.pendente &&
                        o.curralOrigemId == curral.id,
                  )
                  .toList();
              return _CurralCard(
                curral: curral,
                ordensPendentes: ordemPendente,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CurralCard extends ConsumerWidget {
  const _CurralCard({required this.curral, required this.ordensPendentes});

  final CurralInfo curral;
  final List<OrdemPendente> ordensPendentes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                curral.nome,
                style: TextStyle(
                  fontWeight: AppTypography.weightSemibold,
                  color: semantic.fgDefault,
                ),
              ),
              AppChip(
                tone: switch (curral.situacao) {
                  CurralSituacao.ocupado => AppChipTone.brand,
                  CurralSituacao.vazio => AppChipTone.neutral,
                  CurralSituacao.vazioSanitario ||
                  CurralSituacao.limpeza => AppChipTone.blue,
                  CurralSituacao.manutencao ||
                  CurralSituacao.enfermaria => AppChipTone.amber,
                  CurralSituacao.interditado => AppChipTone.red,
                },
                child: Text(curral.situacao.label),
              ),
            ],
          ),
          if (curral.ocupado && curral.indicadores != null) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(
              '${curral.indicadores!.totalAnimais}/${curral.capacidade} cabeças',
              style: TextStyle(
                fontSize: AppTypography.sm,
                color: semantic.fgMuted,
              ),
            ),
          ],
          if (ordensPendentes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space2),
              decoration: BoxDecoration(
                color: semantic.bgSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.bellRing, size: 14, color: semantic.fgMuted),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Text(
                      ordensPendentes.length == 1
                          ? '1 ordem pendente do ADM para este curral'
                          : '${ordensPendentes.length} ordens pendentes do ADM para este curral',
                      style: TextStyle(
                        fontSize: AppTypography.xs,
                        color: semantic.fgMuted,
                      ),
                    ),
                  ),
                  AppButton(
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        context.push('/fazendas/campo/ordens-pendentes'),
                    child: const Text('Ver'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space3),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              AppButton(
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                onPressed: () => _abrirAlterarSituacao(context, ref, curral),
                child: const Text('Alterar situação'),
              ),
              // Cada ação rápida reaproveita a rota que a própria funcionalidade
              // já declara no catálogo (Lei 2 — sem duplicar fluxo existente):
              // `pesagem` e `mortes` têm `existingRoute` em `campo/:flowId`
              // (mortes cai em `ciclo`, junto de nascimentos), enquanto
              // `sanitario` não tem rota dedicada e é resolvido pelo motor
              // genérico em `operacional/:featureId`. Apontar as três para
              // `campo/<id>` levava ao fallback vazio de `buildCampoFlow`.
              //
              // `push`, não `go`: essas rotas são irmãs de `campo/meus-currais`
              // (linhagem desta própria tela), não filhas dela — `go` troca a
              // página na pilha em vez de empilhar, então o voltar do sistema
              // pulava direto para `/fazendas` (redirecionado para a home do
              // perfil) em vez de retornar para Meus Currais, perdendo o
              // curral selecionado. `push` mantém esta tela na pilha; o botão
              // voltar (`SubPageHeader`/`maybePop`) já resolve o resto.
              AppButton(
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/fazendas/campo/pesagem'),
                child: const Text('Pesagem'),
              ),
              AppButton(
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                onPressed: () =>
                    context.push('/fazendas/operacional/sanitario'),
                child: const Text('Sanitário'),
              ),
              AppButton(
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/fazendas/campo/ciclo'),
                child: const Text('Óbito'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _abrirAlterarSituacao(
  BuildContext context,
  WidgetRef ref,
  CurralInfo curral,
) {
  var situacao = curral.situacao;

  showAppBottomSheet<void>(
    context,
    title: 'Alterar situação — ${curral.nome}',
    child: StatefulBuilder(
      builder: (context, setSheetState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Situação',
              required: true,
              child: AppFormSelect(
                options: [
                  for (final s in CurralSituacao.values)
                    AppFormSelectOption(value: s.name, label: s.label),
                ],
                value: situacao.name,
                onChanged: (v) => setSheetState(
                  () => situacao = CurralSituacao.values.firstWhere(
                    (s) => s.name == v,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            AppButton(
              fullWidth: true,
              onPressed: () {
                ref
                    .read(confinamentoStoreProvider.notifier)
                    .alterarSituacaoCurral(curral.id, situacao);
                Navigator.of(context).pop();
              },
              child: const Text('Salvar situação'),
            ),
          ],
        );
      },
    ),
  );
}
