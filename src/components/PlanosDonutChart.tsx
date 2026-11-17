import { ResponsiveContainer, PieChart, Pie, Cell, Tooltip } from 'recharts';
import ChartTooltip from './ChartTooltip';
import { distribuicaoPlanos } from '../data/mock';

/** Gráfico de rosca com a proporção de alunos por plano. */
export default function PlanosDonutChart() {
  const total = distribuicaoPlanos.reduce((acc, p) => acc + p.alunos, 0);

  return (
    <div className="flex flex-col items-center">
      <div className="relative w-full h-52">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={distribuicaoPlanos}
              dataKey="alunos"
              nameKey="plano"
              innerRadius="68%"
              outerRadius="92%"
              paddingAngle={3}
              stroke="#121214"
              strokeWidth={2}
            >
              {distribuicaoPlanos.map((p) => (
                <Cell key={p.plano} fill={p.cor} />
              ))}
            </Pie>
            <Tooltip
              content={
                <ChartTooltip valueFormatter={(v) => `${v} alunos · ${((v / total) * 100).toFixed(0)}%`} />
              }
            />
          </PieChart>
        </ResponsiveContainer>
        {/* Total no centro da rosca */}
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
          <span className="text-3xl font-bold text-white">{total}</span>
          <span className="text-[11px] uppercase tracking-wider text-zinc-500">Alunos</span>
        </div>
      </div>

      {/* Legenda */}
      <div className="w-full grid grid-cols-2 gap-x-4 gap-y-2.5 mt-5">
        {distribuicaoPlanos.map((p) => (
          <div key={p.plano} className="flex items-center justify-between text-xs">
            <span className="flex items-center gap-2 text-zinc-400">
              <span className="w-2 h-2 rounded-full" style={{ backgroundColor: p.cor }}></span>
              {p.plano}
            </span>
            <span className="font-semibold text-zinc-200">{((p.alunos / total) * 100).toFixed(0)}%</span>
          </div>
        ))}
      </div>
    </div>
  );
}
