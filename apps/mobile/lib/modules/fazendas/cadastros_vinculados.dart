// banco-real (onda 5 — cadastros vinculados): no sistema real, um registro
// escolhido num campo nunca chega "sozinho" — ele carrega o próprio cadastro.
// Escolher o lote (ciclo de produção) já responde cultura, safra e área;
// escolher o produto já responde a unidade; escolher o item de estoque já
// responde o armazém; escolher o equipamento já responde o medidor, a leitura
// atual e o custo-hora. Pedir de novo o que o cadastro já sabe é o que mais
// distancia o protótipo do produto final.
//
// Este arquivo é a fonte única desses cadastros (Lei 2): os catálogos de
// opções (`catalogoProdutos`, `catalogoItensEstoque`, `catalogoEquipamentos`)
// e os mapas de atributo moram juntos, para que nenhuma opção exista sem o
// cadastro que ela carrega — invariante conferida em
// `test/modules/fazendas/cadastros_vinculados_test.dart`.
//
// Evidência no dump gbcerne (análise de 23/09/2026 — ver
// docs/ajustes-banco-real/05-cadastros-vinculados.md):
// - `production_cycles` (lote agrícola) → `cultivation_id`, `harvest_id`,
//   `center_id` e os talhões de `production_cycle_areas`/`areas`
//   (`total_area`, `productive_area`).
// - `appropriation_stock.amount` = `stocks.average_cost`;
//   `total_quantity` = dose × `appropriations.used_area`.
// - `appropriation_equipment.quantity` = horímetro final − inicial (100% das
//   linhas com horímetro) e `amount` = `equipments.vl_time_productive`.
// - `appropriation_supply.warehouse_id` = `stocks.warehouse_id` (99,98%) e o
//   combustível de um equipamento é o mesmo em 89% dos abastecimentos.
// - `operations` × `activities` via `operation_activities` (1.854 de 1.855
//   apontamentos respeitam o par).
//
// Todos os nomes e valores abaixo são fictícios: o dump só informa a FORMA
// dos cadastros, nunca um dado real de cliente.

/// Rótulo de dinheiro no padrão brasileiro, sem depender de `intl` — o
/// protótipo só precisa exibir custo derivado de cadastro.
String formatarReais(num valor) => 'R\$ ${formatarNumero(valor)}';

/// Número com vírgula decimal e ponto de milhar (`12.400,50`).
String formatarNumero(num valor, {int casas = 2}) {
  final negativo = valor < 0;
  final partes = valor.abs().toStringAsFixed(casas).split('.');
  final inteiro = partes.first;
  final milhares = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) milhares.write('.');
    milhares.write(inteiro[i]);
  }
  final decimal = partes.length > 1 ? ',${partes[1]}' : '';
  return '${negativo ? '-' : ''}$milhares$decimal';
}

