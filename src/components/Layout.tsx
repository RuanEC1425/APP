import { Outlet, Link, useLocation } from 'react-router-dom';
import { Search, Bell, Sun, LayoutDashboard, Activity, Users, UserPlus, Settings, FileText, Dumbbell } from 'lucide-react';

export default function AdminLayout() {
  const location = useLocation();

  const menuItems = [
    { name: 'Visão Geral', icon: LayoutDashboard, path: '/' },
    { name: 'Analytics', icon: Activity, path: '/pagamentos' },
    { name: 'Relatórios', icon: FileText, path: '/formularios' },
    { name: 'Alunos', icon: Users, path: '/alunos' },
    { name: 'Novo Aluno', icon: UserPlus, path: '/registrar' },
    { name: 'Treinos', icon: Dumbbell, path: '/treinos' },
    { name: 'Definições', icon: Settings, path: '/definicoes' },
  ];

  return (
    <div className="flex h-screen overflow-hidden bg-[#0c0c0e] text-zinc-300 font-sans">
      
      {/* Sidebar Lateral */}
      <aside className="w-64 flex-shrink-0 border-r border-zinc-800/60 bg-[#121214] flex flex-col">
        {/* Logótipo */}
        <div className="h-16 flex items-center px-6 gap-3 border-b border-zinc-800/60">
          <div className="bg-red-500 text-white font-bold p-1.5 rounded text-sm">R</div>
          <span className="text-white font-bold tracking-wide">REC <span className="text-zinc-500 font-normal text-xs uppercase tracking-widest ml-1">Admin</span></span>
        </div>

        {/* Navegação */}
        <nav className="flex-1 px-3 py-6 space-y-1">
          {menuItems.map((item) => {
            const isActive = item.path === '/'
              ? location.pathname === '/'
              : location.pathname === item.path || location.pathname.startsWith(`${item.path}/`);
            return (
              <Link
                key={item.name}
                to={item.path}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all ${
                  isActive 
                    ? 'bg-red-500/10 text-red-500' 
                    : 'text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800/50'
                }`}
              >
                <item.icon size={18} className={isActive ? 'text-red-500' : ''} />
                <span className="font-medium text-sm">{item.name}</span>
              </Link>
            );
          })}
        </nav>

        {/* Módulo de Quota / Status (Baseado na imagem) */}
        <div className="p-4 mx-3 mb-4 rounded-xl bg-zinc-800/30 border border-zinc-800/60">
          <p className="text-sm text-zinc-100 font-medium mb-1">REC Pro</p>
          <p className="text-xs text-zinc-500 mb-3">72% do limite utilizado</p>
          <div className="h-1.5 w-full bg-zinc-800 rounded-full overflow-hidden">
            <div className="h-full bg-red-500 w-[72%]"></div>
          </div>
        </div>
      </aside>

      {/* Área Principal de Conteúdo */}
      <div className="flex-1 flex flex-col overflow-hidden">
        
        {/* Cabeçalho (Top Bar) */}
        <header className="h-16 border-b border-zinc-800/60 bg-[#0c0c0e]/80 backdrop-blur-md flex items-center justify-between px-8">
          <div className="flex items-center w-96 bg-[#18181b] border border-zinc-800 rounded-md px-3 py-1.5">
            <Search size={16} className="text-zinc-500" />
            <input 
              type="text" 
              placeholder="Pesquisar métricas, alunos..." 
              className="bg-transparent border-none text-sm text-zinc-200 placeholder-zinc-500 focus:outline-none ml-2 w-full"
            />
            <span className="text-[10px] bg-red-500/20 text-red-500 px-1.5 py-0.5 rounded font-bold tracking-wider">LIVE</span>
          </div>

          <div className="flex items-center gap-4">
            <span className="text-sm text-zinc-400">19 Out, 2026</span>
            <button className="p-2 text-zinc-400 hover:text-zinc-100 transition-colors"><Sun size={18} /></button>
            <button className="p-2 text-zinc-400 hover:text-zinc-100 transition-colors relative">
              <Bell size={18} />
              <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
            </button>
            <div className="w-8 h-8 rounded-full bg-red-600 text-white flex items-center justify-center font-bold text-xs ml-2 cursor-pointer shadow-[0_0_10px_rgba(239,68,68,0.3)]">
              RE
            </div>
          </div>
        </header>

        {/* Conteúdo Dinâmico (Páginas) */}
        <main className="flex-1 overflow-y-auto p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}