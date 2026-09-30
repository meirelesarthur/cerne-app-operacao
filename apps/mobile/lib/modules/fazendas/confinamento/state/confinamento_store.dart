import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks.dart' as mocks;
import '../models.dart';

/// Store do submódulo Confinamento — guarda em memória tudo que o
/// Operacional lança em campo (situação de curral, bateladas, trato diário,
/// leituras de cocho, confirmação de ordens). Sem backend: mesmo padrão de
/// `fazendas_store.dart`/`prototype_records_store.dart` (protótipo frontend).
///
/// O que o escritório cadastra no web chega aqui como dado de leitura; o
/// store só guarda o que o campo lança.
class ConfinamentoState {
  const ConfinamentoState({
    required this.currais,
    required this.bateladas,
    required this.tratosDiarios,
    required this.leiturasCocho,
  });

  final List<CurralInfo> currais;
  final List<Batelada> bateladas;
  final List<TratoDiario> tratosDiarios;
  final List<LeituraCocho> leiturasCocho;

  ConfinamentoState copyWith({
    List<CurralInfo>? currais,
    List<Batelada>? bateladas,
    List<TratoDiario>? tratosDiarios,
    List<LeituraCocho>? leiturasCocho,
  }) {
    return ConfinamentoState(
      currais: currais ?? this.currais,
      bateladas: bateladas ?? this.bateladas,
      tratosDiarios: tratosDiarios ?? this.tratosDiarios,
      leiturasCocho: leiturasCocho ?? this.leiturasCocho,
    );
  }
}

final confinamentoStoreProvider =
    NotifierProvider<ConfinamentoStoreNotifier, ConfinamentoState>(
      ConfinamentoStoreNotifier.new,
    );

class ConfinamentoStoreNotifier extends Notifier<ConfinamentoState> {
  @override
  ConfinamentoState build() {
    return ConfinamentoState(
      currais: List.of(mocks.currais),
      bateladas: [mocks.bateladaConcluida],
      tratosDiarios: [mocks.tratoDiarioEmAndamento],
      leiturasCocho: [mocks.leituraCochoRecente],
    );
  }

  CurralInfo curralById(String id) =>
      state.currais.firstWhere((c) => c.id == id);

  /// "Alterar Situação" (spec §3.3) — ação rápida disponível ao Operacional
  /// no seu próprio setor, independente do cadastro completo (que é do web).
  void alterarSituacaoCurral(
    String curralId,
    CurralSituacao novaSituacao, {
    DateTime? liberacaoEm,
  }) {
    state = state.copyWith(
      currais: [
        for (final c in state.currais)
          if (c.id == curralId)
            c.copyWith(
              situacao: novaSituacao,
              liberacaoEm: liberacaoEm,
              clearLiberacao: !novaSituacao.temLiberacaoPrevista,
            )
          else
            c,
      ],
    );
  }

  /// Produzir Batelada (spec §4.3) — a escala dos ingredientes já vem
  /// calculada pela tela (regra: quantidade original × produzida ÷
  /// referência); aqui só persiste o registro com o previsto e o realizado
  /// informado pelo operador.
  void registrarBatelada(Batelada batelada) {
    state = state.copyWith(bateladas: [...state.bateladas, batelada]);
  }

  /// Trato Diário — registra o fornecido a um curral elegível e, quando
  /// `concluir` é true, marca o lançamento como concluído (spec §4.4).
  void registrarFornecimento(
    String tratoId,
    String curralId,
    double quantidadeFornecida, {
    bool concluir = false,
  }) {
    state = state.copyWith(
      tratosDiarios: [
        for (final t in state.tratosDiarios)
          if (t.id == tratoId)
            TratoDiario(
              id: t.id,
              bateladaId: t.bateladaId,
              lancamentos: [
                for (final l in t.lancamentos)
                  if (l.curralId == curralId)
                    l.copyWith(
                      quantidadeFornecida: quantidadeFornecida,
                      concluido: concluir,
                    )
                  else
                    l,
              ],
            )
          else
            t,
      ],
    );
  }

  void iniciarTratoDiario(TratoDiario trato) {
    state = state.copyWith(tratosDiarios: [...state.tratosDiarios, trato]);
  }

  /// Leitura de Cocho (spec §4.5) — grava a leitura completa (todos os
  /// currais e ocorrências incluídos na sessão de leitura).
  void registrarLeituraCocho(LeituraCocho leitura) {
    state = state.copyWith(leiturasCocho: [...state.leiturasCocho, leitura]);
  }
}
