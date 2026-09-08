import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_layout.dart';
import '../../../design/generated/app_spacing.dart';
import '../../../design/theme/app_theme_extension.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import 'package:cerne_app/design/generated/app_typography.dart';
import '../functional_catalog.dart' show catalogoProdutos;
import '../state/fazendas_store.dart';
import '../types.dart';
import 'flow_shell.dart';
import 'success_screen.dart';

// banco-real: domínios reais do apontamento (`appropriations` + tabelas
// filhas `appropriation_employee/equipment/stock/occurrences` do dump
// gbcerne — ver docs/ajustes-banco-real/04-apontamento-appropriations.md).
// Operação/Atividade eram campo livre; agora espelham `operations`/
// `activities`, com uma curadoria representativa (10 e 18 itens reais de
// ~19 e ~148 no banco) — mesmo critério de curadoria das demais telas do
// catálogo, não a lista federal inteira.
const _operacoes = <AppFormSelectOption>[
  AppFormSelectOption(value: 'preparo-solo', label: 'Preparo do Solo'),
  AppFormSelectOption(value: 'plantio', label: 'Plantio'),
  AppFormSelectOption(value: 'tratos-culturais', label: 'Tratos Culturais'),
  AppFormSelectOption(
    value: 'tratos-fitossanitarios',
    label: 'Tratos Fitossanitários',
  ),
  AppFormSelectOption(value: 'colheita', label: 'Colheita'),
  AppFormSelectOption(value: 'pos-colheita', label: 'Pós Colheita'),
  AppFormSelectOption(value: 'armazenagem', label: 'Armazenagem'),
  AppFormSelectOption(
    value: 'conservacao-solo',
    label: 'Conservação do Solo',
  ),
  AppFormSelectOption(value: 'transporte', label: 'Transporte'),
  AppFormSelectOption(value: 'outros', label: 'Outros'),
];

const _atividades = <AppFormSelectOption>[
  AppFormSelectOption(value: 'aracao', label: 'Aração'),
  AppFormSelectOption(value: 'gradagem-aradora', label: 'Gradagem Aradora'),
  AppFormSelectOption(value: 'subsolagem', label: 'Subsolagem'),
  AppFormSelectOption(value: 'calagem', label: 'Calagem'),
  AppFormSelectOption(value: 'plantio-mecanizado', label: 'Plantio Mecanizado'),
  AppFormSelectOption(value: 'plantio-manual', label: 'Plantio Manual'),
  AppFormSelectOption(value: 'capina-mecanizada', label: 'Capina Mecanizada'),
  AppFormSelectOption(value: 'rocagem', label: 'Roçagem'),
  AppFormSelectOption(value: 'aplicacao-herbicida', label: 'Aplicação de Herbicida'),
  AppFormSelectOption(value: 'aplicacao-fungicida', label: 'Aplicação de Fungicida'),
  AppFormSelectOption(
    value: 'aplicacao-inseticida',
    label: 'Aplicação de Inseticida',
  ),
  AppFormSelectOption(
    value: 'pulverizacao-mecanizada',
    label: 'Pulverização Mecanizada',
  ),
  AppFormSelectOption(value: 'colheita-mecanizada', label: 'Colheita Mecanizada'),
  AppFormSelectOption(value: 'colheita-manual', label: 'Colheita Manual'),
  AppFormSelectOption(value: 'secagem', label: 'Secagem'),
  AppFormSelectOption(value: 'classificacao-produto', label: 'Classificação Produto'),
  AppFormSelectOption(value: 'beneficiamento', label: 'Beneficiamento'),
  AppFormSelectOption(value: 'transporte-interno', label: 'Transporte Interno'),
];

const _culturas = <AppFormSelectOption>[
  AppFormSelectOption(value: 'soja', label: 'Soja'),
  AppFormSelectOption(value: 'milho', label: 'Milho'),
  AppFormSelectOption(value: 'algodao', label: 'Algodão'),
  AppFormSelectOption(value: 'cana', label: 'Cana-de-açúcar'),
  AppFormSelectOption(value: 'cafe', label: 'Café'),
  AppFormSelectOption(value: 'arroz', label: 'Arroz'),
  AppFormSelectOption(value: 'feijao', label: 'Feijão'),
  AppFormSelectOption(value: 'sorgo', label: 'Sorgo'),
  AppFormSelectOption(value: 'braquiaria', label: 'Braquiária'),
  AppFormSelectOption(value: 'milheto', label: 'Milheto'),
];

