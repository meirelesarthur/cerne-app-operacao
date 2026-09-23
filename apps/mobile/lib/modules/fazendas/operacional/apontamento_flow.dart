import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/generated/app_spacing.dart';
import '../../../shell/state/shell_store.dart';
import '../../../ui/ui.dart';
import '../cadastros_vinculados.dart';
import '../functional_catalog.dart' show catalogoArmazens, catalogoResponsaveis;
import '../state/fazendas_store.dart';
import '../types.dart';
import 'apontamento_registro.dart';
import 'flow_shell.dart';
import 'success_screen.dart';

// banco-real: domínios reais do apontamento (`appropriations` + tabelas
// filhas `appropriation_employee/equipment/stock/production/occurrences` do
// dump gbcerne — ver docs/ajustes-banco-real/04-apontamento-appropriations.md
// e 05-cadastros-vinculados.md).
//
// Onda 5 (cadastros vinculados): o apontamento deixa de perguntar o que os
// cadastros já respondem.
// - O **lote** (`production_cycles`) traz cultura/variedade, safra, centro de
//   custo e os talhões; o **talhão** (`areas`) traz área total e sugere a
//   área utilizada (área produtiva).
// - A **operação** restringe as atividades (`operation_activities`).
// - O **item de estoque** traz armazém, saldo e custo médio; o **produto**
//   traz a unidade. A quantidade do insumo é dose por hectare — o total é
//   dose × área utilizada (`appropriation_stock.total_quantity`).
// - O **equipamento** traz medidor, leitura atual, unidade e custo-hora; a
//   quantidade é a diferença do medidor (`appropriation_equipment`).
// - O **executor** (funcionário/função/prestador) traz a função e sugere o
//   valor pelo custo-hora do cadastro.
const _operacoes = <String>[
  'Preparo do Solo',
  'Plantio',
  'Tratos Culturais',
  'Tratos Fitossanitários',
  'Colheita',
  'Pós Colheita',
  'Armazenagem',
  'Conservação do Solo',
  'Transporte',
  'Outros',
];

List<AppFormSelectOption> _opcoes(Iterable<String> labels) => [
  for (final label in labels) AppFormSelectOption(value: label, label: label),
];

/// Mão de obra / Serviços — `appropriation_employee`. Unidade de medida da
/// quantidade (`measurements`); `fatorHora` converte o custo-hora do cadastro
/// na sugestão de valor unitário da unidade escolhida.
const _unidadesMaoDeObra = <({String value, String label, num fatorHora})>[
  (value: 'hora', label: 'Hora', fatorHora: 1),
  (value: 'dia', label: 'Dia', fatorHora: 8),
  (value: 'hora-homem', label: 'Hora/homem', fatorHora: 1),
  (value: 'dia-homem', label: 'Dia/homem', fatorHora: 8),
];

String _unidadeMaoDeObraLabel(String value) =>
    _unidadesMaoDeObra.firstWhere((u) => u.value == value).label;

num _fatorHora(String? value) => value == null
    ? 1
    : _unidadesMaoDeObra.firstWhere((u) => u.value == value).fatorHora;

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
}

// Mão de obra "3-em-1" — `appropriation_employee` guarda três FKs mutuamente
// exclusivas (`functions`, `employees`, `providers`) discriminadas por
// `labor_items.*.type` (espelho de `App\Enums\Appropriation\LaborType`:
// 1=Funcionário, 2=Função, 3=Prestador). `AppropriationRequest::rules()` exige
// `type` (`required_with:labor_items`) e, por `required_if`, a FK do tipo
// escolhido — sem o discriminante o POST dá 422.
enum _TipoMaoDeObra { funcionario, funcao, prestador }

extension on _TipoMaoDeObra {
  String get label => switch (this) {
    _TipoMaoDeObra.funcionario => 'Funcionário',
    _TipoMaoDeObra.funcao => 'Função',
    _TipoMaoDeObra.prestador => 'Prestador de Serviço',
  };

  /// Rótulo do alvo (a FK exigida por `required_if` para este `type`).
  String get alvoLabel => switch (this) {
    _TipoMaoDeObra.funcionario => 'Funcionário',
    _TipoMaoDeObra.funcao => 'Função exercida',
    _TipoMaoDeObra.prestador => 'Prestador',
  };

  /// Cadastro de onde o alvo vem — cada um com o seu custo-hora.
  List<ExecutorCadastro> get cadastro => switch (this) {
    _TipoMaoDeObra.funcionario => cadastroFuncionarios,
    _TipoMaoDeObra.funcao => cadastroFuncoes,
    _TipoMaoDeObra.prestador => cadastroPrestadores,
  };
}

const _tiposMaoDeObra = <AppFormSelectOption>[
  AppFormSelectOption(value: 'funcionario', label: 'Funcionário'),
  AppFormSelectOption(value: 'funcao', label: 'Função'),
  AppFormSelectOption(value: 'prestador', label: 'Prestador de Serviço'),
];

class _MaoDeObraItem {
  const _MaoDeObraItem({
    required this.tipo,
    required this.alvo,
    required this.quantidade,
    required this.unidade,
    required this.valorUnitario,
    this.funcao,
  });

  /// Discriminante `labor_items.*.type`.
  final _TipoMaoDeObra tipo;

