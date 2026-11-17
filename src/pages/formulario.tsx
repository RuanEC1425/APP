import { FileText, Clock, CheckCircle, XCircle, Search, Filter, Eye } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Formulario() {
  // Dados simulados baseados no nosso DER (Tabela Forms_Anamnesis)
  const formulariosRecentes = [
    { id: 1, aluno: 'Carlos Souza', tipo: 'Pré-seleção', data: '12/08/2026', status: 'Pendente' },
    { id: 2, aluno: 'Elizangela', tipo: 'Anamnese Corporal', data: '10/08/2026', status: 'Analisado' },
    { id: 3, aluno: 'Roberto Alves', tipo: 'Pré-seleção', data: '09/08/2026', status: 'Negado' },
    { id: 4, aluno: 'Maycon', tipo: 'Anamnese Alimentar', data: '08/08/2026', status: 'Analisado' },
    { id: 5, aluno: 'Juliana Costa', tipo: 'Anamnese Espacial', data: '08/08/2026', status: 'Pendente' },
  ];

  // Função auxiliar para renderizar a badge de status com cores dinâmicas
  const renderStatus = (status: string) => {
    switch (status) {
      case 'Pendente':
        return (
          <span className="flex items-center gap-1.5 w-fit bg-amber-500/10 text-amber-400 px-2.5 py-1 rounded-full text-[11px] font-medium border border-amber-500/20">
            <Clock size={13} /> Pendente
          </span>
        );
      case 'Analisado':
        return (
          <span className="flex items-center gap-1.5 w-fit bg-emerald-500/10 text-emerald-400 px-2.5 py-1 rounded-full text-[11px] font-medium border border-emerald-500/20">
            <CheckCircle size={13} /> Analisado
          </span>
        );
      case 'Negado':
        return (
          <span className="flex items-center gap-1.5 w-fit bg-red-500/10 text-red-400 px-2.5 py-1 rounded-full text-[11px] font-medium border border-red-500/20">
            <XCircle size={13} /> Negado
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="w-full max-w-6xl mx-auto space-y-6">
      
      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-2.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
            <FileText size={22} />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">Central de Formulários</h1>
            <p className="text-zinc-400 text-sm mt-1">Gerencie anamneses, diagnósticos e seleções</p>
          </div>
        </div>
        
        {/* Barra de Pesquisa Rápida */}
        <div className="flex w-full md:w-auto items-center bg-[#18181b] border border-zinc-800 rounded-lg px-3 focus-within:border-red-500 transition-colors">
          <Search size={16} className="text-zinc-500" />
          <input 
            type="text" 
            placeholder="Buscar aluno ou form..." 
            className="py-2 ml-2 bg-transparent text-sm text-zinc-200 placeholder-zinc-500 focus:outline-none w-full md:w-64"
          />
        </div>
      </div>

      {/* Cards de Resumo (Indicadores) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors flex items-center justify-between">
          <div>
            <p className="text-zinc-400 text-xs font-medium mb-3">Aguardando Análise</p>
            <p className="text-3xl font-bold text-white">12</p>
          </div>
          <div className="bg-amber-500/10 p-3 rounded-lg border border-amber-500/20 text-amber-400">
            <Clock size={22} />
          </div>
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors flex items-center justify-between">
          <div>
            <p className="text-zinc-400 text-xs font-medium mb-3">Diagnósticos Ativos</p>
            <p className="text-3xl font-bold text-white">5</p>
          </div>
          <div className="bg-red-500/10 p-3 rounded-lg border border-red-500/20 text-red-500">
            <FileText size={22} />
          </div>
        </div>

        <div className="bg-[#121214] border border-zinc-800/80 p-5 rounded-xl hover:border-zinc-700 transition-colors flex items-center justify-between">
          <div>
            <p className="text-zinc-400 text-xs font-medium mb-3">Aprovados este mês</p>
            <p className="text-3xl font-bold text-white">8</p>
          </div>
          <div className="bg-emerald-500/10 p-3 rounded-lg border border-emerald-500/20 text-emerald-400">
            <CheckCircle size={22} />
          </div>
        </div>
      </div>

      {/* Tabela de Formulários */}
      <div className="bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
        <div className="px-5 py-4 border-b border-zinc-800/80 flex justify-between items-center">
          <h3 className="text-zinc-100 font-medium">Documentos Recentes</h3>
          <button className="flex items-center gap-2 text-xs font-medium text-zinc-400 border border-zinc-800 px-3 py-1.5 rounded-lg hover:text-zinc-100 hover:border-zinc-700 hover:bg-zinc-800/50 transition-colors">
            <Filter size={14} /> Filtrar
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-zinc-800/50 bg-zinc-900/50">
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Aluno/Candidato</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Tipo de Documento</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Data de Envio</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500">Status</th>
                <th className="px-5 py-3 font-semibold uppercase tracking-wider text-[11px] text-zinc-500 text-center">Ação</th>
              </tr>
            </thead>
            <tbody>
              {formulariosRecentes.map((form) => (
                <tr key={form.id} className="border-b border-zinc-800/50 last:border-0 hover:bg-zinc-800/30 transition-colors">
                  <td className="px-5 py-4 text-sm font-medium text-zinc-100">{form.aluno}</td>
                  <td className="px-5 py-4 text-sm text-zinc-300">{form.tipo}</td>
                  <td className="px-5 py-4 text-sm text-zinc-500">{form.data}</td>
                  <td className="px-5 py-4">{renderStatus(form.status)}</td>
                  <td className="px-5 py-4 text-center">
                    <Link to={`/formularios/${form.id}`} className="inline-flex items-center justify-center p-2 border border-zinc-800 rounded-lg text-zinc-400 hover:text-red-500 hover:border-red-500/50 hover:bg-red-500/10 transition-colors" title="Ver Respostas">
                      <Eye size={16} />
                    </Link>
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
