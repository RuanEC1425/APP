import { Calendar as CalendarIcon, Clock, User, Plus } from 'lucide-react';

export default function Calendario() {
  // Dados simulados baseados no nosso DER (Tabela Calendar_Events)
  const compromissosHoje = [
    { id: 1, tipo: 'Diagnóstico', aluno: 'Elizangela', hora: '14:00', status: 'pendente' },
    { id: 2, tipo: 'Análise de Protocolo', aluno: 'Maycon', hora: '16:30', status: 'concluido' },
  ];

  return (
    <div className="w-full max-w-5xl mx-auto space-y-6">
      
      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-2.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
            <CalendarIcon size={22} />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">Agenda e Compromissos</h1>
            <p className="text-zinc-400 text-sm mt-1">Controle de diagnósticos e protocolos</p>
          </div>
        </div>
        <button className="flex items-center gap-2 bg-red-500 hover:bg-red-600 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.2)]">
          <Plus size={18} /> Novo Evento
        </button>
      </div>

      {/* Grade Principal */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Coluna 1: Mini Calendário e Filtros (Layout Placeholder) */}
        <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <h3 className="text-zinc-100 font-medium border-b border-zinc-800/80 pb-3 mb-4">Agosto 2026</h3>
          <div className="text-center p-8 border border-dashed border-zinc-700 rounded-lg text-sm text-zinc-500">
            (Componente de Calendário Mensal entrará aqui)
          </div>
        </div>

        {/* Coluna 2 e 3: Lista de Eventos do Dia */}
        <div className="lg:col-span-2 bg-[#121214] border border-zinc-800/80 rounded-xl p-6">
          <h3 className="text-zinc-100 font-medium border-b border-zinc-800/80 pb-3 mb-4">Compromissos de Hoje</h3>
          
          <div className="space-y-3">
            {compromissosHoje.map((evento) => (
              <div key={evento.id} className="flex items-center justify-between p-4 bg-[#18181b] border border-zinc-800 rounded-lg hover:border-red-500/40 transition-colors">
                <div className="flex items-center gap-4">
                  <div className="bg-zinc-800/60 p-2.5 rounded-lg border border-zinc-700/60">
                    <Clock size={18} className="text-zinc-400" />
                  </div>
                  <div>
                    <p className="font-semibold text-lg text-white">{evento.hora}</p>
                    <p className="text-xs font-medium text-red-500 uppercase tracking-wider">{evento.tipo}</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-2">
                  <User size={14} className="text-zinc-500" />
                  <span className="text-sm font-medium text-zinc-300">{evento.aluno}</span>
                </div>

                <div>
                  <button className="text-xs font-medium text-zinc-400 border border-zinc-800 px-3 py-1.5 rounded-lg hover:text-red-500 hover:border-red-500/50 hover:bg-red-500/10 transition-colors">
                    Ver Detalhes
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
}
