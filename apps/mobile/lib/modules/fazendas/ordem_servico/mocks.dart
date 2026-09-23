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
    maoDeObra: const ['João Oliveira — Encarregado', 'Pedro Alves — Auxiliar de campo'],
    maquinas: const ['Trator MF 4275 (cravador de mourão)'],
    insumos: const ['12 mourões de eucalipto tratado', 'Arame liso nº 12 — 200 m', 'Grampos galvanizados — 2 kg'],
    epis: const ['Luva de raspa', 'Óculos de proteção', 'Bota de segurança'],
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
        observacao: 'Recursos alocados: 2 colaboradores, 1 trator, insumos de cerca.',
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
    maoDeObra: const ['João Oliveira — Encarregado', 'Fabiana Rocha — Auxiliar veterinária'],
    maquinas: const ['Tronco de contenção móvel'],
    insumos: const ['Vacina Aftosa (lote VA-2026-08) — 220 doses', 'Seringas dosadoras — 4 un.'],
    epis: const ['Luva de procedimento', 'Avental impermeável', 'Bota de segurança'],
    status: OrdemServicoStatus.emExecucao,
    responsavelExecucao: 'João Oliveira',
    dataInicio: DateTime(2026, 9, 14, 7, 20),
    evidencias: [
      EvidenciaOs(
        legenda: 'Boletim sanitário parcial — 96 de 214 animais vacinados',
        dataHora: DateTime(2026, 9, 14, 11, 45),
      ),
      EvidenciaOs(
        legenda: 'Foto do lote de vacina e temperatura da caixa térmica',
        dataHora: DateTime(2026, 9, 14, 7, 25),
      ),
    ],
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 8, 7), autor: 'Roberto Lima', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 8, 9, 15), autor: 'Ana Beatriz', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 14, 7, 20), autor: 'João Oliveira', acao: 'Execução iniciada'),
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
    maoDeObra: const ['Sérgio Nunes — Mecânico'],
    maquinas: const ['Trator John Deere 6110 (TR-03)'],
    insumos: const ['Óleo hidráulico 15W-40 — 20 L', 'Filtro de óleo e ar', 'Correia da TDP'],
    epis: const ['Luva de raspa', 'Óculos de proteção', 'Protetor auricular'],
    status: OrdemServicoStatus.pausada,
    responsavelExecucao: 'Sérgio Nunes',
    dataInicio: DateTime(2026, 9, 15, 8),
    dataPausa: DateTime(2026, 9, 15, 10, 30),
    motivoPausa: 'Correia da tomada de força fora do estoque local — aguardando envio do almoxarifado central.',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 5, 16), autor: 'Pedro Alves', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 6, 8), autor: 'Carlos Menezes', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 15, 8), autor: 'Sérgio Nunes', acao: 'Execução iniciada'),
      EventoOs(
        dataHora: DateTime(2026, 9, 15, 10, 30),
        autor: 'Sérgio Nunes',
        acao: 'Execução pausada',
        observacao: 'Correia da tomada de força fora do estoque local — aguardando almoxarifado central.',
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
    maoDeObra: const ['Sérgio Nunes — Mecânico', 'João Oliveira — Encarregado'],
    maquinas: const ['Betoneira 400L', 'Trator MF 4275 (carreta basculante)'],
    insumos: const ['Bebedouro 1.000 L com boia', 'Cimento — 6 sacos', 'Brita e areia — 1 m³'],
    epis: const ['Capacete', 'Luva de raspa', 'Bota de segurança', 'Cinto de segurança'],
    status: OrdemServicoStatus.entregue,
    responsavelExecucao: 'Sérgio Nunes',
    dataInicio: DateTime(2026, 9, 8, 7, 30),
    dataEntrega: DateTime(2026, 9, 10, 16, 45),
    evidencias: [
      EvidenciaOs(
        legenda: 'Base de concreto curada e bebedouro nivelado',
        dataHora: DateTime(2026, 9, 10, 16),
      ),
      EvidenciaOs(
        legenda: 'Teste da boia automática com reservatório cheio',
        dataHora: DateTime(2026, 9, 10, 16, 30),
      ),
    ],
    historico: [
      EventoOs(dataHora: DateTime(2026, 8, 28, 9), autor: 'Ana Beatriz', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 8, 28, 15, 40), autor: 'Carlos Menezes', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 8, 7, 30), autor: 'Sérgio Nunes', acao: 'Execução iniciada'),
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
    maoDeObra: const ['João Oliveira — Encarregado', 'Fabiana Rocha — Auxiliar veterinária'],
    maquinas: const ['Camionete de apoio'],
    insumos: const ['Cerca elétrica provisória — 150 m', 'Cones de sinalização — 8 un.'],
    epis: const ['Colete refletivo', 'Luva de raspa', 'Bota de segurança'],
    status: OrdemServicoStatus.refeita,
    responsavelExecucao: 'João Oliveira',
    dataInicio: DateTime(2026, 9, 2, 7, 20),
    justificativaRefazer:
        'Cerca elétrica provisória não resistiu à chuva da noite seguinte e o '
        'lote voltou a se aproximar da estrada — necessário refazer com '
        'mourões fixos e fio de arame reforçado em vez de fita provisória.',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 2, 6, 45), autor: 'Roberto Lima', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 2, 7, 10), autor: 'Ana Beatriz', acao: 'OS autorizada'),
      EventoOs(dataHora: DateTime(2026, 9, 2, 7, 20), autor: 'João Oliveira', acao: 'Execução iniciada'),
      EventoOs(
        dataHora: DateTime(2026, 9, 3, 6, 30),
        autor: 'João Oliveira',
        acao: 'OS marcada como refeita',
        observacao: 'Cerca provisória não resistiu à chuva — necessário refazer com fixação reforçada.',
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
    maoDeObra: const ['Pedro Alves — Auxiliar de campo', 'Sérgio Nunes — Mecânico'],
    maquinas: const ['Escada extensível 7 m'],
    insumos: const ['Boia 3/4" — 1 un.', 'Massa epóxi para vedação — 2 un.'],
    epis: const ['Cinto de segurança', 'Luva de raspa', 'Bota de segurança'],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'Pedro Alves',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 22, 6, 40), autor: 'João Oliveira', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 22, 7, 5), autor: 'Carlos Menezes', acao: 'OS autorizada'),
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
    maoDeObra: const ['Pedro Alves — Operador de máquinas'],
    maquinas: const ['Trator MF 4275', 'Roçadeira hidráulica 1,7 m'],
    insumos: const ['Óleo diesel — 60 L'],
    epis: const ['Protetor auricular', 'Óculos de proteção', 'Bota de segurança'],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'Pedro Alves',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 19, 10), autor: 'Maria Fernandes', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 19, 16, 20), autor: 'Carlos Menezes', acao: 'OS autorizada'),
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
    maoDeObra: const ['Fabiana Rocha — Auxiliar'],
    maquinas: const ['Escada extensível 7 m'],
    insumos: const ['Sacos de lixo — 10 un.'],
    epis: const ['Cinto de segurança', 'Luva de raspa', 'Capacete'],
    status: OrdemServicoStatus.aguardando,
    responsavelExecucao: 'Fabiana Rocha',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 21, 14), autor: 'Ana Beatriz', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 22, 8), autor: 'Carlos Menezes', acao: 'OS autorizada'),
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
    maoDeObra: const ['Pedro Alves — Operador de máquinas'],
    maquinas: const ['Trator MF 4275', 'Pulverizador Jacto 2000 L'],
    insumos: const ['Herbicida pré-emergente — 44 L'],
    epis: const ['Máscara com filtro químico', 'Macacão impermeável', 'Luva nitrílica'],
    status: OrdemServicoStatus.cancelada,
    responsavelExecucao: 'Pedro Alves',
    motivoCancelamento: 'Chuva prevista para a semana toda; aplicação remarcada em nova OS.',
    historico: [
      EventoOs(dataHora: DateTime(2026, 9, 10, 9), autor: 'Maria Fernandes', acao: 'OS solicitada'),
      EventoOs(dataHora: DateTime(2026, 9, 10, 11), autor: 'Carlos Menezes', acao: 'OS autorizada'),
      EventoOs(
        dataHora: DateTime(2026, 9, 12, 8),
        autor: 'Carlos Menezes',
        acao: 'OS cancelada',
        observacao: 'Chuva prevista para a semana toda.',
      ),
    ],
  ),
];
