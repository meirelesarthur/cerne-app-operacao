/// Mocks dos dashboards administrativos de Fazendas (spec §4) — espelha
/// `src/modules/fazendas/mocks/dashboards.ts`. Porta apenas os dados usados
/// pelos 7 dashboards administrativos (financeiro, pecuária, confinamento,
/// ativos, suprimentos, uso, consultas). Determinístico, sem `DateTime.now`.
library;

/* ---- Financeiro (§4.3) ---- */

class FinanceiroKpis {
  FinanceiroKpis._();

  static const aReceber = 'R\$ 1,82 mi';
  static const aPagar = 'R\$ 940 mil';
  static const atrasados = 'R\$ 128 mil';
  static const investimentos = 'R\$ 350 mil';
}

/// Item de despesa por centro de custo — consumido por `AppBarChart` (`AppBarDatum`).
class CentroCusto {
  const CentroCusto({required this.label, required this.value});

  final String label;
  final double value;
}

const List<CentroCusto> centrosCusto = [
  CentroCusto(label: 'Nutrição', value: 420),
  CentroCusto(label: 'Sanidade', value: 180),
  CentroCusto(label: 'Mão de obra', value: 260),
  CentroCusto(label: 'Manutenção', value: 130),
  CentroCusto(label: 'Administrativo', value: 90),
  CentroCusto(label: 'Logística', value: 150),
];

/* ---- Pecuária de Corte (§4.1) ---- */

/// Bloco financeiro do dashboard de Pecuária — consumido por `AppDashboardCard`.
class PecuariaFinanceiroItem {
  const PecuariaFinanceiroItem({required this.label, required this.value, required this.delta, required this.spark});

  final String label;
  final String value;
  final double delta;
  final List<double> spark;
}

const List<PecuariaFinanceiroItem> pecuariaFinanceiro = [
  PecuariaFinanceiroItem(label: 'Receita', value: 'R\$ 2,4 mi', delta: 12, spark: [8, 10, 9, 12, 14, 13, 16]),
  PecuariaFinanceiroItem(label: 'Custo', value: 'R\$ 1,1 mi', delta: -4, spark: [9, 8, 8, 7, 6, 7, 6]),
  PecuariaFinanceiroItem(label: 'Margem', value: 'R\$ 1,3 mi', delta: 9, spark: [4, 6, 5, 7, 8, 9, 11]),
];

/* ---- Lotação de Currais / Confinamento (§4.2) ---- */

class Curral {
  const Curral({required this.id, required this.nome, required this.setor, required this.atual, required this.max});

  final String id;
  final String nome;
  final String setor;
  final int atual;
  final int max;
}

const List<Curral> currais = [
  Curral(id: 'c1', nome: 'Curral 01', setor: 'Setor A', atual: 78, max: 100),
  Curral(id: 'c2', nome: 'Curral 02', setor: 'Setor A', atual: 95, max: 100),
  Curral(id: 'c3', nome: 'Curral 03', setor: 'Setor B', atual: 100, max: 100),
  Curral(id: 'c4', nome: 'Curral 04', setor: 'Setor B', atual: 42, max: 100),
  Curral(id: 'c5', nome: 'Curral 05', setor: 'Setor C', atual: 88, max: 100),
  Curral(id: 'c6', nome: 'Curral 06', setor: 'Setor C', atual: 60, max: 100),
  Curral(id: 'c7', nome: 'Curral 07', setor: 'Setor D', atual: 110, max: 100),
  Curral(id: 'c8', nome: 'Curral 08', setor: 'Setor D', atual: 25, max: 100),
];

/* ---- Ativos / Depreciação (§4.5) ---- */

enum AtivoEstado { ativo, manutencao }

class Ativo {
  const Ativo({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.ano,
    required this.aquisicao,
    required this.depreciado,
    required this.valorResidual,
    required this.proximaManutencao,
    required this.estado,
  });

  final String id;
  final String nome;
  final String categoria;

  /// Ano de aquisição do ativo.
  final int ano;
  final String aquisicao;
  final int depreciado;

  /// Valor residual estimado (aquisição − depreciação acumulada).
  final String valorResidual;
  final String proximaManutencao;
  final AtivoEstado estado;
}

