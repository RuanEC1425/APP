import { Users, Search, Filter, TrendingUp, FileText, ArrowRight, Activity } from 'lucide-react';
import { useNavigate } from 'react-router-dom';


export default function Alunos() {
  const navigate = useNavigate();
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
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-2.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
            <Users size={22} />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">Galeria de Alunos</h1>
            <p className="text-zinc-400 text-sm mt-1">Gerencie perfis e acompanhe evoluções</p>
          </div>
        </div>
        
        <div className="flex gap-3 w-full md:w-auto">
          <div className="flex flex-1 items-center bg-[#18181b] border border-zinc-800 rounded-lg px-3 focus-within:border-red-500 transition-colors">
            <Search size={16} className="text-zinc-500" />
            <input 
              type="text" 
              placeholder="Buscar pelo nome..." 
              className="py-2 ml-2 bg-transparent text-sm text-zinc-200 placeholder-zinc-500 focus:outline-none w-full md:w-48"
            />
          </div>
          <button className="flex items-center justify-center p-2.5 border border-zinc-800 bg-[#121214] text-zinc-400 rounded-lg hover:text-zinc-100 hover:border-zinc-700 transition-colors">
            <Filter size={18} />
          </button>
        </div>
      </div>

      {/* Galeria / Grid de Perfis */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        
        {alunosGaleria.map((aluno) => (
          /* Container do Card com a classe 'group' para ativar efeitos de hover nos elementos internos */
          <div key={aluno.id} className="group relative bg-[#121214] border border-zinc-800/80 rounded-xl h-72 hover:border-red-500/50 hover:shadow-[0_0_25px_rgba(239,68,68,0.12)] transition-all duration-300 overflow-hidden cursor-pointer">
            
            {/* ESTADO NORMAL (O que aparece antes de passar o mouse) */}
            <div className="absolute inset-0 p-6 flex flex-col items-center justify-center text-center transition-opacity duration-300 group-hover:opacity-0">
              <img 
                src={aluno.foto} 
                alt={`Foto de ${aluno.nome}`} 
                className="w-24 h-24 rounded-full border-2 border-zinc-700 ring-4 ring-zinc-800/50 mb-4 object-cover"
              />
              <h3 className="text-lg font-semibold text-white tracking-tight">{aluno.nome}</h3>
              <p className="text-zinc-500 text-xs font-medium uppercase tracking-widest mt-1">{aluno.plano}</p>
              <div className="mt-4 flex items-center gap-2">
                <span className="bg-zinc-800/60 border border-zinc-700/60 px-3 py-1 rounded-full text-[11px] font-medium text-zinc-300">
                  {aluno.objetivo}
                </span>
                <span className={`px-3 py-1 rounded-full text-[11px] font-medium border ${
                  aluno.noCaminho
                    ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
                    : 'bg-red-500/10 text-red-400 border-red-500/20'
                }`}>
                  {aluno.noCaminho ? 'Na meta' : 'Acima da meta'}
                </span>
              </div>
            </div>

            {/* ESTADO HOVER (A camada escura que sobe quando passa o mouse) */}
            <div className="absolute inset-0 bg-[#18181b] p-6 flex flex-col justify-between translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-in-out">
              
              <div className="space-y-4">
                {/* Informação de Peso com Lógica de Cor */}
                <div className="border-b border-zinc-800 pb-4">
                  <p className="text-zinc-500 font-medium uppercase tracking-wider text-[11px] mb-2 flex items-center gap-1.5">
                    <Activity size={13} /> Peso Atual vs Meta
                  </p>
                  <div className="flex items-end gap-2">
                    <span className={`text-3xl font-bold ${aluno.noCaminho ? 'text-emerald-400' : 'text-red-400'}`}>
                      {aluno.pesoAtual}
                    </span>
                    <span className="text-zinc-500 font-medium text-sm mb-1">
                      / {aluno.meta}
                    </span>
                  </div>
                </div>

                {/* Informação da Anamnese */}
                <div>
                  <p className="text-zinc-500 font-medium uppercase tracking-wider text-[11px] mb-1.5 flex items-center gap-1.5">
                    <FileText size={13} /> Anamnese Base
                  </p>
                  <p className="font-medium text-zinc-100">{aluno.anamnese}</p>
                </div>
              </div>

              {/* Botão/Link para a Sub-aba de Gráficos */}
              <button 
                className="w-full flex items-center justify-between bg-red-500 hover:bg-red-600 text-white text-sm px-4 py-2.5 rounded-lg font-medium transition-colors shadow-[0_0_15px_rgba(239,68,68,0.25)] mt-auto"
                onClick={() => navigate(`/alunos/${aluno.id}`)}
              >
                <span className="flex items-center gap-2">
                  <TrendingUp size={18} /> Ver Gráficos
                </span>
                <ArrowRight size={18} />
              </button>

            </div>
          </div>
        ))}

      </div>
    </div>
  );
}
