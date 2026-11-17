// Dados simulados usados pelos gráficos e telas de detalhamento.
// Serão substituídos pelas consultas reais (Supabase) futuramente.

export const formatBRL = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL', maximumFractionDigits: 0 });

/** Faturamento Bruto vs. Inadimplência — últimos 12 meses */
export const receitaMensal = [
  { mes: 'Jun', faturamento: 28400, inadimplencia: 2100 },
  { mes: 'Jul', faturamento: 30100, inadimplencia: 1900 },
  { mes: 'Ago', faturamento: 29300, inadimplencia: 2400 },
  { mes: 'Set', faturamento: 32800, inadimplencia: 1700 },
  { mes: 'Out', faturamento: 31900, inadimplencia: 2000 },
  { mes: 'Nov', faturamento: 34600, inadimplencia: 1500 },
  { mes: 'Dez', faturamento: 30200, inadimplencia: 2800 },
  { mes: 'Jan', faturamento: 36400, inadimplencia: 1600 },
  { mes: 'Fev', faturamento: 35700, inadimplencia: 1400 },
  { mes: 'Mar', faturamento: 38200, inadimplencia: 1300 },
  { mes: 'Abr', faturamento: 39900, inadimplencia: 1200 },
  { mes: 'Mai', faturamento: 42190, inadimplencia: 1100 },
];

/** Distribuição de alunos por plano */
export const distribuicaoPlanos = [
  { plano: 'Mensal', alunos: 72, cor: '#ef4444' },
  { plano: 'Trimestral', alunos: 54, cor: '#f87171' },
  { plano: 'Semestral', alunos: 34, cor: '#71717a' },
  { plano: 'Anual', alunos: 24, cor: '#3f3f46' },
];

export type StatusSessao = 'Concluída' | 'Agendada' | 'Pendente';
export type StatusPagamento = 'Em dia' | 'Atrasado' | 'Pendente';

export interface AlunoDetalhe {
  id: number;
  nome: string;
  plano: string;
  objetivo: string;
  foto: string;
  inicio: string;
  pesoMeta: number;
  evolucao: { semana: string; peso: number; gordura: number }[];
  macros: { proteinas: number; carboidratos: number; gorduras: number; metaCalorica: number; caloriasAtuais: number };
  macrosMeta: { proteinas: number; carboidratos: number; gorduras: number };
  treinos: { titulo: string; semanas: number; inicio: string; status: string }[];
  diagnosticos: { tipo: string; data: string; status: StatusSessao }[];
  pagamentos: { referencia: string; valor: number; vencimento: string; status: StatusPagamento }[];
}

export const alunosDetalhe: AlunoDetalhe[] = [
  {
    id: 1,
    nome: 'Elizangela',
    plano: 'Trimestral',
    objetivo: 'Emagrecimento',
    foto: 'https://i.pravatar.cc/150?u=elizangela',
    inicio: '15/05/2026',
    pesoMeta: 60,
    evolucao: [
      { semana: 'S1', peso: 74.0, gordura: 32.5 },
      { semana: 'S2', peso: 73.1, gordura: 32.0 },
      { semana: 'S3', peso: 72.4, gordura: 31.4 },
      { semana: 'S4', peso: 71.8, gordura: 30.9 },
      { semana: 'S5', peso: 70.6, gordura: 30.1 },
      { semana: 'S6', peso: 69.9, gordura: 29.6 },
      { semana: 'S7', peso: 69.0, gordura: 29.0 },
      { semana: 'S8', peso: 68.0, gordura: 28.3 },
    ],
    macros: { proteinas: 130, carboidratos: 150, gorduras: 50, metaCalorica: 1650, caloriasAtuais: 1570 },
    macrosMeta: { proteinas: 140, carboidratos: 160, gorduras: 55 },
    treinos: [
      { titulo: 'Emagrecimento Acelerado', semanas: 6, inicio: '15/08/2026', status: 'Ativo' },
      { titulo: 'Adaptação Anatômica', semanas: 4, inicio: '15/05/2026', status: 'Concluído' },
    ],
    diagnosticos: [
      { tipo: 'Diagnóstico Inicial', data: '15/05/2026', status: 'Concluída' },
      { tipo: 'Reavaliação Corporal', data: '15/07/2026', status: 'Concluída' },
      { tipo: 'Diagnóstico Trimestral', data: '14:00 · Hoje', status: 'Agendada' },
    ],
    pagamentos: [
      { referencia: 'Trimestral · Mai–Jul', valor: 597, vencimento: '15/05/2026', status: 'Em dia' },
      { referencia: 'Trimestral · Ago–Out', valor: 597, vencimento: '15/08/2026', status: 'Em dia' },
    ],
  },
  {
    id: 2,
    nome: 'Maycon',
    plano: 'Mensal',
    objetivo: 'Hipertrofia',
    foto: 'https://i.pravatar.cc/150?u=maycon',
    inicio: '10/07/2026',
    pesoMeta: 82,
    evolucao: [
      { semana: 'S1', peso: 71.2, gordura: 14.0 },
      { semana: 'S2', peso: 71.9, gordura: 14.1 },
      { semana: 'S3', peso: 72.5, gordura: 14.0 },
      { semana: 'S4', peso: 73.0, gordura: 14.2 },
      { semana: 'S5', peso: 73.8, gordura: 14.3 },
      { semana: 'S6', peso: 74.4, gordura: 14.3 },
      { semana: 'S7', peso: 75.0, gordura: 14.4 },
    ],
    macros: { proteinas: 165, carboidratos: 340, gorduras: 75, metaCalorica: 2900, caloriasAtuais: 2700 },
    macrosMeta: { proteinas: 175, carboidratos: 380, gorduras: 80 },
    treinos: [{ titulo: 'Hipertrofia Base - ABC', semanas: 4, inicio: '10/08/2026', status: 'Ativo' }],
    diagnosticos: [
      { tipo: 'Pré-seleção', data: '05/07/2026', status: 'Concluída' },
      { tipo: 'Análise de Protocolo', data: '16:30 · Hoje', status: 'Concluída' },
    ],
    pagamentos: [
      { referencia: 'Mensal · Jul', valor: 229, vencimento: '10/07/2026', status: 'Em dia' },
      { referencia: 'Mensal · Ago', valor: 229, vencimento: '10/08/2026', status: 'Atrasado' },
    ],
  },
  {
    id: 3,
    nome: 'Carlos Souza',
    plano: 'Anual',
    objetivo: 'Emagrecimento',
    foto: 'https://i.pravatar.cc/150?u=carlos',
    inicio: '01/01/2026',
    pesoMeta: 85,
    evolucao: [
      { semana: 'S1', peso: 96.0, gordura: 27.8 },
      { semana: 'S2', peso: 95.4, gordura: 27.5 },
      { semana: 'S3', peso: 95.8, gordura: 27.6 },
      { semana: 'S4', peso: 95.1, gordura: 27.2 },
      { semana: 'S5', peso: 94.7, gordura: 27.1 },
      { semana: 'S6', peso: 94.9, gordura: 27.0 },
      { semana: 'S7', peso: 94.0, gordura: 26.7 },
    ],
    macros: { proteinas: 150, carboidratos: 260, gorduras: 85, metaCalorica: 2200, caloriasAtuais: 2550 },
    macrosMeta: { proteinas: 180, carboidratos: 200, gorduras: 65 },
    treinos: [{ titulo: 'Força Máxima - 5x5', semanas: 8, inicio: '01/07/2026', status: 'Vencendo' }],
    diagnosticos: [
      { tipo: 'Anamnese Alimentar', data: '02/01/2026', status: 'Concluída' },
      { tipo: 'Pré-seleção', data: '12/08/2026', status: 'Pendente' },
    ],
    pagamentos: [{ referencia: 'Anual · 2026', valor: 2290, vencimento: '01/01/2026', status: 'Em dia' }],
  },
];

