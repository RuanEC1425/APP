import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import AdminLayout from '/Users/Ruan Emanuel/Desktop/Consultoria/APP/src/app-web-consultoria/src/components/Layout'; // Ajuste o caminho se necessário
import Registrar from './registrar';
import Calendario from './calendario';
import './index.tsx';
import '/Users/Ruan Emanuel/Desktop/Consultoria/APP/src/app-web-consultoria/index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<AdminLayout />}>
          {/* Rota inicial / Home vazia */}
          <Route index element={
            <div className="opacity-20 flex flex-col items-center justify-center w-full h-full">
               <svg width="200" height="200" viewBox="0 0 100 100" className="text-red-600">
                <polygon points="50,5 95,25 95,75 50,95 5,75 5,25" fill="none" stroke="currentColor" strokeWidth="2"/>
                <path d="M60,10 L45,50 L65,50 L40,90 L50,50 L35,50 Z" fill="currentColor"/>
              </svg>
            </div>
          } />
          <Route path="registrar" element={<Registrar />} />
          <Route path="calendario" element={<Calendario />} />
          {/* Adicionaremos as outras rotas depois */}
        </Route>
      </Routes>
    </BrowserRouter>
  </React.StrictMode>
);
