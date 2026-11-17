import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import {
  ResponsiveContainer, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ReferenceLine,
} from 'recharts';
import { ArrowLeft, Target, CalendarDays, Dumbbell, Stethoscope, CreditCard, Flame, TrendingDown, TrendingUp } from 'lucide-react';
import ChartTooltip from '../components/ChartTooltip';
import { alunosDetalhe, formatBRL } from '../data/mock';

type Aba = 'treinos' | 'diagnosticos' | 'pagamentos';

const badge: Record<string, string> = {
  'Ativo': 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
  'Em dia': 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
  'Concluída': 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20',
  'Vencendo': 'bg-amber-500/10 text-amber-400 border-amber-500/20',
  'Pendente': 'bg-amber-500/10 text-amber-400 border-amber-500/20',
  'Agendada': 'bg-red-500/10 text-red-400 border-red-500/20',
  'Atrasado': 'bg-red-500/10 text-red-400 border-red-500/20',
  'Concluído': 'bg-zinc-500/10 text-zinc-400 border-zinc-600/40',
};

const Badge = ({ status }: { status: string }) => (
  <span className={`px-2.5 py-1 rounded-full text-[11px] font-medium border ${badge[status] ?? badge['Concluído']}`}>
    {status}
  </span>
);

export default function AlunoPerfil() {
  const { id } = useParams();
  const [aba, setAba] = useState<Aba>('treinos');
  const aluno = alunosDetalhe.find((a) => a.id === Number(id));

  if (!aluno) {
    return (
      <div className="w-full max-w-3xl mx-auto bg-[#121214] border border-zinc-800/80 rounded-xl p-10 text-center">
        <p className="text-zinc-300 font-medium">Aluno não encontrado.</p>
        <Link to="/alunos" className="inline-flex items-center gap-2 mt-4 text-sm text-red-500 hover:text-red-400">
          <ArrowLeft size={16} /> Voltar para a galeria
        </Link>
      </div>
    );
  }

  const primeiro = aluno.evolucao[0];
  const atual = aluno.evolucao[aluno.evolucao.length - 1];
  const variacaoPeso = +(atual.peso - primeiro.peso).toFixed(1);
  const variacaoGordura = +(atual.gordura - primeiro.gordura).toFixed(1);
  const querPerder = aluno.pesoMeta < primeiro.peso;
  const progressoMeta = Math.min(
    100,
    Math.max(0, ((primeiro.peso - atual.peso) / (primeiro.peso - aluno.pesoMeta)) * 100),
  );

  const macros = [
    { nome: 'Proteínas', atual: aluno.macros.proteinas, meta: aluno.macrosMeta.proteinas, unidade: 'g', cor: 'bg-red-500' },
    { nome: 'Carboidratos', atual: aluno.macros.carboidratos, meta: aluno.macrosMeta.carboidratos, unidade: 'g', cor: 'bg-red-400' },
    { nome: 'Gorduras', atual: aluno.macros.gorduras, meta: aluno.macrosMeta.gorduras, unidade: 'g', cor: 'bg-zinc-400' },
  ];
  const kcalPct = (aluno.macros.caloriasAtuais / aluno.macros.metaCalorica) * 100;

  const abas: { key: Aba; label: string; icon: typeof Dumbbell }[] = [
    { key: 'treinos', label: 'Treinos', icon: Dumbbell },
    { key: 'diagnosticos', label: 'Diagnostics', icon: Stethoscope },
    { key: 'pagamentos', label: 'Pagamentos', icon: CreditCard },
  ];

  const thClass = 'px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500';
  const trClass = 'border-b border-zinc-800/50 last:border-0 hover:bg-zinc-800/30 transition-colors';

  return (
    <div className="w-full max-w-7xl mx-auto space-y-6 pb-12">

      {/* Cabeçalho do Perfil */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <Link to="/alunos" className="p-2.5 border border-zinc-800 bg-[#121214] rounded-lg text-zinc-400 hover:text-zinc-100 hover:border-zinc-700 transition-colors">
            <ArrowLeft size={20} />
          </Link>
          <img src={aluno.foto} alt={`Foto de ${aluno.nome}`} className="w-14 h-14 rounded-full border-2 border-zinc-700 ring-4 ring-zinc-800/50 object-cover" />
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">{aluno.nome}</h1>
            <div className="flex flex-wrap items-center gap-2 mt-1.5">
              <span className="text-xs text-zinc-400">{aluno.plano}</span>
              <span className="text-zinc-700">·</span>
              <span className="bg-zinc-800/60 border border-zinc-700/60 px-2.5 py-0.5 rounded-full text-[11px] font-medium text-zinc-300">{aluno.objetivo}</span>
              <span className="text-zinc-700">·</span>
              <span className="flex items-center gap-1 text-xs text-zinc-500"><CalendarDays size={12} /> Desde {aluno.inicio}</span>
            </div>
          </div>
        </div>
        <Link to="/novo-treino" className="flex items-center gap-2 bg-red-500 hover:bg-red-600 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.2)]">
          <Dumbbell size={16} /> Atribuir Treino
        </Link>
      </div>

      {/* Indicadores rápidos */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5">
          <p className="text-zinc-400 text-xs font-medium mb-3">Peso Atual</p>
          <p className="text-3xl font-bold text-white">{atual.peso} <span className="text-sm font-medium text-zinc-500">kg</span></p>
          <p className={`text-xs font-medium mt-2 flex items-center gap-1 ${(variacaoPeso < 0) === querPerder ? 'text-emerald-400' : 'text-red-400'}`}>
            {variacaoPeso < 0 ? <TrendingDown size={13} /> : <TrendingUp size={13} />}
            {variacaoPeso > 0 ? '+' : ''}{variacaoPeso} kg desde o início
          </p>
        </div>
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5">
          <p className="text-zinc-400 text-xs font-medium mb-3">% de Gordura</p>
          <p className="text-3xl font-bold text-white">{atual.gordura}<span className="text-sm font-medium text-zinc-500">%</span></p>
          <p className={`text-xs font-medium mt-2 ${variacaoGordura <= 0 ? 'text-emerald-400' : 'text-red-400'}`}>
            {variacaoGordura > 0 ? '+' : ''}{variacaoGordura} p.p.
          </p>
        </div>
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5">
          <div className="flex items-center justify-between mb-3">
            <p className="text-zinc-400 text-xs font-medium">Progresso da Meta</p>
            <Target size={15} className="text-zinc-500" />
          </div>
          <p className="text-3xl font-bold text-white">{progressoMeta.toFixed(0)}<span className="text-sm font-medium text-zinc-500">%</span></p>
          <div className="h-1.5 w-full bg-zinc-800 rounded-full overflow-hidden mt-3">
            <div className="h-full bg-red-500 rounded-full" style={{ width: `${progressoMeta}%` }}></div>
          </div>
        </div>
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5">
          <p className="text-zinc-400 text-xs font-medium mb-3">Meta de Peso</p>
          <p className="text-3xl font-bold text-white">{aluno.pesoMeta} <span className="text-sm font-medium text-zinc-500">kg</span></p>
          <p className="text-xs font-medium mt-2 text-zinc-500">Faltam {Math.abs(+(atual.peso - aluno.pesoMeta).toFixed(1))} kg</p>
        </div>
      </div>

      {/* Evolução + Macronutrientes */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

        {/* Visão Geral de Evolução */}
        <div className="lg:col-span-2 bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h3 className="text-zinc-100 font-medium">Visão Geral de Evolução</h3>
              <p className="text-xs text-zinc-500 mt-0.5">Peso corporal e % de gordura por semana</p>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={260}>
            <LineChart data={aluno.evolucao} margin={{ top: 8, right: 4, left: -12, bottom: 0 }}>
              <CartesianGrid stroke="#27272a" strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="semana" tick={{ fill: '#71717a', fontSize: 10, fontWeight: 600 }} axisLine={false} tickLine={false} />
              <YAxis yAxisId="peso" domain={['dataMin - 2', 'dataMax + 2']} tick={{ fill: '#71717a', fontSize: 10 }} axisLine={false} tickLine={false} />
              <YAxis yAxisId="gordura" orientation="right" domain={['dataMin - 2', 'dataMax + 2']} tick={{ fill: '#71717a', fontSize: 10 }} axisLine={false} tickLine={false} />
              <Tooltip
                cursor={{ stroke: '#3f3f46', strokeDasharray: '3 3' }}
                content={<ChartTooltip valueFormatter={(v, name) => (name.includes('Gordura') ? `${v}%` : `${v} kg`)} />}
              />
              <Legend verticalAlign="top" align="right" height={28} iconType="circle" iconSize={8}
                formatter={(value: string) => <span className="text-xs text-zinc-400">{value}</span>} />
              <ReferenceLine yAxisId="peso" y={aluno.pesoMeta} stroke="#3f3f46" strokeDasharray="4 4"
                label={{ value: `Meta ${aluno.pesoMeta} kg`, fill: '#71717a', fontSize: 10, position: 'insideBottomLeft' }} />
              <Line yAxisId="peso" type="monotone" dataKey="peso" name="Peso Corporal" stroke="#ef4444" strokeWidth={2.5}
                dot={{ r: 3, fill: '#121214', stroke: '#ef4444', strokeWidth: 2 }} activeDot={{ r: 5, fill: '#ef4444', stroke: '#121214', strokeWidth: 2 }} />
              <Line yAxisId="gordura" type="monotone" dataKey="gordura" name="% de Gordura" stroke="#a1a1aa" strokeWidth={2} strokeDasharray="5 4"
                dot={{ r: 3, fill: '#121214', stroke: '#a1a1aa', strokeWidth: 2 }} activeDot={{ r: 5, fill: '#a1a1aa', stroke: '#121214', strokeWidth: 2 }} />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Painel de Macronutrientes */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <h3 className="text-zinc-100 font-medium">Painel de Macronutrientes</h3>
          <p className="text-xs text-zinc-500 mt-0.5 mb-6">Divisão atual da dieta vs. meta</p>

          {/* Meta calórica */}
          <div className="bg-[#18181b] border border-zinc-800 rounded-lg p-4 mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="flex items-center gap-2 text-xs font-medium text-zinc-400"><Flame size={14} className="text-red-500" /> Meta Calórica Diária</span>
              <span className={`text-[11px] font-medium ${kcalPct > 105 ? 'text-red-400' : 'text-emerald-400'}`}>{kcalPct.toFixed(0)}%</span>
            </div>
            <p className="text-2xl font-bold text-white">
              {aluno.macros.caloriasAtuais.toLocaleString('pt-BR')}
              <span className="text-sm font-medium text-zinc-500"> / {aluno.macros.metaCalorica.toLocaleString('pt-BR')} kcal</span>
            </p>
            <div className="h-1.5 w-full bg-zinc-800 rounded-full overflow-hidden mt-3">
              <div className={`h-full rounded-full ${kcalPct > 105 ? 'bg-red-500' : 'bg-emerald-400'}`} style={{ width: `${Math.min(kcalPct, 100)}%` }}></div>
            </div>
          </div>

          <div className="space-y-5">
            {macros.map((m) => {
              const pct = Math.min((m.atual / m.meta) * 100, 100);
              return (
                <div key={m.nome}>
                  <div className="flex items-center justify-between text-xs mb-2">
                    <span className="font-medium text-zinc-300">{m.nome}</span>
                    <span className="text-zinc-500"><span className="font-semibold text-zinc-100">{m.atual}{m.unidade}</span> / {m.meta}{m.unidade}</span>
                  </div>
                  <div className="h-2 w-full bg-zinc-800 rounded-full overflow-hidden">
                    <div className={`h-full rounded-full ${m.cor}`} style={{ width: `${pct}%` }}></div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Histórico Integrado */}
      <div className="bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
        <div className="flex border-b border-zinc-800/80 bg-zinc-900/50">
          {abas.map((a) => (
            <button
              key={a.key}
              onClick={() => setAba(a.key)}
              className={`flex items-center gap-2 px-6 py-3.5 text-sm font-medium border-b-2 transition-colors ${
                aba === a.key
                  ? 'border-red-500 text-red-500 bg-red-500/5'
                  : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800/40'
              }`}
            >
              <a.icon size={15} /> {a.label}
            </button>
          ))}
        </div>

        <div className="overflow-x-auto">
          {aba === 'treinos' && (
            <table className="w-full text-left border-collapse whitespace-nowrap">
              <thead><tr className="border-b border-zinc-800/50 bg-zinc-900/30">
                <th className={thClass}>Planilha</th><th className={thClass}>Duração</th><th className={thClass}>Início</th><th className={thClass}>Status</th>
              </tr></thead>
              <tbody>
                {aluno.treinos.map((t, i) => (
                  <tr key={i} className={trClass}>
                    <td className="px-5 py-4 text-sm font-medium text-zinc-100">{t.titulo}</td>
                    <td className="px-5 py-4 text-sm text-zinc-400">{t.semanas} Semanas</td>
                    <td className="px-5 py-4 text-sm text-zinc-500">{t.inicio}</td>
                    <td className="px-5 py-4"><Badge status={t.status} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}

          {aba === 'diagnosticos' && (
            <table className="w-full text-left border-collapse whitespace-nowrap">
              <thead><tr className="border-b border-zinc-800/50 bg-zinc-900/30">
                <th className={thClass}>Sessão</th><th className={thClass}>Data</th><th className={thClass}>Status</th>
              </tr></thead>
              <tbody>
                {aluno.diagnosticos.map((d, i) => (
                  <tr key={i} className={trClass}>
                    <td className="px-5 py-4 text-sm font-medium text-zinc-100">{d.tipo}</td>
                    <td className="px-5 py-4 text-sm text-zinc-500">{d.data}</td>
                    <td className="px-5 py-4"><Badge status={d.status} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}

          {aba === 'pagamentos' && (
            <table className="w-full text-left border-collapse whitespace-nowrap">
              <thead><tr className="border-b border-zinc-800/50 bg-zinc-900/30">
                <th className={thClass}>Referência</th><th className={thClass}>Valor</th><th className={thClass}>Vencimento</th><th className={thClass}>Status</th>
              </tr></thead>
              <tbody>
                {aluno.pagamentos.map((p, i) => (
                  <tr key={i} className={trClass}>
                    <td className="px-5 py-4 text-sm font-medium text-zinc-100">{p.referencia}</td>
                    <td className="px-5 py-4 text-sm text-zinc-300">{formatBRL(p.valor)}</td>
                    <td className="px-5 py-4 text-sm text-zinc-500">{p.vencimento}</td>
                    <td className="px-5 py-4"><Badge status={p.status} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

    </div>
  );
}