const List<Ativo> ativos = [
  Ativo(id: 'at1', nome: 'Trator John Deere 6110', categoria: 'Máquinas', ano: 2021, aquisicao: 'R\$ 380 mil', depreciado: 45, valorResidual: 'R\$ 209 mil', proximaManutencao: '15/07', estado: AtivoEstado.ativo),
  Ativo(id: 'at2', nome: 'Colheitadeira CR7', categoria: 'Máquinas', ano: 2022, aquisicao: 'R\$ 620 mil', depreciado: 30, valorResidual: 'R\$ 434 mil', proximaManutencao: '02/08', estado: AtivoEstado.ativo),
  Ativo(id: 'at3', nome: 'Caminhão Boiadeiro', categoria: 'Veículos', ano: 2020, aquisicao: 'R\$ 240 mil', depreciado: 68, valorResidual: 'R\$ 77 mil', proximaManutencao: '20/07', estado: AtivoEstado.manutencao),
  Ativo(id: 'at4', nome: 'Balança de Curral', categoria: 'Equipamentos', ano: 2023, aquisicao: 'R\$ 45 mil', depreciado: 20, valorResidual: 'R\$ 36 mil', proximaManutencao: '10/09', estado: AtivoEstado.ativo),
  Ativo(id: 'at5', nome: 'Pivô de Irrigação', categoria: 'Infraestrutura', ano: 2019, aquisicao: 'R\$ 310 mil', depreciado: 55, valorResidual: 'R\$ 140 mil', proximaManutencao: '28/08', estado: AtivoEstado.manutencao),
  Ativo(id: 'at6', nome: 'Pulverizador Autopropelido', categoria: 'Máquinas', ano: 2022, aquisicao: 'R\$ 290 mil', depreciado: 38, valorResidual: 'R\$ 180 mil', proximaManutencao: '05/08', estado: AtivoEstado.ativo),
];

class AtivosResumo {
  AtivosResumo._();

  static const total = 'R\$ 1,88 mi';
  static const depreciacao = 'R\$ 720 mil';
  static const liquido = 'R\$ 1,16 mi';
}

/* ---- Suprimentos (§4.4) — status PARCIAL: selo "Dados de exemplo" ---- */

enum CotacaoStatus { cotacao, aprovada, recusada }

enum CotacaoTipo { produto, servico, frete, manutencao }

class Cotacao {
  const Cotacao({
    required this.id,
    required this.fornecedor,
    required this.produto,
    required this.tipo,
    required this.total,
    required this.itens,
    required this.status,
    required this.unidade,
    required this.precoAtual,
    required this.variacao,
    required this.validade,
    required this.historico,
  });

  final String id;
  final String fornecedor;

  /// Produto/serviço cotado — usado no cabeçalho do detalhe.
  final String produto;
  final CotacaoTipo tipo;
  final String total;
  final int itens;
  final CotacaoStatus status;

  /// Unidade de referência do preço unitário (ex.: "saca 40kg", "hora técnica").
  final String unidade;

  /// Preço unitário vigente, já formatado (tabular-nums na exibição).
  final String precoAtual;

  /// Variação percentual frente à cotação anterior; positivo = alta, negativo = queda.
  final double variacao;
  final String validade;

  /// Mini-histórico de preço unitário (3 pontos, mais recente por último).
  final List<double> historico;
}

const List<Cotacao> cotacoes = [
  Cotacao(id: 'q1', fornecedor: 'Agropecuária Vale', produto: 'Ração Confinamento', tipo: CotacaoTipo.produto, total: 'R\$ 48.900', itens: 12, status: CotacaoStatus.aprovada, unidade: 'saca 40kg', precoAtual: 'R\$ 118,50', variacao: -2.4, validade: '18/07', historico: [124, 121, 118.5]),
  Cotacao(id: 'q2', fornecedor: 'Nutrição Total', produto: 'Sal Mineral', tipo: CotacaoTipo.produto, total: 'R\$ 132.400', itens: 8, status: CotacaoStatus.cotacao, unidade: 'saca 25kg', precoAtual: 'R\$ 62,90', variacao: 1.8, validade: '22/07', historico: [60.4, 61.8, 62.9]),
  Cotacao(id: 'q3', fornecedor: 'TransBoi Logística', produto: 'Frete Rodoviário', tipo: CotacaoTipo.frete, total: 'R\$ 22.100', itens: 3, status: CotacaoStatus.cotacao, unidade: 'km rodado', precoAtual: 'R\$ 4,35', variacao: 3.1, validade: '15/07', historico: [4.05, 4.2, 4.35]),
  Cotacao(id: 'q4', fornecedor: 'MecAgro Serviços', produto: 'Revisão Hidráulica', tipo: CotacaoTipo.manutencao, total: 'R\$ 15.700', itens: 5, status: CotacaoStatus.recusada, unidade: 'hora técnica', precoAtual: 'R\$ 185,00', variacao: -5.6, validade: '10/07', historico: [205, 196, 185]),
  Cotacao(id: 'q5', fornecedor: 'Veterinária Campo', produto: 'Vacina Aftosa (aplicação)', tipo: CotacaoTipo.servico, total: 'R\$ 9.300', itens: 4, status: CotacaoStatus.aprovada, unidade: 'dose', precoAtual: 'R\$ 7,80', variacao: 0.9, validade: '30/07', historico: [7.6, 7.7, 7.8]),
  Cotacao(id: 'q6', fornecedor: 'Sementes Sul', produto: 'Semente Braquiária', tipo: CotacaoTipo.produto, total: 'R\$ 61.200', itens: 15, status: CotacaoStatus.cotacao, unidade: 'kg', precoAtual: 'R\$ 24,60', variacao: -3.5, validade: '25/07', historico: [26.1, 25.2, 24.6]),
];

