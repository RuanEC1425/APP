// Tooltip customizado em tema escuro reutilizado pelos gráficos (recharts)

interface TooltipEntry {
  name?: string | number;
  value?: number | string | (number | string)[];
  color?: string;
  payload?: { fill?: string };
}

interface ChartTooltipProps {
  active?: boolean;
  payload?: TooltipEntry[];
  label?: string | number;
  /** Formata o valor exibido em cada linha (ex.: moeda, kg, %). */
  valueFormatter?: (value: number, name: string) => string;
}

export default function ChartTooltip({ active, payload, label, valueFormatter }: ChartTooltipProps) {
  if (!active || !payload || payload.length === 0) return null;

  return (
    <div className="bg-[#18181b] border border-zinc-800 rounded-lg px-3 py-2.5 shadow-xl shadow-black/40 min-w-[150px]">
      {label !== undefined && label !== '' && (
        <p className="text-[11px] font-semibold uppercase tracking-wider text-zinc-500 mb-2">{label}</p>
      )}
      <div className="space-y-1.5">
        {payload.map((entry, i) => {
          const name = String(entry.name ?? '');
          const raw = Number(Array.isArray(entry.value) ? entry.value[0] : entry.value);
          const color = entry.color ?? entry.payload?.fill ?? '#ef4444';
          return (
            <div key={i} className="flex items-center justify-between gap-4 text-xs">
              <span className="flex items-center gap-2 text-zinc-400">
                <span className="w-2 h-2 rounded-full" style={{ backgroundColor: color }}></span>
                {name}
              </span>
              <span className="font-semibold text-zinc-100">
                {valueFormatter ? valueFormatter(raw, name) : raw}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
