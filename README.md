# 📱 REC Consultoria Online — Aplicativo Mobile (Flutter)

Aplicativo mobile multiplataforma (iOS, Android, Web e Desktop) da **REC Consultoria Online**, construído na **Etapa 3** com o **Design System Dark Mode** (`#0C0C0E`, `#121214`, `#18181B`, `#EF4444` e bordas `#27272A`) e modelos 100% compatíveis para sincronização com o painel Web do professor (`app-web-consultoria`).

## Estrutura das 4 Abas do Aluno

1. **Home (`lib/screens/home_screen.dart`)**
   - **Canto superior esquerdo**: Avatar interativo do aluno alternando entre `'Home'`, `'Community'` e `'You'` (e troca rápida entre os perfis sincronizados: *Elizangela*, *Maycon* e *Carlos Souza*).
   - **Canto superior direito**:
     - **Agenda Comparativa**: compara dias treinados vs. não treinados e metas batidas vs. não batidas no período selecionado (7, 14 ou 28 dias).
     - **Sininho de Notificações**: avisos de alterações de treino feitas pelo treinador, mensagens, curtidas/comentários da comunidade e atalho para Anamnese pendente.
   - **Botão `"Iniciar sessão de treino"`**: permite montar e registrar um treino avulso fora do planejamento.
   - **Card de Último Treino Feito**: exibe nome do treino, peso levantado (`kg`), quantidade de séries e duração, com ações diretas de **Editar**, **Compartilhar** (na aba `Community`), **Salvar** e **Excluir**.

2. **Treino (`lib/screens/treino_screen.dart`)**
   - Fichas de treino prescritas pelo treinador (Treino A, B, C, D) sincronizadas com o banco de exercícios.
   - Suporte completo aos tipos de série: `Warm-up Set`, `Feeder Set`, `Working Set`, `Top Set`, `Backoff Set`, `Drop Set`, `Super Set`, `Cluster Set` e tipos customizados cadastrados pelo treinador.
   - Exibição da faixa de repetições sugerida, técnica avançada, registro de carga (`kg`), checkbox de série concluída e cronômetro integrado de descanso (`90s`, `60s`, `+15s`, `-15s`, `Pular`).

3. **Dieta (`lib/screens/dieta_screen.dart`)**
   - **Meta de Água Diária** integrada dentro da aba (`+250ml`, `+500ml` e barra de progresso).
   - **Gráfico de Calorias Ingeridas** e **Gráfico de Macronutrientes**.
   - **Dieta Sugerida pelo Treinador**: pré-visualização dos alimentos e quantidades por refeição; confirmação com 1 toque ou opção **"Fora da dieta / Outro alimento"** para registrar substituição.
   - **Cadastro Livre de Alimentos Consumidos** ao longo do dia.
   - **Lista Completa de Macro e Micronutrientes Ingeridos** abaixo dos gráficos.

4. **You (`lib/screens/you_screen.dart` & `lib/widgets/muscle_body_3d_widget.dart`)**
   - **Visão Geral**: duração, volume e treinos feitos na semana (gráfico comparativo), gráfico de recuperação muscular por grupamento, **Ilustração Anatômica 3D (Frente e Costas)** dos grupamentos trabalhados na semana, calendário mensal de treinos e **Recordes Pessoais (PRs)**.
   - **Exercícios Feitos**: gráfico de evolução das marcas de pesos batidos por Semana, Mês e Ano.
   - **Medidas**: registro e acompanhamento de medidas por grupamento muscular.
   - **Fotos & Check-in**: fotos de evolução (`Frente`, `Costas`, `Perfil`) e **Wizard de Anamnese** (`Corporal`, `Alimentar`, `Espacial`).

## Utilitário CLI de Sincronização (`bin/rec_sync_cli.dart`)

```bash
dart run bin/rec_sync_cli.dart summary
dart run bin/rec_sync_cli.dart export --student 1 --output sync_elizangela.json
```