/// Data no padrão do campo `AppDateInput` (`DD/MM/AAAA`).
String formatarData(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Hoje em `DD/MM/AAAA` — valor inicial dos campos de data de evento: quase
/// sempre o lançamento é do próprio dia, e digitar data é o passo mais lento.
String hojeFormatado() => formatarData(DateTime.now());

/// Lê um número digitado em campo (`12,5` ou `12.5`). `null` se inválido.
num? lerNumero(String texto) =>
    num.tryParse(texto.trim().replaceAll('.', '').replaceAll(',', '.')) ??
    num.tryParse(texto.trim());

// ---------------------------------------------------------------------------
// Produtos — `products` (`measurement_id`, `average_cost`,
// `default_warehouse_id`).
// ---------------------------------------------------------------------------

const catalogoProdutos = <String>[
  'Ração Engorda 18%',
  'Sal Mineral Proteinado',
  'Vacina Aftosa',
  'Vermífugo Injetável',
  'Diesel S10',
  'Semente de Braquiária',
  'Fertilizante NPK 20-05-20',
  'Filtro de óleo — trator',
  'Herbicida Glifosato 480 SL',
  'Fungicida Azoxistrobina',
  'Semente de Soja TMG 2383',
  'Soja em grão',
  'Milho em grão',
];

/// `products.measurement_id` — a unidade é do produto, não de quem lança.
const unidadePorProduto = <String, String>{
  'Ração Engorda 18%': 'kg',
  'Sal Mineral Proteinado': 'kg',
  'Vacina Aftosa': 'Unidade',
  'Vermífugo Injetável': 'L',
  'Diesel S10': 'L',
  'Semente de Braquiária': 'kg',
  'Fertilizante NPK 20-05-20': 'kg',
  'Filtro de óleo — trator': 'Unidade',
  'Herbicida Glifosato 480 SL': 'L',
  'Fungicida Azoxistrobina': 'L',
  'Semente de Soja TMG 2383': 'kg',
  'Soja em grão': 'Saco',
  'Milho em grão': 'Saco',
};

/// `products.default_warehouse_id` — sugestão, a pessoa pode trocar.
const armazemPadraoPorProduto = <String, String>{
  'Ração Engorda 18%': 'Armazém A',
  'Sal Mineral Proteinado': 'Armazém A',
  'Vacina Aftosa': 'Farmácia',
  'Vermífugo Injetável': 'Farmácia',
  'Diesel S10': 'Tanque Diesel',
  'Semente de Braquiária': 'Depósito B',
  'Fertilizante NPK 20-05-20': 'Depósito B',
  'Filtro de óleo — trator': 'Depósito B',
  'Herbicida Glifosato 480 SL': 'Armazém A',
  'Fungicida Azoxistrobina': 'Armazém A',
  'Semente de Soja TMG 2383': 'Depósito B',
  'Soja em grão': 'Armazém A',
  'Milho em grão': 'Armazém A',
};

/// `products.average_cost` por unidade do produto, em texto de campo
/// (vírgula decimal) — é o que o motor genérico grava no `Map<String,String>`.
const custoMedioPorProduto = <String, String>{
  'Ração Engorda 18%': '1,85',
  'Sal Mineral Proteinado': '3,40',
  'Vacina Aftosa': '2,10',
  'Vermífugo Injetável': '96,00',
  'Diesel S10': '6,19',
  'Semente de Braquiária': '18,50',
  'Fertilizante NPK 20-05-20': '3,85',
  'Filtro de óleo — trator': '84,90',
  'Herbicida Glifosato 480 SL': '29,02',
  'Fungicida Azoxistrobina': '151,22',
  'Semente de Soja TMG 2383': '8,17',
  'Soja em grão': '128,00',
  'Milho em grão': '62,00',
};

// ---------------------------------------------------------------------------
// Itens de estoque — `stocks` (produto + armazém + lote do fornecedor, com
// saldo, validade e custo médio próprios).
// ---------------------------------------------------------------------------

class ItemEstoqueCadastro {
  const ItemEstoqueCadastro({
    required this.rotulo,
    required this.produto,
    required this.armazem,
    required this.saldo,
    required this.custoMedio,
    this.validade,
  });

  final String rotulo;
  final String produto;
  final String armazem;
  final num saldo;
  final num custoMedio;
  final String? validade;

  String get unidade => unidadePorProduto[produto]!;
}

const cadastroItensEstoque = <ItemEstoqueCadastro>[
  ItemEstoqueCadastro(
    rotulo: 'Ração Engorda 18% — Lote 2026-07-A',
    produto: 'Ração Engorda 18%',
    armazem: 'Armazém A',
    saldo: 12400,
    custoMedio: 1.82,
    validade: '30/11/2026',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Sal Mineral Proteinado — Lote 2026-06-C',
    produto: 'Sal Mineral Proteinado',
    armazem: 'Armazém A',
    saldo: 3150,
    custoMedio: 3.40,
    validade: '31/12/2026',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Vacina Aftosa — Lote 2026-09-V',
    produto: 'Vacina Aftosa',
    armazem: 'Farmácia',
    saldo: 500,
    custoMedio: 2.10,
    validade: '31/03/2027',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Vermífugo Injetável — Lote 2026-05-B',
    produto: 'Vermífugo Injetável',
    armazem: 'Farmácia',
    saldo: 18,
    custoMedio: 96,
    validade: '31/05/2027',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Diesel S10 — Lote 2026-08-A',
    produto: 'Diesel S10',
    armazem: 'Tanque Diesel',
    saldo: 14800,
    custoMedio: 6.19,
  ),
  ItemEstoqueCadastro(
    rotulo: 'Semente de Braquiária — Lote 2026-01-B',
    produto: 'Semente de Braquiária',
    armazem: 'Depósito B',
    saldo: 1200,
    custoMedio: 18.50,
    validade: '31/01/2027',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Fertilizante NPK 20-05-20 — Lote 2026-03-N',
    produto: 'Fertilizante NPK 20-05-20',
    armazem: 'Depósito B',
    saldo: 22000,
    custoMedio: 3.85,
  ),
  ItemEstoqueCadastro(
    rotulo: 'Filtro de óleo — trator — Lote 2026-02-P',
    produto: 'Filtro de óleo — trator',
    armazem: 'Depósito B',
    saldo: 6,
    custoMedio: 84.90,
  ),
  ItemEstoqueCadastro(
    rotulo: 'Herbicida Glifosato 480 SL — Lote 2026-04-H',
    produto: 'Herbicida Glifosato 480 SL',
    armazem: 'Armazém A',
    saldo: 640,
    custoMedio: 29.02,
    validade: '30/04/2028',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Fungicida Azoxistrobina — Lote 2026-02-F',
    produto: 'Fungicida Azoxistrobina',
    armazem: 'Armazém A',
    saldo: 85,
    custoMedio: 151.22,
    validade: '28/02/2028',
  ),
  ItemEstoqueCadastro(
    rotulo: 'Semente de Soja TMG 2383 — Lote 2026-08-S',
    produto: 'Semente de Soja TMG 2383',
    armazem: 'Depósito B',
    saldo: 9600,
    custoMedio: 8.17,
    validade: '31/12/2026',
  ),
];

/// Opções do campo "Item de estoque" — derivadas do cadastro acima, que é a
/// fonte (mesmos rótulos, mesma ordem).
const catalogoItensEstoque = <String>[
  'Ração Engorda 18% — Lote 2026-07-A',
  'Sal Mineral Proteinado — Lote 2026-06-C',
  'Vacina Aftosa — Lote 2026-09-V',
  'Vermífugo Injetável — Lote 2026-05-B',
  'Diesel S10 — Lote 2026-08-A',
  'Semente de Braquiária — Lote 2026-01-B',
  'Fertilizante NPK 20-05-20 — Lote 2026-03-N',
  'Filtro de óleo — trator — Lote 2026-02-P',
  'Herbicida Glifosato 480 SL — Lote 2026-04-H',
  'Fungicida Azoxistrobina — Lote 2026-02-F',
  'Semente de Soja TMG 2383 — Lote 2026-08-S',
];

/// Estoques disponíveis de cada produto — filtra "Item de estoque" pelo
/// produto escolhido (só aparecem os lotes daquele produto).
const estoquesPorProduto = <String, List<String>>{
  'Ração Engorda 18%': ['Ração Engorda 18% — Lote 2026-07-A'],
  'Sal Mineral Proteinado': ['Sal Mineral Proteinado — Lote 2026-06-C'],
  'Vacina Aftosa': ['Vacina Aftosa — Lote 2026-09-V'],
  'Vermífugo Injetável': ['Vermífugo Injetável — Lote 2026-05-B'],
  'Diesel S10': ['Diesel S10 — Lote 2026-08-A'],
  'Semente de Braquiária': ['Semente de Braquiária — Lote 2026-01-B'],
  'Fertilizante NPK 20-05-20': ['Fertilizante NPK 20-05-20 — Lote 2026-03-N'],
  'Filtro de óleo — trator': ['Filtro de óleo — trator — Lote 2026-02-P'],
  'Herbicida Glifosato 480 SL': ['Herbicida Glifosato 480 SL — Lote 2026-04-H'],
  'Fungicida Azoxistrobina': ['Fungicida Azoxistrobina — Lote 2026-02-F'],
  'Semente de Soja TMG 2383': ['Semente de Soja TMG 2383 — Lote 2026-08-S'],
  'Soja em grão': [],
  'Milho em grão': [],
};

/// `stocks.warehouse_id` — o armazém é do item de estoque, não de quem lança.
const armazemPorItemEstoque = <String, String>{
  'Ração Engorda 18% — Lote 2026-07-A': 'Armazém A',
  'Sal Mineral Proteinado — Lote 2026-06-C': 'Armazém A',
  'Vacina Aftosa — Lote 2026-09-V': 'Farmácia',
  'Vermífugo Injetável — Lote 2026-05-B': 'Farmácia',
  'Diesel S10 — Lote 2026-08-A': 'Tanque Diesel',
  'Semente de Braquiária — Lote 2026-01-B': 'Depósito B',
  'Fertilizante NPK 20-05-20 — Lote 2026-03-N': 'Depósito B',
  'Filtro de óleo — trator — Lote 2026-02-P': 'Depósito B',
  'Herbicida Glifosato 480 SL — Lote 2026-04-H': 'Armazém A',
  'Fungicida Azoxistrobina — Lote 2026-02-F': 'Armazém A',
  'Semente de Soja TMG 2383 — Lote 2026-08-S': 'Depósito B',
};

/// Unidade do item de estoque — a do produto que ele guarda.
const unidadePorItemEstoque = <String, String>{
  'Ração Engorda 18% — Lote 2026-07-A': 'kg',
  'Sal Mineral Proteinado — Lote 2026-06-C': 'kg',
  'Vacina Aftosa — Lote 2026-09-V': 'Unidade',
  'Vermífugo Injetável — Lote 2026-05-B': 'L',
  'Diesel S10 — Lote 2026-08-A': 'L',
  'Semente de Braquiária — Lote 2026-01-B': 'kg',
  'Fertilizante NPK 20-05-20 — Lote 2026-03-N': 'kg',
  'Filtro de óleo — trator — Lote 2026-02-P': 'Unidade',
  'Herbicida Glifosato 480 SL — Lote 2026-04-H': 'L',
  'Fungicida Azoxistrobina — Lote 2026-02-F': 'L',
  'Semente de Soja TMG 2383 — Lote 2026-08-S': 'kg',
};

ItemEstoqueCadastro? itemEstoquePorRotulo(String? rotulo) {
  for (final item in cadastroItensEstoque) {
    if (item.rotulo == rotulo) return item;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Equipamentos e veículos — `equipments` (`hour_meter`, `plate`,
// `vl_time_productive`) + combustível habitual dos abastecimentos.
// ---------------------------------------------------------------------------

/// Qual leitura o equipamento tem: máquina marca hora (horímetro), veículo
/// emplacado marca quilômetro (hodômetro), implemento não tem medidor próprio
/// (é puxado por outra máquina).
enum MedidorEquipamento { horimetro, hodometro, nenhum }

class EquipamentoCadastro {
  const EquipamentoCadastro({
    required this.nome,
    required this.familia,
    required this.medidor,
    required this.custoPorUnidade,
    this.leituraAtual = 0,
    this.combustivel,
    this.placa,
  });

  final String nome;
  final String familia;
  final MedidorEquipamento medidor;

  /// Última leitura do medidor (`equipments.hour_meter` / hodômetro).
  final num leituraAtual;

  /// `vl_time_productive` — custo por hora (ou por km, no veículo).
  final num custoPorUnidade;
  final String? combustivel;
  final String? placa;

  /// Unidade em que o uso do equipamento é apontado.
  String get unidadeUso =>
      medidor == MedidorEquipamento.hodometro ? 'km' : 'Hora';

  String get medidorLabel => switch (medidor) {
    MedidorEquipamento.horimetro => 'Horímetro',
    MedidorEquipamento.hodometro => 'Hodômetro',
    MedidorEquipamento.nenhum => 'Sem medidor',
  };
}

const cadastroEquipamentos = <EquipamentoCadastro>[
  EquipamentoCadastro(
    nome: 'Trator John Deere 6110',
    familia: 'Tratores',
    medidor: MedidorEquipamento.horimetro,
    leituraAtual: 1248.5,
    custoPorUnidade: 185,
    combustivel: 'Diesel S10',
  ),
  EquipamentoCadastro(
    nome: 'Colheitadeira CR7',
    familia: 'Colheitadeiras',
    medidor: MedidorEquipamento.horimetro,
    leituraAtual: 540,
    custoPorUnidade: 620,
    combustivel: 'Diesel S10',
  ),
  EquipamentoCadastro(
    nome: 'Caminhão Boiadeiro',
    familia: 'Caminhões',
    medidor: MedidorEquipamento.hodometro,
    leituraAtual: 184320,
    custoPorUnidade: 4.8,
    combustivel: 'Diesel S500',
    placa: 'QAB-1C23',
  ),
  EquipamentoCadastro(
    nome: 'Pulverizador',
    familia: 'Pulverizadores autopropelidos',
    medidor: MedidorEquipamento.horimetro,
    leituraAtual: 213,
    custoPorUnidade: 240,
    combustivel: 'Diesel S10',
  ),
  EquipamentoCadastro(
    nome: 'Grade Aradora',
    familia: 'Implementos',
    medidor: MedidorEquipamento.nenhum,
    custoPorUnidade: 60,
  ),
  EquipamentoCadastro(
    nome: 'Retroescavadeira',
    familia: 'Máquinas pesadas',
    medidor: MedidorEquipamento.horimetro,
    leituraAtual: 3410,
    custoPorUnidade: 210,
    combustivel: 'Diesel S10',
  ),
];

const catalogoEquipamentos = <String>[
  'Trator John Deere 6110',
  'Colheitadeira CR7',
  'Caminhão Boiadeiro',
  'Pulverizador',
  'Grade Aradora',
  'Retroescavadeira',
];

/// Só o que abastece — implemento sem motor não entra em abastecimento.
const catalogoEquipamentosMotorizados = <String>[
  'Trator John Deere 6110',
  'Colheitadeira CR7',
  'Caminhão Boiadeiro',
  'Pulverizador',
  'Retroescavadeira',
];

/// Combustível habitual (sugestão — 89% dos abastecimentos reais repetem o
/// combustível do equipamento; a pessoa pode trocar).
const combustivelPorEquipamento = <String, String>{
  'Trator John Deere 6110': 'Diesel S10',
  'Colheitadeira CR7': 'Diesel S10',
  'Caminhão Boiadeiro': 'Diesel S500',
  'Pulverizador': 'Diesel S10',
  'Retroescavadeira': 'Diesel S10',
};

/// Todo combustível do catálogo é medido em litro.
const unidadePorCombustivel = <String, String>{
  'Diesel S10': 'L',
  'Diesel S500': 'L',
  'Gasolina': 'L',
  'Etanol': 'L',
};

/// Última leitura de horímetro das máquinas (sugestão da leitura atual).
const horimetroAtualPorEquipamento = <String, String>{
  'Trator John Deere 6110': '1248,5',
  'Colheitadeira CR7': '540',
  'Pulverizador': '213',
  'Retroescavadeira': '3410',
};

/// Última leitura de hodômetro dos veículos emplacados.
const hodometroAtualPorEquipamento = <String, String>{
  'Caminhão Boiadeiro': '184320',
};

/// Unidade de uso apontada por equipamento (hora para máquina e implemento,
/// km para veículo).
const unidadeUsoPorEquipamento = <String, String>{
  'Trator John Deere 6110': 'Hora',
  'Colheitadeira CR7': 'Hora',
  'Caminhão Boiadeiro': 'km',
  'Pulverizador': 'Hora',
  'Grade Aradora': 'Hora',
  'Retroescavadeira': 'Hora',
};

EquipamentoCadastro? equipamentoPorNome(String? nome) {
  for (final equipamento in cadastroEquipamentos) {
    if (equipamento.nome == nome) return equipamento;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Lote agrícola — `production_cycles` + `production_cycle_areas` + `areas`.
// ---------------------------------------------------------------------------

class TalhaoCadastro {
  const TalhaoCadastro({
    required this.nome,
    required this.areaTotal,
    required this.areaProdutiva,
  });

  final String nome;

  /// `areas.total_area` (ha).
  final num areaTotal;

  /// `areas.productive_area` (ha) — sugestão de área utilizada.
  final num areaProdutiva;
}

class LoteAgricolaCadastro {
  const LoteAgricolaCadastro({
    required this.codigo,
    required this.descricao,
    required this.cultura,
    required this.variedade,
    required this.safra,
    required this.centroCusto,
    required this.inicio,
    required this.fim,
    required this.talhoes,
  });

  final String codigo;
  final String descricao;

  /// `cultivations.parent_id` — a cultura (Soja, Milho...).
  final String cultura;

  /// `cultivation_id` do ciclo — a variedade/cultivar.
  final String variedade;

  /// `harvests.description`.
  final String safra;

  /// `production_cycles.center_id` — onde os custos do apontamento caem.
  final String centroCusto;
  final String inicio;
  final String fim;
  final List<TalhaoCadastro> talhoes;

  String get rotulo => '$codigo — $descricao';

  num get areaTotal =>
      talhoes.fold<num>(0, (soma, talhao) => soma + talhao.areaTotal);
}

const cadastroLotesAgricolas = <LoteAgricolaCadastro>[
  LoteAgricolaCadastro(
    codigo: '0001',
    descricao: 'Soja Verão 25/26',
    cultura: 'Soja',
    variedade: 'TMG 2383',
    safra: '2025/2026',
    centroCusto: 'Centro Agrícola',
    inicio: '01/10/2025',
    fim: '30/04/2026',
    talhoes: [
      TalhaoCadastro(nome: 'Talhão 01', areaTotal: 42.35, areaProdutiva: 41.5),
      TalhaoCadastro(nome: 'Talhão 02', areaTotal: 65.3, areaProdutiva: 64),
    ],
  ),
  LoteAgricolaCadastro(
    codigo: '0002',
    descricao: 'Milho Safrinha 2026',
    cultura: 'Milho',
    variedade: 'DKB 360 PRO3',
    safra: '2025/2026',
    centroCusto: 'Centro Agrícola',
    inicio: '15/02/2026',
    fim: '31/08/2026',
    talhoes: [
      TalhaoCadastro(nome: 'Talhão 03', areaTotal: 38.4, areaProdutiva: 37.9),
    ],
  ),
  LoteAgricolaCadastro(
    codigo: '0003',
    descricao: 'Café Arábica 26/27',
    cultura: 'Café',
    variedade: 'Catuaí Vermelho 144',
    safra: '2026/2027',
    centroCusto: 'Centro Agrícola',
    inicio: '01/10/2026',
    fim: '30/09/2027',
    talhoes: [
      TalhaoCadastro(nome: 'Gleba Café 01', areaTotal: 31.8, areaProdutiva: 30),
      TalhaoCadastro(
        nome: 'Gleba Café 02',
        areaTotal: 17.29,
        areaProdutiva: 16,
      ),
    ],
  ),
  LoteAgricolaCadastro(
    codigo: '0004',
    descricao: 'Cana 2º corte',
    cultura: 'Cana-de-açúcar',
    variedade: 'RB867515',
    safra: '2025/2026',
    centroCusto: 'Centro Agrícola',
    inicio: '11/09/2025',
    fim: '31/08/2026',
    talhoes: [
      TalhaoCadastro(
        nome: 'Talhão 07 — Cana',
        areaTotal: 88.08,
        areaProdutiva: 88.08,
      ),
    ],
  ),
];

LoteAgricolaCadastro? loteAgricolaPorRotulo(String? rotulo) {
  for (final lote in cadastroLotesAgricolas) {
    if (lote.rotulo == rotulo) return lote;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Operação → atividades — `operation_activities`.
// ---------------------------------------------------------------------------

const atividadesPorOperacao = <String, List<String>>{
  'Preparo do Solo': ['Aração', 'Gradagem Aradora', 'Subsolagem', 'Calagem'],
  'Plantio': ['Plantio Mecanizado', 'Plantio Manual'],
  'Tratos Culturais': [
    'Capina Mecanizada',
    'Roçagem',
    'Aplicação de Herbicida',
  ],
  'Tratos Fitossanitários': [
    'Aplicação de Herbicida',
    'Aplicação de Fungicida',
    'Aplicação de Inseticida',
    'Pulverização Mecanizada',
  ],
  'Colheita': ['Colheita Mecanizada', 'Colheita Manual'],
  'Pós Colheita': ['Secagem', 'Classificação Produto', 'Beneficiamento'],
  'Armazenagem': ['Secagem', 'Classificação Produto'],
  'Conservação do Solo': ['Subsolagem', 'Calagem', 'Roçagem'],
  'Transporte': ['Transporte Interno'],
  'Outros': ['Roçagem', 'Transporte Interno'],
};

// ---------------------------------------------------------------------------
// Mão de obra — `employees`/`functions`/`providers` (custo-hora de cada um).
// ---------------------------------------------------------------------------

class ExecutorCadastro {
  const ExecutorCadastro({
    required this.nome,
    required this.custoHora,
    this.funcao,
  });

  final String nome;

  /// `vl_time_productive` (funcionário/função) ou `hour_value` (prestador).
  final num custoHora;

  /// Função do funcionário (`employees.function_id`).
  final String? funcao;
}

const cadastroFuncionarios = <ExecutorCadastro>[
  ExecutorCadastro(
    nome: 'João Oliveira',
    funcao: 'Tratorista Agrícola',
    custoHora: 28.5,
  ),
  ExecutorCadastro(
    nome: 'Maria Souza',
    funcao: 'Técnico Agrícola',
    custoHora: 42,
  ),
  ExecutorCadastro(
    nome: 'Carlos Dias',
    funcao: 'Operador de Máquinas',
    custoHora: 32,
  ),
];

const cadastroFuncoes = <ExecutorCadastro>[
  ExecutorCadastro(nome: 'Trabalhador Rural', custoHora: 14.2),
  ExecutorCadastro(nome: 'Tratorista Agrícola', custoHora: 26),
  ExecutorCadastro(nome: 'Operador de Máquinas', custoHora: 30),
  ExecutorCadastro(nome: 'Encarregado de Área', custoHora: 35),
  ExecutorCadastro(nome: 'Técnico Agrícola', custoHora: 40),
  ExecutorCadastro(nome: 'Técnico Agropecuário', custoHora: 38),
  ExecutorCadastro(nome: 'Engenheiro Agrônomo', custoHora: 85),
  ExecutorCadastro(nome: 'Auxiliar de Produção', custoHora: 16.5),
];

const cadastroPrestadores = <ExecutorCadastro>[
  ExecutorCadastro(nome: 'Agro Serviços Cerrado', custoHora: 95),
  ExecutorCadastro(nome: 'Pulverização Horizonte', custoHora: 180),
  ExecutorCadastro(nome: 'Transportes Vale Verde', custoHora: 120),
];
