import { Users, Search, Filter, TrendingUp, FileText, ArrowRight, Activity } from 'lucide-react';


export default function Alunos() {
  // Dados simulados da galeria
  const alunosGaleria = [
    {
      id: 1,
      nome: 'Elizangela',
      plano: 'Trimestral',
      objetivo: 'Emagrecimento',
      pesoAtual: '68 kg',
      meta: '60 kg',
      noCaminho: true, // P
      anamnese: 'Anamnese Corporal',
      foto: 'https://i.pravatar.cc/150?u=elizangela'
    },
    {
      id: 2,
      nome: 'Maycon',
      plano: 'Mensal',
      objetivo: 'Hipertrofia',
      pesoAtual: '75 kg',
      meta: '82 kg',
      noCaminho: true, // 
      anamnese: 'Pré-seleção',
      foto: 'https://i.pravatar.cc/150?u=maycon'
    },
    {
      id: 3,
      nome: 'Carlos Souza',
      plano: 'Anual',
      objetivo: 'Emagrecimento',
      pesoAtual: '94 kg',
      meta: '85 kg',
      noCaminho: false, // 
      anamnese: 'Anamnese Alimentar',
      foto: 'https://i.pravatar.cc/150?u=carlos'
    }
  ];

  return (
    <div className="w-full max-w-7xl mx-auto space-y-6">
      
      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center bg-white border-2 border-black p-6 rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] gap-4">
        <div className="flex items-center gap-3">
          <Users size={32} className="text-red-600" />
          <div>
            <h2 className="text-2xl font-bold uppercase tracking-wider">Galeria de Alunos</h2>
            <p className="text-gray-500 font-medium">Gerencie perfis e acompanhe evoluções</p>
          </div>
        </div>
        
        <div className="flex gap-3 w-full md:w-auto">
          <div className="flex flex-1 items-center border-2 border-black rounded bg-gray-50 overflow-hidden">
            <div className="p-2 text-gray-500"><Search size={20} /></div>
            <input 
              type="text" 
              placeholder="Buscar pelo nome..." 
              className="p-2 bg-transparent focus:outline-none w-full md:w-48 font-medium"
            />
          </div>
          <button className="flex items-center justify-center p-2 bg-black text-white rounded hover:bg-gray-800 transition-colors">
            <Filter size={24} />
          </button>
        </div>
      </div>

      {/* Galeria / Grid de Perfis */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
        
        {alunosGaleria.map((aluno) => (
          /* Container do Card com a classe 'group' para ativar efeitos de hover nos elementos internos */
          <div key={aluno.id} className="group relative bg-white border-2 border-black rounded-lg h-72 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] transition-all overflow-hidden cursor-pointer">
            
            {/* ESTADO NORMAL (O que aparece antes de passar o mouse) */}
            <div className="absolute inset-0 p-6 flex flex-col items-center justify-center text-center transition-opacity duration-300 group-hover:opacity-0">
              <img 
                src={aluno.foto} 
                alt={`Foto de ${aluno.nome}`} 
                className="w-24 h-24 rounded-full border-4 border-black mb-4 object-cover"
              />
              <h3 className="text-xl font-black uppercase tracking-wide">{aluno.nome}</h3>
              <p className="text-gray-500 font-bold uppercase text-sm mt-1">{aluno.plano}</p>
              <div className="mt-4 bg-gray-100 border border-gray-300 px-3 py-1 rounded-full text-xs font-bold uppercase text-gray-600">
                {aluno.objetivo}
              </div>
            </div>

            {/* ESTADO HOVER (A camada escura que sobe quando passa o mouse) */}
            <div className="absolute inset-0 bg-gray-900 text-white p-6 flex flex-col justify-between translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-in-out">
              
              <div className="space-y-4">
                {/* Informação de Peso com Lógica de Cor */}
                <div className="border-b border-gray-700 pb-3">
                  <p className="text-gray-400 font-bold uppercase text-xs mb-1 flex items-center gap-1">
                    <Activity size={14} /> Peso Atual vs Meta
                  </p>
                  <div className="flex items-end gap-2">
                    <span className={`text-3xl font-black ${aluno.noCaminho ? 'text-green-400' : 'text-red-400'}`}>
                      {aluno.pesoAtual}
                    </span>
                    <span className="text-gray-500 font-medium text-sm mb-1">
                      / {aluno.meta}
                    </span>
                  </div>
                </div>

                {/* Informação da Anamnese */}
                <div>
                  <p className="text-gray-400 font-bold uppercase text-xs mb-1 flex items-center gap-1">
                    <FileText size={14} /> Anamnese Base
                  </p>
                  <p className="font-bold text-gray-100">{aluno.anamnese}</p>
                </div>
              </div>

              {/* Botão/Link para a Sub-aba de Gráficos */}
              <button 
                className="w-full flex items-center justify-between bg-red-600 text-white px-4 py-3 rounded border-2 border-transparent hover:bg-white hover:text-black hover:border-black font-bold uppercase tracking-wider transition-colors mt-auto"
                onClick={() => console.log(`Abrir gráficos do aluno ${aluno.id}`)}
              >
                <span className="flex items-center gap-2">
                  <TrendingUp size={20} /> Ver Gráficos
                </span>
                <ArrowRight size={20} />
              </button>

            </div>
          </div>
        ))}

      </div>
    </div>
  );
}