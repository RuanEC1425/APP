// src/components/AdminLayout.tsx (ou onde estiver o seu layout)
import { useState } from 'react';
import { Link, Outlet } from 'react-router-dom';
import { Menu, User, FileText, Calendar, Users, Dumbbell, CreditCard, UserPlus } from 'lucide-react';

export default function AdminLayout() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  const menuItems = [
    { name: 'REGISTRAR', icon: <UserPlus size={20} />, path: '/registrar' },
    { name: 'CALENDÁRIO', icon: <Calendar size={20} />, path: '/calendario' },
    { name: 'FORMULÁRIOS', icon: <FileText size={20} />, path: '/formularios' },
    { name: 'PAGAMENTOS', icon: <CreditCard size={20} />, path: '/pagamentos' },
    { name: 'ALUNOS', icon: <Users size={20} />, path: '/alunos' },
    { name: 'TREINOS', icon: <Dumbbell size={20} />, path: '/treinos' },
  ];

  return (
    <div className="flex h-screen bg-gray-50 font-sans text-gray-900">
      
      <aside className={`${isSidebarOpen ? 'w-64' : 'w-0 hidden'} bg-white border-r-2 border-black flex flex-col transition-all duration-300`}>
        <div className="p-6 border-b-2 border-black flex items-center gap-3">
          <div className="p-2 border-2 border-black rounded-full">
            <User size={24} />
          </div>
          <span className="font-bold tracking-wider">MUSCLE SCIENCE</span>
        </div>

        <nav className="flex-1 flex flex-col">
          {menuItems.map((item, index) => (
            <Link 
              key={index}
              to={item.path}
              className="flex items-center gap-3 p-4 border-b-2 border-black hover:bg-gray-100 transition-colors text-left font-semibold tracking-wide"
            >
              {item.icon}
              {item.name}
            </Link>
          ))}
        </nav>
      </aside>

      <main className="flex-1 flex flex-col relative overflow-hidden">
        <header className="p-4 flex items-center">
          <button onClick={() => setIsSidebarOpen(!isSidebarOpen)} className="p-2 hover:bg-gray-200 rounded-md transition-colors">
            <Menu size={32} />
          </button>
        </header>

        <div className="flex-1 overflow-y-auto p-8 flex justify-center">
          {/* O Outlet é onde as páginas (Registrar, Calendário, etc) vão aparecer! */}
          <Outlet /> 
        </div>
      </main>
    </div>
  );
}