  /// Nome do funcionário/prestador ou da função escolhida no cadastro.
  final String alvo;

  /// Função do funcionário, vinda do cadastro (`employees.function_id`).
  final String? funcao;
  final num quantidade;
  final String unidade;
  final num valorUnitario;

  num get total => quantidade * valorUnitario;
}

class _MaquinaItem {
  const _MaquinaItem({
    required this.equipamento,
    required this.leituraInicial,
    required this.leituraFinal,
    required this.quantidade,
  });

  final EquipamentoCadastro equipamento;
  final num leituraInicial;
  final num leituraFinal;

  /// Horas (ou km) trabalhadas — diferença do medidor quando o equipamento
  /// tem medidor; informada à mão no implemento.
  final num quantidade;

  num get total => quantidade * equipamento.custoPorUnidade;
}

class _InsumoItem {
  const _InsumoItem({
    required this.estoque,
    required this.dose,
    required this.areaUtilizada,
  });

  /// `stock_items.*.stock_uuid` — traz produto, armazém (`warehouse_uuid`),
  /// saldo e custo médio.
  final ItemEstoqueCadastro estoque;

  /// Dose por hectare (`appropriation_stock.quantity`).
  final num dose;
  final num areaUtilizada;

  String get produto => estoque.produto;
  String get unidade => estoque.unidade;

  /// `total_quantity` = dose × área utilizada.
  num get quantidadeTotal => dose * areaUtilizada;
  num get custoTotal => quantidadeTotal * estoque.custoMedio;
}

class _ProducaoItem {
  const _ProducaoItem({required this.produto, required this.quantidade});

  final String produto;
  final num quantidade;

  String get unidade => unidadePorProduto[produto]!;
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

/// Campo que o cadastro já respondeu: o mesmo controle do formulário,
/// desabilitado, com o valor dentro e a origem no `hint`. A chave por valor
/// remonta o `AppTextInput` (que só lê `initialValue` no primeiro build)
/// quando a fonte muda.
Widget _campoDoCadastro({
  required String label,
  required String value,
  String hint = 'Preenchido automaticamente pelo cadastro.',
}) => AppFormField(
  label: label,
  hint: hint,
  child: AppTextInput(
    key: ValueKey('$label=$value'),
    initialValue: value,
    enabled: false,
  ),
);

String _ha(num valor) => '${formatarNumero(valor)} ha';

String _qtd(num valor, String unidade) =>
    '${formatarNumero(valor, casas: valor == valor.roundToDouble() ? 0 : 2)} '
    '$unidade';

/// Apontamento agrícola (spec real: `appropriations` + tabelas filhas do
/// dump gbcerne). Os cinco grupos de recurso (Mão de obra, Máquinas, Insumos,
/// Produção, Ocorrências) têm campo por item — cada "Adicionar" abre um
/// formulário real e o item entra na lista com os dados verdadeiros.
class ApontamentoFlow extends ConsumerStatefulWidget {
  const ApontamentoFlow({super.key});

  @override
  ConsumerState<ApontamentoFlow> createState() => _ApontamentoFlowState();
}

class _ApontamentoFlowState extends ConsumerState<ApontamentoFlow> {
  String? _responsavel;
  String? _lote;
  String? _talhao;
  String? _operacao;
  String? _atividade;
  String _data = '';
  String _areaUtilizada = '';
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

  /// fidelidade-campos (onda 2): três etapas com a régua do arquétipo
  /// `Cadastro steps` — identificação, dados da operação e lançamentos.
  int _step = 0;
  static const _totalSteps = 3;

  LoteAgricolaCadastro? get _loteCadastro => loteAgricolaPorRotulo(_lote);

  TalhaoCadastro? get _talhaoCadastro {
    for (final talhao in _loteCadastro?.talhoes ?? const <TalhaoCadastro>[]) {
      if (talhao.nome == _talhao) return talhao;
    }
    return null;
  }

  num? get _areaUtilizadaNum => lerNumero(_areaUtilizada);

  /// Erro da área utilizada: obrigatória, positiva e nunca maior que a área
  /// total do talhão.
  String? get _erroAreaUtilizada {
    final area = _areaUtilizadaNum;
    if (area == null || area <= 0) return 'Informe a área utilizada.';
    final total = _talhaoCadastro?.areaTotal;
    if (total != null && area > total) {
      return 'A área utilizada não pode passar da área total (${_ha(total)}).';
    }
    return null;
  }

  bool get _etapaIdentificacaoValida =>
      _responsavel != null &&
      _loteCadastro != null &&
      _talhaoCadastro != null &&
      _operacao != null &&
      _atividade != null &&
      _data.isNotEmpty;

  bool get _etapaOperacaoValida =>
      _erroAreaUtilizada == null && _armazemProducao != null;

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

  /// Trocar o lote troca os talhões possíveis: com um talhão só, ele já vem
  /// escolhido; com mais de um, a pessoa escolhe.
  void _escolherLote(String? rotulo) => setState(() {
    _lote = rotulo;
    final talhoes = _loteCadastro?.talhoes ?? const <TalhaoCadastro>[];
    _escolherTalhaoSemSetState(
      talhoes.length == 1 ? talhoes.single.nome : null,
    );
  });

