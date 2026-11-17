import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, CheckCircle, XCircle, Clock, User, CalendarDays, Activity, Utensils, MapPin } from 'lucide-react';
import { formulariosDetalhe } from '../data/mock';
import type { StatusFormulario } from '../data/mock';

const iconeSecao = {
  'Anamnese Corporal': Activity,
  'Anamnese Alimentar': Utensils,
  'Anamnese Espacial': MapPin,
} as const;

const statusInfo: Record<StatusFormulario, { classe: string; icon: typeof Clock }> = {
  Pendente: { classe: 'bg-amber-500/10 text-amber-400 border-amber-500/20', icon: Clock },
  Analisado: { classe: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20', icon: CheckCircle },
  Negado: { classe: 'bg-red-500/10 text-red-400 border-red-500/20', icon: XCircle },
};

export default function FormularioVisualizar() {
  const { id } = useParams();
  const formulario = formulariosDetalhe.find((f) => f.id === Number(id));
  // Estado local apenas para refletir a ação na tela (sem persistência por enquanto)
  const [status, setStatus] = useState<StatusFormulario | undefined>(formulario?.status);

  if (!formulario || !status) {
    return (
      <div className="w-full max-w-3xl mx-auto bg-[#121214] border border-zinc-800/80 rounded-xl p-10 text-center">
        <p className="text-zinc-300 font-medium">Formulário não encontrado.</p>
        <Link to="/formularios" className="inline-flex items-center gap-2 mt-4 text-sm text-red-500 hover:text-red-400">
          <ArrowLeft size={16} /> Voltar para a central
        </Link>
      </div>
    );
  }

  const StatusIcon = statusInfo[status].icon;

  return (
    <div className="w-full max-w-4xl mx-auto space-y-6 pb-28">

      {/* Cabeçalho */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <Link to="/formularios" className="p-2.5 border border-zinc-800 bg-[#121214] rounded-lg text-zinc-400 hover:text-zinc-100 hover:border-zinc-700 transition-colors">
            <ArrowLeft size={20} />
          </Link>
          <div>
            <h1 className="text-3xl font-bold text-white tracking-tight">{formulario.tipo}</h1>
            <div className="flex flex-wrap items-center gap-3 mt-1.5 text-xs text-zinc-400">
              <span className="flex items-center gap-1.5"><User size={13} className="text-zinc-500" /> {formulario.aluno}</span>
              <span className="flex items-center gap-1.5"><CalendarDays size={13} className="text-zinc-500" /> Enviado em {formulario.data}</span>
            </div>
          </div>
        </div>
        <span className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border ${statusInfo[status].classe}`}>
          <StatusIcon size={14} /> {status}
        </span>
      </div>

      {/* Seções de respostas */}
      {formulario.secoes.map((secao) => {
        const Icone = iconeSecao[secao.titulo];
        return (
          <div key={secao.titulo} className="bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
            <div className="px-6 py-4 border-b border-zinc-800/80 flex items-center gap-3">
              <div className="p-2 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
                <Icone size={16} />
              </div>
              <h3 className="text-zinc-100 font-medium">{secao.titulo}</h3>
            </div>
            <dl className="divide-y divide-zinc-800/50">
              {secao.respostas.map((r) => (
                <div key={r.pergunta} className="px-6 py-4 grid grid-cols-1 md:grid-cols-5 gap-1 md:gap-6">
                  <dt className="md:col-span-2 text-xs font-medium uppercase tracking-wider text-zinc-500 md:pt-0.5">{r.pergunta}</dt>
                  <dd className="md:col-span-3 text-sm text-zinc-200 leading-relaxed">{r.resposta}</dd>
                </div>
              ))}
            </dl>
          </div>
        );
      })}

      {/* Barra de ações rápidas */}
      <div className="fixed bottom-6 left-1/2 md:left-[calc(50%+8rem)] -translate-x-1/2 z-20 flex items-center gap-3 bg-[#121214]/90 backdrop-blur-md border border-zinc-800 rounded-xl p-2 shadow-2xl shadow-black/50">
        <span className="hidden sm:block text-xs text-zinc-500 px-3">Decisão do professor</span>
        <button
          onClick={() => setStatus('Negado')}
          disabled={status === 'Negado'}
          className="flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-lg border border-zinc-800 text-zinc-300 hover:text-red-400 hover:border-red-500/50 hover:bg-red-500/10 disabled:opacity-40 disabled:pointer-events-none transition-colors"
        >
          <XCircle size={16} /> Recusar (Negado)
        </button>
        <button
          onClick={() => setStatus('Analisado')}
          disabled={status === 'Analisado'}
          className="flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-lg bg-red-500 hover:bg-red-600 text-white shadow-[0_0_15px_rgba(239,68,68,0.25)] disabled:opacity-40 disabled:pointer-events-none transition-colors"
        >
          <CheckCircle size={16} /> Aprovar (Analisado)
        </button>
      </div>

    </div>
  );
}