const _safras = <AppFormSelectOption>[
  AppFormSelectOption(value: '23-24', label: '2023/2024'),
  AppFormSelectOption(value: '24-25', label: '2024/2025'),
  AppFormSelectOption(value: '25-26', label: '2025/2026'),
  AppFormSelectOption(value: '26-27', label: '2026/2027'),
];

const _armazens = <AppFormSelectOption>[
  AppFormSelectOption(value: 'armazem-a', label: 'Armazém A'),
  AppFormSelectOption(value: 'deposito-b', label: 'Depósito B'),
];

const _responsaveis = <AppFormSelectOption>[
  AppFormSelectOption(value: 'joao', label: 'João Oliveira'),
  AppFormSelectOption(value: 'maria', label: 'Maria Souza'),
  AppFormSelectOption(value: 'carlos', label: 'Carlos Dias'),
];

const _areas = <AppFormSelectOption>[
  AppFormSelectOption(value: 'talhao-01', label: 'Talhão 01'),
  AppFormSelectOption(value: 'talhao-02', label: 'Talhão 02'),
  AppFormSelectOption(value: 'pasto-norte', label: 'Pasto Norte'),
];

// Mão de obra / Serviços — `appropriation_employee` (função: `functions`,
// mão de obra própria; prestador: `providers`, terceirizada).
const _funcoes = <AppFormSelectOption>[
  AppFormSelectOption(value: 'trabalhador-rural', label: 'Trabalhador Rural'),
  AppFormSelectOption(value: 'tratorista', label: 'Tratorista Agrícola'),
  AppFormSelectOption(value: 'operador-maquinas', label: 'Operador de Máquinas'),
  AppFormSelectOption(value: 'encarregado-area', label: 'Encarregado de Área'),
  AppFormSelectOption(value: 'tecnico-agricola', label: 'Técnico Agrícola'),
  AppFormSelectOption(
    value: 'tecnico-agropecuario',
    label: 'Técnico Agropecuário',
  ),
  AppFormSelectOption(value: 'engenheiro-agronomo', label: 'Engenheiro Agrônomo'),
  AppFormSelectOption(value: 'auxiliar-producao', label: 'Auxiliar de Produção'),
];

const _unidadesMaoDeObra = <AppFormSelectOption>[
  AppFormSelectOption(value: 'dia', label: 'Dia'),
  AppFormSelectOption(value: 'hora', label: 'Hora'),
  AppFormSelectOption(value: 'dia-homem', label: 'Dia/homem'),
  AppFormSelectOption(value: 'hora-homem', label: 'Hora/homem'),
];

// Máquinas / Implementos — `appropriation_equipment` (`equipments`); mesmo
// vocabulário de frota já usado em Abastecimentos/Manutenção
// (`functional_catalog.dart`).
const _equipamentos = <AppFormSelectOption>[
  AppFormSelectOption(value: 'trator-6110', label: 'Trator John Deere 6110'),
  AppFormSelectOption(value: 'colheitadeira-cr7', label: 'Colheitadeira CR7'),
  AppFormSelectOption(value: 'pulverizador', label: 'Pulverizador'),
  AppFormSelectOption(value: 'grade-aradora', label: 'Grade Aradora'),
  AppFormSelectOption(value: 'retroescavadeira', label: 'Retroescavadeira'),
];

const _unidadesMaquina = <AppFormSelectOption>[
  AppFormSelectOption(value: 'hora', label: 'Hora'),
  AppFormSelectOption(value: 'dia', label: 'Dia'),
  AppFormSelectOption(value: 'km', label: 'km'),
];