  void _escolherTalhao(String? nome) =>
      setState(() => _escolherTalhaoSemSetState(nome));

  /// A área utilizada nasce com a área produtiva do talhão
  /// (`areas.productive_area` — o valor mais frequente de `used_area` no
  /// dump); a pessoa só ajusta quando o trabalho foi parcial.
  void _escolherTalhaoSemSetState(String? nome) {
    _talhao = nome;
    final talhao = _talhaoCadastro;
    _areaUtilizada = talhao == null ? '' : formatarNumero(talhao.areaProdutiva);
  }

  /// Trocar a operação limpa a atividade que não pertence a ela
  /// (`operation_activities`).
  void _escolherOperacao(String? operacao) => setState(() {
    _operacao = operacao;
    final permitidas = atividadesPorOperacao[operacao] ?? const <String>[];
    if (!permitidas.contains(_atividade)) _atividade = null;
    if (permitidas.length == 1) _atividade = permitidas.single;
  });

  void _confirmar() {
    final isOnline = ref.read(shellStoreProvider).isOnline;
    final queued = !isOnline;
    final atividade = _atividade!;
    final lote = _loteCadastro!;
    if (queued) {
      ref
          .read(fazendasStoreProvider.notifier)
          .enqueueSync(
            SyncItem(
              id: 'apt-${DateTime.now().microsecondsSinceEpoch}',
              label: 'Apontamento — $atividade',
              detail: [
                '${lote.codigo} · $_talhao',
                if (_descricao.isNotEmpty) _descricao,
                if (_maoDeObra.isNotEmpty) '${_maoDeObra.length} mão de obra',
                if (_maquinas.isNotEmpty) '${_maquinas.length} máquina(s)',
                if (_insumos.isNotEmpty) '${_insumos.length} insumo(s)',
                if (_producoes.isNotEmpty) '${_producoes.length} produção(ões)',
                if (_ocorrencias.isNotEmpty)
                  '${_ocorrencias.length} ocorrência(s)',
              ].join(' · '),
              kind: ActivityKind.evento,
            ),
          );
    }
    // Registro estruturado para a consulta administrativa (`DashApontamentos`)
    // — mesmos campos e rótulos do cadastro, independente de estar online ou
    // na fila de sincronização (o apontamento já foi lançado nesta sessão).
    ref
        .read(apontamentoRegistroStoreProvider.notifier)
        .add(
          ApontamentoRegistro(
            id: 'apt-${DateTime.now().microsecondsSinceEpoch}',
            responsavel: _responsavel!,
            lote: lote.rotulo,
            area: _talhao!,
            operacao: _operacao!,
            atividade: atividade,
            data: _data,
            areaTotal: formatarNumero(_talhaoCadastro!.areaTotal),
            areaUtilizada: _areaUtilizada,
            armazemProducao: _armazemProducao!,
            cultura: '${lote.cultura} — ${lote.variedade}',
            safra: lote.safra,
            centroCusto: lote.centroCusto,
            armazemInsumo: _armazemInsumo,
            descricao: _descricao,
            registradoEm: DateTime.now(),
            maoDeObra: [
              for (final item in _maoDeObra)
                '${item.tipo.label}: ${item.alvo} — ${item.quantidade} '
                    '${_unidadeMaoDeObraLabel(item.unidade)} · '
                    '${formatarReais(item.total)}',
            ],
            maquinas: [
              for (final item in _maquinas)
                '${item.equipamento.nome} — '
                    '${_qtd(item.quantidade, item.equipamento.unidadeUso)} · '
                    '${formatarReais(item.total)}',
            ],
            insumos: [
              for (final item in _insumos)
                '${item.produto} — ${_qtd(item.quantidadeTotal, item.unidade)} · '
                    '${item.estoque.armazem}',
            ],
            producoes: [
              for (final item in _producoes)
                '${item.produto} — ${_qtd(item.quantidade, item.unidade)}',
            ],
            ocorrencias: [
              for (final item in _ocorrencias)
                '${item.prioridade.label}: ${item.diagnostico}',
            ],
          ),
        );
    setState(() => _queued = queued);
  }

