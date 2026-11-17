import { useState } from 'react';
import { ArrowLeft, Save, Plus, Trash2, Search, Dumbbell } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function NovoTreino() {
  // Estado simples para simular as abas dos dias de treino
  const [abaAtiva, setAbaAtiva] = useState('A');

  const diasTreino = ['A', 'B', 'C', 'D'];

  // Classes reutilizadas nos inputs escuros da ficha
  const inputBase = 'bg-[#18181b] border border-zinc-800 text-zinc-100 placeholder-zinc-600 rounded-lg focus:outline-none focus:border-red-500 transition-colors';

  return (
    <div className="w-full max-w-7xl mx-auto space-y-6 pb-12">
      
      {/* Cabeçalho de Ação */}

  <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <Link to="/treinos" className="p-2.5 border border-zinc-800 bg-[#121214] rounded-lg text-zinc-400 hover:text-zinc-100 hover:border-zinc-700 transition-colors">
            <ArrowLeft size={20} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">Montagem de Ficha</h1>
            <p className="text-zinc-400 text-sm mt-1">Estruture a periodização e os exercícios</p>
          </div>
        </div>
        
        <Link to="/novo-treino" className="flex items-center gap-2 bg-red-500 hover:bg-red-600 text-white text-sm font-medium px-5 py-2.5 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.2)]">
          <Save size={18} /> Salvar Treino
        </Link>
      </div>

      {/* Configurações Globais do Treino */}
      <div className="bg-[#121214] border border-zinc-800/80 p-6 rounded-xl">
        <h3 className="text-zinc-100 font-medium mb-5 pb-3 border-b border-zinc-800/80 flex items-center gap-2">
          <Dumbbell size={18} className="text-red-500" /> Configurações Base
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2 flex flex-col gap-1.5">
            <label className="text-xs font-medium text-zinc-400">Título da Planilha</label>
            <input type="text" placeholder="Ex: Hipertrofia Fase 1" className={`p-2.5 text-sm ${inputBase}`} />
          </div>
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-medium text-zinc-400">Vincular Aluno</label>
            <select className={`p-2.5 text-sm ${inputBase}`}>
              <option>Selecione um aluno...</option>
              <option>Elizangela</option>
              <option>Maycon</option>
              <option>Carlos Souza</option>
            </select>
          </div>
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-medium text-zinc-400">Duração (Semanas)</label>
            <input type="number" min="1" placeholder="Ex: 4" className={`p-2.5 text-sm ${inputBase}`} />
          </div>
        </div>
      </div>

      {/* Construtor da Ficha (Dias e Exercícios) */}
      <div className="bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
        
        {/* Abas dos Dias */}
        <div className="flex border-b border-zinc-800/80 bg-zinc-900/50">
          {diasTreino.map((dia) => (
            <button
              key={dia}
              onClick={() => setAbaAtiva(dia)}
              className={`flex-1 py-3.5 text-sm font-medium border-b-2 transition-colors ${
                abaAtiva === dia
                  ? 'border-red-500 text-red-500 bg-red-500/5'
                  : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800/40'
              }`}
            >
              Treino {dia}
            </button>
          ))}
          <button className="px-6 flex items-center justify-center text-zinc-500 hover:text-zinc-100 hover:bg-zinc-800/40 border-l border-zinc-800/80 transition-colors" title="Adicionar Novo Dia">
            <Plus size={20} />
          </button>
        </div>

        {/* Lista de Exercícios da Aba Ativa */}
        <div className="p-6 space-y-4">
          
          <div className="flex flex-col md:flex-row justify-between md:items-center gap-3 mb-6">
            <h4 className="text-lg font-semibold text-white">Exercícios - Treino {abaAtiva}</h4>
            <div className="flex gap-2">
              <div className="flex items-center bg-[#18181b] border border-zinc-800 rounded-lg px-3 focus-within:border-red-500 transition-colors">
                <Search size={16} className="text-zinc-500" />
                <input type="text" placeholder="Buscar no banco..." className="py-2 ml-2 bg-transparent outline-none w-48 text-sm text-zinc-200 placeholder-zinc-500" />
              </div>
              <button className="flex items-center gap-2 border border-zinc-800 text-zinc-300 text-sm font-medium px-4 py-2 rounded-lg hover:text-white hover:border-red-500/50 hover:bg-red-500/10 transition-colors">
                <Plus size={16} /> Exercício Manual
              </button>
            </div>
          </div>

          {/* Tabela de Exercícios (Simulação de 2 exercícios) */}
          <div className="border border-zinc-800/80 rounded-lg overflow-hidden">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-zinc-900/50 border-b border-zinc-800/50">
                  <th className="p-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Exercício</th>
                  <th className="p-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Séries</th>
                  <th className="p-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Repetições</th>
                  <th className="p-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Descanso</th>
                  <th className="p-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Técnica/Obs</th>
                  <th className="p-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500 text-center">Ação</th>
                </tr>
              </thead>
              <tbody>
                <tr className="border-b border-zinc-800/50 hover:bg-zinc-800/20 transition-colors">
                  <td className="p-3 text-sm font-medium text-zinc-100">Supino Reto com Barra</td>
                  <td className="p-3"><input type="text" defaultValue="4" className={`w-16 p-1.5 text-sm text-center ${inputBase}`} /></td>
                  <td className="p-3"><input type="text" defaultValue="8 a 10" className={`w-24 p-1.5 text-sm text-center ${inputBase}`} /></td>
                  <td className="p-3"><input type="text" defaultValue="90s" className={`w-20 p-1.5 text-sm text-center ${inputBase}`} /></td>
                  <td className="p-3"><input type="text" placeholder="Ex: Ponto zero" className={`w-full p-1.5 text-sm ${inputBase}`} /></td>
                  <td className="p-3 text-center">
                    <button className="p-1.5 rounded-lg text-zinc-500 hover:text-red-500 hover:bg-red-500/10 transition-colors"><Trash2 size={18} /></button>
                  </td>
                </tr>
                <tr className="hover:bg-zinc-800/20 transition-colors">
                  <td className="p-3 text-sm font-medium text-zinc-100">Crucifixo Inclinado c/ Halteres</td>
                  <td className="p-3"><input type="text" defaultValue="3" className={`w-16 p-1.5 text-sm text-center ${inputBase}`} /></td>
                  <td className="p-3"><input type="text" defaultValue="12" className={`w-24 p-1.5 text-sm text-center ${inputBase}`} /></td>
                  <td className="p-3"><input type="text" defaultValue="60s" className={`w-20 p-1.5 text-sm text-center ${inputBase}`} /></td>
                  <td className="p-3"><input type="text" defaultValue="Drop-set na última" className={`w-full p-1.5 text-sm ${inputBase}`} /></td>
                  <td className="p-3 text-center">
                    <button className="p-1.5 rounded-lg text-zinc-500 hover:text-red-500 hover:bg-red-500/10 transition-colors"><Trash2 size={18} /></button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

        </div>
      </div>

    </div>
  );
}