// Insumos — `appropriation_stock`; produto vem do catálogo real de produtos
// (`catalogoProdutos`, fonte única — mesma busca de Formulações/Batida).
const _unidadesInsumo = <AppFormSelectOption>[
  AppFormSelectOption(value: 'kg', label: 'kg'),
  AppFormSelectOption(value: 'l', label: 'L'),
  AppFormSelectOption(value: 'ton', label: 't'),
  AppFormSelectOption(value: 'sc', label: 'Saco'),
  AppFormSelectOption(value: 'un', label: 'Unidade'),
];

// Produção — `appropriation_production`: o que a operação **gerou** (colheita,
// forragem, semente). Era a quinta coleção do contrato `/appropriations` e a
// única que o protótipo não tinha; sem ela um apontamento de colheita não
// registra colheita nenhuma.
const _unidadesProducao = <AppFormSelectOption>[
  AppFormSelectOption(value: 'kg', label: 'kg'),
  AppFormSelectOption(value: 'ton', label: 't'),
  AppFormSelectOption(value: 'sc', label: 'Saco'),
  AppFormSelectOption(value: 'arroba', label: 'Arroba'),
  AppFormSelectOption(value: 'un', label: 'Unidade'),
];

// Ocorrências — `appropriation_occurrences.priority` (char(1), sem tabela de
// domínio no dump — B/M/A inferido do próprio nome da coluna, mesmo padrão
// de enum local já usado em `leitura_cocho_flow.dart`).
enum _Prioridade { baixa, media, alta }

extension on _Prioridade {
  String get label => switch (this) {
    _Prioridade.baixa => 'Baixa',
    _Prioridade.media => 'Média',
    _Prioridade.alta => 'Alta',
  };

  AppChipTone get tone => switch (this) {
    _Prioridade.baixa => AppChipTone.neutral,
    _Prioridade.media => AppChipTone.amber,
    _Prioridade.alta => AppChipTone.red,
  };
}

T _byValue<T>(List<T> values, String value) =>
    values.firstWhere((v) => (v as dynamic).name == value);

/// Rótulo de uma `AppFormSelectOption` pelo `value` selecionado — `_byValue`
/// acima é para enums Dart (`.name`), não para as opções de dropdown dos
/// domínios reais (`.value`/`.label`).
String _optionLabel(List<AppFormSelectOption> options, String value) =>
    options.firstWhere((o) => o.value == value).label;

class _MaoDeObraItem {
  const _MaoDeObraItem({
    required this.funcao,
    required this.colaborador,
    required this.quantidade,
    required this.unidade,
    required this.valorUnitario,
  });

  final String funcao;
  final String colaborador;
  final num quantidade;
  final String unidade;
  final num valorUnitario;
}

class _MaquinaItem {
  const _MaquinaItem({
    required this.equipamento,
    required this.horimetroInicial,
    required this.horimetroFinal,
    required this.quantidade,
    required this.unidade,
  });

  final String equipamento;
  final num horimetroInicial;
  final num horimetroFinal;
  final num quantidade;
  final String unidade;
}

class _InsumoItem {
  const _InsumoItem({
    required this.produto,
    required this.quantidade,
    required this.unidade,
    this.armazem,
  });

  final String produto;
  final num quantidade;
  final String unidade;

  /// `appropriation_stock.warehouse_uuid` — no contrato o armazém é **do
  /// item**, não do cabeçalho. Fica opcional aqui: em branco, o item herda o
  /// "Armazém de insumo" do cabeçalho, que é o caso comum de um apontamento
  /// tirando tudo do mesmo depósito.
  final String? armazem;
}

class _ProducaoItem {
  const _ProducaoItem({
    required this.produto,
    required this.quantidade,
    required this.unidade,
    this.armazem,
  });

  final String produto;
  final num quantidade;
  final String unidade;

  /// Destino da produção; em branco herda o "Armazém de produção" do
  /// cabeçalho.
  final String? armazem;
}

class _OcorrenciaItem {
  const _OcorrenciaItem({
    required this.prioridade,
    required this.diagnostico,
    this.recomendacao,
    this.foto,
  });

  final _Prioridade prioridade;
  final String diagnostico;
  final String? recomendacao;
  final String? foto;
}

