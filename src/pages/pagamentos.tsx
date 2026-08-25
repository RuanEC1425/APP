import { CreditCard, AlertCircle, CheckCircle2, Clock, Search, Filter, DollarSign, Download } from 'lucide-react';

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
          <span className="flex items-center gap-1 text-green-700 font-bold bg-green-100 px-3 py-1 rounded-full border border-green-300 text-xs uppercase tracking-wider w-fit">
            <CheckCircle2 size={16} /> Em dia
          </span>
        );
      case 'Atrasado':
        return (
          <span className="flex items-center gap-1 text-red-700 font-bold bg-red-100 px-3 py-1 rounded-full border border-red-300 text-xs uppercase tracking-wider w-fit">
            <AlertCircle size={16} /> Atrasado
          </span>
        );
      case 'Pendente':
        return (
          <span className="flex items-center gap-1 text-yellow-700 font-bold bg-yellow-100 px-3 py-1 rounded-full border border-yellow-300 text-xs uppercase tracking-wider w-fit">
            <Clock size={16} /> Pendente
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="w-full max-w-7xl mx-auto space-y-6">
      
      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center bg-white border-2 border-black p-6 rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] gap-4">
        <div className="flex items-center gap-3">
          <CreditCard size={32} className="text-red-600" />
          <div>
            <h2 className="text-2xl font-bold uppercase tracking-wider">Controle Financeiro</h2>
            <p className="text-gray-500 font-medium">Gerencie assinaturas e vencimentos</p>
          </div>
        </div>
        
        <div className="flex gap-3 w-full md:w-auto">
          <div className="flex flex-1 items-center border-2 border-black rounded bg-gray-50 overflow-hidden">
            <div className="p-2 text-gray-500"><Search size={20} /></div>
            <input 
              type="text" 
              placeholder="Buscar aluno..." 
              className="p-2 bg-transparent focus:outline-none w-full md:w-48 font-medium"
            />
          </div>
          <button className="flex items-center justify-center gap-2 bg-black text-white px-4 py-2 rounded font-bold uppercase hover:bg-red-600 transition-colors">
            <Download size={20} /> Relatório
          </button>
        </div>
      </div>

      {/* Cards de Resumo */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white border-2 border-black p-4 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
          <p className="text-gray-500 font-bold uppercase text-xs mb-1">Receita Prevista (Mês)</p>
          <div className="flex items-center gap-2">
            <DollarSign size={24} className="text-blue-600" />
            <p className="text-2xl font-black">R$ 4.850,00</p>
          </div>
        </div>
        
        <div className="bg-white border-2 border-black p-4 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] border-l-4 border-l-green-500">
          <p className="text-gray-500 font-bold uppercase text-xs mb-1">Pagamentos em Dia</p>
          <p className="text-2xl font-black text-green-700">32 Alunos</p>
        </div>

        <div className="bg-white border-2 border-black p-4 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] border-l-4 border-l-red-500">
          <p className="text-gray-500 font-bold uppercase text-xs mb-1">Inadimplência</p>
          <p className="text-2xl font-black text-red-700">3 Alunos</p>
        </div>

        <div className="bg-white border-2 border-black p-4 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] border-l-4 border-l-yellow-500">
          <p className="text-gray-500 font-bold uppercase text-xs mb-1">Vencendo nos próximos 7 dias</p>
          <p className="text-2xl font-black text-yellow-700">5 Alunos</p>
        </div>
      </div>

      {/* Tabela de Controle */}
      <div className="bg-white border-2 border-black rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] overflow-hidden">
        <div className="p-4 border-b-2 border-black flex justify-between items-center bg-gray-100">
          <h3 className="font-bold text-lg uppercase tracking-wide">Status de Assinaturas</h3>
          <button className="flex items-center gap-2 text-sm font-bold uppercase border-2 border-black px-3 py-1 rounded hover:bg-black hover:text-white transition-colors">
            <Filter size={16} /> Filtrar Status
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse whitespace-nowrap">
            <thead>
              <tr className="border-b-2 border-black bg-white">
                <th className="p-4 font-bold uppercase text-xs text-gray-600">Aluno</th>
                <th className="p-4 font-bold uppercase text-xs text-gray-600">Plano Selecionado</th>
                <th className="p-4 font-bold uppercase text-xs text-gray-600">Método</th>
                <th className="p-4 font-bold uppercase text-xs text-gray-600">Data de Entrada</th>
                <th className="p-4 font-bold uppercase text-xs text-gray-600">Vencimento</th>
                <th className="p-4 font-bold uppercase text-xs text-gray-600">Status</th>
                <th className="p-4 font-bold uppercase text-xs text-gray-600 text-center">Ação</th>
              </tr>
            </thead>
            <tbody>
              {pagamentosAlunos.map((item) => (
                <tr key={item.id} className="border-b border-gray-200 hover:bg-gray-50 transition-colors">
                  <td className="p-4 font-bold text-base">{item.aluno}</td>
                  <td className="p-4 font-medium text-gray-700">{item.plano}</td>
                  <td className="p-4 text-gray-600 font-medium">{item.forma}</td>
                  <td className="p-4 text-gray-500 font-medium">{item.dataEntrada}</td>
                  <td className="p-4 font-bold text-gray-800">{item.vencimento}</td>
                  <td className="p-4">{renderStatus(item.status)}</td>
                  <td className="p-4 text-center">
                    <button className="text-xs font-bold uppercase border-2 border-black px-3 py-1 rounded hover:bg-black hover:text-white transition-colors">
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