  @override
  Widget build(BuildContext context) {
    if (_queued != null) {
      return SuccessScreen(
        title: 'Apontamento registrado',
        queued: _queued!,
        effects:
            'Mão de obra, máquinas e insumos caem no centro de custo do lote; '
            'os insumos baixam do estoque de origem e a produção lançada entra '
            'no armazém de destino.',
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

  /// Etapa 1 — quem, qual lote/talhão, o quê e quando: os vínculos que
  /// identificam o apontamento e sem os quais nenhum lançamento tem endereço.
  Widget _etapaIdentificacao() {
    final lote = _loteCadastro;
    final talhoes = lote?.talhoes ?? const <TalhaoCadastro>[];
    final atividades = _operacao == null
        ? const <String>[]
        : atividadesPorOperacao[_operacao] ?? const <String>[];
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
            options: _opcoes(catalogoResponsaveis),
            value: _responsavel,
            placeholder: 'Selecione',
            onChanged: (v) => setState(() => _responsavel = v),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        // fidelidade-esteira: campo de Lote é sempre dropdown com busca.
        AppFormField(
          label: 'Lote',
          required: true,
          hint: lote == null
              ? 'O lote traz cultura, safra, centro de custo e talhões.'
              : '${lote.cultura} ${lote.variedade} · Safra ${lote.safra}',
          error: _attempted && lote == null ? 'Selecione o lote.' : null,
          child: AppSearchSelect(
            options: [
              for (final item in cadastroLotesAgricolas)
                AppSearchSelectOption(value: item.rotulo, label: item.rotulo),
            ],
            value: _lote,
            label: 'Lote',
            placeholder: 'Buscar lote...',
            onChanged: _escolherLote,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Talhão',
          required: true,
          hint: lote == null
              ? 'Escolha o lote para ver os talhões dele.'
              : talhoes.length == 1
              ? 'Único talhão do lote — já selecionado.'
              : null,
          error: _attempted && lote != null && _talhaoCadastro == null
              ? 'Selecione o talhão.'
              : null,
          child: AppFormSelect(
            options: _opcoes(talhoes.map((t) => t.nome)),
            value: _talhao,
            placeholder: 'Selecione o talhão',
            enabled: lote != null,
            onChanged: _escolherTalhao,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppFormField(
                label: 'Operação',
                required: true,
                error: _attempted && _operacao == null
                    ? 'Selecione a operação.'
                    : null,
                child: AppFormSelect(
                  options: _opcoes(_operacoes),
                  value: _operacao,
                  placeholder: 'Selecione',
                  onChanged: _escolherOperacao,
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
                  options: _opcoes(atividades),
                  value: _atividade,
                  placeholder: 'Selecione',
                  enabled: _operacao != null,
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
          child: AppDateInput(
            // Etapas recriam o campo a cada troca: sem `initialValue` o texto
            // já digitado sumiria da tela ao voltar uma etapa.
            initialValue: _data.isEmpty ? null : _data,
            onChanged: (v) => setState(() => _data = v),
            invalid: _attempted && _data.isEmpty,
          ),
        ),
      ],
    );
  }

  /// Etapa 2 — o que o lote e o talhão já responderam (travado), a área
  /// realmente trabalhada (sugerida) e os armazéns dos lançamentos.
  Widget _etapaOperacao() {
    final lote = _loteCadastro!;
    final talhao = _talhaoCadastro!;
    final erroArea = _attempted || _areaUtilizada.isNotEmpty
        ? _erroAreaUtilizada
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionTitle(child: Text('Dados do lote ${lote.codigo}')),
        const SizedBox(height: AppSpacing.space3),
        _campoDoCadastro(
          label: 'Cultura / variedade',
          value: '${lote.cultura} — ${lote.variedade}',
          hint: 'Preenchido pelo lote.',
        ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campoDoCadastro(
                label: 'Safra',
                value: lote.safra,
                hint: 'Preenchido pelo lote.',
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _campoDoCadastro(
                label: 'Centro de custo',
                value: lote.centroCusto,
                hint: 'Recebe os custos do apontamento.',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _campoDoCadastro(
                label: 'Área total',
                value: _ha(talhao.areaTotal),
                hint: 'Preenchido pelo talhão.',
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: AppFormField(
                label: 'Área utilizada',
                required: true,
                hint: erroArea == null
                    ? 'Área produtiva do talhão — ajuste se o trabalho foi '
                          'parcial.'
                    : null,
                error: erroArea,
                child: AppTextInput(
                  key: ValueKey('area-utilizada-${talhao.nome}'),
                  initialValue: _areaUtilizada,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => setState(() => _areaUtilizada = v),
                  placeholder: 'ha',
                  invalid: erroArea != null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space4),
        AppFormField(
          label: 'Armazém de insumo',
          hint: 'Sugere o armazém de origem ao lançar insumos.',
          child: AppFormSelect(
            options: _opcoes(catalogoArmazens),
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
            options: _opcoes(catalogoArmazens),
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

  static const _grupoMaoDeObra = 'Mão de obra / Serviços';
  static const _grupoMaquinas = 'Máquinas / Implementos';
  static const _grupoInsumos = 'Insumos';
  static const _grupoProducao = 'Produção';
  static const _grupoOcorrencias = 'Ocorrências';

  /// Etapa 3 — as cinco coleções do contrato, em grade 2x2 de cards
  /// quadrados: cada card só mostra o nome do grupo e um contador, nunca os
  /// itens soltos. "Adicionar" abre o formulário direto; "editar" abre a
  /// listagem dos itens já lançados naquele grupo, com edição e exclusão.
  Widget _etapaLancamentos(BuildContext context) {
    return AppSquareGroupGrid(
      groups: const [
        _grupoMaoDeObra,
        _grupoMaquinas,
        _grupoInsumos,
        _grupoProducao,
        _grupoOcorrencias,
      ],
      counts: {
        _grupoMaoDeObra: _maoDeObra.length,
        _grupoMaquinas: _maquinas.length,
        _grupoInsumos: _insumos.length,
        _grupoProducao: _producoes.length,
        _grupoOcorrencias: _ocorrencias.length,
      },
      onAdd: (group) => _abrirFormularioDoGrupo(context, group),
      onManage: (group) => _gerenciarGrupo(context, group),
    );
  }

  void _abrirFormularioDoGrupo(
    BuildContext context,
    String group, {
    int? editIndex,
  }) {
    switch (group) {
      case _grupoMaoDeObra:
        _adicionarMaoDeObra(context, editIndex: editIndex);
      case _grupoMaquinas:
        _adicionarMaquina(context, editIndex: editIndex);
      case _grupoInsumos:
        _adicionarInsumo(context, editIndex: editIndex);
      case _grupoProducao:
        _adicionarProducao(context, editIndex: editIndex);
      case _grupoOcorrencias:
        _adicionarOcorrencia(context, editIndex: editIndex);
    }
  }

  /// Listagem dos itens já lançados de um grupo — aberta pelo "editar" do
  /// card. Reusa [AppCollectionList]: "editar" fecha esta listagem e reabre o
  /// formulário do grupo pré-preenchido; "remover" tira o item na hora.
  void _gerenciarGrupo(BuildContext context, String group) {
    List<AppCollectionItemView> items() => switch (group) {
      _grupoMaoDeObra => [
        for (final item in _maoDeObra)
          AppCollectionItemView(
            title: '${item.tipo.label}: ${item.alvo}',
            subtitle:
                '${item.quantidade} ${_unidadeMaoDeObraLabel(item.unidade)} · '
                '${formatarReais(item.valorUnitario)} · '
                'total ${formatarReais(item.total)}',
          ),
      ],
      _grupoMaquinas => [
        for (final item in _maquinas)
          AppCollectionItemView(
            title: item.equipamento.nome,
            subtitle:
                '${_qtd(item.quantidade, item.equipamento.unidadeUso)}'
                '${item.equipamento.medidor == MedidorEquipamento.nenhum ? '' : ' · ${item.equipamento.medidorLabel.toLowerCase()} ${formatarNumero(item.leituraInicial, casas: 1)}→${formatarNumero(item.leituraFinal, casas: 1)}'}'
                ' · ${formatarReais(item.total)}',
          ),
      ],
      _grupoInsumos => [
        for (final item in _insumos)
          AppCollectionItemView(
            title: item.produto,
            subtitle:
                '${_qtd(item.dose, '${item.unidade}/ha')} · '
                'total ${_qtd(item.quantidadeTotal, item.unidade)} · '
                '${item.estoque.armazem}',
          ),
      ],
      _grupoProducao => [
        for (final item in _producoes)
          AppCollectionItemView(
            title: item.produto,
            subtitle: _qtd(item.quantidade, item.unidade),
          ),
      ],
      _ => [
        for (final item in _ocorrencias)
          AppCollectionItemView(
            title: item.prioridade.label,
            subtitle: item.diagnostico,
          ),
      ],
    };

    void remover(int index) => setState(() {
      switch (group) {
        case _grupoMaoDeObra:
          _maoDeObra.removeAt(index);
        case _grupoMaquinas:
          _maquinas.removeAt(index);
        case _grupoInsumos:
          _insumos.removeAt(index);
        case _grupoProducao:
          _producoes.removeAt(index);
        case _grupoOcorrencias:
          _ocorrencias.removeAt(index);
      }
    });

    showAppBottomSheet<void>(
      context,
      title: group,
      child: StatefulBuilder(
        builder: (sheetContext, setSheetState) => AppCollectionList(
          name: group,
          items: items(),
          onAdd: () {
            Navigator.of(sheetContext).pop();
            _abrirFormularioDoGrupo(context, group);
          },
          onEdit: (index) {
            Navigator.of(sheetContext).pop();
            _abrirFormularioDoGrupo(context, group, editIndex: index);
          },
          onRemove: (index) {
            remover(index);
            setSheetState(() {});
          },
        ),
      ),
    );
  }

  void _adicionarMaoDeObra(BuildContext context, {int? editIndex}) {
    final existente = editIndex == null ? null : _maoDeObra[editIndex];
    _TipoMaoDeObra? tipo = existente?.tipo;
    String? alvo = existente?.alvo;
    num quantidade = existente?.quantidade ?? 1;
    String? unidade = existente?.unidade ?? 'hora';
    var valor = existente == null
        ? ''
        : formatarNumero(existente.valorUnitario);

    ExecutorCadastro? cadastro() {
      for (final item in tipo?.cadastro ?? const <ExecutorCadastro>[]) {
        if (item.nome == alvo) return item;
      }
      return null;
    }

    /// Sugestão de valor unitário: custo-hora do cadastro na unidade escolhida
    /// (dia = 8 h). Sobrescreve o valor só quando alvo ou unidade mudam — o
    /// que a pessoa digitou depois continua valendo.
    void sugerirValor() {
      final executor = cadastro();
      if (executor == null) return;
      valor = formatarNumero(executor.custoHora * _fatorHora(unidade));
    }

    showAppBottomSheet<void>(
      context,
      title: editIndex == null
          ? 'Mão de obra / Serviço'
          : 'Editar mão de obra / serviço',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final executor = cadastro();
          final valorNum = lerNumero(valor);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Tipo',
                required: true,
                child: AppFormSelect(
                  options: _tiposMaoDeObra,
                  value: tipo?.name,
                  placeholder: 'Funcionário, função ou prestador',
                  onChanged: (v) => setSheetState(() {
                    tipo = v == null ? null : _TipoMaoDeObra.values.byName(v);
                    // Troca de tipo zera o alvo do tipo anterior.
                    alvo = null;
                    valor = '';
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: tipo?.alvoLabel ?? 'Funcionário / prestador',
                required: true,
                child: AppFormSelect(
                  options: _opcoes(
                    (tipo?.cadastro ?? const <ExecutorCadastro>[]).map(
                      (e) => e.nome,
                    ),
                  ),
                  value: alvo,
                  enabled: tipo != null,
                  placeholder: tipo == null
                      ? 'Escolha o tipo primeiro'
                      : 'Selecione',
                  onChanged: (v) => setSheetState(() {
                    alvo = v;
                    sugerirValor();
                  }),
                ),
              ),
              if (executor?.funcao case final funcao?) ...[
                const SizedBox(height: AppSpacing.space3),
                _campoDoCadastro(
                  label: 'Função',
                  value: funcao,
                  hint: 'Preenchido pelo cadastro do funcionário.',
                ),
              ],
              const SizedBox(height: AppSpacing.space3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppFormField(
                      label: 'Quantidade',
                      required: true,
                      child: AppStepper(
                        value: quantidade,
                        onChanged: (v) => setSheetState(() => quantidade = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: AppFormField(
                      label: 'Unidade',
                      required: true,
                      child: AppFormSelect(
                        options: [
                          for (final u in _unidadesMaoDeObra)
                            AppFormSelectOption(value: u.value, label: u.label),
                        ],
                        value: unidade,
                        placeholder: 'Selecione',
                        onChanged: (v) => setSheetState(() {
                          unidade = v;
                          sugerirValor();
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Valor unitário (R\$)',
                required: true,
                hint: executor == null
                    ? null
                    : 'Sugerido pelo custo-hora do cadastro '
                          '(${formatarReais(executor.custoHora)}/h).',
                child: AppTextInput(
                  key: ValueKey('valor-$tipo-$alvo-$unidade'),
                  initialValue: valor,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => setSheetState(() => valor = v),
                  placeholder: '0,00',
                ),
              ),
              if (valorNum != null && valorNum > 0) ...[
                const SizedBox(height: AppSpacing.space3),
                AppReviewList(
                  style: AppReviewStyle.inputCapsule,
                  items: [
                    AppReviewItem(
                      label: 'Total',
                      value: formatarReais(quantidade * valorNum),
                      copyable: false,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                onPressed: tipo == null || alvo == null || unidade == null
                    ? null
                    : () {
                        final item = _MaoDeObraItem(
                          tipo: tipo!,
                          alvo: alvo!,
                          funcao: executor?.funcao,
                          quantidade: quantidade,
                          unidade: unidade!,
                          valorUnitario: valorNum ?? 0,
                        );
                        setState(() {
                          if (editIndex == null) {
                            _maoDeObra.add(item);
                          } else {
                            _maoDeObra[editIndex] = item;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                child: Text(editIndex == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// `appropriation_equipment` — o equipamento traz medidor, leitura atual,
  /// unidade e custo-hora. Com medidor, a quantidade é a diferença entre a
  /// leitura final e a inicial (nunca digitada); sem medidor (implemento), a
  /// pessoa informa as horas.
  void _adicionarMaquina(BuildContext context, {int? editIndex}) {
    final existente = editIndex == null ? null : _maquinas[editIndex];
    EquipamentoCadastro? equipamento = existente?.equipamento;
    num leituraInicial = existente?.leituraInicial ?? 0;
    num leituraFinal = existente?.leituraFinal ?? 0;
    num horasManuais = existente?.quantidade ?? 1;

    bool temMedidor() =>
        equipamento != null &&
        equipamento!.medidor != MedidorEquipamento.nenhum;
    num quantidade() =>
        temMedidor() ? leituraFinal - leituraInicial : horasManuais;

    showAppBottomSheet<void>(
      context,
      title: editIndex == null
          ? 'Máquina / Implemento'
          : 'Editar máquina / implemento',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final eq = equipamento;
          final qtd = quantidade();
          final leituraInvalida = temMedidor() && qtd <= 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Equipamento',
                required: true,
                child: AppSearchSelect(
                  options: [
                    for (final nome in catalogoEquipamentos)
                      AppSearchSelectOption(value: nome, label: nome),
                  ],
                  value: eq?.nome,
                  label: 'Equipamento',
                  placeholder: 'Buscar equipamento...',
                  onChanged: (v) => setSheetState(() {
                    equipamento = equipamentoPorNome(v);
                    // A leitura inicial é a última do cadastro; a final
                    // começa igual e a pessoa avança até o que o painel
                    // marca agora.
                    leituraInicial = equipamento?.leituraAtual ?? 0;
                    leituraFinal = leituraInicial;
                    horasManuais = 1;
                  }),
                ),
              ),
              if (eq != null) ...[
                const SizedBox(height: AppSpacing.space3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _campoDoCadastro(
                        label: 'Medidor',
                        value: eq.medidorLabel,
                        hint: 'Preenchido pelo equipamento.',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: _campoDoCadastro(
                        label: 'Custo por ${eq.unidadeUso.toLowerCase()}',
                        value: formatarReais(eq.custoPorUnidade),
                        hint: 'Preenchido pelo equipamento.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                if (temMedidor()) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppFormField(
                          label: '${eq.medidorLabel} inicial',
                          hint: 'Última leitura do cadastro.',
                          child: AppStepper(
                            value: leituraInicial,
                            onChanged: (v) =>
                                setSheetState(() => leituraInicial = v),
                            step: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: AppFormField(
                          label: '${eq.medidorLabel} final',
                          required: true,
                          error: leituraInvalida
                              ? 'Precisa ser maior que a inicial.'
                              : null,
                          child: AppStepper(
                            value: leituraFinal,
                            onChanged: (v) =>
                                setSheetState(() => leituraFinal = v),
                            step: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _campoDoCadastro(
                    label: 'Quantidade',
                    value: _qtd(qtd < 0 ? 0 : qtd, eq.unidadeUso),
                    hint: 'Calculada: leitura final − inicial.',
                  ),
                ] else
                  AppFormField(
                    label: 'Quantidade (${eq.unidadeUso.toLowerCase()})',
                    required: true,
                    hint: 'Implemento sem medidor próprio — informe as horas.',
                    child: AppStepper(
                      value: horasManuais,
                      onChanged: (v) => setSheetState(() => horasManuais = v),
                      step: 0.5,
                    ),
                  ),
                if (qtd > 0) ...[
                  const SizedBox(height: AppSpacing.space3),
                  AppReviewList(
                    style: AppReviewStyle.inputCapsule,
                    items: [
                      AppReviewItem(
                        label: 'Custo total',
                        value: formatarReais(qtd * eq.custoPorUnidade),
                        copyable: false,
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                onPressed: eq == null || qtd <= 0
                    ? null
                    : () {
                        final item = _MaquinaItem(
                          equipamento: eq,
                          leituraInicial: leituraInicial,
                          leituraFinal: leituraFinal,
                          quantidade: qtd,
                        );
                        setState(() {
                          if (editIndex == null) {
                            _maquinas.add(item);
                          } else {
                            _maquinas[editIndex] = item;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                child: Text(editIndex == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // fidelidade-contrato (re-auditoria 3ª avaliação): `stock_items.*` exige
  // `warehouse_uuid` por item. Onda 5: o armazém é o do item de estoque
  // escolhido (`stocks.warehouse_id`) — travado, não mais um select solto que
  // podia apontar para um armazém onde o produto não está. O "Armazém de
  // insumo" do cabeçalho prioriza o estoque daquele armazém.
  void _adicionarInsumo(BuildContext context, {int? editIndex}) {
    final existente = editIndex == null ? null : _insumos[editIndex];
    String? produto = existente?.produto;
    ItemEstoqueCadastro? estoque = existente?.estoque;
    var dose = existente == null ? '1' : formatarNumero(existente.dose);
    final area = _areaUtilizadaNum ?? 0;

    List<ItemEstoqueCadastro> estoquesDoProduto() => [
      for (final rotulo in estoquesPorProduto[produto] ?? const <String>[])
        itemEstoquePorRotulo(rotulo)!,
    ];

    showAppBottomSheet<void>(
      context,
      title: editIndex == null ? 'Insumo' : 'Editar insumo',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final estoques = estoquesDoProduto();
          final doseNum = lerNumero(dose);
          final total = doseNum == null ? null : doseNum * area;
          final saldoInsuficiente =
              estoque != null && total != null && total > estoque!.saldo;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Produto',
                required: true,
                child: AppSearchSelect(
                  // Só entra produto com estoque: insumo sai de um lote de
                  // estoque (`stock_uuid`), não do nada.
                  options: [
                    for (final p in catalogoProdutos)
                      if ((estoquesPorProduto[p] ?? const []).isNotEmpty)
                        AppSearchSelectOption(value: p, label: p),
                  ],
                  value: produto,
                  label: 'Produto',
                  placeholder: 'Buscar produto...',
                  onChanged: (v) => setSheetState(() {
                    produto = v;
                    final opcoes = estoquesDoProduto();
                    estoque =
                        opcoes
                            .where((e) => e.armazem == _armazemInsumo)
                            .firstOrNull ??
                        (opcoes.length == 1 ? opcoes.single : null);
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Item de estoque',
                required: true,
                hint: estoque == null
                    ? null
                    : 'Saldo ${_qtd(estoque!.saldo, estoque!.unidade)}'
                          '${estoque!.validade == null ? '' : ' · validade ${estoque!.validade}'}',
                child: AppFormSelect(
                  options: _opcoes(estoques.map((e) => e.rotulo)),
                  value: estoque?.rotulo,
                  enabled: produto != null,
                  placeholder: produto == null
                      ? 'Escolha o produto primeiro'
                      : 'Selecione o lote',
                  onChanged: (v) =>
                      setSheetState(() => estoque = itemEstoquePorRotulo(v)),
                ),
              ),
              if (estoque != null) ...[
                const SizedBox(height: AppSpacing.space3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _campoDoCadastro(
                        label: 'Armazém de origem',
                        value: estoque!.armazem,
                        hint: 'Preenchido pelo item de estoque.',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: _campoDoCadastro(
                        label: 'Unidade',
                        value: estoque!.unidade,
                        hint: 'Preenchido pelo produto.',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: estoque == null
                    ? 'Dose por hectare'
                    : 'Dose por hectare (${estoque!.unidade}/ha)',
                required: true,
                error: saldoInsuficiente
                    ? 'Saldo insuficiente: o total passa do estoque.'
                    : null,
                child: AppTextInput(
                  initialValue: dose,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => setSheetState(() => dose = v),
                  invalid: saldoInsuficiente,
                ),
              ),
              if (estoque != null && total != null && total > 0) ...[
                const SizedBox(height: AppSpacing.space3),
                AppReviewList(
                  style: AppReviewStyle.inputCapsule,
                  items: [
                    AppReviewItem(
                      label: 'Quantidade total (dose × ${_ha(area)})',
                      value: _qtd(total, estoque!.unidade),
                      copyable: false,
                    ),
                    AppReviewItem(
                      label: 'Custo estimado',
                      value:
                          '${formatarReais(total * estoque!.custoMedio)} '
                          '(${formatarReais(estoque!.custoMedio)}/${estoque!.unidade})',
                      copyable: false,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                onPressed:
                    estoque == null ||
                        doseNum == null ||
                        doseNum <= 0 ||
                        saldoInsuficiente
                    ? null
                    : () {
                        final item = _InsumoItem(
                          estoque: estoque!,
                          dose: doseNum,
                          areaUtilizada: area,
                        );
                        setState(() {
                          if (editIndex == null) {
                            _insumos.add(item);
                          } else {
                            _insumos[editIndex] = item;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                child: Text(editIndex == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// `appropriation_production` — o que a operação gerou. A unidade é do
  /// produto (`product_um`) e o destino é sempre o "Armazém de produção" do
  /// cabeçalho (`appropriation_production` não tem `warehouse_uuid` próprio).
  void _adicionarProducao(BuildContext context, {int? editIndex}) {
    final existente = editIndex == null ? null : _producoes[editIndex];
    String? produto = existente?.produto;
    num quantidade = existente?.quantidade ?? 1;
    final area = _areaUtilizadaNum ?? 0;

    showAppBottomSheet<void>(
      context,
      title: editIndex == null ? 'Produção' : 'Editar produção',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final unidade = produto == null ? null : unidadePorProduto[produto];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppFormField(
                label: 'Produto colhido',
                required: true,
                child: AppSearchSelect(
                  options: [
                    for (final p in catalogoProdutos)
                      AppSearchSelectOption(value: p, label: p),
                  ],
                  value: produto,
                  label: 'Produto colhido',
                  placeholder: 'Buscar produto...',
                  onChanged: (v) => setSheetState(() => produto = v),
                ),
              ),
              if (unidade != null) ...[
                const SizedBox(height: AppSpacing.space3),
                _campoDoCadastro(
                  label: 'Unidade',
                  value: unidade,
                  hint: 'Preenchido pelo produto.',
                ),
              ],
              const SizedBox(height: AppSpacing.space3),
              AppFormField(
                label: 'Quantidade',
                required: true,
                child: AppStepper(
                  value: quantidade,
                  onChanged: (v) => setSheetState(() => quantidade = v),
                ),
              ),
              if (unidade != null && area > 0 && quantidade > 0) ...[
                const SizedBox(height: AppSpacing.space3),
                AppReviewList(
                  style: AppReviewStyle.inputCapsule,
                  items: [
                    AppReviewItem(
                      label: 'Produtividade',
                      value: _qtd(quantidade / area, '$unidade/ha'),
                      copyable: false,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.space4),
              AppButton(
                fullWidth: true,
                onPressed: produto == null || quantidade <= 0
                    ? null
                    : () {
                        final item = _ProducaoItem(
                          produto: produto!,
                          quantidade: quantidade,
                        );
                        setState(() {
                          if (editIndex == null) {
                            _producoes.add(item);
                          } else {
                            _producoes[editIndex] = item;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                child: Text(editIndex == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _adicionarOcorrencia(BuildContext context, {int? editIndex}) {
    final existente = editIndex == null ? null : _ocorrencias[editIndex];
    var prioridade = existente?.prioridade ?? _Prioridade.media;
    var diagnostico = existente?.diagnostico ?? '';
    var recomendacao = existente?.recomendacao ?? '';
    String? foto = existente?.foto;

    showAppBottomSheet<void>(
      context,
      title: editIndex == null ? 'Ocorrência' : 'Editar ocorrência',
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
                  () => prioridade = _Prioridade.values.byName(v!),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Diagnóstico',
              required: true,
              child: AppTextarea(
                initialValue: diagnostico,
                onChanged: (v) => setSheetState(() => diagnostico = v),
                minLines: 2,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            AppFormField(
              label: 'Recomendação',
              child: AppTextarea(
                initialValue: recomendacao,
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
                      final item = _OcorrenciaItem(
                        prioridade: prioridade,
                        diagnostico: diagnostico,
                        recomendacao: recomendacao.isEmpty
                            ? null
                            : recomendacao,
                        foto: foto,
                      );
                      setState(() {
                        if (editIndex == null) {
                          _ocorrencias.add(item);
                        } else {
                          _ocorrencias[editIndex] = item;
                        }
                      });
                      Navigator.of(context).pop();
                    },
              child: Text(
                editIndex == null
                    ? 'Adicionar ocorrência'
                    : 'Salvar ocorrência',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
