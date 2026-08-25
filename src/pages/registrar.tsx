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

  return (
    <div className="w-full max-w-4xl mx-auto bg-white border-2 border-black rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] overflow-hidden">
      
      {/* Cabeçalho da Página */}
      <div className="bg-gray-100 border-b-2 border-black p-6 flex items-center gap-3">
        <UserPlus size={28} className="text-red-600" />
        <h2 className="text-2xl font-bold uppercase tracking-wider">Registrar Novo Aluno</h2>
      </div>

      {/* Formulário */}
      <form onSubmit={handleSubmit} className="p-8 space-y-8">
        
        {/* Seção 1: Dados Pessoais */}
        <div>
          <h3 className="text-lg font-bold border-b-2 border-gray-200 pb-2 mb-4 flex items-center gap-2">
            <UserPlus size={20} className="text-gray-500" />
            Dados Pessoais
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="col-span-2 md:col-span-1">
              <label className="block text-sm font-bold text-gray-700 mb-2 uppercase">Nome Completo</label>
              <input 
                type="text" name="nomeCompleto" required
                value={formData.nomeCompleto}
                onChange={handleChange}
                className="w-full p-3 border-2 border-black rounded focus:outline-none focus:ring-2 focus:ring-red-600 transition-all"
                placeholder="Ex: João da Silva"
              />
            </div>
            
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-2 uppercase">CPF</label>
              <input 
                type="text" name="cpf" required
                value={formData.cpf}
                onChange={handleChange}
                className="w-full p-3 border-2 border-black rounded focus:outline-none focus:ring-2 focus:ring-red-600 transition-all"
                placeholder="000.000.000-00"
              />
            </div>

            <div>
              <label className="block text-sm font-bold text-gray-700 mb-2 uppercase">Número de Telefone</label>
              <input 
                type="text" name="telefone" required
                value={formData.telefone}
                onChange={handleChange}
                className="w-full p-3 border-2 border-black rounded focus:outline-none focus:ring-2 focus:ring-red-600 transition-all"
                placeholder="(00) 00000-0000"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm font-bold text-gray-700 mb-2 uppercase">Endereço Completo</label>
              <input 
                type="text" name="endereco" required
                value={formData.endereco}
                onChange={handleChange}
                className="w-full p-3 border-2 border-black rounded focus:outline-none focus:ring-2 focus:ring-red-600 transition-all"
                placeholder="Rua, Número, Bairro, Cidade - Estado"
              />
            </div>
          </div>
        </div>

        {/* Seção 2: Plano e Pagamento */}
        <div>
          <h3 className="text-lg font-bold border-b-2 border-gray-200 pb-2 mb-4 flex items-center gap-2">
            <CreditCard size={20} className="text-gray-500" />
            Detalhes do Plano
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            
            <div>
              <label className="block text-sm font-bold text-gray-700 mb-2 uppercase">Plano Selecionado</label>
              <select 
                name="plano" 
                value={formData.plano}
                onChange={handleChange}
                className="w-full p-3 border-2 border-black rounded focus:outline-none focus:ring-2 focus:ring-red-600 bg-white font-medium"
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
              <label className="block text-sm font-bold text-gray-700 mb-2 uppercase">Forma de Pagamento</label>
              <select 
                name="formaPagamento" 
                value={formData.formaPagamento}
                onChange={handleChange}
                className="w-full p-3 border-2 border-black rounded focus:outline-none focus:ring-2 focus:ring-red-600 bg-white font-medium"
              >
                <option value="pix">PIX</option>
                <option value="cartao_credito">Cartão de Crédito</option>
                <option value="cartao_debito">Cartão de Débito</option>
              </select>
            </div>

          </div>
        </div>

        {/* Botão de Salvar */}
        <div className="pt-4 border-t-2 border-gray-200 flex justify-end">
          <button 
            type="submit"
            className="flex items-center gap-2 bg-black text-white px-8 py-4 rounded font-bold uppercase tracking-wider hover:bg-red-600 transition-colors"
          >
            <Save size={20} />
            Salvar Registro
          </button>
        </div>

      </form>
    </div>
  );
}