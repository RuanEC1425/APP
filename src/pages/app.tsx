import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';


// Imports relativos!
import AdminLayout from '../components/Layout'; 
import Registrar from './registrar';
import Calendario from './calendario';
import Alunos from './alunos';
import Formulario from './formulario';
import Pagamentos from './pagamentos';
import Treinos from './treinos';
import DashboardOverview from './index';
import NovoTreino from './NovoTreino';
import AlunoPerfil from './AlunoPerfil';
import FormularioVisualizar from './FormularioVisualizar';
import Definicoes from './definicoes';
import '../index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<AdminLayout />}>
           <Route index element={<DashboardOverview />} />
           <Route path="registrar" element={<Registrar />} />
           <Route path="calendario" element={<Calendario />} />
           <Route path="alunos" element={<Alunos />} />
           <Route path="formularios" element={<Formulario />} />
           <Route path="pagamentos" element={<Pagamentos />} />
           <Route path="treinos" element={<Treinos />} />
           <Route path="novo-treino" element={<NovoTreino />} />
           <Route path="alunos/:id" element={<AlunoPerfil />} />
           <Route path="formularios/:id" element={<FormularioVisualizar />} />
           <Route path="definicoes" element={<Definicoes />} />
           
        </Route>
      </Routes>
    </BrowserRouter>
  </React.StrictMode>
);