/// Apontamento agrícola (spec real: `appropriations` + tabelas filhas do
/// dump gbcerne — Onda 4 `banco-real`). Substitui o motor genérico
/// (`fields`/`sections` de `FeatureDefinition`): os cinco grupos de recurso
/// (Mão de obra, Máquinas, Insumos, Produção, Ocorrências) têm campo por item,
/// não um contador cego — cada "Adicionar" abre um formulário real e o item
/// entra na lista com os dados verdadeiros preenchidos.
class ApontamentoFlow extends ConsumerStatefulWidget {
  const ApontamentoFlow({super.key});

  @override
  ConsumerState<ApontamentoFlow> createState() => _ApontamentoFlowState();
}

class _ApontamentoFlowState extends ConsumerState<ApontamentoFlow> {
  String? _responsavel;
  String? _area;
  String? _operacao;
  String? _atividade;
  String _data = '';
  String _areaTotal = '';
  String _areaUtilizada = '';
  String? _cultura;
  String? _safra;
  String? _armazemInsumo;
  String? _armazemProducao;
  String _descricao = '';

  final _maoDeObra = <_MaoDeObraItem>[];
  final _maquinas = <_MaquinaItem>[];
  final _insumos = <_InsumoItem>[];
  final _producoes = <_ProducaoItem>[];
  final _ocorrencias = <_OcorrenciaItem>[];

  bool? _queued;
  bool _attempted = false;

  /// fidelidade-campos (onda 2): o apontamento tem 12 campos de cabeçalho e 5
  /// coleções — numa tela só, a pessoa rolava três telas de altura sem saber
  /// quanto faltava, e o CTA "Salvar" ficava a uma rolagem de distância do
  /// primeiro campo. Agora são três etapas com a régua do arquétipo `Cadastro
  /// steps`: identificação, dados da operação e lançamentos.
  int _step = 0;
  static const _totalSteps = 3;

  bool get _etapaIdentificacaoValida =>
      _responsavel != null &&
      _area != null &&
      _operacao != null &&
      _atividade != null &&
      _data.isNotEmpty;

  bool get _etapaOperacaoValida =>
      _areaTotal.isNotEmpty &&
      _areaUtilizada.isNotEmpty &&
      _armazemProducao != null;

  /// O contrato `/appropriations` exige ao menos um lançamento: um apontamento
  /// sem recurso, produção nem ocorrência não registra nada.
  bool get _etapaLancamentosValida =>
      _maoDeObra.isNotEmpty ||
      _maquinas.isNotEmpty ||
      _insumos.isNotEmpty ||
      _producoes.isNotEmpty ||
      _ocorrencias.isNotEmpty;

  bool get _etapaAtualValida => switch (_step) {
    0 => _etapaIdentificacaoValida,
    1 => _etapaOperacaoValida,
    _ => _etapaLancamentosValida,
  };

