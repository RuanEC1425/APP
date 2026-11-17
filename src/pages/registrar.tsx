import { useState } from 'react';
import type { ChangeEvent, FormEvent } from 'react';
import { Save, UserPlus, CreditCard } from 'lucide-react';

export default function Registrar() {
  const [formData, setFormData] = useState({
    nomeCompleto: '',
    cpf: '',
    telefone: '',
    endereco: '',
    plano: 'mensal',
    formaPagamento: 'pix',
  });

  // Tipagem adicionada para os eventos de Input e Select no TypeScript
  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // Tipagem adicionada para o evento de Submit do formulário no TypeScript
  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    console.log('Dados a serem salvos:', formData);
    alert('Aluno registrado com sucesso!');
  };

  // Classes padrão dos campos no tema escuro
  const fieldClass = 'w-full p-3 text-sm bg-[#18181b] border border-zinc-800 text-zinc-100 placeholder-zinc-600 rounded-lg focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500/30 transition-all';
  const labelClass = 'block text-xs font-medium text-zinc-400 mb-2';

  return (
    <div className="w-full max-w-4xl mx-auto bg-[#121214] border border-zinc-800/80 rounded-xl overflow-hidden">
      
      {/* Cabeçalho da Página */}
      <div className="border-b border-zinc-800/80 p-6 flex items-center gap-4">
        <div className="p-2.5 rounded-lg bg-red-500/10 border border-red-500/20 text-red-500">
          <UserPlus size={22} />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight">Registrar Novo Aluno</h1>
          <p className="text-zinc-400 text-sm mt-0.5">Cadastre os dados pessoais e o plano contratado</p>
        </div>
      </div>

      {/* Formulário */}
      <form onSubmit={handleSubmit} className="p-8 space-y-8">
        
        {/* Seção 1: Dados Pessoais */}
        <div>
          <h3 className="text-sm font-medium text-zinc-100 border-b border-zinc-800/80 pb-3 mb-5 flex items-center gap-2">
            <UserPlus size={16} className="text-zinc-500" />
            Dados Pessoais
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="col-span-2 md:col-span-1">
              <label className={labelClass}>Nome Completo</label>
              <input 
                type="text" name="nomeCompleto" required
                value={formData.nomeCompleto}
                onChange={handleChange}
                className={fieldClass}
                placeholder="Ex: João da Silva"
              />
            </div>
            
            <div>
              <label className={labelClass}>CPF</label>
              <input 
                type="text" name="cpf" required
                value={formData.cpf}
                onChange={handleChange}
                className={fieldClass}
                placeholder="000.000.000-00"
              />
            </div>

            <div>
              <label className={labelClass}>Número de Telefone</label>
              <input 
                type="text" name="telefone" required
                value={formData.telefone}
                onChange={handleChange}
                className={fieldClass}
                placeholder="(00) 00000-0000"
              />
            </div>

            <div className="col-span-2">
              <label className={labelClass}>Endereço Completo</label>
              <input 
                type="text" name="endereco" required
                value={formData.endereco}
                onChange={handleChange}
                className={fieldClass}
                placeholder="Rua, Número, Bairro, Cidade - Estado"
              />
            </div>
          </div>
        </div>

        {/* Seção 2: Plano e Pagamento */}
        <div>
          <h3 className="text-sm font-medium text-zinc-100 border-b border-zinc-800/80 pb-3 mb-5 flex items-center gap-2">
            <CreditCard size={16} className="text-zinc-500" />
            Detalhes do Plano
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            
            <div>
              <label className={labelClass}>Plano Selecionado</label>
              <select 
                name="plano" 
                value={formData.plano}
                onChange={handleChange}
                className={fieldClass}
              >
                <option value="mensal">Mensal</option>
                <option value="trimestral">Trimestral</option>
                <option value="semestral">Semestral</option>
                <option value="anual">Anual</option>
                <option value="planilha_personalizada">Planilha Personalizada</option>
                <option value="diagnostico">Diagnóstico</option>
              </select>
            </div>

            <div>
              <label className={labelClass}>Forma de Pagamento</label>
              <select 
                name="formaPagamento" 
                value={formData.formaPagamento}
                onChange={handleChange}
                className={fieldClass}
              >
                <option value="pix">PIX</option>
                <option value="cartao_credito">Cartão de Crédito</option>
                <option value="cartao_debito">Cartão de Débito</option>
              </select>
            </div>

          </div>
        </div>

        {/* Botão de Salvar */}
        <div className="pt-6 border-t border-zinc-800/80 flex justify-end">
          <button 
            type="submit"
            className="flex items-center gap-2 bg-red-500 hover:bg-red-600 text-white text-sm font-medium px-6 py-3 rounded-lg transition-colors shadow-[0_0_15px_rgba(239,68,68,0.25)]"
          >
            <Save size={18} />
            Salvar Registro
          </button>
        </div>

      </form>
    </div>
  );
}
