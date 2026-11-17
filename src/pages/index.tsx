import RevenueChart from '../components/RevenueChart';

export default function DashboardOverview() {
  return (
    <div className="w-full max-w-6xl space-y-6">
      
      {/* Título Principal */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Overview</h1>
          <p className="text-zinc-400 text-sm mt-1">Operações em resumo · últimos 30 dias</p>
        </div>
        <button className="bg-red-500 hover:bg-red-600 text-white font-medium text-sm px-4 py-2 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.2)]">
          Novo relatório
        </button>
      </div>

      {/* Grelha de Métricas (Cartões) */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {/* Cartão 1 */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5 hover:border-zinc-700 transition-colors">
          <h3 className="text-zinc-400 text-xs font-medium mb-3">Receita</h3>
          <p className="text-3xl font-bold text-white mb-2">R$ 42.190</p>
          <p className="text-red-500 text-xs font-medium">~ 12.4%</p>
        </div>
        
        {/* Cartão 2 */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5 hover:border-zinc-700 transition-colors">
          <h3 className="text-zinc-400 text-xs font-medium mb-3">Alunos Ativos</h3>
          <p className="text-3xl font-bold text-white mb-2">184</p>
          <p className="text-red-500 text-xs font-medium">~ 5.1%</p>
        </div>

        {/* Cartão 3 */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5 hover:border-zinc-700 transition-colors">
          <h3 className="text-zinc-400 text-xs font-medium mb-3">Conversão</h3>
          <p className="text-3xl font-bold text-white mb-2">3.42%</p>
          <p className="text-zinc-500 text-xs font-medium">~ 0.8%</p>
        </div>

        {/* Cartão 4 */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-5 hover:border-zinc-700 transition-colors">
          <h3 className="text-zinc-400 text-xs font-medium mb-3">Retenção Média</h3>
          <p className="text-3xl font-bold text-white mb-2">4 Meses</p>
          <p className="text-red-500 text-xs font-medium">~ 3.2%</p>
        </div>
      </div>

      {/* Gráficos e Atividades Recentes */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 pt-4">
        
        {/* Área do Gráfico */}
        <div className="lg:col-span-2 bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-zinc-100 font-medium">Tendência de Receita</h3>
            <span className="text-xs text-zinc-500">12M · MRR</span>
          </div>
          
          {/* Gráfico combinado: Faturamento Bruto vs. Inadimplência */}
          <RevenueChart height={240} />
        </div>

        {/* Atividade Recente */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <h3 className="text-zinc-100 font-medium mb-6">Atividade Recente</h3>
          <div className="space-y-5">
            {[
              { desc: 'Ficha de treino enviada', time: '2m', dot: 'bg-red-500' },
              { desc: 'Novo aluno adicionado', time: '16m', dot: 'bg-zinc-600' },
              { desc: 'Faturação #5641 paga', time: '1h', dot: 'bg-zinc-600' },
              { desc: 'Análise de Anamnese concluída', time: '3h', dot: 'bg-zinc-600' },
            ].map((act, i) => (
              <div key={i} className="flex justify-between items-center border-b border-zinc-800/50 pb-3 last:border-0">
                <div className="flex items-center gap-3">
                  <span className={`w-1.5 h-1.5 rounded-full ${act.dot}`}></span>
                  <p className="text-sm text-zinc-300">{act.desc}</p>
                </div>
                <span className="text-xs text-zinc-500">{act.time}</span>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}