export type StatusFormulario = 'Pendente' | 'Analisado' | 'Negado';

export interface FormularioDetalhe {
  id: number;
  aluno: string;
  tipo: string;
  data: string;
  status: StatusFormulario;
  secoes: { titulo: 'Anamnese Corporal' | 'Anamnese Alimentar' | 'Anamnese Espacial'; respostas: { pergunta: string; resposta: string }[] }[];
}

const secoesPadrao = (variante: number): FormularioDetalhe['secoes'] => [
  {
    titulo: 'Anamnese Corporal',
    respostas: [
      { pergunta: 'Peso e altura atuais', resposta: variante === 1 ? '94 kg · 1,78 m' : '68 kg · 1,63 m' },
      { pergunta: 'Possui lesões ou dores articulares?', resposta: variante === 1 ? 'Desconforto leve no joelho direito.' : 'Não.' },
      { pergunta: 'Histórico de cirurgias', resposta: 'Nenhuma cirurgia relevante.' },
      { pergunta: 'Pratica atividade física atualmente?', resposta: variante === 1 ? 'Caminhada 2x por semana.' : 'Musculação 3x por semana.' },
    ],
  },
  {
    titulo: 'Anamnese Alimentar',
    respostas: [
      { pergunta: 'Quantas refeições faz por dia?', resposta: variante === 1 ? '3 refeições, pula o café da manhã.' : '5 refeições.' },
      { pergunta: 'Restrições ou alergias alimentares', resposta: variante === 1 ? 'Intolerância à lactose.' : 'Nenhuma.' },
      { pergunta: 'Consumo diário de água', resposta: variante === 1 ? '1 litro' : '2,5 litros' },
      { pergunta: 'Uso de suplementos', resposta: variante === 1 ? 'Nenhum.' : 'Whey protein e creatina.' },
    ],
  },
  {
    titulo: 'Anamnese Espacial',
    respostas: [
      { pergunta: 'Local de treino', resposta: variante === 1 ? 'Academia de condomínio.' : 'Academia completa.' },
      { pergunta: 'Equipamentos disponíveis', resposta: variante === 1 ? 'Halteres até 20 kg, esteira e banco.' : 'Todos os equipamentos convencionais.' },
      { pergunta: 'Disponibilidade semanal', resposta: variante === 1 ? '3 dias · 50 min' : '5 dias · 1h15' },
    ],
  },
];

export const formulariosDetalhe: FormularioDetalhe[] = [
  { id: 1, aluno: 'Carlos Souza', tipo: 'Pré-seleção', data: '12/08/2026', status: 'Pendente', secoes: secoesPadrao(1) },
  { id: 2, aluno: 'Elizangela', tipo: 'Anamnese Corporal', data: '10/08/2026', status: 'Analisado', secoes: secoesPadrao(2) },
  { id: 3, aluno: 'Roberto Alves', tipo: 'Pré-seleção', data: '09/08/2026', status: 'Negado', secoes: secoesPadrao(1) },
  { id: 4, aluno: 'Maycon', tipo: 'Anamnese Alimentar', data: '08/08/2026', status: 'Analisado', secoes: secoesPadrao(2) },
  { id: 5, aluno: 'Juliana Costa', tipo: 'Anamnese Espacial', data: '08/08/2026', status: 'Pendente', secoes: secoesPadrao(2) },
];
