import 'models.dart';

/// Nove OS de amostra cobrindo os seis estados do ciclo de vida e variando
/// tipo de serviço, fazenda, prioridade e recursos internamente cadastrados
/// — mesmo padrão de fidelidade dos mocks de Confinamento
/// (`confinamento/mocks.dart`), para o Operacional ver
/// dados equivalentes ao que a OS carregaria vindo do app web.
final List<OrdemServico> ordensServico = [
  // 1) Aguardando — ainda não iniciada, elegível a cancelamento pelo escritório.
  OrdemServico(
    id: 'os-2201',
    codigo: 'OS #2201',
    titulo: 'Reparo de cerca do Talhão 04',
    tipo: TipoServicoOs.agricola,
    fazenda: 'Fazenda São Pedro',
    areaOuTalhao: 'Talhão 04',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataSolicitacao: DateTime(2026, 9, 12, 8, 30),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 12, 14, 10),
    prioridade: PrioridadeOs.alta,
    prazo: DateTime(2026, 9, 19),
    descricao:
        'Trecho de 180 m de cerca derrubado por queda de árvore na divisa '
        'com o Talhão 05. Substituir 12 mourões e esticar 3 fios de arame liso.',
    instrucoesSeguranca:
        'Uso obrigatório de luvas de raspa e óculos de proteção ao manusear '
        'arame sob tensão. Isolar a área de acesso do rebanho antes de iniciar.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'João Oliveira',
        funcao: 'Encarregado',
        quantidade: 16,
        unidade: 'h',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Pedro Alves',
        funcao: 'Auxiliar de campo',
        quantidade: 16,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Trator MF 4275',
        quantidade: 6,
        unidade: 'h',
        identificacao: 'TR-01',
        operador: 'Pedro Alves',
      ),
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Cravador de mourão',
        quantidade: 6,
        unidade: 'h',
        identificacao: 'IM-07',
        operador: 'Pedro Alves',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Sede São Pedro',
    insumos: const [
      InsumoOs(
        produto: 'Mourão de eucalipto tratado 2,2 m',
        unidadeMedida: 'un.',
        estoque: 48,
        quantidadeTotal: 12,
      ),
      InsumoOs(
        produto: 'Arame liso nº 12',
        unidadeMedida: 'm',
        estoque: 1500,
        quantidadeTotal: 200,
      ),
      InsumoOs(
        produto: 'Grampo galvanizado',
        unidadeMedida: 'kg',
        estoque: 18.5,
        quantidadeTotal: 2,
      ),
    ],
    armazemProducao: 'Armazém de Produção — Pátio de lenha',
    producao: const [
      ProducaoOs(
        produto: 'Lenha de eucalipto',
        unidadeMedida: 'm³',
        quantidade: 2,
        observacao:
            'Madeira da árvore caída sobre a cerca, cortada e empilhada.',
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Luva de raspa',
        quantidade: 1,
        certificadoAprovacao: 'CA 32.456',
        uso: 'Ao manusear arame sob tensão',
      ),
      EpiOs(
        nome: 'Óculos de proteção',
        quantidade: 1,
        certificadoAprovacao: 'CA 11.268',
        uso: 'Durante todo o serviço',
      ),
      EpiOs(
        nome: 'Bota de segurança',
        quantidade: 1,
        certificadoAprovacao: 'CA 40.377',
      ),
    ],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'João Oliveira',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 8, 30),
        autor: 'Maria Fernandes',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 14, 10),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
        observacao:
            'Recursos alocados: 2 colaboradores, 1 trator, insumos de cerca.',
      ),
    ],
  ),

  // 2) Em execução, com evidências registradas — ainda cancelável.
  OrdemServico(
    id: 'os-2198',
    codigo: 'OS #2198',
    titulo: 'Vacinação contra aftosa — Lote 12',
    tipo: TipoServicoOs.pecuario,
    fazenda: 'Fazenda Santa Rita',
    areaOuTalhao: 'Curral de manejo 2',
    solicitante: 'Roberto Lima — Médico Veterinário',
    dataSolicitacao: DateTime(2026, 9, 8, 7),
    autorizador: 'Ana Beatriz — Gerente Administrativa',
    dataAutorizacao: DateTime(2026, 9, 8, 9, 15),
    prioridade: PrioridadeOs.media,
    prazo: DateTime(2026, 9, 18),
    descricao:
        'Aplicar dose de reforço da vacina contra febre aftosa em 214 animais '
        'do Lote 12, com registro individual por brinco no boletim sanitário.',
    instrucoesSeguranca:
        'Contenção no tronco de manejo antes de cada aplicação. Descarte de '
        'agulhas em coletor perfurocortante; nunca reencapar.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'João Oliveira',
        funcao: 'Encarregado',
        quantidade: 2,
        unidade: 'diárias',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Fabiana Rocha',
        funcao: 'Auxiliar veterinária',
        quantidade: 2,
        unidade: 'diárias',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Tronco de contenção móvel',
        quantidade: 12,
        unidade: 'h',
        identificacao: 'IM-12',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Santa Rita',
    insumos: const [
      InsumoOs(
        produto: 'Vacina Aftosa (lote VA-2026-08)',
        unidadeMedida: 'dose',
        estoque: 640,
        quantidadeTotal: 220,
      ),
      InsumoOs(
        produto: 'Seringa dosadora 50 ml',
        unidadeMedida: 'un.',
        estoque: 11,
        quantidadeTotal: 4,
      ),
      InsumoOs(
        produto: 'Agulha 15x18 descartável',
        unidadeMedida: 'un.',
        estoque: 380,
        quantidadeTotal: 60,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Luva de procedimento',
        quantidade: 4,
        certificadoAprovacao: 'CA 38.941',
        uso: 'Trocar a cada 50 animais',
      ),
      EpiOs(
        nome: 'Avental impermeável',
        quantidade: 1,
        certificadoAprovacao: 'CA 29.710',
      ),
      EpiOs(
        nome: 'Bota de segurança',
        quantidade: 1,
        certificadoAprovacao: 'CA 40.377',
      ),
    ],
    status: OrdemServicoStatus.emExecucao,
    responsavelExecucao: 'João Oliveira',
    dataInicio: DateTime(2026, 9, 14, 7, 20),
    evidencias: [
      EvidenciaOs(
        legenda: 'Boletim sanitário parcial — 96 de 214 animais vacinados',
        dataHora: DateTime(2026, 9, 14, 11, 45),
        autor: 'João Oliveira',
        observacao:
            'Faltam os lotes do retiro; o restante fica para amanhã cedo, antes do calor.',
      ),
      EvidenciaOs(
        legenda: 'Foto do lote de vacina e temperatura da caixa térmica',
        dataHora: DateTime(2026, 9, 14, 7, 25),
        autor: 'Fabiana Rocha',
        observacao:
            'Caixa térmica a 5 °C na abertura, dentro da faixa de 2 °C a 8 °C.',
      ),
    ],
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 8, 7),
        autor: 'Roberto Lima',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 8, 9, 15),
        autor: 'Ana Beatriz',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 14, 7, 20),
        autor: 'João Oliveira',
        acao: 'Execução iniciada',
      ),
    ],
  ),

  // 3) Pausada — motivo de pausa registrado pelo Operacional.
  OrdemServico(
    id: 'os-2185',
    codigo: 'OS #2185',
    titulo: 'Manutenção do trator John Deere 6110',
    tipo: TipoServicoOs.manutencao,
    fazenda: 'Fazenda São Pedro',
    areaOuTalhao: 'Oficina mecânica',
    solicitante: 'Pedro Alves — Auxiliar de campo',
    dataSolicitacao: DateTime(2026, 9, 5, 16),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 6, 8),
    prioridade: PrioridadeOs.alta,
    prazo: DateTime(2026, 9, 20),
    descricao:
        'Troca de óleo, filtros e correia do trator John Deere 6110 (placa '
        'interna TR-03), com ruído anormal reportado na tomada de força.',
    instrucoesSeguranca:
        'Bloquear a chave de partida durante a intervenção (procedimento '
        'lockout/tagout). Motor frio antes de abrir o sistema de arrefecimento.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Sérgio Nunes',
        funcao: 'Mecânico',
        quantidade: 6,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Trator John Deere 6110',
        quantidade: 1,
        unidade: 'h',
        identificacao: 'TR-03',
        operador: 'Sérgio Nunes',
      ),
    ],
    armazemInsumos: 'Almoxarifado da oficina',
    insumos: const [
      InsumoOs(
        produto: 'Óleo 15W-40',
        unidadeMedida: 'L',
        estoque: 64,
        quantidadeTotal: 20,
      ),
      InsumoOs(
        produto: 'Filtro de óleo JD RE504836',
        unidadeMedida: 'un.',
        estoque: 3,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Filtro de ar JD RE198533',
        unidadeMedida: 'un.',
        estoque: 2,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Correia da TDP',
        unidadeMedida: 'un.',
        estoque: 0,
        quantidadeTotal: 1,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Luva de raspa',
        quantidade: 1,
        certificadoAprovacao: 'CA 32.456',
      ),
      EpiOs(
        nome: 'Óculos de proteção',
        quantidade: 1,
        certificadoAprovacao: 'CA 11.268',
      ),
      EpiOs(
        nome: 'Protetor auricular',
        quantidade: 1,
        certificadoAprovacao: 'CA 5.745',
        uso: 'Com o motor ligado',
      ),
    ],
    status: OrdemServicoStatus.pausada,
    responsavelExecucao: 'Sérgio Nunes',
    dataInicio: DateTime(2026, 9, 15, 8),
    dataPausa: DateTime(2026, 9, 15, 10, 30),
    motivoPausa:
        'Correia da tomada de força fora do estoque local — aguardando envio do almoxarifado central.',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 5, 16),
        autor: 'Pedro Alves',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 6, 8),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 15, 8),
        autor: 'Sérgio Nunes',
        acao: 'Execução iniciada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 15, 10, 30),
        autor: 'Sérgio Nunes',
        acao: 'Execução pausada',
        observacao:
            'Correia da tomada de força fora do estoque local — aguardando almoxarifado central.',
      ),
    ],
  ),

  // 4) Entregue — encerrada com sucesso pelo Operacional; escritório só visualiza.
  OrdemServico(
    id: 'os-2170',
    codigo: 'OS #2170',
    titulo: 'Construção de bebedouro no Piquete 07',
    tipo: TipoServicoOs.infraestrutura,
    fazenda: 'Fazenda Boa Vista',
    areaOuTalhao: 'Piquete 07',
    solicitante: 'Ana Beatriz — Gerente Administrativa',
    dataSolicitacao: DateTime(2026, 8, 28, 9),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 8, 28, 15, 40),
    prioridade: PrioridadeOs.media,
    prazo: DateTime(2026, 9, 10),
    descricao:
        'Instalar bebedouro de 1.000 L com boia automática e base de concreto '
        'no Piquete 07, atendendo o novo lote de recria transferido para a área.',
    instrucoesSeguranca:
        'Sinalizar a escavação durante a obra. Uso de capacete ao operar a '
        'betoneira e cinto de segurança na montagem da estrutura elevada.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Sérgio Nunes',
        funcao: 'Mecânico',
        quantidade: 3,
        unidade: 'diárias',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'João Oliveira',
        funcao: 'Encarregado',
        quantidade: 3,
        unidade: 'diárias',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Betoneira 400 L',
        quantidade: 10,
        unidade: 'h',
        identificacao: 'EQ-04',
        operador: 'João Oliveira',
      ),
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Trator MF 4275',
        quantidade: 4,
        unidade: 'h',
        identificacao: 'TR-01',
        operador: 'Sérgio Nunes',
      ),
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Carreta basculante 4 t',
        quantidade: 4,
        unidade: 'h',
        identificacao: 'IM-02',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Boa Vista',
    insumos: const [
      InsumoOs(
        produto: 'Bebedouro 1.000 L com boia',
        unidadeMedida: 'un.',
        estoque: 3,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Cimento CP-II 50 kg',
        unidadeMedida: 'saco',
        estoque: 42,
        quantidadeTotal: 6,
      ),
      InsumoOs(
        produto: 'Brita nº 1',
        unidadeMedida: 'm³',
        estoque: 8,
        quantidadeTotal: 0.5,
      ),
      InsumoOs(
        produto: 'Areia média',
        unidadeMedida: 'm³',
        estoque: 12,
        quantidadeTotal: 0.5,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Capacete',
        quantidade: 1,
        certificadoAprovacao: 'CA 31.469',
        uso: 'Ao operar a betoneira',
      ),
      EpiOs(
        nome: 'Luva de raspa',
        quantidade: 1,
        certificadoAprovacao: 'CA 32.456',
      ),
      EpiOs(
        nome: 'Bota de segurança',
        quantidade: 1,
        certificadoAprovacao: 'CA 40.377',
      ),
      EpiOs(
        nome: 'Cinto de segurança tipo paraquedista',
        quantidade: 1,
        certificadoAprovacao: 'CA 35.529',
        uso: 'Na montagem da estrutura elevada',
      ),
    ],
    status: OrdemServicoStatus.entregue,
    responsavelExecucao: 'Sérgio Nunes',
    dataInicio: DateTime(2026, 9, 8, 7, 30),
    dataEntrega: DateTime(2026, 9, 10, 16, 45),
    evidencias: [
      EvidenciaOs(
        legenda: 'Base de concreto curada e bebedouro nivelado',
        dataHora: DateTime(2026, 9, 10, 16),
        autor: 'Sérgio Nunes',
      ),
      EvidenciaOs(
        legenda: 'Teste da boia automática com reservatório cheio',
        dataHora: DateTime(2026, 9, 10, 16, 30),
        autor: 'João Oliveira',
      ),
    ],
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 8, 28, 9),
        autor: 'Ana Beatriz',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 8, 28, 15, 40),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 8, 7, 30),
        autor: 'Sérgio Nunes',
        acao: 'Execução iniciada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 10, 16, 45),
        autor: 'Sérgio Nunes',
        acao: 'OS marcada como entregue',
      ),
    ],
  ),

  // 5) Refeita — encerrada pelo Operacional com justificativa de retrabalho.
  OrdemServico(
    id: 'os-2160',
    codigo: 'OS #2160',
    titulo: 'Contenção emergencial de gado solto — Estrada vicinal',
    tipo: TipoServicoOs.pecuario,
    fazenda: 'Fazenda Santa Rita',
    areaOuTalhao: 'Divisa com a estrada vicinal km 4',
    solicitante: 'Roberto Lima — Médico Veterinário',
    dataSolicitacao: DateTime(2026, 9, 2, 6, 45),
    autorizador: 'Ana Beatriz — Gerente Administrativa',
    dataAutorizacao: DateTime(2026, 9, 2, 7, 10),
    prioridade: PrioridadeOs.urgente,
    prazo: DateTime(2026, 9, 3),
    descricao:
        'Recolher 18 cabeças do Lote 09 que romperam a cerca em direção à '
        'estrada vicinal e montar contenção provisória até o reparo definitivo.',
    instrucoesSeguranca:
        'Sinalização com cones na estrada durante o recolhimento. Nenhum '
        'colaborador entra na pista sem colete refletivo.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'João Oliveira',
        funcao: 'Encarregado',
        quantidade: 10,
        unidade: 'h',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Fabiana Rocha',
        funcao: 'Auxiliar veterinária',
        quantidade: 10,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Camionete de apoio Hilux',
        quantidade: 80,
        unidade: 'km',
        identificacao: 'VE-02',
        operador: 'João Oliveira',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Santa Rita',
    insumos: const [
      InsumoOs(
        produto: 'Fita para cerca elétrica provisória',
        unidadeMedida: 'm',
        estoque: 600,
        quantidadeTotal: 150,
      ),
      InsumoOs(
        produto: 'Haste isoladora',
        unidadeMedida: 'un.',
        estoque: 120,
        quantidadeTotal: 40,
      ),
      InsumoOs(
        produto: 'Cone de sinalização 75 cm',
        unidadeMedida: 'un.',
        estoque: 16,
        quantidadeTotal: 8,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Colete refletivo',
        quantidade: 1,
        certificadoAprovacao: 'CA 42.117',
        uso: 'Obrigatório na pista',
      ),
      EpiOs(
        nome: 'Luva de raspa',
        quantidade: 1,
        certificadoAprovacao: 'CA 32.456',
      ),
      EpiOs(
        nome: 'Bota de segurança',
        quantidade: 1,
        certificadoAprovacao: 'CA 40.377',
      ),
    ],
    status: OrdemServicoStatus.refeita,
    responsavelExecucao: 'João Oliveira',
    dataInicio: DateTime(2026, 9, 2, 7, 20),
    justificativaRefazer:
        'Cerca elétrica provisória não resistiu à chuva da noite seguinte e o '
        'lote voltou a se aproximar da estrada — necessário refazer com '
        'mourões fixos e fio de arame reforçado em vez de fita provisória.',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 2, 6, 45),
        autor: 'Roberto Lima',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 2, 7, 10),
        autor: 'Ana Beatriz',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 2, 7, 20),
        autor: 'João Oliveira',
        acao: 'Execução iniciada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 3, 6, 30),
        autor: 'João Oliveira',
        acao: 'OS marcada como refeita',
        observacao:
            'Cerca provisória não resistiu à chuva — necessário refazer com fixação reforçada.',
      ),
    ],
  ),

  // 6) Aguardando — urgente, a próxima da fila depois das já iniciadas.
  OrdemServico(
    id: 'os-2207',
    codigo: 'OS #2207',
    titulo: 'Vazamento na caixa d’água do Curral 12',
    tipo: TipoServicoOs.infraestrutura,
    fazenda: 'Fazenda São Pedro',
    areaOuTalhao: 'Curral 12',
    solicitante: 'João Oliveira — Encarregado',
    dataSolicitacao: DateTime(2026, 9, 22, 6, 40),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 22, 7, 5),
    prioridade: PrioridadeOs.urgente,
    prazo: DateTime(2026, 9, 24),
    descricao:
        'Boia travada e trinca na base da caixa d’água de 5.000 L que abastece '
        'os bebedouros do Curral 12. Trocar a boia e vedar a trinca.',
    instrucoesSeguranca:
        'Fechar o registro geral antes de subir. Escada presa na estrutura e '
        'um colaborador segurando embaixo o tempo todo.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Pedro Alves',
        funcao: 'Auxiliar de campo',
        quantidade: 4,
        unidade: 'h',
      ),
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Sérgio Nunes',
        funcao: 'Mecânico',
        quantidade: 4,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Escada extensível 7 m',
        quantidade: 4,
        unidade: 'h',
        identificacao: 'EQ-09',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Sede São Pedro',
    insumos: const [
      InsumoOs(
        produto: 'Boia 3/4"',
        unidadeMedida: 'un.',
        estoque: 5,
        quantidadeTotal: 1,
      ),
      InsumoOs(
        produto: 'Massa epóxi para vedação',
        unidadeMedida: 'un.',
        estoque: 9,
        quantidadeTotal: 2,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Cinto de segurança tipo paraquedista',
        quantidade: 1,
        certificadoAprovacao: 'CA 35.529',
        uso: 'Acima de 2 m de altura',
      ),
      EpiOs(
        nome: 'Luva de raspa',
        quantidade: 1,
        certificadoAprovacao: 'CA 32.456',
      ),
      EpiOs(
        nome: 'Bota de segurança',
        quantidade: 1,
        certificadoAprovacao: 'CA 40.377',
      ),
    ],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'Pedro Alves',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 22, 6, 40),
        autor: 'João Oliveira',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 22, 7, 5),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
    ],
  ),

  // 7) Aguardando — média.
  OrdemServico(
    id: 'os-2204',
    codigo: 'OS #2204',
    titulo: 'Roçada do Piquete 03',
    tipo: TipoServicoOs.agricola,
    fazenda: 'Fazenda Boa Vista',
    areaOuTalhao: 'Piquete 03',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataSolicitacao: DateTime(2026, 9, 19, 10),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 19, 16, 20),
    prioridade: PrioridadeOs.media,
    prazo: DateTime(2026, 9, 27),
    descricao:
        'Roçar 6 ha de pasto com excesso de capim-colonião antes da entrada '
        'do Lote 04. Manter a altura de corte em 20 cm.',
    instrucoesSeguranca:
        'Retirar o gado do piquete antes de iniciar. Ninguém a menos de 30 m '
        'da roçadeira em funcionamento.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Pedro Alves',
        funcao: 'Operador de máquinas',
        quantidade: 8,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Trator MF 4275',
        quantidade: 7,
        unidade: 'h',
        identificacao: 'TR-01',
        operador: 'Pedro Alves',
      ),
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Roçadeira hidráulica 1,7 m',
        quantidade: 7,
        unidade: 'h',
        identificacao: 'IM-04',
        operador: 'Pedro Alves',
      ),
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Enfardadora de feno',
        quantidade: 4,
        unidade: 'h',
        identificacao: 'IM-09',
        operador: 'Pedro Alves',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Boa Vista',
    insumos: const [
      InsumoOs(
        produto: 'Óleo diesel S10',
        unidadeMedida: 'L',
        estoque: 1850,
        quantidadeTotal: 60,
        quantidadePorHa: 10,
      ),
      InsumoOs(
        produto: 'Barbante para enfardadora',
        unidadeMedida: 'rolo',
        estoque: 14,
        quantidadeTotal: 2,
      ),
    ],
    armazemProducao: 'Armazém de Produção — Galpão de feno',
    producao: const [
      ProducaoOs(
        produto: 'Feno de capim-colonião',
        unidadeMedida: 'fardo',
        quantidade: 120,
        observacao: 'Enfardar só com o capim seco; fardos de cerca de 20 kg.',
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Protetor auricular',
        quantidade: 1,
        certificadoAprovacao: 'CA 5.745',
        uso: 'Com a roçadeira ligada',
      ),
      EpiOs(
        nome: 'Óculos de proteção',
        quantidade: 1,
        certificadoAprovacao: 'CA 11.268',
      ),
      EpiOs(
        nome: 'Bota de segurança',
        quantidade: 1,
        certificadoAprovacao: 'CA 40.377',
      ),
    ],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'Pedro Alves',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 19, 10),
        autor: 'Maria Fernandes',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 19, 16, 20),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
    ],
  ),

  // 8) Aguardando — baixa, prazo folgado.
  OrdemServico(
    id: 'os-2209',
    codigo: 'OS #2209',
    titulo: 'Limpeza das calhas do galpão de insumos',
    tipo: TipoServicoOs.manutencao,
    fazenda: 'Fazenda São Pedro',
    areaOuTalhao: 'Galpão de insumos',
    solicitante: 'Ana Beatriz — Gerente Administrativa',
    dataSolicitacao: DateTime(2026, 9, 21, 14),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 22, 8),
    prioridade: PrioridadeOs.baixa,
    prazo: DateTime(2026, 10, 3),
    descricao:
        'Retirar folhas e barro das calhas antes do período de chuva para '
        'evitar infiltração sobre os sacos de ração.',
    instrucoesSeguranca:
        'Trabalho em altura: usar cinto preso à linha de vida. Não subir com '
        'telhado molhado.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Fabiana Rocha',
        funcao: 'Auxiliar',
        quantidade: 4,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Escada extensível 7 m',
        quantidade: 4,
        unidade: 'h',
        identificacao: 'EQ-09',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Sede São Pedro',
    insumos: const [
      InsumoOs(
        produto: 'Saco de lixo 100 L',
        unidadeMedida: 'un.',
        estoque: 85,
        quantidadeTotal: 10,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Cinto de segurança tipo paraquedista',
        quantidade: 1,
        certificadoAprovacao: 'CA 35.529',
        uso: 'Preso à linha de vida',
      ),
      EpiOs(
        nome: 'Luva de raspa',
        quantidade: 1,
        certificadoAprovacao: 'CA 32.456',
      ),
      EpiOs(nome: 'Capacete', quantidade: 1, certificadoAprovacao: 'CA 31.469'),
    ],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'Fabiana Rocha',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 21, 14),
        autor: 'Ana Beatriz',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 22, 8),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
    ],
  ),

  // 9) Cancelada — o escritório cancelou antes do início.
  OrdemServico(
    id: 'os-2192',
    codigo: 'OS #2192',
    titulo: 'Aplicação de herbicida no Talhão 09',
    tipo: TipoServicoOs.agricola,
    fazenda: 'Fazenda Santa Rita',
    areaOuTalhao: 'Talhão 09',
    solicitante: 'Maria Fernandes — Supervisora de Campo',
    dataSolicitacao: DateTime(2026, 9, 10, 9),
    autorizador: 'Carlos Menezes — Gerente Operacional',
    dataAutorizacao: DateTime(2026, 9, 10, 11),
    prioridade: PrioridadeOs.media,
    prazo: DateTime(2026, 9, 16),
    descricao:
        'Aplicação de herbicida pré-emergente em 22 ha antes do plantio do '
        'milho safrinha.',
    instrucoesSeguranca:
        'Aplicar só com vento abaixo de 10 km/h. Máscara com filtro químico e '
        'macacão impermeável durante todo o preparo da calda.',
    maoDeObra: const [
      MaoDeObraOs(
        tipo: TipoMaoDeObraOs.funcionario,
        nome: 'Pedro Alves',
        funcao: 'Operador de máquinas',
        quantidade: 8,
        unidade: 'h',
      ),
    ],
    maquinas: const [
      MaquinaOs(
        tipo: TipoMaquinaOs.maquina,
        nome: 'Trator MF 4275',
        quantidade: 8,
        unidade: 'h',
        identificacao: 'TR-01',
        operador: 'Pedro Alves',
      ),
      MaquinaOs(
        tipo: TipoMaquinaOs.implemento,
        nome: 'Pulverizador Jacto 2000 L',
        quantidade: 8,
        unidade: 'h',
        identificacao: 'IM-01',
        operador: 'Pedro Alves',
      ),
    ],
    armazemInsumos: 'Armazém Insumos — Santa Rita',
    insumos: const [
      InsumoOs(
        produto: 'Herbicida pré-emergente',
        unidadeMedida: 'L',
        estoque: 7.02,
        quantidadeTotal: 44,
        quantidadePorHa: 2,
      ),
      InsumoOs(
        produto: 'Óleo diesel S10',
        unidadeMedida: 'L',
        estoque: 1850,
        quantidadeTotal: 90,
        quantidadePorHa: 4.09,
      ),
    ],
    epis: const [
      EpiOs(
        nome: 'Máscara com filtro químico',
        quantidade: 1,
        certificadoAprovacao: 'CA 7.071',
        uso: 'Durante o preparo da calda e a aplicação',
      ),
      EpiOs(
        nome: 'Macacão impermeável',
        quantidade: 1,
        certificadoAprovacao: 'CA 27.332',
      ),
      EpiOs(
        nome: 'Luva nitrílica',
        quantidade: 2,
        certificadoAprovacao: 'CA 28.017',
      ),
    ],
    status: OrdemServicoStatus.cancelada,
    responsavelExecucao: 'Pedro Alves',
    motivoCancelamento:
        'Chuva prevista para a semana toda; aplicação remarcada em nova OS.',
    historico: [
      EventoOs(
        dataHora: DateTime(2026, 9, 10, 9),
        autor: 'Maria Fernandes',
        acao: 'OS solicitada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 10, 11),
        autor: 'Carlos Menezes',
        acao: 'OS autorizada',
      ),
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 8),
        autor: 'Carlos Menezes',
        acao: 'OS cancelada',
        observacao: 'Chuva prevista para a semana toda.',
      ),
    ],
  ),
];
