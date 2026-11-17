import { Link } from 'react-router-dom';
import { Dumbbell, Search, Filter, Plus, Copy, Edit, User, CalendarDays, Activity } from 'lucide-react';

export default function Treinos() {
  // Dados simulados baseados no gerenciamento de treinos
  const planilhasTreino = [
    { id: 1, titulo: 'Hipertrofia Base - ABC', aluno: 'Maycon', semanas: 4, inicio: '10/08/2026', status: 'Ativo' },
    { id: 2, titulo: 'Emagrecimento Acelerado', aluno: 'Elizangela', semanas: 6, inicio: '15/08/2026', status: 'Ativo' },
    { id: 3, titulo: 'Força Máxima - 5x5', aluno: 'Carlos Souza', semanas: 8, inicio: '01/07/2026', status: 'Vencendo' },
    { id: 4, titulo: 'Adaptação Anatômica', aluno: 'Sem atribuição', semanas: 4, inicio: '-', status: 'Rascunho' },
  ];

  const renderStatus = (status: string) => {
    switch (status) {
      case 'Ativo':
        return <span className="bg-emerald-500/10 text-emerald-400 px-2.5 py-1 rounded-full text-[11px] font-medium border border-emerald-500/20">Ativo</span>;
      case 'Vencendo':
        return <span className="bg-amber-500/10 text-amber-400 px-2.5 py-1 rounded-full text-[11px] font-medium border border-amber-500/20">Vencendo</span>;
      case 'Rascunho':
        return <span className="bg-zinc-500/10 text-zinc-400 px-2.5 py-1 rounded-full text-[11px] font-medium border border-zinc-600/40">Rascunho</span>;
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
            <Dumbbell size={22} />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">Gestão de Treinos</h1>
            <p className="text-zinc-400 text-sm mt-1">Crie planilhas, periodizações e atribua aos alunos</p>
          </div>
        </div>
        
        <div className="flex gap-3 w-full md:w-auto">
          <div className="flex flex-1 items-center bg-[#18181b] border border-zinc-800 rounded-lg px-3 focus-within:border-red-500 transition-colors">
            <Search size={16} className="text-zinc-500" />
            <input 
              type="text" 
              placeholder="Buscar planilha..." 
              className="py-2 ml-2 bg-transparent text-sm text-zinc-200 placeholder-zinc-500 focus:outline-none w-full md:w-48"
            />
          </div>
          <Link to="/novo-treino" className="flex items-center justify-center gap-2 bg-red-500 hover:bg-red-600 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.2)] whitespace-nowrap">
          <Plus size={18} /> Novo Treino
          </Link>
        </div>
      </div>

      {/* Cards de Resumo */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors flex items-center justify-between">
          <div>
            <p className="text-zinc-400 text-xs font-medium mb-3">Planilhas Ativas</p>
            <p className="text-3xl font-bold text-white">48</p>
          </div>
          <div className="bg-emerald-500/10 p-3 rounded-lg border border-emerald-500/20 text-emerald-400">
            <Activity size={22} />
          </div>
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors flex items-center justify-between">
          <div>
            <p className="text-zinc-400 text-xs font-medium mb-3">Treinos Vencendo (7 dias)</p>
            <p className="text-3xl font-bold text-white">12</p>
          </div>
          <div className="bg-amber-500/10 p-3 rounded-lg border border-amber-500/20 text-amber-400">
            <CalendarDays size={22} />
          </div>
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors flex items-center justify-between">
          <div>
            <p className="text-zinc-400 text-xs font-medium mb-3">Modelos Base (Rascunhos)</p>
            <p className="text-3xl font-bold text-white">15</p>
          </div>
          <div className="bg-zinc-800/60 p-3 rounded-lg border border-zinc-700/60 text-zinc-400">
            <Copy size={22} />
          </div>
        </div>
      </div>

      {/* Tabela de Planilhas */}
      <div className="bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
        <div className="px-5 py-4 border-b border-zinc-800/80 flex justify-between items-center">
          <h3 className="text-zinc-100 font-medium">Biblioteca de Treinos</h3>
          <button className="flex items-center gap-2 text-xs font-medium text-zinc-400 border border-zinc-800 px-3 py-1.5 rounded-lg hover:text-zinc-100 hover:border-zinc-700 hover:bg-zinc-800/50 transition-colors">
            <Filter size={14} /> Filtrar
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse whitespace-nowrap">
            <thead>
              <tr className="border-b border-zinc-800/50 bg-zinc-900/50">
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Título da Planilha</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Aluno Atribuído</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Duração</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Data de Início</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Status</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500 text-center">Ações</th>
              </tr>
            </thead>
            <tbody>
              {planilhasTreino.map((treino) => (
                <tr key={treino.id} className="border-b border-zinc-800/50 last:border-0 hover:bg-zinc-800/30 transition-colors">
                  <td className="px-5 py-4 font-medium text-sm text-zinc-100">{treino.titulo}</td>
                  <td className="px-5 py-4">
                    <span className="flex items-center gap-2 text-sm text-zinc-300">
                      <User size={14} className="text-zinc-500" /> {treino.aluno}
                    </span>
                  </td>
                  <td className="px-5 py-4 text-sm text-zinc-400">{treino.semanas} Semanas</td>
                  <td className="px-5 py-4 text-sm text-zinc-500">{treino.inicio}</td>
                  <td className="px-5 py-4">{renderStatus(treino.status)}</td>
                  <td className="px-5 py-4 text-center">
                    <div className="flex items-center justify-center gap-2">
                      <button className="p-2 border border-zinc-800 rounded-lg text-zinc-400 hover:text-red-500 hover:border-red-500/50 hover:bg-red-500/10 transition-colors" title="Editar">
                        <Edit size={15} />
                      </button>
                      <button className="p-2 border border-zinc-800 rounded-lg text-zinc-400 hover:text-red-500 hover:border-red-500/50 hover:bg-red-500/10 transition-colors" title="Duplicar Modelo">
                        <Copy size={15} />
                      </button>
                    </div>
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
