import { ResponsiveContainer, ComposedChart, Bar, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts';
import ChartTooltip from './ChartTooltip';
import { receitaMensal, formatBRL } from '../data/mock';

interface RevenueChartProps {
  height?: number;
}

/** Gráfico combinado: Faturamento Bruto (barras) vs. Inadimplência (linha) — últimos 12 meses. */
export default function RevenueChart({ height = 260 }: RevenueChartProps) {
  const ultimo = receitaMensal.length - 1;

  return (
    <ResponsiveContainer width="100%" height={height}>
      <ComposedChart data={receitaMensal} margin={{ top: 8, right: 8, left: -8, bottom: 0 }}>
        <defs>
          <linearGradient id="barFaturamento" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#3f3f46" stopOpacity={1} />
            <stop offset="100%" stopColor="#27272a" stopOpacity={1} />
          </linearGradient>
          <linearGradient id="barFaturamentoAtual" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#ef4444" stopOpacity={1} />
            <stop offset="100%" stopColor="#b91c1c" stopOpacity={1} />
          </linearGradient>
        </defs>
        <CartesianGrid stroke="#27272a" strokeDasharray="3 3" vertical={false} />
        <XAxis
          dataKey="mes"
          tick={{ fill: '#71717a', fontSize: 10, fontWeight: 600 }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          tick={{ fill: '#71717a', fontSize: 10 }}
          axisLine={false}
          tickLine={false}
          tickFormatter={(v: number) => `${Math.round(v / 1000)}k`}
        />
        <Tooltip
          cursor={{ fill: 'rgba(63, 63, 70, 0.25)' }}
          content={<ChartTooltip valueFormatter={(v) => formatBRL(v)} />}
        />
        <Legend
          verticalAlign="top"
          align="right"
          height={28}
          iconType="circle"
          iconSize={8}
          formatter={(value: string) => <span className="text-xs text-zinc-400">{value}</span>}
        />
        <Bar
          dataKey="faturamento"
          name="Faturamento Bruto"
          radius={[3, 3, 0, 0]}
          fill="url(#barFaturamento)"
          // Destaca o mês atual em vermelho
          shape={(props: unknown) => {
            const { x, y, width, height: h, index } = props as { x: number; y: number; width: number; height: number; index: number };
            return (
              <rect
                x={x}
                y={y}
                width={width}
                height={h}
                rx={3}
                fill={index === ultimo ? 'url(#barFaturamentoAtual)' : 'url(#barFaturamento)'}
              />
            );
          }}
        />
        <Line
          type="monotone"
          dataKey="inadimplencia"
          name="Inadimplência"
          stroke="#f87171"
          strokeWidth={2}
          dot={{ r: 3, fill: '#121214', stroke: '#f87171', strokeWidth: 2 }}
          activeDot={{ r: 5, fill: '#ef4444', stroke: '#121214', strokeWidth: 2 }}
        />
      </ComposedChart>
    </ResponsiveContainer>
  );
}
