import { Settings } from 'lucide-react';

export default function Definicoes() {
  return (
    <div className="w-full max-w-4xl mx-auto space-y-6">
      <div className="flex items-center gap-4">
        <div className="p-2.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
          <Settings size={22} />
        </div>
        <div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Definições</h1>
          <p className="text-zinc-400 text-sm mt-1">Configurações gerais da plataforma e preferências da conta</p>
        </div>
      </div>

      <div className="bg-[#121214] border border-zinc-800/80 rounded-xl p-12 text-center">
        <p className="text-zinc-300 font-medium">Painel de Configurações</p>
        <p className="text-zinc-500 text-xs mt-1">As futuras configurações da aplicação serão adicionadas aqui.</p>
      </div>
    </div>
  );
}
