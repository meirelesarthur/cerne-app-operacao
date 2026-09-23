/// Contrato de domínio de Ordem de Serviço (OS) — a partir da especificação
/// funcional web (levantamento de 16/09/2026): planejar, autorizar, executar
/// e acompanhar serviços de campo (agrícolas/pecuários), cobrindo o ciclo
/// solicitação → detalhamento técnico/segurança → alocação de recursos (mão
/// de obra, máquinas, insumos, EPIs) → execução com evidências → conclusão.
///
/// LACUNA (premissa de protótipo): a OS nasce no app **web** — o app mobile
/// nunca cadastra uma OS nova, só recebe o que já foi solicitado/autorizado
/// por lá (mesmo padrão de Confinamento: cadastro no web, lançamento em
/// campo no mobile). Por isso não há formulário de criação aqui, só os
/// mocks que representam o que chegaria do banco compartilhado.
///
/// Decisão de perfil confirmada com o usuário:
/// - Operacional inicia, pausa/retoma e encerra a própria OS (entregue, ou
///   refeita com justificativa quando o serviço não pôde ser concluído como
///   planejado).
/// - O escritório (no app web) pode cancelar, mas só enquanto a OS ainda não
///   foi encerrada pelo Operacional (aguardando/em execução/pausada) — nunca
///   uma já entregue ou refeita. O mobile só exibe esse dado.
library;

enum TipoServicoOs { agricola, pecuario, manutencao, infraestrutura }

extension TipoServicoOsLabel on TipoServicoOs {
  String get label => switch (this) {
    TipoServicoOs.agricola => 'Agrícola',
    TipoServicoOs.pecuario => 'Pecuário',
    TipoServicoOs.manutencao => 'Manutenção',
    TipoServicoOs.infraestrutura => 'Infraestrutura',
  };
}

enum PrioridadeOs { baixa, media, alta, urgente }

extension PrioridadeOsLabel on PrioridadeOs {
  String get label => switch (this) {
    PrioridadeOs.baixa => 'Baixa',
    PrioridadeOs.media => 'Média',
    PrioridadeOs.alta => 'Alta',
    PrioridadeOs.urgente => 'Urgente',
  };
}

/// Ciclo de vida da OS. `entregue` e `refeita` são os dois encerramentos que
/// só o Operacional decide; `cancelada` só o escritório decide — e só
/// antes de um desses dois encerramentos.
enum OrdemServicoStatus {
  aguardando,
  emExecucao,
  pausada,
  entregue,
  refeita,
  cancelada,
}

extension OrdemServicoStatusLabel on OrdemServicoStatus {
  String get label => switch (this) {
    OrdemServicoStatus.aguardando => 'Aguardando',
    OrdemServicoStatus.emExecucao => 'Em execução',
    OrdemServicoStatus.pausada => 'Pausada',
    OrdemServicoStatus.entregue => 'Entregue',
    // "Refeita" soava como "já refiz" — é o contrário: o serviço volta.
    OrdemServicoStatus.refeita => 'Precisa refazer',
    OrdemServicoStatus.cancelada => 'Cancelada',
  };

  /// Só nesses três estados o Operacional ainda pode agir (iniciar, pausar,
  /// retomar, entregar, refazer) e o escritório pode cancelar.
  bool get emAndamento =>
      this == OrdemServicoStatus.aguardando ||
      this == OrdemServicoStatus.emExecucao ||
      this == OrdemServicoStatus.pausada;

  bool get encerrada => !emAndamento;
}

/// Evidência registrada pelo Operacional durante a execução (spec: "execução
/// em campo com registro de evidências"). Sem upload real no protótipo —
/// `legenda` descreve o que a foto mostraria.
class EvidenciaOs {
  const EvidenciaOs({required this.legenda, required this.dataHora});

  final String legenda;
  final DateTime dataHora;
}

/// Linha do histórico/timeline da OS — cada ação (iniciar, pausar, entregar,
/// refazer, cancelar) fica registrada aqui, auditável.
class EventoOs {
  const EventoOs({
    required this.dataHora,
    required this.autor,
    required this.acao,
    this.observacao,
  });

  final DateTime dataHora;
  final String autor;
  final String acao;
  final String? observacao;
}

class OrdemServico {
  const OrdemServico({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.tipo,
    required this.fazenda,
    required this.areaOuTalhao,
    required this.solicitante,
    required this.dataSolicitacao,
    required this.autorizador,
    required this.dataAutorizacao,
    required this.prioridade,
    required this.prazo,
    required this.descricao,
    required this.instrucoesSeguranca,
    required this.maoDeObra,
    required this.maquinas,
    required this.insumos,
    required this.epis,
    required this.status,
    required this.responsavelExecucao,
    required this.historico,
    this.dataInicio,
    this.dataPausa,
    this.motivoPausa,
    this.dataEntrega,
    this.evidencias = const [],
    this.justificativaRefazer,
    this.motivoCancelamento,
  });

  final String id;
  final String codigo;
  final String titulo;
  final TipoServicoOs tipo;
  final String fazenda;
  final String areaOuTalhao;

  final String solicitante;
  final DateTime dataSolicitacao;
  final String autorizador;
  final DateTime dataAutorizacao;

  final PrioridadeOs prioridade;
  final DateTime prazo;
  final String descricao;
  final String instrucoesSeguranca;

  /// Alocação de recursos definida na autorização (spec: mão de obra,
  /// máquinas, insumos, EPIs).
  final List<String> maoDeObra;
  final List<String> maquinas;
  final List<String> insumos;
  final List<String> epis;

  final OrdemServicoStatus status;
  final String responsavelExecucao;

  final DateTime? dataInicio;
  final DateTime? dataPausa;
  final String? motivoPausa;
  final DateTime? dataEntrega;
  final List<EvidenciaOs> evidencias;
  final String? justificativaRefazer;

  final String? motivoCancelamento;

  final List<EventoOs> historico;

  OrdemServico copyWith({
    OrdemServicoStatus? status,
    DateTime? dataInicio,
    DateTime? dataPausa,
    String? motivoPausa,
    bool clearMotivoPausa = false,
    DateTime? dataEntrega,
    List<EvidenciaOs>? evidencias,
    String? justificativaRefazer,
    String? motivoCancelamento,
    List<EventoOs>? historico,
  }) {
    return OrdemServico(
      id: id,
      codigo: codigo,
      titulo: titulo,
      tipo: tipo,
      fazenda: fazenda,
      areaOuTalhao: areaOuTalhao,
      solicitante: solicitante,
      dataSolicitacao: dataSolicitacao,
      autorizador: autorizador,
      dataAutorizacao: dataAutorizacao,
      prioridade: prioridade,
      prazo: prazo,
      descricao: descricao,
      instrucoesSeguranca: instrucoesSeguranca,
      maoDeObra: maoDeObra,
      maquinas: maquinas,
      insumos: insumos,
      epis: epis,
      status: status ?? this.status,
      responsavelExecucao: responsavelExecucao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataPausa: clearMotivoPausa ? null : (dataPausa ?? this.dataPausa),
      motivoPausa: clearMotivoPausa ? null : (motivoPausa ?? this.motivoPausa),
      dataEntrega: dataEntrega ?? this.dataEntrega,
      evidencias: evidencias ?? this.evidencias,
      justificativaRefazer: justificativaRefazer ?? this.justificativaRefazer,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      historico: historico ?? this.historico,
    );
  }
}