/* ---- Análise de Uso (§4.6) ---- */

class UsuarioAtivo {
  const UsuarioAtivo({required this.nome, required this.ultimoAcesso, required this.ativo});

  final String nome;
  final String ultimoAcesso;
  final bool ativo;
}

class FazendaAtividade {
  const FazendaAtividade({required this.id, required this.nome, required this.online, required this.usuarios});

  final String id;
  final String nome;
  final int online;
  final List<UsuarioAtivo> usuarios;
}

const List<FazendaAtividade> usoFazendas = [
  FazendaAtividade(
    id: 'f1',
    nome: 'Fazenda São Pedro',
    online: 3,
    usuarios: [
      UsuarioAtivo(nome: 'João Silva', ultimoAcesso: 'há 2 min', ativo: true),
      UsuarioAtivo(nome: 'Maria Souza', ultimoAcesso: 'há 4 min', ativo: true),
      UsuarioAtivo(nome: 'Pedro Alves', ultimoAcesso: 'há 1 min', ativo: true),
      UsuarioAtivo(nome: 'Ana Lima', ultimoAcesso: 'há 3 h', ativo: false),
    ],
  ),
  FazendaAtividade(
    id: 'f2',
    nome: 'Fazenda Santa Rita',
    online: 1,
    usuarios: [
      UsuarioAtivo(nome: 'Carlos Dias', ultimoAcesso: 'há 30 s', ativo: true),
      UsuarioAtivo(nome: 'Rita Nunes', ultimoAcesso: 'ontem', ativo: false),
    ],
  ),
  FazendaAtividade(
    id: 'f3',
    nome: 'Fazenda Boa Vista',
    online: 0,
    usuarios: [UsuarioAtivo(nome: 'Luís Prado', ultimoAcesso: 'há 2 dias', ativo: false)],
  ),
];

/* ---- Consultas Gerenciais (§4.7) — read-only ---- */

class LinhaConsulta {
  const LinhaConsulta({required this.id, required this.titulo, required this.subtitulo, required this.meta});

  final String id;
  final String titulo;
  final String subtitulo;
  final String meta;
}

const List<LinhaConsulta> lotes = [
  LinhaConsulta(id: 'l1', titulo: 'Lote 42', subtitulo: '128 cabeças · 18.240 kg', meta: 'Curral 02'),
  LinhaConsulta(id: 'l2', titulo: 'Lote 19', subtitulo: '96 cabeças · 13.100 kg', meta: 'Curral 05'),
  LinhaConsulta(id: 'l3', titulo: 'Lote 07', subtitulo: '150 cabeças · 22.500 kg', meta: 'Piquete 3'),
  LinhaConsulta(id: 'l4', titulo: 'Lote 33', subtitulo: '64 cabeças · 9.800 kg', meta: 'Curral 01'),
];

const List<LinhaConsulta> estoque = [
  LinhaConsulta(id: 'e1', titulo: 'Ração Engorda', subtitulo: 'Armazém A', meta: '12.400 kg'),
  LinhaConsulta(id: 'e2', titulo: 'Sal Mineral', subtitulo: 'Armazém A', meta: '3.200 kg'),
  LinhaConsulta(id: 'e3', titulo: 'Vacina Aftosa', subtitulo: 'Farmácia', meta: '540 doses'),
  LinhaConsulta(id: 'e4', titulo: 'Herbicida', subtitulo: 'Depósito B', meta: '180 L'),
];

const List<LinhaConsulta> pesagensDia = [
  LinhaConsulta(id: 'p1', titulo: 'Lote 42', subtitulo: '128 cabeças · 142 kg/cab', meta: '07:12'),
  LinhaConsulta(id: 'p2', titulo: 'Lote 19', subtitulo: '96 cabeças · 136 kg/cab', meta: '08:03'),
  LinhaConsulta(id: 'p3', titulo: 'Lote 07', subtitulo: '150 cabeças · 150 kg/cab', meta: '09:20'),
];
