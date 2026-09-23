import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks.dart' as mocks;
import '../models.dart';

/// Store de Ordem de Serviço — guarda em memória o que o Operacional lança
/// (iniciar/pausar/retomar/entregar/refazer) e o que chega do escritório
/// (cancelamento), sem backend: mesmo padrão de
/// `confinamento/state/confinamento_store.dart` (protótipo frontend).
class OrdemServicoState {
  const OrdemServicoState({required this.ordens});

  final List<OrdemServico> ordens;

  OrdemServicoState copyWith({List<OrdemServico>? ordens}) {
    return OrdemServicoState(ordens: ordens ?? this.ordens);
  }
}

/// Relógio das telas de OS ("em execução há 2h15", "atrasada há 3 dias").
/// Provider para os testes fixarem o "agora" em vez de depender da data da
/// máquina.
final osRelogioProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final ordemServicoStoreProvider =
    NotifierProvider<OrdemServicoStoreNotifier, OrdemServicoState>(
      OrdemServicoStoreNotifier.new,
    );

class OrdemServicoStoreNotifier extends Notifier<OrdemServicoState> {
  @override
  OrdemServicoState build() {
    return OrdemServicoState(ordens: List.of(mocks.ordensServico));
  }

  OrdemServico byId(String id) => state.ordens.firstWhere((o) => o.id == id);

  void _update(String id, OrdemServico Function(OrdemServico atual) update) {
    state = state.copyWith(
      ordens: [
        for (final o in state.ordens)
          if (o.id == id) update(o) else o,
      ],
    );
  }

  /// Ação do Operacional: aguardando → em execução.
  void iniciar(String id, {required String autor}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.emExecucao,
        dataInicio: agora,
        historico: [
          ...o.historico,
          EventoOs(dataHora: agora, autor: autor, acao: 'Execução iniciada'),
        ],
      ),
    );
  }

  /// Ação do Operacional: em execução → pausada, com motivo.
  void pausar(String id, {required String autor, required String motivo}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.pausada,
        dataPausa: agora,
        motivoPausa: motivo,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'Execução pausada',
            observacao: motivo,
          ),
        ],
      ),
    );
  }

  /// Ação do Operacional: pausada → em execução novamente.
  void retomar(String id, {required String autor}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.emExecucao,
        clearMotivoPausa: true,
        historico: [
          ...o.historico,
          EventoOs(dataHora: agora, autor: autor, acao: 'Execução retomada'),
        ],
      ),
    );
  }

  /// Ação do Operacional: encerra a OS com sucesso.
  void marcarEntregue(String id, {required String autor}) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.entregue,
        dataEntrega: agora,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'OS marcada como entregue',
          ),
        ],
      ),
    );
  }

  /// Ação do Operacional: encerra a OS sinalizando retrabalho, com justificativa.
  void marcarRefeita(
    String id, {
    required String autor,
    required String justificativa,
  }) {
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.refeita,
        justificativaRefazer: justificativa,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'OS marcada como refeita',
            observacao: justificativa,
          ),
        ],
      ),
    );
  }

  /// Cancelamento feito pelo escritório (no app web) chegando ao mobile —
  /// só vale enquanto a OS não foi encerrada pelo Operacional. O app não
  /// oferece essa ação ao operador; ela existe para simular o dado que viria
  /// do banco compartilhado.
  void cancelar(String id, {required String autor, required String motivo}) {
    final atual = byId(id);
    if (atual.status.encerrada) return;
    final agora = DateTime.now();
    _update(
      id,
      (o) => o.copyWith(
        status: OrdemServicoStatus.cancelada,
        motivoCancelamento: motivo,
        historico: [
          ...o.historico,
          EventoOs(
            dataHora: agora,
            autor: autor,
            acao: 'OS cancelada',
            observacao: motivo,
          ),
        ],
      ),
    );
  }
}