  void _avancar() {
    if (!_etapaAtualValida) {
      setState(() => _attempted = true);
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() {
        _step += 1;
        _attempted = false;
      });
      return;
    }
    _confirmar();
  }

  void _voltar() => setState(() {
    _step -= 1;
    _attempted = false;
  });

  void _confirmar() {
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    if (queued) {
      final atividade = _optionLabel(_atividades, _atividade!);
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'apt-${DateTime.now().microsecondsSinceEpoch}',
              label: 'Apontamento — $atividade',
              detail: [
                if (_descricao.isNotEmpty) _descricao,
                if (_maoDeObra.isNotEmpty) '${_maoDeObra.length} mão de obra',
                if (_maquinas.isNotEmpty) '${_maquinas.length} máquina(s)',
                if (_insumos.isNotEmpty) '${_insumos.length} insumo(s)',
                if (_producoes.isNotEmpty)
                  '${_producoes.length} produção(ões)',
                if (_ocorrencias.isNotEmpty)
                  '${_ocorrencias.length} ocorrência(s)',
              ].join(' · '),
              kind: ActivityKind.evento,
            ),
          );
    }
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Apontamento registrado',
        queued: _queued!,
        effects:
            'Mão de obra, máquinas e insumos baixam do centro de custo da '
            'área; a produção lançada entra no armazém de destino.',
      );
    }

    final lancamentoPendente =
        _step == _totalSteps - 1 && _attempted && !_etapaLancamentosValida;

    return FlowShell(
      title: 'Apontamento agrícola',
      totalSteps: _totalSteps,
      currentStep: _step + 1,
      onBack: _step == 0 ? null : _voltar,
      primaryLabel: _step < _totalSteps - 1
          ? 'Continuar'
          : 'Salvar apontamento',
      onPrimary: _avancar,
      summary: lancamentoPendente
          ? const Align(
              alignment: Alignment.centerLeft,
              child: AppChip(
                tone: AppChipTone.red,
                child: Text('Adicione ao menos um lançamento para salvar'),
              ),
            )
          : null,
      child: switch (_step) {
        0 => _etapaIdentificacao(),
        1 => _etapaOperacao(),
        _ => _etapaLancamentos(context),
      },
    );
  }

  /// Etapa 1 — quem, onde, o quê e quando: os cinco vínculos que identificam o
  /// apontamento e sem os quais nenhum lançamento tem endereço.
  Widget _etapaIdentificacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFormField(
          label: 'Responsável',
          required: true,
          error: _attempted && _responsavel == null
              ? 'Selecione o responsável.'
              : null,
          child: AppFormSelect(
            options: _responsaveis,
            value: _responsavel,
            placeholder: 'Selecione',
            onChanged: (v) => setState(() => _responsavel = v),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Área',
          required: true,
          error: _attempted && _area == null ? 'Selecione a área.' : null,
          child: AppFormSelect(
            options: _areas,
            value: _area,
            placeholder: 'Selecione a área',
            onChanged: (v) => setState(() => _area = v),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          children: [
            Expanded(
              child: AppFormField(
                label: 'Operação',
                required: true,
                error: _attempted && _operacao == null
                    ? 'Selecione a operação.'
                    : null,
                child: AppFormSelect(
                  options: _operacoes,
                  value: _operacao,
                  placeholder: 'Selecione',
                  onChanged: (v) => setState(() => _operacao = v),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: AppFormField(
                label: 'Atividade',
                required: true,
                error: _attempted && _atividade == null
                    ? 'Selecione a atividade.'
                    : null,
                child: AppFormSelect(
                  options: _atividades,
                  value: _atividade,
                  placeholder: 'Selecione',
                  onChanged: (v) => setState(() => _atividade = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Data do apontamento',
          required: true,
          error: _attempted && _data.isEmpty ? 'Informe a data.' : null,
          child: AppTextInput(
            // Etapas recriam o campo a cada troca: sem `initialValue` o texto
            // já digitado sumiria da tela ao voltar uma etapa.
            initialValue: _data,
            onChanged: (v) => setState(() => _data = v),
            placeholder: 'dd/mm/aaaa',
            invalid: _attempted && _data.isEmpty,
          ),
        ),
      ],
    );
  }

  /// Etapa 2 — a dimensão da operação (área trabalhada, cultura, safra) e os
  /// armazéns padrão dos lançamentos da etapa seguinte.
  Widget _etapaOperacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: AppFormField(
                label: 'Área total',
                required: true,
                error: _attempted && _areaTotal.isEmpty
                    ? 'Informe a área total.'
                    : null,
                child: AppTextInput(
                  initialValue: _areaTotal,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => setState(() => _areaTotal = v),
                  placeholder: 'ha',
                  invalid: _attempted && _areaTotal.isEmpty,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: AppFormField(
                label: 'Área utilizada',
                required: true,
                error: _attempted && _areaUtilizada.isEmpty
                    ? 'Informe a área utilizada.'
                    : null,
                child: AppTextInput(
                  initialValue: _areaUtilizada,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => setState(() => _areaUtilizada = v),
                  placeholder: 'ha',
                  invalid: _attempted && _areaUtilizada.isEmpty,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          children: [
            Expanded(
              child: AppFormField(
                label: 'Cultura / variedade',
                child: AppFormSelect(
                  options: _culturas,
                  value: _cultura,
                  placeholder: 'Selecione',
                  onChanged: (v) => setState(() => _cultura = v),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: AppFormField(
                label: 'Safra',
                child: AppFormSelect(
                  options: _safras,
                  value: _safra,
                  placeholder: 'Selecione',
                  onChanged: (v) => setState(() => _safra = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Armazém de insumo',
          child: AppFormSelect(
            options: _armazens,
            value: _armazemInsumo,
            placeholder: 'Selecione',
            onChanged: (v) => setState(() => _armazemInsumo = v),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Armazém de produção',
          required: true,
          error: _attempted && _armazemProducao == null
              ? 'Selecione o armazém de produção.'
              : null,
          child: AppFormSelect(
            options: _armazens,
            value: _armazemProducao,
            placeholder: 'Selecione',
            onChanged: (v) => setState(() => _armazemProducao = v),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Descrição / Histórico',
          child: AppTextarea(
            initialValue: _descricao,
            onChanged: (v) => _descricao = v,
            minLines: 2,
            maxLines: 4,
          ),
        ),
      ],
    );
  }

  /// Etapa 3 — as cinco coleções do contrato. Cada "Adicionar" abre um
  /// formulário real e o item entra na lista com os dados verdadeiros.
  Widget _etapaLancamentos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAddableGroupList(
          groups: const ['Mão de obra / Serviços'],
          counts: {'Mão de obra / Serviços': _maoDeObra.length},
          onAdd: (_) => _adicionarMaoDeObra(context),
        ),
        for (final item in _maoDeObra)
          _ItemRow(
            title: _optionLabel(_funcoes, item.funcao),
            subtitle:
                '${item.colaborador} · ${item.quantidade} ${_optionLabel(_unidadesMaoDeObra, item.unidade)} · R\$ ${item.valorUnitario}',
            onRemove: () => setState(() => _maoDeObra.remove(item)),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppAddableGroupList(
          groups: const ['Máquinas / Implementos'],
          counts: {'Máquinas / Implementos': _maquinas.length},
          onAdd: (_) => _adicionarMaquina(context),
        ),
        for (final item in _maquinas)
          _ItemRow(
            title: _optionLabel(_equipamentos, item.equipamento),
            subtitle:
                '${item.quantidade} ${_optionLabel(_unidadesMaquina, item.unidade)} · horímetro ${item.horimetroInicial}→${item.horimetroFinal}',
            onRemove: () => setState(() => _maquinas.remove(item)),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppAddableGroupList(
          groups: const ['Insumos'],
          counts: {'Insumos': _insumos.length},
          onAdd: (_) => _adicionarInsumo(context),
        ),
        for (final item in _insumos)
          _ItemRow(
            title: item.produto,
            subtitle: [
              '${item.quantidade} '
                  '${_optionLabel(_unidadesInsumo, item.unidade)}',
              if (item.armazem case final armazem?)
                _optionLabel(_armazens, armazem),
            ].join(' · '),
            onRemove: () => setState(() => _insumos.remove(item)),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppAddableGroupList(
          groups: const ['Produção'],
          counts: {'Produção': _producoes.length},
          onAdd: (_) => _adicionarProducao(context),
        ),
        for (final item in _producoes)
          _ItemRow(
            title: item.produto,
            subtitle: [
              '${item.quantidade} '
                  '${_optionLabel(_unidadesProducao, item.unidade)}',
              if (item.armazem case final armazem?)
                _optionLabel(_armazens, armazem),
            ].join(' · '),
            onRemove: () => setState(() => _producoes.remove(item)),
          ),
        const SizedBox(height: AppSpacing.space5),
        AppAddableGroupList(
          groups: const ['Ocorrências'],
          counts: {'Ocorrências': _ocorrencias.length},
          onAdd: (_) => _adicionarOcorrencia(context),
        ),
        for (final item in _ocorrencias)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppChip(
                  tone: item.prioridade.tone,
                  child: Text(item.prioridade.label),
                ),
                const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: Text(
                    item.diagnostico,
                    style: const TextStyle(fontSize: AppTypography.sm),
                  ),
                ),
                AppIconButton(
                  icon: const AppIcon(AppIcons.x, size: AppSize.iconXs),
                  label: 'Remover ocorrência',
                  onPressed: () => setState(() => _ocorrencias.remove(item)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _adicionarMaoDeObra(BuildContext context) {
    String? funcao;
    var colaborador = '';
    num quantidade = 1;
    String? unidade;
    var valor = '';

    showAppBottomSheet<void>(
      context,
      title: 'Mão de obra / Serviço',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Função',
              required: true,
              child: AppFormSelect(
                options: _funcoes,
                value: funcao,
                placeholder: 'Selecione a função',
                onChanged: (v) => setSheetState(() => funcao = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Colaborador / prestador',
              required: true,
              child: AppTextInput(
                onChanged: (v) => colaborador = v,
                placeholder: 'Nome do colaborador ou prestador',
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Quantidade',
              required: true,
              child: AppStepper(
                value: quantidade,
                onChanged: (v) => setSheetState(() => quantidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Unidade',
              required: true,
              child: AppFormSelect(
                options: _unidadesMaoDeObra,
                value: unidade,
                placeholder: 'Selecione',
                onChanged: (v) => setSheetState(() => unidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Valor unitário (R\$)',
              required: true,
              child: AppTextInput(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => valor = v,
                placeholder: '0,00',
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              fullWidth: true,
              onPressed: funcao == null || colaborador.isEmpty || unidade == null
                  ? null
                  : () {
                      setState(
                        () => _maoDeObra.add(
                          _MaoDeObraItem(
                            funcao: funcao!,
                            colaborador: colaborador,
                            quantidade: quantidade,
                            unidade: unidade!,
                            valorUnitario: num.tryParse(
                                  valor.replaceAll(',', '.'),
                                ) ??
                                0,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarMaquina(BuildContext context) {
    String? equipamento;
    num horimetroInicial = 0;
    num horimetroFinal = 0;
    num quantidade = 1;
    String? unidade;

    showAppBottomSheet<void>(
      context,
      title: 'Máquina / Implemento',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Equipamento',
              required: true,
              child: AppFormSelect(
                options: _equipamentos,
                value: equipamento,
                placeholder: 'Selecione o equipamento',
                onChanged: (v) => setSheetState(() => equipamento = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: 'Horímetro inicial',
                    child: AppStepper(
                      value: horimetroInicial,
                      onChanged: (v) =>
                          setSheetState(() => horimetroInicial = v),
                      step: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: AppFormField(
                    label: 'Horímetro final',
                    child: AppStepper(
                      value: horimetroFinal,
                      onChanged: (v) => setSheetState(() => horimetroFinal = v),
                      step: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Quantidade',
              required: true,
              child: AppStepper(
                value: quantidade,
                onChanged: (v) => setSheetState(() => quantidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Unidade',
              required: true,
              child: AppFormSelect(
                options: _unidadesMaquina,
                value: unidade,
                placeholder: 'Selecione',
                onChanged: (v) => setSheetState(() => unidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              fullWidth: true,
              onPressed: equipamento == null || unidade == null
                  ? null
                  : () {
                      setState(
                        () => _maquinas.add(
                          _MaquinaItem(
                            equipamento: equipamento!,
                            horimetroInicial: horimetroInicial,
                            horimetroFinal: horimetroFinal,
                            quantidade: quantidade,
                            unidade: unidade!,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarInsumo(BuildContext context) {
    String? produto;
    num quantidade = 1;
    String? unidade;
    String? armazem;

    showAppBottomSheet<void>(
      context,
      title: 'Insumo',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Produto',
              required: true,
              child: AppFormSelect(
                options: [
                  for (final p in catalogoProdutos)
                    AppFormSelectOption(value: p, label: p),
                ],
                value: produto,
                placeholder: 'Selecione o produto',
                onChanged: (v) => setSheetState(() => produto = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Quantidade',
              required: true,
              child: AppStepper(
                value: quantidade,
                onChanged: (v) => setSheetState(() => quantidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Unidade',
              required: true,
              child: AppFormSelect(
                options: _unidadesInsumo,
                value: unidade,
                placeholder: 'Selecione',
                onChanged: (v) => setSheetState(() => unidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            // `appropriation_stock.warehouse_uuid` é do item. Opcional: em
            // branco o item sai do armazém de insumo do cabeçalho.
            AppFormField(
              label: 'Armazém de origem',
              hint: 'Em branco, usa o armazém de insumo do cabeçalho.',
              child: AppFormSelect(
                options: _armazens,
                value: armazem,
                placeholder: 'Selecione',
                onChanged: (v) => setSheetState(() => armazem = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              fullWidth: true,
              onPressed: produto == null || unidade == null
                  ? null
                  : () {
                      setState(
                        () => _insumos.add(
                          _InsumoItem(
                            produto: produto!,
                            quantidade: quantidade,
                            unidade: unidade!,
                            armazem: armazem,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  /// `appropriation_production` — o que a operação gerou. Mesma anatomia do
  /// formulário de insumo (produto do catálogo real, quantidade no stepper,
  /// unidade e armazém), porque para quem preenche é a mesma pergunta com o
  /// sinal invertido: ali o que saiu, aqui o que entrou.
  void _adicionarProducao(BuildContext context) {
    String? produto;
    num quantidade = 1;
    String? unidade;
    String? armazem;

    showAppBottomSheet<void>(
      context,
      title: 'Produção',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Produto colhido',
              required: true,
              child: AppFormSelect(
                options: [
                  for (final p in catalogoProdutos)
                    AppFormSelectOption(value: p, label: p),
                ],
                value: produto,
                placeholder: 'Selecione o produto',
                onChanged: (v) => setSheetState(() => produto = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Quantidade',
              required: true,
              child: AppStepper(
                value: quantidade,
                onChanged: (v) => setSheetState(() => quantidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Unidade',
              required: true,
              child: AppFormSelect(
                options: _unidadesProducao,
                value: unidade,
                placeholder: 'Selecione',
                onChanged: (v) => setSheetState(() => unidade = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Armazém de destino',
              hint: 'Em branco, usa o armazém de produção do cabeçalho.',
              child: AppFormSelect(
                options: _armazens,
                value: armazem,
                placeholder: 'Selecione',
                onChanged: (v) => setSheetState(() => armazem = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              fullWidth: true,
              onPressed: produto == null || unidade == null
                  ? null
                  : () {
                      setState(
                        () => _producoes.add(
                          _ProducaoItem(
                            produto: produto!,
                            quantidade: quantidade,
                            unidade: unidade!,
                            armazem: armazem,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarOcorrencia(BuildContext context) {
    var prioridade = _Prioridade.media;
    var diagnostico = '';
    var recomendacao = '';
    String? foto;

    showAppBottomSheet<void>(
      context,
      title: 'Ocorrência',
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              label: 'Prioridade',
              required: true,
              child: AppFormSelect(
                options: [
                  for (final p in _Prioridade.values)
                    AppFormSelectOption(value: p.name, label: p.label),
                ],
                value: prioridade.name,
                onChanged: (v) => setSheetState(
                  () => prioridade = _byValue(_Prioridade.values, v!),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Diagnóstico',
              required: true,
              child: AppTextarea(
                onChanged: (v) => diagnostico = v,
                minLines: 2,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Recomendação',
              child: AppTextarea(
                onChanged: (v) => recomendacao = v,
                minLines: 2,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Foto',
              child: AppFileUpload(
                value: foto,
                accept: '.jpg,.png',
                hint: 'Toque para anexar foto da ocorrência',
                onChanged: (v) => setSheetState(() => foto = v),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            AppButton(
              fullWidth: true,
              onPressed: diagnostico.isEmpty
                  ? null
                  : () {
                      setState(
                        () => _ocorrencias.add(
                          _OcorrenciaItem(
                            prioridade: prioridade,
                            diagnostico: diagnostico,
                            recomendacao: recomendacao.isEmpty
                                ? null
                                : recomendacao,
                            foto: foto,
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
              child: const Text('Adicionar ocorrência'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha compacta de um item já adicionado — resumo + remover. Mesmo papel
/// visual do cabeçalho de `_AvaliacaoCard` em `leitura_cocho_flow.dart`, sem
/// o card inteiro em volta (aqui o item é uma linha de uma lista simples,
/// não um formulário aninhado).
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: AppTypography.weightSemibold,
                    color: semantic.fgDefault,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppTypography.sm,
                    color: semantic.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: const AppIcon(AppIcons.x, size: AppSize.iconXs),
            label: 'Remover $title',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
