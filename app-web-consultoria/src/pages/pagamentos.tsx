import { CreditCard, AlertCircle, CheckCircle2, Clock, Search, Filter, DollarSign, Download } from 'lucide-react';
import RevenueChart from '../components/RevenueChart';
import PlanosDonutChart from '../components/PlanosDonutChart';

export default function Pagamentos() {
  // Dados simulados baseados no nosso DER (Tabelas Students_Profile e Subscriptions)
  const pagamentosAlunos = [
    { id: 1, aluno: 'Elizangela', plano: 'Trimestral', forma: 'Cartão de Crédito', dataEntrada: '15/05/2026', vencimento: '15/08/2026', status: 'Em dia' },
    { id: 2, aluno: 'Maycon', plano: 'Mensal', forma: 'PIX', dataEntrada: '10/07/2026', vencimento: '10/08/2026', status: 'Atrasado' },
    { id: 3, aluno: 'Carlos Souza', plano: 'Anual', forma: 'Cartão de Crédito', dataEntrada: '01/01/2026', vencimento: '01/01/2027', status: 'Em dia' },
    { id: 4, aluno: 'Juliana Costa', plano: 'Planilha Personalizada', forma: 'PIX', dataEntrada: '18/08/2026', vencimento: '18/08/2026', status: 'Pendente' },
    { id: 5, aluno: 'Roberto Alves', plano: 'Diagnóstico', forma: 'Cartão de Débito', dataEntrada: '05/08/2026', vencimento: '05/08/2026', status: 'Em dia' },
  ];

  // Função para estilizar o status financeiro
  const renderStatus = (status: string) => {
    switch (status) {
      case 'Em dia':
        return (
          <span className="flex items-center gap-1.5 text-emerald-400 font-medium bg-emerald-500/10 px-2.5 py-1 rounded-full border border-emerald-500/20 text-[11px] w-fit">
            <CheckCircle2 size={13} /> Em dia
          </span>
        );
      case 'Atrasado':
        return (
          <span className="flex items-center gap-1.5 text-red-400 font-medium bg-red-500/10 px-2.5 py-1 rounded-full border border-red-500/20 text-[11px] w-fit">
            <AlertCircle size={13} /> Atrasado
          </span>
        );
      case 'Pendente':
        return (
          <span className="flex items-center gap-1.5 text-amber-400 font-medium bg-amber-500/10 px-2.5 py-1 rounded-full border border-amber-500/20 text-[11px] w-fit">
            <Clock size={13} /> Pendente
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="w-full max-w-7xl mx-auto space-y-6">
      
      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-2.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
            <CreditCard size={22} />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">Controle Financeiro</h1>
            <p className="text-zinc-400 text-sm mt-1">Gerencie assinaturas e vencimentos</p>
          </div>
        </div>
        
        <div className="flex gap-3 w-full md:w-auto">
          <div className="flex flex-1 items-center bg-[#18181b] border border-zinc-800 rounded-lg px-3 focus-within:border-red-500 transition-colors">
            <Search size={16} className="text-zinc-500" />
            <input 
              type="text" 
              placeholder="Buscar aluno..." 
              className="py-2 ml-2 bg-transparent text-sm text-zinc-200 placeholder-zinc-500 focus:outline-none w-full md:w-48"
            />
          </div>
          <button className="flex items-center justify-center gap-2 bg-red-500 hover:bg-red-600 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.2)]">
            <Download size={16} /> Relatório
          </button>
        </div>
      </div>

      {/* Cards de Resumo */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <p className="text-zinc-400 text-xs font-medium">Receita Prevista (Mês)</p>
            <DollarSign size={16} className="text-zinc-500" />
          </div>
          <p className="text-3xl font-bold text-white">R$ 4.850,00</p>
        </div>
        
        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <p className="text-zinc-400 text-xs font-medium">Pagamentos em Dia</p>
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
          </div>
          <p className="text-3xl font-bold text-white">32 <span className="text-sm font-medium text-emerald-400">Alunos</span></p>
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <p className="text-zinc-400 text-xs font-medium">Inadimplência</p>
            <span className="w-1.5 h-1.5 rounded-full bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.6)]"></span>
          </div>
          <p className="text-3xl font-bold text-white">3 <span className="text-sm font-medium text-red-400">Alunos</span></p>
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors">
          <div className="flex items-center justify-between mb-3">
            <p className="text-zinc-400 text-xs font-medium">Vencendo nos próximos 7 dias</p>
            <span className="w-1.5 h-1.5 rounded-full bg-amber-400"></span>
          </div>
          <p className="text-3xl font-bold text-white">5 <span className="text-sm font-medium text-amber-400">Alunos</span></p>
        </div>
      </div>

      {/* Gráficos: Receita vs. Inadimplência e Distribuição de Planos */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h3 className="text-zinc-100 font-medium">Faturamento vs. Inadimplência</h3>
              <p className="text-xs text-zinc-500 mt-0.5">Últimos 12 meses</p>
            </div>
            <span className="text-xs text-zinc-500">12M · MRR</span>
          </div>
          <RevenueChart height={260} />
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <div className="mb-4">
            <h3 className="text-zinc-100 font-medium">Retenção por Plano</h3>
            <p className="text-xs text-zinc-500 mt-0.5">Distribuição dos alunos ativos</p>
          </div>
          <PlanosDonutChart />
        </div>
      </div>

      {/* Tabela de Controle */}
      <div className="bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
        <div className="px-5 py-4 border-b border-zinc-800/80 flex justify-between items-center">
          <h3 className="text-zinc-100 font-medium">Status de Assinaturas</h3>
          <button className="flex items-center gap-2 text-xs font-medium text-zinc-400 border border-zinc-800 px-3 py-1.5 rounded-lg hover:text-zinc-100 hover:border-zinc-700 hover:bg-zinc-800/50 transition-colors">
            <Filter size={14} /> Filtrar Status
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse whitespace-nowrap">
            <thead>
              <tr className="border-b border-zinc-800/50 bg-zinc-900/50">
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Aluno</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Plano Selecionado</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Método</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Data de Entrada</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Vencimento</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Status</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500 text-center">Ação</th>
              </tr>
            </thead>
            <tbody>
              {pagamentosAlunos.map((item) => (
                <tr key={item.id} className="border-b border-zinc-800/50 last:border-0 hover:bg-zinc-800/30 transition-colors">
                  <td className="px-5 py-4 font-medium text-sm text-zinc-100">{item.aluno}</td>
                  <td className="px-5 py-4 text-sm text-zinc-300">{item.plano}</td>
                  <td className="px-5 py-4 text-sm text-zinc-400">{item.forma}</td>
                  <td className="px-5 py-4 text-sm text-zinc-500">{item.dataEntrada}</td>
                  <td className="px-5 py-4 text-sm font-medium text-zinc-200">{item.vencimento}</td>
                  <td className="px-5 py-4">{renderStatus(item.status)}</td>
                  <td className="px-5 py-4 text-center">
                    <button className="text-xs font-medium text-zinc-400 border border-zinc-800 px-3 py-1.5 rounded-lg hover:text-red-500 hover:border-red-500/50 hover:bg-red-500/10 transition-colors">
                      Gerenciar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

    </div>
  );
}
