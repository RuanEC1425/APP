import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rec_consultoria_mobile/rec_consultoria_mobile.dart';

void main() {
  group('Modelos, Estado e Sincronizacao JSON (Mobile -> Web)', () {
    test('Serializacao de Series, Exercicios, Dieta e Perfil para Web', () {
      final state = RecAppState();
      expect(state.students.length, 3);
      expect(state.activeStudent.name, 'Elizangela');

      // Testa serialização de todos os tipos de série (Warm-up, Feeder, Working, Top, Backoff, Drop, Super, Cluster, Custom)
      for (final st in SetType.values) {
        expect(SetType.fromKey(st.name), st);
      }

      final customSet = ExerciseSet(
        id: 'cs-1',
        index: 1,
        type: SetType.custom,
        customTypeLabel: 'Rest-Pause 20s',
        targetReps: '8+4+2',
        weightKg: 50,
        completedReps: 14,
        completed: true,
      );
      expect(customSet.displayTypeLabel, 'Rest-Pause 20s');
      expect(customSet.setVolumeKg, 700.0);
      final restoredSet = ExerciseSet.fromJson(customSet.toJson());
      expect(restoredSet.displayTypeLabel, 'Rest-Pause 20s');
      expect(restoredSet.weightKg, 50);

      // Testa workout plan roundtrip
      final firstPlan = state.activeWorkoutDay;
      final restoredPlan = WorkoutPlanDay.fromJson(firstPlan.toJson());
      expect(restoredPlan.code, firstPlan.code);
      expect(restoredPlan.exercises.length, firstPlan.exercises.length);

      // Testa sessão livre ("Iniciar sessão de treino") + editar + salvar + compartilhar + excluir
      final created = state.recordWorkoutSession(
        workoutName: 'Treino Livre de Deltoides',
        totalWeightLiftedKg: 3200,
        totalSets: 12,
        durationMinutes: 42,
        workedMuscles: [MuscleGroup.ombros],
        isFreeSession: true,
        notes: 'Foco lateral',
      );
      expect(
        state.activeStudent.completedSessions.first.workoutName,
        'Treino Livre de Deltoides',
      );

      state.editCompletedSession(
        sessionId: created.id,
        newWorkoutName: 'Treino Livre de Deltoides (Editado)',
        newTotalWeightKg: 3600,
        newTotalSets: 14,
        newDurationMinutes: 48,
        newNotes: 'Subiu carga',
      );
      expect(
        state.activeStudent.completedSessions.first.totalWeightLiftedKg,
        3600,
      );

      state.toggleSaveCompletedSession(created.id);
      expect(state.activeStudent.completedSessions.first.isSaved, isTrue);

      final initialPosts = state.communityPosts.length;
      state.shareCompletedSessionToCommunity(
        created.id,
        caption: 'Compartilhado do teste!',
      );
      expect(state.communityPosts.length, initialPosts + 1);

      state.deleteCompletedSession(created.id);
      expect(
        state.activeStudent.completedSessions.any((s) => s.id == created.id),
        isFalse,
      );
    });

    test(
      'Dieta Sugerida, Substituicao Fora da Dieta, Alimento Avulso, Agua e Nutrientes',
      () {
        final state = RecAppState();
        final meal = state.activeStudent.suggestedMeals.first;
        final item = meal.items.first;

        // Confirma quantidade ajustada
        state.confirmSuggestedDietFood(
          mealId: meal.id,
          foodItemId: item.id,
          isConfirmed: true,
          confirmedAmountGrams: 200,
        );
        expect(item.confirmedAmountGrams, 200);

        // Substitui por alimento consumido fora da dieta
        state.replaceSuggestedFoodWithOffDiet(
          mealId: meal.id,
          foodItemId: item.id,
          offDietFoodName: 'Tapioca com Frango',
          offDietAmountGrams: 180,
          calories: 310,
          proteinG: 24,
          carbsG: 42,
          fatG: 5,
        );
        expect(item.isReplacedOffDiet, isTrue);
        expect(item.effectiveIngestedNutrients.calories, 310);

        // Cadastra alimento avulso
        final beforeCalories =
            state.activeStudent.totalIngestedNutrients.calories;
        state.addCustomConsumedFood(
          name: 'Barra de Proteina',
          amountGrams: 45,
          mealOccasion: 'Lanche',
          calories: 180,
          proteinG: 15,
          carbsG: 18,
          fatG: 6,
        );
        expect(
          state.activeStudent.totalIngestedNutrients.calories,
          beforeCalories + 180,
        );

        // Meta de água
        final beforeWater = state.activeStudent.waterTracker.consumedMl;
        state.addWaterIntake(500);
        expect(state.activeStudent.waterTracker.consumedMl, beforeWater + 500);

        // Exporta payload JSON completo para a Web
        final jsonStr = state.exportSyncPayloadJson();
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        expect(decoded['schemaVersion'], '1.0.0');
        expect(
          (decoded['student'] as Map<String, dynamic>)['nome'],
          'Elizangela',
        );
      },
    );

    test(
      'R1–R8: Persistencia Local, 19 Subdivisoes Anatomicas, Recuperacao SRA, Calendario Multi-mes, PRs e Evolucao Inteligente',
      () async {
        final tempFile = File(
          '${Directory.systemTemp.path}/rec_consultoria_test_storage_${DateTime.now().microsecondsSinceEpoch}.json',
        );
        final storage = LocalFileStorageRepository(customFilePath: tempFile.path);
        final state = RecAppState(storageRepository: storage);

        // R2: 19 subdivisões anatômicas (10 anteriores e 9 posteriores)
        expect(MuscleGroup.values.length, 19);
        expect(MuscleGroup.values.where((g) => g.isFrontBody).length, 10);
        expect(MuscleGroup.values.where((g) => !g.isFrontBody).length, 9);
        expect(state.activeStudent.muscleRecovery.length, 19);

        // R3: Visão Geral da Semana em kg inteiros (Seg..Dom) e atualizando ao registrar treino
        expect(state.activeStudent.weeklyMetrics.length, 7);
        final initialTotalVolume = state.activeStudent.weeklyMetrics.fold<int>(
          0,
          (sum, m) => sum + m.integerVolumeKg,
        );
        final initialSessionsCount = state.activeStudent.weeklyMetrics.fold<int>(
          0,
          (sum, m) => sum + m.workoutsCount,
        );
        expect(initialTotalVolume, greaterThan(0));

        // R4: Cálculo científico SRA / Impulse-Response de recuperação muscular
        final peitoBefore = state.activeStudent.muscleRecovery.firstWhere(
          (r) => r.group == MuscleGroup.peitoralMaior,
        );
        final setsBefore = peitoBefore.weeklySetsCompleted;
        final recBefore = peitoBefore.recoveryPercent;

        // Registra uma nova sessão intensa na semana ativa (Domingo 25/10/2026)
        state.recordWorkoutSession(
          workoutName: 'Sessão Extra de Peitoral e Tríceps',
          totalWeightLiftedKg: 4250,
          totalSets: 10,
          durationMinutes: 50,
          workedMuscles: [
            MuscleGroup.peitoralMaior,
            MuscleGroup.peitoralSuperior,
            MuscleGroup.triceps,
          ],
          completedAt: DateTime(2026, 10, 25, 19, 30),
          exerciseLogs: [
            CompletedExerciseLog(
              exerciseName: 'Supino Reto com Barra',
              primaryMuscle: MuscleGroup.peitoralMaior,
              secondaryMuscles: const [
                MuscleGroup.peitoralSuperior,
                MuscleGroup.triceps,
              ],
              sets: [
                ExerciseSet(
                  id: 'test-set-1',
                  index: 1,
                  type: SetType.working,
                  targetReps: '8-10',
                  weightKg: 38,
                  completedReps: 10,
                  completed: true,
                ),
                ExerciseSet(
                  id: 'test-set-2',
                  index: 2,
                  type: SetType.top,
                  targetReps: '6-8',
                  weightKg: 44,
                  completedReps: 8,
                  completed: true,
                ),
              ],
            ),
          ],
        );

        final updatedTotalVolume = state.activeStudent.weeklyMetrics.fold<int>(
          0,
          (sum, m) => sum + m.integerVolumeKg,
        );
        final updatedSessionsCount = state.activeStudent.weeklyMetrics.fold<int>(
          0,
          (sum, m) => sum + m.workoutsCount,
        );
        expect(updatedTotalVolume, initialTotalVolume + 4250);
        expect(updatedSessionsCount, initialSessionsCount + 1);

        final peitoAfter = state.activeStudent.muscleRecovery.firstWhere(
          (r) => r.group == MuscleGroup.peitoralMaior,
        );
        expect(peitoAfter.weeklySetsCompleted, greaterThan(setsBefore));
        expect(peitoAfter.recoveryPercent, lessThanOrEqualTo(recBefore));

        // R5: Calendário multi-mês (Agosto, Setembro e Outubro 2026 possuem sessões)
        final augDays = state.buildCalendarDaysForMonth(year: 2026, month: 8);
        final sepDays = state.buildCalendarDaysForMonth(year: 2026, month: 9);
        final octDays = state.buildCalendarDaysForMonth(year: 2026, month: 10);
        expect(augDays.where((d) => d.trained).isNotEmpty, isTrue);
        expect(sepDays.where((d) => d.trained).isNotEmpty, isTrue);
        expect(octDays.where((d) => d.trained).isNotEmpty, isTrue);

        // R6: Novo recorde pessoal (PR) atualiza automaticamente com carga anterior e ganho
        final supinoPr = state.activeStudent.personalRecords.firstWhere(
          (pr) => pr.exerciseName == 'Supino Reto com Barra',
        );
        expect(supinoPr.integerWeightKg, 44);
        expect(supinoPr.integerPreviousBestKg, 38);
        expect(supinoPr.integerImprovementKg, 6);

        // R7: Exercícios feitos - comparação intra-semana (>=2x na semana) vs semanas do mês (1x na semana)
        final supinoEvo = state.activeStudent.exerciseEvolutions.firstWhere(
          (e) => e.exerciseName == 'Supino Reto com Barra',
        );
        expect(supinoEvo.isIntraWeekSessionComparison, isTrue);
        expect(supinoEvo.occurrencesInActiveWeek, greaterThanOrEqualTo(2));
        expect(
          supinoEvo.weeklyMarks.first.label,
          contains('Sessão 1'),
        );

        final agachamentoEvo = state.activeStudent.exerciseEvolutions
            .firstWhere((e) => e.exerciseName == 'Agachamento Livre com Barra');
        expect(agachamentoEvo.isIntraWeekSessionComparison, isFalse);
        expect(agachamentoEvo.occurrencesInActiveWeek, 1);
        expect(
          agachamentoEvo.weeklyMarks.any((m) => m.label.startsWith('Sem ')),
          isTrue,
        );

        // R8: Central de Anamneses inclui Avaliação Física do Professor
        final assessment = state.activeStudent.coachPhysicalAssessment;
        expect(assessment.weightKg, greaterThan(0));
        expect(assessment.heightMeters, greaterThan(1.0));
        expect(assessment.bodyFatPercent, greaterThan(0));
        expect(assessment.leanMassPercent, greaterThan(0));

        // R1: Persistência local salva automaticamente e recarrega o estado completo
        final reloadedState = RecAppState(
          storageRepository: storage,
          loadFromStorageIfAvailable: true,
        );
        expect(
          reloadedState.activeStudent.completedSessions.any(
            (s) => s.workoutName == 'Sessão Extra de Peitoral e Tríceps',
          ),
          isTrue,
        );
        if (tempFile.existsSync()) {
          await tempFile.delete();
        }
      },
    );

    test('CLI Runner executa summary, export e valida erros de uso', () async {
      final outBuf = StringBuffer();
      final errBuf = StringBuffer();
      final runner = RecSyncCliRunner(out: outBuf, err: errBuf);

      final summaryCode = await runner.run(['summary']);
      expect(summaryCode, 0);
      expect(outBuf.toString(), contains('Elizangela'));
      expect(outBuf.toString(), contains('Maycon'));
      expect(outBuf.toString(), contains('Carlos Souza'));

      outBuf.clear();
      final tempFile = File(
        '${Directory.systemTemp.path}/rec_sync_test_export.json',
      );
      final exportCode = await runner.run([
        'export',
        '--student',
        '2',
        '--output',
        tempFile.path,
      ]);
      expect(exportCode, 0);
      expect(tempFile.existsSync(), isTrue);
      final fileContent = jsonDecode(await tempFile.readAsString());
      expect(fileContent['student']['nome'], 'Maycon');
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }

      // Argumento inválido
      errBuf.clear();
      final badCode = await runner.run(['export', '--student', 'abc']);
      expect(badCode, 64);
    });
  });

  group(
    'Testes de Interface e Navegacao nas 4 Abas (Home, Treino, Dieta, You)',
    () {
      testWidgets(
        'Navega por Home, Community, Agenda, Sininho, Treino, Dieta e You',
        (WidgetTester tester) async {
          final state = RecAppState();
          await tester.pumpWidget(RecConsultoriaMobileApp(appState: state));
          await tester.pumpAndSettle();

          // 1. Verifica elementos da Aba Home
          expect(find.text('Último Treino Feito'), findsOneWidget);
          expect(
            find.byKey(const Key('start_free_workout_button')),
            findsOneWidget,
          );

          // Abre modal de Agenda Comparativa no canto superior direito
          await tester.tap(find.byKey(const Key('header_agenda_button')));
          await tester.pumpAndSettle();
          expect(find.text('Agenda Comparativa de Metas'), findsOneWidget);
          Navigator.of(
            tester.element(find.text('Agenda Comparativa de Metas')),
          ).pop();
          await tester.pumpAndSettle();

          // Abre Sininho de Notificações no canto superior direito
          await tester.tap(find.byKey(const Key('header_notifications_bell')));
          await tester.pumpAndSettle();
          expect(
            find.text('Notificações & Avisos do Treinador'),
            findsOneWidget,
          );
          await tester.tap(find.text('Marcar lidas'));
          await tester.pumpAndSettle();
          expect(state.unreadNotificationsCount, 0);

          // Alterna para 'Community' pelo seletor rápido do Avatar no canto superior esquerdo
          await tester.tap(find.byKey(const Key('avatar_space_community')));
          await tester.pumpAndSettle();
          expect(find.textContaining('Top set no supino reto'), findsOneWidget);

          // Volta para 'Home'
          await tester.tap(find.byKey(const Key('avatar_space_home')));
          await tester.pumpAndSettle();

          // 2. Navega para a Aba Treino (Prescrito pelo Treinador)
          await tester.tap(find.text('Treino'));
          await tester.pumpAndSettle();
          expect(find.text('Ficha Prescrita pelo Treinador'), findsOneWidget);
          expect(find.text('Supino Reto com Barra'), findsOneWidget);

          // Alterna para Treino B
          await tester.tap(find.byKey(const Key('workout_day_tab_B')));
          await tester.pumpAndSettle();
          expect(find.text('Agachamento Livre com Barra'), findsOneWidget);

          // 3. Navega para a Aba Dieta (com Meta de Água inclusa)
          await tester.tap(find.text('Dieta'));
          await tester.pumpAndSettle();
          expect(find.text('Meta de Água Diária'), findsOneWidget);
          expect(
            find.text('Gráfico de Calorias & Macronutrientes Ingeridos'),
            findsOneWidget,
          );

          // Clica em +250ml de água
          await tester.tap(find.byKey(const Key('water_add_250_button')));
          await tester.pumpAndSettle();
          expect(state.activeStudent.waterTracker.consumedMl, 2500);

          // Rola a ListView da Dieta até a seção de Dieta Sugerida
          await tester.scrollUntilVisible(
            find.text('Dieta Sugerida pelo Treinador'),
            250.0,
          );
          await tester.pumpAndSettle();
          expect(find.text('Dieta Sugerida pelo Treinador'), findsOneWidget);

          // 4. Navega para a Aba You (Visão Geral, 3D, Exercícios, Medidas, Fotos & Anamnese)
          await tester.tap(find.text('You'));
          await tester.pumpAndSettle();
          expect(
            find.text('Visão Geral da Semana · Comparativo'),
            findsOneWidget,
          );
          expect(
            find.text('Mapa Muscular Anatômico'),
            findsOneWidget,
          );

          // Sub-aba Exercícios Feitos
          await tester.tap(find.byKey(const Key('you_subtab_1')));
          await tester.pumpAndSettle();
          expect(find.text('Evolução de Cargas por Exercício'), findsOneWidget);

          // Sub-aba Medidas
          await tester.tap(find.byKey(const Key('you_subtab_2')));
          await tester.pumpAndSettle();
          expect(
            find.text('Medidas dos Grupamentos Musculares'),
            findsOneWidget,
          );

          // Sub-aba Fotos & Check-in
          await tester.tap(find.byKey(const Key('you_subtab_3')));
          await tester.pumpAndSettle();
          expect(
            find.text('Fotos de Evolução (Frente, Costas, Perfil)'),
            findsOneWidget,
          );
          expect(find.text('Central de Anamneses & Check-in'), findsOneWidget);
        },
      );

      testWidgets(
        'Valida interacoes de Fibras Musculares, Calendario Multi-mes, Modal de GIF PR, Exercicios Feitos e Anamnese do Professor',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1080, 2800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final state = RecAppState();
          await tester.pumpWidget(RecConsultoriaMobileApp(appState: state));
          await tester.pumpAndSettle();

          // Vai direto para a aba You na barra de navegação inferior
          await tester.tap(find.text('You').last);
          await tester.pumpAndSettle();

          // R3: Verifica que os rótulos de barras semanais usam kg inteiros (ex: "6840 kg")
          expect(find.text('6840 kg'), findsOneWidget);

          // R2: Toca em um chip muscular para abrir o painel de inspeção de fibras musculares
          final peitoChip = find.byKey(const Key('muscle_chip_peitoralMaior'));
          await tester.tap(peitoChip);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('muscle_fiber_inspection_card')),
            findsOneWidget,
          );

          // R5: No Calendário, navega para Setembro 2026
          final prevMonthBtn = find.byKey(
            const Key('calendar_prev_month_button'),
          );
          expect(find.textContaining('Outubro 2026'), findsWidgets);

          await tester.tap(prevMonthBtn);
          await tester.pumpAndSettle();
          expect(find.textContaining('Setembro 2026'), findsWidgets);

          // Toca em um dia treinado em Setembro 2026 (dia 25)
          final day25 = find.byKey(const Key('calendar_day_2026_9_25'));
          await tester.tap(day25);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('calendar_day_sessions_panel')),
            findsOneWidget,
          );

          // R6: Toca em um Recorde Pessoal (PR) -> abre tela de todos os exercícios feitos -> abre os 5 recordes do exercício
          final prCard = find.byKey(
            const Key('pr_item_Agachamento Livre com Barra'),
          );
          await tester.tap(prCard);
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('personal_records_all_exercises_screen')),
            findsOneWidget,
          );
          await tester.tap(
            find.byKey(
              const Key('pr_all_exercise_row_Agachamento Livre com Barra'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('exercise_personal_records_detail_screen')),
            findsOneWidget,
          );
          expect(find.text('1RM Estimado'), findsOneWidget);
          expect(find.text('Peso Máximo'), findsOneWidget);
          expect(find.text('Repetições Máximas'), findsOneWidget);
          expect(find.text('Volume da Sessão Máximo'), findsOneWidget);
          expect(find.text('Volume Máximo de uma Série'), findsOneWidget);

          await tester.pageBack();
          await tester.pumpAndSettle();
          await tester.pageBack();
          await tester.pumpAndSettle();

          // R7: Sub-aba Exercícios Feitos -> Verifica modo intra-semana (2x) vs semanas do mês (1x)
          await tester.tap(find.byKey(const Key('you_subtab_1')));
          await tester.pumpAndSettle();

          // Seleciona "Supino Reto com Barra" (feito 2x na semana ativa -> compara sessões dentro da semana)
          final supinoChip = find.byKey(
            const Key('exercise_chip_Supino Reto com Barra'),
          );
          await tester.tap(supinoChip);
          await tester.pumpAndSettle();
          expect(find.textContaining('Sessão 1'), findsOneWidget);
          expect(find.textContaining('Sessão 2'), findsOneWidget);

          // Seleciona "Agachamento Livre com Barra" (feito 1x na semana ativa -> compara com as semanas do mesmo mês)
          final agachamentoChip = find.byKey(
            const Key('exercise_chip_Agachamento Livre com Barra'),
          );
          await tester.tap(agachamentoChip);
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Comparativo entre semanas do mês'),
            findsOneWidget,
          );

          // R8: Sub-aba Fotos & Check-in -> Verifica Avaliação Física do Professor e modal de detalhes
          await tester.tap(find.byKey(const Key('you_subtab_3')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('coach_physical_assessment_card')),
            findsOneWidget,
          );
          expect(
            find.text('Anamnese & Avaliação Física do Professor'),
            findsOneWidget,
          );
          expect(find.text('% DE GORDURA'), findsOneWidget);
          expect(find.text('% MASSA MAGRA'), findsOneWidget);
        },
      );

      testWidgets(
        'Mapa Anatomico 3D colore grupamentos do Azul (menos desgaste) ao Vermelho (mais desgaste) conforme treinos registrados',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(900, 1400);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          // 1. Valida escala cromática estática: Sem treino (Cinza), Menos desgaste (Azul), Intermediário (Gradiente), Mais desgaste (Vermelho)
          final unworkedColor = MuscleBody3DWidget.colorForWear(
            0.0,
            isWorked: false,
          );
          expect(unworkedColor, MuscleBody3DWidget.unworkedMuscleColor);

          final lowWearColor = MuscleBody3DWidget.colorForWear(
            0.12,
            isWorked: true,
          );
          expect(lowWearColor.b, greaterThan(lowWearColor.r));

          final midWearColor = MuscleBody3DWidget.colorForWear(
            0.55,
            isWorked: true,
          );
          expect(midWearColor, isNot(equals(lowWearColor)));

          final highWearColor = MuscleBody3DWidget.colorForWear(
            0.92,
            isWorked: true,
          );
          expect(highWearColor.r, greaterThan(highWearColor.b));

          // 2. Valida transição dinâmica do músculo conforme o aluno registra sessões de treino
          final state = RecAppState();
          MuscleRecoveryStatus statusOf(MuscleGroup g) =>
              state.activeStudent.muscleRecovery.firstWhere(
                (m) => m.group == g,
              );

          // Na semana ativa inicial:
          // - Peitoral Maior e Dorsal possuem alto desgaste (mais vermelho)
          // - Deltoide Lateral e Bíceps possuem menor desgaste (mais azul)
          // - Panturrilhas ainda não foram treinadas na semana ativa (cinza neutro 3D)
          final peitoInitialColor = MuscleBody3DWidget.statusWearColor(
            statusOf(MuscleGroup.peitoralMaior),
          );
          final dorsalInitialColor = MuscleBody3DWidget.statusWearColor(
            statusOf(MuscleGroup.dorsal),
          );
          final deltLatInitialColor = MuscleBody3DWidget.statusWearColor(
            statusOf(MuscleGroup.deltoideLateral),
          );
          final bicepsInitialColor = MuscleBody3DWidget.statusWearColor(
            statusOf(MuscleGroup.biceps),
          );
          final calfInitialStatus = statusOf(MuscleGroup.panturrilhas);

          expect(peitoInitialColor.r, greaterThan(peitoInitialColor.b));
          expect(dorsalInitialColor.r, greaterThan(dorsalInitialColor.b));
          expect(deltLatInitialColor.b, greaterThan(deltLatInitialColor.r));
          expect(bicepsInitialColor.b, greaterThan(bicepsInitialColor.r));
          expect(calfInitialStatus.wearPercent, 0);
          expect(
            MuscleBody3DWidget.statusWearColor(calfInitialStatus),
            MuscleBody3DWidget.unworkedMuscleColor,
          );

          // Aluno registra treino leve de Panturrilhas (2 séries) -> passa a ter pouco desgaste (Azul)
          state.recordWorkoutSession(
            workoutName: 'Estímulo Leve de Panturrilhas',
            totalWeightLiftedKg: 1200,
            totalSets: 2,
            durationMinutes: 15,
            workedMuscles: const [MuscleGroup.panturrilhas],
            completedAt: DateTime(2026, 10, 24, 18, 0),
            exerciseLogs: [
              CompletedExerciseLog(
                exerciseName: 'Panturrilha em Pé na Máquina',
                primaryMuscle: MuscleGroup.panturrilhas,
                sets: [
                  ExerciseSet(
                    id: 'calf-light-1',
                    index: 1,
                    type: SetType.working,
                    targetReps: '12',
                    weightKg: 50,
                    completedReps: 12,
                    completed: true,
                  ),
                  ExerciseSet(
                    id: 'calf-light-2',
                    index: 2,
                    type: SetType.working,
                    targetReps: '12',
                    weightKg: 50,
                    completedReps: 12,
                    completed: true,
                  ),
                ],
              ),
            ],
          );

          final calfLowWearStatus = statusOf(MuscleGroup.panturrilhas);
          final calfLowWearColor = MuscleBody3DWidget.statusWearColor(
            calfLowWearStatus,
          );
          expect(calfLowWearStatus.wearPercent, greaterThan(0));
          expect(calfLowWearStatus.wearPercent, lessThan(40));
          expect(calfLowWearColor.b, greaterThan(calfLowWearColor.r));

          // Aluno registra novo treino intenso de Panturrilhas (9 Top Sets) -> alto desgaste (Vermelho)
          state.recordWorkoutSession(
            workoutName: 'Choque de Panturrilhas Intenso',
            totalWeightLiftedKg: 6400,
            totalSets: 9,
            durationMinutes: 35,
            workedMuscles: const [MuscleGroup.panturrilhas],
            completedAt: DateTime(2026, 10, 25, 18, 0),
            exerciseLogs: [
              CompletedExerciseLog(
                exerciseName: 'Panturrilha em Pé na Máquina',
                primaryMuscle: MuscleGroup.panturrilhas,
                sets: List.generate(
                  9,
                  (i) => ExerciseSet(
                    id: 'calf-heavy-$i',
                    index: i + 1,
                    type: SetType.top,
                    targetReps: '15',
                    weightKg: 90,
                    completedReps: 15,
                    completed: true,
                  ),
                ),
              ),
            ],
          );

          final calfHighWearStatus = statusOf(MuscleGroup.panturrilhas);
          final calfHighWearColor = MuscleBody3DWidget.statusWearColor(
            calfHighWearStatus,
          );
          expect(
            calfHighWearStatus.wearPercent,
            greaterThan(calfLowWearStatus.wearPercent),
          );
          expect(calfHighWearStatus.wearPercent, greaterThanOrEqualTo(75));
          expect(calfHighWearColor.r, greaterThan(calfHighWearColor.b));

          // 3. Verifica renderização da legenda de gradiente e toque direto no canvas 3D
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: MuscleBody3DWidget(
                    muscleStatuses: state.activeStudent.muscleRecovery,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Mapa Muscular Anatômico'),
            findsOneWidget,
          );
          final horizontalChipsFinder = find.byKey(
            const Key('muscle_chips_horizontal_scroll'),
          );
          expect(horizontalChipsFinder, findsOneWidget);
          final horizontalScrollWidget = tester.widget<SingleChildScrollView>(
            horizontalChipsFinder,
          );
          expect(horizontalScrollWidget.scrollDirection, Axis.horizontal);
          expect(
            find.byKey(const Key('muscle_wear_gradient_legend')),
            findsOneWidget,
          );
          expect(find.text('Menos desgaste'), findsOneWidget);
          expect(find.text('Mais desgaste'), findsOneWidget);

          // Toca no peitoral na vista anterior do canvas 3D
          final frontCanvas = find.byKey(const Key('anatomy_front_canvas'));
          final frontRect = tester.getRect(frontCanvas);
          await tester.tapAt(
            Offset(
              frontRect.center.dx - frontRect.width * 0.08,
              frontRect.top + frontRect.height * 0.24,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('muscle_fiber_inspection_card')),
            findsOneWidget,
          );
          expect(find.textContaining('% desgaste'), findsOneWidget);

          // 4. Valida sessões livres (isFreeSession: true, exerciseLogs vazio) e edição de séries (editCompletedSession)
          // Adutores começa com 0% de desgaste (Cinza 3D)
          expect(statusOf(MuscleGroup.adutores).wearPercent, 0);

          final freeAdutoresSession = state.recordWorkoutSession(
            workoutName: 'Sessão Livre de Adutores',
            totalWeightLiftedKg: 800,
            totalSets: 2,
            durationMinutes: 15,
            workedMuscles: const [MuscleGroup.adutores],
            exerciseLogs: const [],
            completedAt: DateTime(2026, 10, 25, 19, 0),
            isFreeSession: true,
          );
          final adutoresLowStatus = statusOf(MuscleGroup.adutores);
          final adutoresLowColor = MuscleBody3DWidget.statusWearColor(
            adutoresLowStatus,
          );
          expect(adutoresLowStatus.wearPercent, greaterThan(0));
          expect(adutoresLowStatus.wearPercent, lessThanOrEqualTo(42));
          expect(adutoresLowColor.b, greaterThan(adutoresLowColor.r));

          // Edita a sessão na Home aumentando de 2 séries para 14 séries -> desgaste sobe para faixa Vermelha!
          state.editCompletedSession(
            sessionId: freeAdutoresSession.id,
            newWorkoutName: 'Sessão Livre de Adutores (Intensa)',
            newTotalWeightKg: 5600,
            newTotalSets: 14,
            newDurationMinutes: 40,
          );
          final adutoresHighStatus = statusOf(MuscleGroup.adutores);
          final adutoresHighColor = MuscleBody3DWidget.statusWearColor(
            adutoresHighStatus,
          );
          expect(
            adutoresHighStatus.wearPercent,
            greaterThan(adutoresLowStatus.wearPercent),
          );
          expect(adutoresHighStatus.wearPercent, greaterThanOrEqualTo(75));
          expect(adutoresHighColor.r, greaterThan(adutoresHighColor.b));
        },
      );

      testWidgets(
        'Recuperacao muscular agrupa grupamentos no eixo horizontal com logos anatomicos e abre nova feature em Ver tudo',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1080, 2800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final state = RecAppState();
          await tester.pumpWidget(RecConsultoriaMobileApp(appState: state));
          await tester.pumpAndSettle();

          // Navega para a aba You
          await tester.tap(find.text('You').last);
          await tester.pumpAndSettle();

          // Verifica cabeçalho "Recuperação muscular", anel circular global e carrossel horizontal
          expect(find.text('Recuperação muscular'), findsOneWidget);
          expect(
            find.text('Veja quais músculos estão prontos para treinar'),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('overall_recovery_gauge')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('recovery_horizontal_scroll')),
            findsOneWidget,
          );

          // Verifica ícones/logos anatômicos individuais (MuscleGroupLogoWidget) nos grupamentos
          expect(
            find.byKey(const Key('recovery_logo_peitoralSuperior')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('recovery_logo_peitoralMaior')),
            findsOneWidget,
          );
          expect(
            MuscleGroupLogoWidget.isLowerBodyGroup(MuscleGroup.quadriceps),
            isTrue,
          );
          expect(
            MuscleGroupLogoWidget.isLowerBodyGroup(MuscleGroup.peitoralMaior),
            isFalse,
          );

          // Clica em "Ver tudo" e verifica que abre a nova feature na tela (MuscleRecoveryFullFeatureScreen)
          final seeAllButton = find.byKey(const Key('recovery_see_all_button'));
          expect(seeAllButton, findsOneWidget);
          await tester.tap(seeAllButton);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('muscle_recovery_full_feature_screen')),
            findsOneWidget,
          );
          expect(find.text('Recuperação Muscular Completa'), findsOneWidget);
          expect(
            find.byKey(const Key('recovery_feature_inspected_card')),
            findsOneWidget,
          );

          // Testa filtros dentro da nova feature ("Posterior") e verifica sincronização do card inspecionado
          await tester.tap(
            find.byKey(const Key('recovery_feature_filter_Posterior')),
          );
          await tester.pumpAndSettle();
          expect(
            find.descendant(
              of: find.byKey(const Key('recovery_feature_inspected_card')),
              matching: find.textContaining('Vista Posterior'),
            ),
            findsOneWidget,
          );

          // Testa filtro "Fatigados (<60%)" e inspeção de grupamento
          await tester.tap(
            find.byKey(const Key('recovery_feature_filter_Fatigados (<60%)')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('recovery_row_peitoralMaior')),
            findsOneWidget,
          );

          // Volta para a tela principal da aba You
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.text('Recuperação muscular'), findsOneWidget);

          // Filtra o eixo horizontal por "Posterior" -> esconde músculos anteriores e exibe posteriores
          await tester.tap(find.byKey(const Key('recovery_filter_Posterior')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('recovery_horizontal_item_peitoralSuperior')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('recovery_horizontal_item_dorsal')),
            findsOneWidget,
          );

          // Toca em um grupamento do eixo horizontal (Dorsal) -> abre a feature pre-selecionada naquele músculo
          await tester.tap(
            find.byKey(const Key('recovery_horizontal_item_dorsal')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('muscle_recovery_full_feature_screen')),
            findsOneWidget,
          );
          expect(find.text('Dorsal (Latíssimo)'), findsWidgets);
        },
      );

      testWidgets(
        'Recuperacao muscular trata estado vazio quando todos os 19 musculos estao 100% recuperados',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1080, 2800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final freshStudent = RecAppState().activeStudent;
          final freshRecoveries = MuscleGroup.values
              .map(
                (g) => MuscleRecoveryStatus(
                  group: g,
                  recoveryPercent: 100,
                  weeklySetsCompleted: 0,
                  hoursSinceLastTrained: 168,
                ),
              )
              .toList();
          freshStudent.muscleRecovery
            ..clear()
            ..addAll(freshRecoveries);

          await tester.pumpWidget(
            MaterialApp(
              home: MuscleRecoveryFullFeatureScreen(student: freshStudent),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('100%'), findsWidgets);
          expect(find.text('19 músc.'), findsOneWidget);

          // Seleciona "Fatigados (<60%)" em perfil 100% recuperado -> exibe estado vazio e botão de reset
          await tester.tap(
            find.byKey(const Key('recovery_feature_filter_Fatigados (<60%)')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('recovery_feature_empty_state')),
            findsOneWidget,
          );

          await tester.tap(
            find.byKey(const Key('recovery_feature_reset_filter_button')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('recovery_feature_empty_state')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('recovery_row_peitoralMaior')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Grafico de Radar de Volume Muscular analisa sessoes da Semana e do Mes e responde a novas sessoes',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1080, 3200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          // 1. Verifica cálculo de volume (Semana vs Mês) independente de recuperação
          final state = RecAppState();
          final initialWeekAxes = RecoveryCalculator.computeMuscleVolumeRadar(
            state.activeStudent.completedSessions,
            period: MuscleVolumePeriod.week,
          );
          final initialMonthAxes = RecoveryCalculator.computeMuscleVolumeRadar(
            state.activeStudent.completedSessions,
            period: MuscleVolumePeriod.month,
          );

          expect(initialWeekAxes.length, 11);
          expect(initialMonthAxes.length, 11);

          final totalWeekSets = initialWeekAxes.fold<int>(
            0,
            (s, a) => s + a.totalSets,
          );
          final totalMonthSets = initialMonthAxes.fold<int>(
            0,
            (s, a) => s + a.totalSets,
          );
          expect(totalWeekSets, greaterThan(0));
          expect(totalMonthSets, greaterThanOrEqualTo(totalWeekSets));

          // 2. Renderiza aba You e valida presença do Gráfico de Radar
          await tester.pumpWidget(RecConsultoriaMobileApp(appState: state));
          await tester.pumpAndSettle();

          await tester.tap(find.text('You').last);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('muscle_volume_radar_card')),
            findsOneWidget,
          );
          final anatomyStage = tester.widget<Container>(
            find.byKey(const Key('anatomy_native_stage')),
          );
          final radarStage = tester.widget<Container>(
            find.byKey(const Key('volume_radar_stage')),
          );
          expect(anatomyStage.color, Colors.transparent);
          expect(radarStage.color, Colors.transparent);
          expect(anatomyStage.decoration, isNull);
          expect(radarStage.decoration, isNull);
          expect(find.text('Esta semana'), findsOneWidget);
          expect(
            find.text('Identifique áreas que precisam de mais foco'),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('volume_radar_vertex_peito')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('volume_radar_vertex_costas')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('volume_radar_vertex_panturrilhas')),
            findsOneWidget,
          );

          // 3. Alterna para o período MÊS -> título muda para "Este mês"
          await tester.tap(find.byKey(const Key('volume_radar_period_month')));
          await tester.pumpAndSettle();
          expect(find.text('Este mês'), findsOneWidget);

          // Volta para SEMANA e toca em um vértice (Peito) para inspecionar volume
          await tester.tap(find.byKey(const Key('volume_radar_period_week')));
          await tester.pumpAndSettle();
          expect(find.text('Esta semana'), findsOneWidget);

          await tester.tap(find.byKey(const Key('volume_radar_vertex_peito')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('volume_radar_selected_axis_card')),
            findsOneWidget,
          );
          expect(find.textContaining('séries efetivas'), findsWidgets);

          // 4. Reatividade do back-end local: registra treino futuro e valida atualização imediata do volume
          final weekPantBefore = initialWeekAxes
              .firstWhere((a) => a.axisId == 'panturrilhas')
              .totalSets;

          state.recordWorkoutSession(
            workoutName: 'Treino Extra Panturrilhas Volume',
            totalWeightLiftedKg: 3200,
            totalSets: 8,
            durationMinutes: 25,
            workedMuscles: const [MuscleGroup.panturrilhas],
            completedAt: DateTime(2026, 10, 26, 19, 0),
          );
          await tester.pumpAndSettle();

          final updatedWeekAxes = RecoveryCalculator.computeMuscleVolumeRadar(
            state.activeStudent.completedSessions,
            period: MuscleVolumePeriod.week,
          );
          final weekPantAfter = updatedWeekAxes
              .firstWhere((a) => a.axisId == 'panturrilhas')
              .totalSets;
          expect(weekPantAfter, greaterThan(weekPantBefore));

          // 5. Toca em "Veja onde focar mais" e verifica abertura da tela detalhada
          await tester.tap(find.byKey(const Key('volume_radar_focus_button')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('muscle_volume_focus_screen')),
            findsOneWidget,
          );
          expect(
            find.text('Distribuição de Volume Muscular'),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('focus_axis_row_peito')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Recordes Pessoais exibe GIF com data, peso e reps, abre lista de todos os exercicios feitos e detalha os 5 recordes por exercicio',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1080, 3200);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final state = RecAppState();

          // 1. Verifica cálculo reativo dos 5 recordes no motor RecoveryCalculator
          final initialRecords =
              RecoveryCalculator.computeAllExercisesCompleteRecords(
                state.activeStudent,
              );
          expect(initialRecords.length, greaterThanOrEqualTo(5));

          final supinoBefore = initialRecords.firstWhere(
            (r) => r.exerciseName == 'Supino Reto com Barra',
          );
          expect(supinoBefore.maxWeightKg, greaterThan(0));
          expect(supinoBefore.estimatedOneRepMaxKg, greaterThan(0));
          expect(supinoBefore.maxReps, greaterThan(0));
          expect(supinoBefore.maxSessionVolumeKg, greaterThan(0));
          expect(supinoBefore.maxSingleSetVolumeKg, greaterThan(0));

          // 2. Renderiza aba You -> card enxuto "Recordes Pessoais" sem textos redundantes antigos
          await tester.pumpWidget(RecConsultoriaMobileApp(appState: state));
          await tester.pumpAndSettle();
          await tester.tap(find.text('You').last);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('personal_records_overview_card')),
            findsOneWidget,
          );
          expect(find.text('Recordes Pessoais'), findsOneWidget);
          expect(
            find.text(
              'Veja seus melhores levantamentos e a evolução ao longo do tempo',
            ),
            findsOneWidget,
          );
          expect(find.textContaining('Músculo alvo:'), findsNothing);

          // 3. Toca em qualquer exercício -> abre tela "Recordes Pessoais" com TODOS os exercícios feitos e 3 filtros
          await tester.tap(
            find.byKey(const Key('pr_item_Supino Reto com Barra')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('personal_records_all_exercises_screen')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('pr_filter_max_weight')), findsOneWidget);
          expect(find.byKey(const Key('pr_filter_best_1rm')), findsOneWidget);
          expect(find.byKey(const Key('pr_filter_max_reps')), findsOneWidget);
          expect(
            find.byKey(const Key('pr_all_exercises_share_button')),
            findsOneWidget,
          );

          // Alterna os filtros
          await tester.tap(find.byKey(const Key('pr_filter_best_1rm')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('pr_filter_max_reps')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('pr_filter_max_weight')));
          await tester.pumpAndSettle();

          // 4. Toca no exercício "Supino Reto com Barra" -> abre tela detalhada com os 5 recordes + Epley
          await tester.tap(
            find.byKey(const Key('pr_all_exercise_row_Supino Reto com Barra')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('exercise_personal_records_detail_screen')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('record_row_1rm')), findsOneWidget);
          expect(find.byKey(const Key('record_row_max_weight')), findsOneWidget);
          expect(find.byKey(const Key('record_row_max_reps')), findsOneWidget);
          expect(
            find.byKey(const Key('record_row_max_session_volume')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('record_row_max_set_volume')),
            findsOneWidget,
          );
          expect(find.text('1RM Estimado'), findsOneWidget);
          expect(find.text('Peso Máximo'), findsOneWidget);
          expect(find.text('Repetições Máximas'), findsOneWidget);
          expect(find.text('Volume da Sessão Máximo'), findsOneWidget);
          expect(find.text('Volume Máximo de uma Série'), findsOneWidget);
          expect(find.text('Desempenho Estimado'), findsOneWidget);

          // Abre modal "Ver histórico de recordes"
          await tester.tap(
            find.byKey(const Key('exercise_pr_history_button')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('exercise_pr_history_modal')),
            findsOneWidget,
          );

          // 5. Reatividade: novo treino pesado no estado atualiza imediatamente os 5 recordes
          state.recordWorkoutSession(
            workoutName: 'Sessão Super PR Supino',
            totalWeightLiftedKg: 2400,
            totalSets: 3,
            durationMinutes: 20,
            workedMuscles: const [MuscleGroup.peitoralMaior],
            completedAt: DateTime(2026, 10, 27, 19, 0),
            exerciseLogs: [
              CompletedExerciseLog(
                exerciseName: 'Supino Reto com Barra',
                primaryMuscle: MuscleGroup.peitoralMaior,
                sets: [
                  ExerciseSet(
                    id: 'sup-pr-1',
                    index: 1,
                    type: SetType.top,
                    targetReps: '10',
                    weightKg: 100,
                    completedReps: 10,
                    completed: true,
                  ),
                ],
              ),
            ],
          );
          final supinoAfter =
              RecoveryCalculator.computeAllExercisesCompleteRecords(
                state.activeStudent,
              ).firstWhere((r) => r.exerciseName == 'Supino Reto com Barra');

          expect(supinoAfter.maxWeightKg, 100);
          expect(
            supinoAfter.estimatedOneRepMaxKg,
            greaterThan(supinoBefore.estimatedOneRepMaxKg),
          );
          expect(supinoAfter.maxSingleSetVolumeKg, 1000);
        },
      );
    },
  );
}
