import '../../../ui/ui.dart' show AppFormSelectOption, AppSearchSelectOption;

/// Opções mockadas para os formulários operacionais (spec §5) — espelha
/// `src/modules/fazendas/mocks/operacional.ts`. Consumido pelos 6 fluxos de
/// campo (`operacional/campo_flow.dart`), construídos em processo separado.

const List<AppSearchSelectOption> lotesOpcoes = [
  AppSearchSelectOption(
    value: 'l42',
    label: 'Lote 42',
    detail: '128 cabeças · Curral 02',
  ),
  AppSearchSelectOption(
    value: 'l19',
    label: 'Lote 19',
    detail: '96 cabeças · Curral 05',
  ),
  AppSearchSelectOption(
    value: 'l07',
    label: 'Lote 07',
    detail: '150 cabeças · Piquete 3',
  ),
  AppSearchSelectOption(
    value: 'l33',
    label: 'Lote 33',
    detail: '64 cabeças · Curral 01',
  ),
  AppSearchSelectOption(
    value: 'l51',
    label: 'Lote 51',
    detail: '110 cabeças · Piquete 1',
  ),
  AppSearchSelectOption(
    value: 'l88',
    label: 'Lote 88',
    detail: '82 cabeças · Curral 04',
  ),
];

/// Animais mockados por lote, para fluxos operacionais que pesam ou
/// identificam um animal específico dentro de um lote já selecionado (ex.
/// `PesagemFlow`). Espelha o mesmo estilo de identificação (brinco/RFID)
/// usado no catálogo funcional (`catalogoIdentificacaoAnimal`).
const Map<String, List<AppSearchSelectOption>> animaisPorLote = {
  'l42': [
    AppSearchSelectOption(value: 'a4201', label: 'Brinco 4201', detail: 'Nelore · 24 meses'),
    AppSearchSelectOption(value: 'a4202', label: 'Brinco 4202', detail: 'Nelore · 22 meses'),
    AppSearchSelectOption(value: 'a4203', label: 'RFID 982000123456120', detail: 'Nelore · 24 meses'),
  ],
  'l19': [
    AppSearchSelectOption(value: 'a1901', label: 'Brinco 1901', detail: 'Angus · 18 meses'),
    AppSearchSelectOption(value: 'a1902', label: 'Brinco 1902', detail: 'Angus · 19 meses'),
  ],
  'l07': [
    AppSearchSelectOption(value: 'a0701', label: 'Brinco 0701', detail: 'Nelore · 30 meses'),
    AppSearchSelectOption(value: 'a0702', label: 'Brinco 0702', detail: 'Nelore · 28 meses'),
    AppSearchSelectOption(value: 'a0703', label: 'Brinco 0703', detail: 'Nelore · 30 meses'),
  ],
  'l33': [
    AppSearchSelectOption(value: 'a3301', label: 'Brinco 3301', detail: 'Brahman · 20 meses'),
    AppSearchSelectOption(value: 'a3302', label: 'Brinco 3302', detail: 'Brahman · 21 meses'),
  ],
  'l51': [
    AppSearchSelectOption(value: 'a5101', label: 'Brinco 5101', detail: 'Nelore · 16 meses'),
    AppSearchSelectOption(value: 'a5102', label: 'Brinco 5102', detail: 'Nelore · 17 meses'),
  ],
  'l88': [
    AppSearchSelectOption(value: 'a8801', label: 'Brinco 8801', detail: 'Nelore · 26 meses'),
    AppSearchSelectOption(value: 'a8802', label: 'Brinco 8802', detail: 'Nelore · 25 meses'),
    AppSearchSelectOption(value: 'a8803', label: 'RFID 982000123456331', detail: 'Nelore · 27 meses'),
  ],
};

