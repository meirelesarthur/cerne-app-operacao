import 'package:flutter_test/flutter_test.dart';

import 'package:cerne_app/modules/fazendas/ordem_servico/mocks.dart';
import 'package:cerne_app/modules/fazendas/ordem_servico/models.dart';

/// Recorte do catálogo do WEB (mapa de campos de 24/09/2026) usado pelos
/// mocks: Operação → Atividades.
const _atividadesPorOperacao = {
  'Construção Instalações': [
    'Construção de Cercas',
    'Construção de Cochos/Creep',
    'Construção de Currais',
    'Construção de Edificações',
    'Construção de Represas',
  ],
  'Sanidade Animal': [
    'Controle Ecto/Endoparasitas',
    'Medicamentos Terapêuticos',
    'Suplementos Minerais/Vitamínicos',
    'Vacinação',
  ],
  'Manutenção Instalações': [
    'Manutenções Cochos/Bebedouros',
    'Manutenções de Cercas',
    'Manutenções de Construções',
    'Manutenções de Currais',
    'Manutenções de Represas',
  ],
  'Manutenção Culturas Perenes': ['Manutenção Pastagens', 'Reforma Pastagens'],
  'Armazenagem': [
    'Beneficiamento',
    'Classificação',
    'Estocagem Externa',
    'Estocagem Interna',
    'Limpeza',
    'Secagem',
    'Transporte Externo',
    'Transporte Interno',
  ],
  'Tratos Fitossanitários': [
    'Aplicação de Herbicida',
    'Aplicação de Herbicida Manual',
    'Aplicação de Inseticida',
    'Aplicação de Fungicida',
  ],
};

/// Operações que o WEB esconde quando Uso = Agricultura.
const _soPecuaria = {
  'Nutrição Animal',
  'Sanidade Animal',
  'Reprodução Animal',
  'Identificação Animal',
  'Reposição de Animais',
};

void main() {
  group('mocks de OS seguem o formulário do WEB', () {
    for (final os in ordensServico) {
      test(os.codigo, () {
        final atividades = _atividadesPorOperacao[os.operacao];
        expect(atividades, isNotNull, reason: 'operação ${os.operacao}');
        expect(atividades, contains(os.atividade));

        if (os.uso == UsoOs.agricultura) {
          expect(_soPecuaria, isNot(contains(os.operacao)));
          expect(os.lote, isNull);
          expect(os.categoria, isNull);
        }
        if (os.uso == UsoOs.pecuaria) expect(os.culturaVariedade, isNull);

        expect(
          os.condicoes.temperaturaMinima,
          lessThan(os.condicoes.temperaturaMaxima),
        );
        expect(os.dataExecucao.isAfter(os.prazo), isFalse);
        // Produção só existe com armazém de produção (um por aba).
        if (os.producao.isNotEmpty) expect(os.armazemProducao, isNotNull);
        for (final insumo in os.insumos) {
          expect(insumo.quantidadeTotal, greaterThan(0));
        }
      });
    }
  });
}
