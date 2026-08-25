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
      <div className="flex justify-between items-center bg-white border-2 border-black p-6 rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]">
        <div className="flex items-center gap-3">
          <CalendarIcon size={32} className="text-red-600" />
          <div>
            <h2 className="text-2xl font-bold uppercase tracking-wider">Agenda e Compromissos</h2>
            <p className="text-gray-500 font-medium">Controle de diagnósticos e protocolos</p>
          </div>
        </div>
        <button className="flex items-center gap-2 bg-black text-white px-4 py-2 rounded font-bold uppercase hover:bg-red-600 transition-colors">
          <Plus size={20} /> Novo Evento
        </button>
      </div>

      {/* Grade Principal */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Coluna 1: Mini Calendário e Filtros (Layout Placeholder) */}
        <div className="bg-white border-2 border-black rounded-lg p-6 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
          <h3 className="font-bold text-lg border-b-2 border-gray-200 pb-2 mb-4">Agosto 2026</h3>
          <div className="text-center p-8 border-2 border-dashed border-gray-300 text-gray-500 font-medium">
            (Componente de Calendário Mensal entrará aqui)
          </div>
        </div>

        {/* Coluna 2 e 3: Lista de Eventos do Dia */}
        <div className="lg:col-span-2 bg-white border-2 border-black rounded-lg p-6 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
          <h3 className="font-bold text-lg border-b-2 border-gray-200 pb-2 mb-4">Compromissos de Hoje</h3>
          
          <div className="space-y-4">
            {compromissosHoje.map((evento) => (
              <div key={evento.id} className="flex items-center justify-between p-4 border-2 border-black rounded hover:bg-gray-50 transition-colors">
                <div className="flex items-center gap-4">
                  <div className="bg-gray-100 p-3 rounded-full border border-gray-300">
                    <Clock size={20} className="text-gray-700" />
                  </div>
                  <div>
                    <p className="font-bold text-lg">{evento.hora}</p>
                    <p className="text-sm font-medium text-red-600 uppercase tracking-wide">{evento.tipo}</p>
                  </div>
                </div>
                
                <div className="flex items-center gap-2">
                  <User size={16} className="text-gray-500" />
                  <span className="font-bold text-gray-700">{evento.aluno}</span>
                </div>

                <div>
                  <button className="border-2 border-black px-4 py-1 text-sm font-bold uppercase hover:bg-black hover:text-white transition-colors">
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