const List<AppFormSelectOption> dietas = [
  AppFormSelectOption(value: 'd1', label: 'Dieta Engorda'),
  AppFormSelectOption(value: 'd2', label: 'Dieta Recria'),
  AppFormSelectOption(value: 'd3', label: 'Dieta Terminação'),
  AppFormSelectOption(value: 'd4', label: 'Dieta Adaptação'),
];

const List<AppFormSelectOption> depositos = [
  AppFormSelectOption(value: 'dep1', label: 'Armazém A'),
  AppFormSelectOption(value: 'dep2', label: 'Armazém B'),
  AppFormSelectOption(value: 'dep3', label: 'Silo Central'),
];

const List<AppFormSelectOption> talhoes = [
  AppFormSelectOption(value: 't1', label: 'Talhão 1 — Sede'),
  AppFormSelectOption(value: 't2', label: 'Talhão 2 — Baixada'),
  AppFormSelectOption(value: 't3', label: 'Talhão 3 — Serra'),
  AppFormSelectOption(value: 't4', label: 'Talhão 4 — Rio'),
];

const List<AppFormSelectOption> ciclos = [
  AppFormSelectOption(value: 'ci1', label: 'Safra 24/25'),
  AppFormSelectOption(value: 'ci2', label: 'Safrinha 25'),
];

const List<AppFormSelectOption> insumos = [
  AppFormSelectOption(value: 'in1', label: 'Herbicida Glifosato'),
  AppFormSelectOption(value: 'in2', label: 'Fertilizante NPK'),
  AppFormSelectOption(value: 'in3', label: 'Inseticida'),
  AppFormSelectOption(value: 'in4', label: 'Calcário'),
];

const List<AppFormSelectOption> causasMorte = [
  AppFormSelectOption(value: 'ca1', label: 'Doença'),
  AppFormSelectOption(value: 'ca2', label: 'Acidente'),
  AppFormSelectOption(value: 'ca3', label: 'Predador'),
  AppFormSelectOption(value: 'ca4', label: 'Causa desconhecida'),
];

// TODO(banco-real): mapeia `sales.payment_method`/`movement_sales.type_payment`,
// campos char(2) no banco real sem tabela de domínio no dump. Confirmar com o
// time web os códigos válidos antes de travar estas opções em produção. Ver
// docs/ajustes-banco-real/03-ajustes-ponto-a-ponto.md, seção C.
const List<AppFormSelectOption> condPagamento = [
  AppFormSelectOption(value: 'p1', label: 'À vista'),
  AppFormSelectOption(value: 'p2', label: '30 dias'),
  AppFormSelectOption(value: 'p3', label: '30/60 dias'),
  AppFormSelectOption(value: 'p4', label: 'A prazo (negociado)'),
];

/// Item de uma NF-e mockada para conferência (spec §5.4).
class NfeItem {
  const NfeItem({
    required this.id,
    required this.descricao,
    required this.qtd,
    required this.valor,
  });

  final String id;
  final String descricao;
  final String qtd;
  final String valor;
}

const List<NfeItem> nfeItens = [
  NfeItem(
    id: 'i1',
    descricao: 'Ração Engorda 40kg',
    qtd: '120 sc',
    valor: 'R\$ 18.000',
  ),
  NfeItem(
    id: 'i2',
    descricao: 'Sal Mineral 25kg',
    qtd: '80 sc',
    valor: 'R\$ 6.400',
  ),
  NfeItem(
    id: 'i3',
    descricao: 'Vacina Aftosa',
    qtd: '540 doses',
    valor: 'R\$ 4.860',
  ),
  NfeItem(id: 'i4', descricao: 'Vermífugo', qtd: '30 fr', valor: 'R\$ 2.100'),
];

class NfeCabecalho {
  const NfeCabecalho({
    required this.fornecedor,
    required this.numero,
    required this.total,
  });

  final String fornecedor;
  final String numero;
  final String total;
}

const nfeCabecalho = NfeCabecalho(
  fornecedor: 'Agropecuária Vale Ltda',
  numero: '4471',
  total: 'R\$ 31.360',
);
