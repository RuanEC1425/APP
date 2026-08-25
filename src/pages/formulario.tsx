import { FileText, Clock, CheckCircle, XCircle, Search, Filter, Eye } from 'lucide-react';

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
          <span className="flex items-center gap-1 bg-yellow-100 text-yellow-800 px-3 py-1 rounded-full text-xs font-bold uppercase border border-yellow-300">
            <Clock size={14} /> Pendente
          </span>
        );
      case 'Analisado':
        return (
          <span className="flex items-center gap-1 bg-green-100 text-green-800 px-3 py-1 rounded-full text-xs font-bold uppercase border border-green-300">
            <CheckCircle size={14} /> Analisado
          </span>
        );
      case 'Negado':
        return (
          <span className="flex items-center gap-1 bg-red-100 text-red-800 px-3 py-1 rounded-full text-xs font-bold uppercase border border-red-300">
            <XCircle size={14} /> Negado
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="w-full max-w-6xl mx-auto space-y-6">
      
      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center bg-white border-2 border-black p-6 rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] gap-4">
        <div className="flex items-center gap-3">
          <FileText size={32} className="text-red-600" />
          <div>
            <h2 className="text-2xl font-bold uppercase tracking-wider">Central de Formulários</h2>
            <p className="text-gray-500 font-medium">Gerencie anamneses, diagnósticos e seleções</p>
          </div>
        </div>
        
        {/* Barra de Pesquisa Rápida */}
        <div className="flex w-full md:w-auto items-center border-2 border-black rounded bg-gray-50 overflow-hidden">
          <div className="p-2 text-gray-500"><Search size={20} /></div>
          <input 
            type="text" 
            placeholder="Buscar aluno ou form..." 
            className="p-2 bg-transparent focus:outline-none w-full md:w-64 font-medium"
          />
        </div>
      </div>

      {/* Cards de Resumo (Indicadores) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white border-2 border-black p-6 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex items-center justify-between">
          <div>
            <p className="text-gray-500 font-bold uppercase text-sm mb-1">Aguardando Análise</p>
            <p className="text-4xl font-black">12</p>
          </div>
          <div className="bg-yellow-100 p-4 rounded-full border-2 border-yellow-400 text-yellow-600">
            <Clock size={32} />
          </div>
        </div>

        <div className="bg-white border-2 border-black p-6 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex items-center justify-between">
          <div>
            <p className="text-gray-500 font-bold uppercase text-sm mb-1">Diagnósticos Ativos</p>
            <p className="text-4xl font-black">5</p>
          </div>
          <div className="bg-blue-100 p-4 rounded-full border-2 border-blue-400 text-blue-600">
            <FileText size={32} />
          </div>
        </div>

        <div className="bg-white border-2 border-black p-6 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex items-center justify-between">
          <div>
            <p className="text-gray-500 font-bold uppercase text-sm mb-1">Aprovados este mês</p>
            <p className="text-4xl font-black">8</p>
          </div>
          <div className="bg-green-100 p-4 rounded-full border-2 border-green-400 text-green-600">
            <CheckCircle size={32} />
          </div>
        </div>
      </div>

      {/* Tabela de Formulários */}
      <div className="bg-white border-2 border-black rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] overflow-hidden">
        <div className="p-4 border-b-2 border-black flex justify-between items-center bg-gray-100">
          <h3 className="font-bold text-lg uppercase tracking-wide">Documentos Recentes</h3>
          <button className="flex items-center gap-2 text-sm font-bold uppercase border-2 border-black px-3 py-1 rounded hover:bg-black hover:text-white transition-colors">
            <Filter size={16} /> Filtrar
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b-2 border-black bg-white">
                <th className="p-4 font-bold uppercase text-sm text-gray-600">Aluno/Candidato</th>
                <th className="p-4 font-bold uppercase text-sm text-gray-600">Tipo de Documento</th>
                <th className="p-4 font-bold uppercase text-sm text-gray-600">Data de Envio</th>
                <th className="p-4 font-bold uppercase text-sm text-gray-600">Status</th>
                <th className="p-4 font-bold uppercase text-sm text-gray-600 text-center">Ação</th>
              </tr>
            </thead>
            <tbody>
              {formulariosRecentes.map((form) => (
                <tr key={form.id} className="border-b border-gray-200 hover:bg-gray-50 transition-colors">
                  <td className="p-4 font-bold">{form.aluno}</td>
                  <td className="p-4 font-medium text-gray-700">{form.tipo}</td>
                  <td className="p-4 text-gray-500 font-medium">{form.data}</td>
                  <td className="p-4">{renderStatus(form.status)}</td>
                  <td className="p-4 text-center">
                    <button className="inline-flex items-center justify-center p-2 border-2 border-black rounded hover:bg-red-600 hover:text-white hover:border-red-600 transition-colors" title="Ver Respostas">
                      <Eye size={18} />
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