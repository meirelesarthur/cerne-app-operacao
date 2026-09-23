import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../design/generated/app_layout.dart';
import '../../design/generated/app_radius.dart';
import '../../design/generated/app_spacing.dart';
import '../../design/theme/app_theme_extension.dart';
import '../../ui/ui.dart';
import '../docs/doc_page.dart';

/// Padrão "Coleções em cadastro" (Widgetbook → Padrões): como um cadastro
/// guarda N itens de um grupo (mão de obra, máquinas, insumos...) sem quebrar
/// o layout, de 1 a 10+ itens. Referência real: etapa de lançamentos do
/// apontamento agrícola.
WidgetbookComponent buildCollectionPatternWidgetbookComponent() {
  return WidgetbookComponent(
    name: 'Coleções em cadastro',
    useCases: [
      WidgetbookUseCase(
        name: 'Guia: qual componente usar',
        builder: (context) => const _CollectionGuidePage(),
      ),
      WidgetbookUseCase(
        name: 'Interativo: cards-gaveta e gerenciador',
        builder: (context) => const _CollectionPatternExample(),
      ),
    ],
  );
}

class _CollectionGuidePage extends StatelessWidget {
  const _CollectionGuidePage();

  @override
  Widget build(BuildContext context) {
    return const DocPage(
      eyebrow: 'Padrão',
      title: 'Coleções em cadastro',
      lead:
          'Quando um cadastro recebe vários itens de um mesmo grupo, a tela '
          'mostra o que existe e quanto — o detalhe de cada item fica a um '
          'toque, no gerenciador.',
      children: [
        DocSection(
          title: 'A ideia: o card é uma gaveta',
          children: [
            DocBullets([
              (
                'Fechada',
                'o card diz o que é (ícone + nome), quantos itens tem ("3 '
                    'itens incluídos") e um resumo agregado ("R\$ 480,00"). '
                    'Nunca o nome de um item: com 7 itens não há qual mostrar.',
              ),
              (
                'Aberta',
                'tocar no card com itens abre o gerenciador: lista, editar '
                    '(toque na linha), remover (lixeira + Desfazer) e '
                    'adicionar (rodapé fixo).',
              ),
              (
                'Vazia',
                'borda tracejada e "Nenhum item": tocar em qualquer lugar do '
                    'card já abre o formulário de adicionar.',
              ),
            ]),
            DocCallout(
              title: 'Um toque, uma regra',
              text:
                  'O card inteiro é o alvo. Vazio → adicionar; com itens → '
                  'abrir. O "+" do card com itens é só atalho de adição '
                  'rápida. Depois de salvar pelo gerenciador, a pessoa volta '
                  'para a lista, com o item novo/editado em destaque.',
              icon: AppIcons.layers,
            ),
          ],
        ),
        DocSection(
          title: 'Qual componente usar',
          children: [
            DocTable(
              header: ['Situação', 'Componente', 'Por quê'],
              rows: [
                [
                  '1 ou 2 grupos, poucos itens, tudo cabe na tela',
                  'CollectionList',
                  'Itens visíveis direto no formulário, sem toque extra.',
                ],
                [
                  '3+ grupos ou itens ilimitados por grupo',
                  'SquareGroupGrid + CollectionManager',
                  'A tela não cresce com os itens: 1 ou 10 itens, mesmo card.',
                ],
                [
                  'Só contar/adicionar, sem editar item a item',
                  'AddableGroupList',
                  'Faixa compacta "Adicionar" + contador.',
                ],
                [
                  'Revisão antes de salvar ou ficha já gravada',
                  'CollectionList sem onAdd/onEdit/onRemove',
                  'Mesma caixa por item, somente leitura.',
                ],
              ],
            ),
          ],
        ),
        DocSection(
          title: 'Resumo agregado: o que mostrar',
          children: [
            DocTable(
              header: ['Grupo', 'Resumo', 'Exemplo'],
              rows: [
                ['Recursos com custo', 'Custo total', r'R$ 480,00'],
                ['Produção', 'Quantidade por unidade', '120 kg · 30 sc'],
                ['Ocorrências', 'Maior prioridade', 'Prioridade alta'],
                ['Sem métrica útil', 'Omitir (só a contagem)', '—'],
              ],
            ),
          ],
        ),
        DocSection(
          title: 'Não faça',
          children: [
            DocBullets([
              ('', 'Mostrar o nome do primeiro item no card.'),
              ('', 'Um número solto no canto — é lido como notificação.'),
              (
                '',
                'Dois alvos para a mesma ação no mesmo card (ex.: card e '
                    'botão "Adicionar" separados).',
              ),
              ('', 'Excluir sem volta — sempre ofereça "Desfazer".'),
              (
                '',
                'Deixar o "Adicionar" no topo de uma lista que rola — fixe no '
                    'rodapé do sheet.',
              ),
            ]),
          ],
        ),
      ],
    );
  }
}

/// Exemplo vivo com a API pública: grade + gerenciador ligados como no
/// apontamento agrícola.
class _CollectionPatternExample extends StatefulWidget {
  const _CollectionPatternExample();

  @override
  State<_CollectionPatternExample> createState() =>
      _CollectionPatternExampleState();
}

class _CollectionPatternExampleState extends State<_CollectionPatternExample> {
  static const _maoDeObra = 'Mão de obra / Serviços';
  static const _maquinas = 'Máquinas / Implementos';
  static const _insumos = 'Insumos';
  static const _producao = 'Produção';
  static const _ocorrencias = 'Ocorrências';

  final _items = <String, List<(String, int)>>{
    _maoDeObra: [('José da Silva', 80)],
    _maquinas: [],
    _insumos: [('Ração Engorda 18%', 1245), ('Sal mineral', 320)],
    _producao: [],
    _ocorrencias: [],
  };

  String? _summary(String group) {
    final list = _items[group]!;
    if (list.isEmpty) return null;
    final total = list.fold<int>(0, (sum, item) => sum + item.$2);
    return switch (group) {
      _producao => '$total kg',
      _ocorrencias => 'Prioridade alta',
      _ => 'R\$ $total,00',
    };
  }

  Future<void> _add(String group) async {
    final list = _items[group]!;
    setState(() => list.add(('Item ${list.length + 1}', 100)));
  }

  void _open(BuildContext context, String group) {
    final list = _items[group]!;
    showAppCollectionManager(
      context,
      title: group,
      items: () => [
        for (final (name, value) in list)
          AppCollectionItemView(title: name, subtitle: 'R\$ $value,00'),
      ],
      summary: () => _summary(group),
      onAdd: () => _add(group),
      onEdit: (index) async =>
          setState(() => list[index] = (list[index].$1, list[index].$2 + 10)),
      onRemove: (index) {
        final removed = list.removeAt(index);
        setState(() {});
        return () => setState(() => list.insert(index, removed));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    AppSquareGroup group(String name, AppIconData icon, {bool wide = false}) =>
        AppSquareGroup(
          name: name,
          icon: icon,
          count: _items[name]!.length,
          summary: _summary(name),
          wide: wide,
        );

    return ColoredBox(
      color: semantic.bgCanvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: AppSize.phone),
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: semantic.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.surface),
            ),
            child: Builder(
              builder: (context) => AppSquareGroupGrid(
                groups: [
                  group(_maoDeObra, AppIcons.users),
                  group(_maquinas, AppIcons.tractor),
                  group(_insumos, AppIcons.package),
                  group(_producao, AppIcons.wheat),
                  group(_ocorrencias, AppIcons.triangleAlert, wide: true),
                ],
                onAdd: _add,
                onOpen: (name) => _open(context, name),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
