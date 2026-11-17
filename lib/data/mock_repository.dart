import '../models/nutrition_models.dart';
import '../models/profile_evolution_models.dart';
import '../models/workout_models.dart';
import '../state/recovery_calculator.dart';

/// Repositório de dados sincronizados com o `mock.ts` do painel Web do professor
/// (`Elizangela`, `Maycon` e `Carlos Souza`), expandido para suportar todas as
/// funcionalidades mobile (19 subdivisões anatômicas com fibras, ~4 meses de histórico
/// de sessões, recuperação muscular SRA/Impulse-Response, PRs com animações vetoriais,
/// evolução de cargas inteligente e avaliação física completa do professor).
class MockRepository {
  MockRepository._();

  /// Data de referência padrão do ecossistema para consistência determinística.
  static final DateTime defaultReferenceNow = DateTime(2026, 10, 25, 19, 30);

  /// Banco de exercícios disponíveis mapeados para as 19 subdivisões anatômicas.
  static const List<Map<String, dynamic>> exerciseCatalog = [
    {
      'name': 'Supino Reto com Barra',
      'muscle': MuscleGroup.peitoralMaior,
      'secondary': [
        MuscleGroup.deltoideAnterior,
        MuscleGroup.triceps,
        MuscleGroup.peitoralSuperior,
      ],
      'animationKey': 'bench_press',
      'gifExample': 'Peito/SUP.RETO.BARRA.jfif',
    },
    {
      'name': 'Crucifixo Inclinado c/ Halteres',
      'muscle': MuscleGroup.peitoralSuperior,
      'secondary': [MuscleGroup.peitoralMaior, MuscleGroup.deltoideAnterior],
      'animationKey': 'chest_fly',
      'gifExample': 'Peito/CRUCIFX.jfif',
    },
    {
      'name': 'Crossover Polia Alta',
      'muscle': MuscleGroup.peitoralMaior,
      'secondary': [MuscleGroup.peitoralSuperior, MuscleGroup.retoAbdominal],
      'animationKey': 'chest_fly',
      'gifExample': 'Peito/CROSSOVER.jfif',
    },
    {
      'name': 'Supino Inclinado no Smith',
      'muscle': MuscleGroup.peitoralSuperior,
      'secondary': [MuscleGroup.deltoideAnterior, MuscleGroup.triceps],
      'animationKey': 'bench_press',
      'gifExample': 'Peito/SUPINO.SMITH.jfif',
    },
    {
      'name': 'Puxada Frontal Aberta',
      'muscle': MuscleGroup.dorsal,
      'secondary': [
        MuscleGroup.biceps,
        MuscleGroup.trapezio,
        MuscleGroup.antebraco,
      ],
      'animationKey': 'lat_pulldown',
    },
    {
      'name': 'Remada Curvada Pronada',
      'muscle': MuscleGroup.dorsal,
      'secondary': [
        MuscleGroup.trapezio,
        MuscleGroup.deltoidePosterior,
        MuscleGroup.lombar,
        MuscleGroup.biceps,
        MuscleGroup.antebraco,
      ],
      'animationKey': 'lat_pulldown',
    },
    {
      'name': 'Crucifixo Inverso na Máquina',
      'muscle': MuscleGroup.deltoidePosterior,
      'secondary': [MuscleGroup.trapezio],
      'animationKey': 'shoulder_press',
    },
    {
      'name': 'Desenvolvimento com Halteres',
      'muscle': MuscleGroup.deltoideAnterior,
      'secondary': [
        MuscleGroup.deltoideLateral,
        MuscleGroup.triceps,
        MuscleGroup.trapezio,
      ],
      'animationKey': 'shoulder_press',
    },
    {
      'name': 'Elevação Lateral Controlada',
      'muscle': MuscleGroup.deltoideLateral,
      'secondary': [MuscleGroup.deltoideAnterior, MuscleGroup.trapezio],
      'animationKey': 'shoulder_press',
    },
    {
      'name': 'Rosca Direta Barra W',
      'muscle': MuscleGroup.biceps,
      'secondary': [MuscleGroup.antebraco],
      'animationKey': 'bicep_curl',
    },
    {
      'name': 'Rosca Martelo Alternada',
      'muscle': MuscleGroup.antebraco,
      'secondary': [MuscleGroup.biceps],
      'animationKey': 'bicep_curl',
    },
    {
      'name': 'Tríceps Corda na Polia',
      'muscle': MuscleGroup.triceps,
      'secondary': [MuscleGroup.antebraco],
      'animationKey': 'tricep_pushdown',
    },
    {
      'name': 'Agachamento Livre com Barra',
      'muscle': MuscleGroup.quadriceps,
      'secondary': [
        MuscleGroup.gluteoMaximo,
        MuscleGroup.adutores,
        MuscleGroup.lombar,
        MuscleGroup.posteriores,
      ],
      'animationKey': 'squat',
    },
    {
      'name': 'Leg Press 45°',
      'muscle': MuscleGroup.quadriceps,
      'secondary': [MuscleGroup.gluteoMaximo, MuscleGroup.adutores],
      'animationKey': 'squat',
    },
    {
      'name': 'Cadeira Adutora Isométrica',
      'muscle': MuscleGroup.adutores,
      'secondary': [MuscleGroup.gluteoMedio],
      'animationKey': 'squat',
    },
    {
      'name': 'Stiff com Barra Olímpica',
      'muscle': MuscleGroup.posteriores,
      'secondary': [
        MuscleGroup.gluteoMaximo,
        MuscleGroup.lombar,
        MuscleGroup.antebraco,
      ],
      'animationKey': 'romanian_deadlift',
    },
    {
      'name': 'Elevação Pélvica c/ Barra',
      'muscle': MuscleGroup.gluteoMaximo,
      'secondary': [
        MuscleGroup.gluteoMedio,
        MuscleGroup.posteriores,
        MuscleGroup.lombar,
      ],
      'animationKey': 'hip_thrust',
    },
    {
      'name': 'Abdução de Quadril na Polia',
      'muscle': MuscleGroup.gluteoMedio,
      'secondary': [MuscleGroup.gluteoMaximo],
      'animationKey': 'hip_thrust',
    },
    {
      'name': 'Panturrilha em Pé na Máquina',
      'muscle': MuscleGroup.panturrilhas,
      'secondary': <MuscleGroup>[],
      'animationKey': 'calf_raise',
    },
    {
      'name': 'Abdominal Infra Paralela',
      'muscle': MuscleGroup.retoAbdominal,
      'secondary': [MuscleGroup.obliquos],
      'animationKey': 'crunch',
    },
    {
      'name': 'Prancha Lateral Dinâmica (Oblíquos)',
      'muscle': MuscleGroup.obliquos,
      'secondary': [MuscleGroup.retoAbdominal, MuscleGroup.lombar],
      'animationKey': 'crunch',
    },
  ];

  static List<CommunityPost> buildInitialCommunityPosts() {
    return [
      CommunityPost(
        id: 'post-1',
        authorName: 'Maycon',
        authorAvatarUrl: 'https://i.pravatar.cc/150?u=maycon',
        workoutTitle: 'Treino A · Peito, Ombro e Tríceps (PR Supino!)',
        totalVolumeKg: 9420,
        setsCount: 18,
        durationLabel: '1h 05min',
        caption:
            'Top set no supino reto bateu 96kg para 8 repetições limpas! Seguindo o protocolo da REC.',
        timeAgo: 'há 42 min',
        likesCount: 14,
        isLikedByMe: true,
        comments: [
          const CommunityComment(
            authorName: 'Treinador Ruan (REC)',
            text:
                'Excelente execução! Na próxima semana subimos o Backoff set em 2kg.',
            timeAgo: 'há 25 min',
          ),
          const CommunityComment(
            authorName: 'Elizangela',
            text: 'Pra cima!! Evolução absurda!',
            timeAgo: 'há 12 min',
          ),
        ],
      ),
      CommunityPost(
        id: 'post-2',
        authorName: 'Elizangela',
        authorAvatarUrl: 'https://i.pravatar.cc/150?u=elizangela',
        workoutTitle: 'Treino B · Inferiores Completo (Foco Glúteo e Quads)',
        totalVolumeKg: 6840,
        setsCount: 16,
        durationLabel: '54min',
        caption:
            'Mais 1 semana batendo 100% dos treinos e meta de água concluída!',
        timeAgo: 'há 3 horas',
        likesCount: 21,
        isLikedByMe: false,
        comments: [
          const CommunityComment(
            authorName: 'Carlos Souza',
            text: 'Constância pura! Parabéns pelo resultado!',
            timeAgo: 'há 2 horas',
          ),
        ],
      ),
    ];
  }

  static List<StudentMobileProfile> buildInitialStudents() {
    return [_buildElizangela(), _buildMaycon(), _buildCarlos()];
  }

  static StudentMobileProfile _buildElizangela() {
    final workoutDays = _buildWorkoutDays(isHypertrophyHeavy: false);
    final sessions = _buildMultiMonthSessionsForStudent(
      studentPrefix: 'eli',
      scale: 0.76,
    );
    final seedPrs = <PersonalRecord>[
      PersonalRecord(
        id: 'pr-1',
        exerciseName: 'Agachamento Livre com Barra',
        weightKg: 76.0,
        reps: 8,
        dateLabel: '24/10/2026',
        previousBestKg: 70.0,
        primaryMuscle: MuscleGroup.quadriceps,
        secondaryMuscles: const [
          MuscleGroup.gluteoMaximo,
          MuscleGroup.adutores,
          MuscleGroup.lombar,
        ],
        animationKey: 'squat',
      ),
      PersonalRecord(
        id: 'pr-2',
        exerciseName: 'Elevação Pélvica c/ Barra',
        weightKg: 110.0,
        reps: 10,
        dateLabel: '23/10/2026',
        previousBestKg: 100.0,
        primaryMuscle: MuscleGroup.gluteoMaximo,
        secondaryMuscles: const [
          MuscleGroup.gluteoMedio,
          MuscleGroup.posteriores,
        ],
        animationKey: 'hip_thrust',
      ),
      PersonalRecord(
        id: 'pr-3',
        exerciseName: 'Supino Reto com Barra',
        weightKg: 38.0,
        reps: 8,
        dateLabel: '22/10/2026',
        previousBestKg: 34.0,
        primaryMuscle: MuscleGroup.peitoralMaior,
        secondaryMuscles: const [
          MuscleGroup.deltoideAnterior,
          MuscleGroup.triceps,
          MuscleGroup.peitoralSuperior,
        ],
        animationKey: 'bench_press',
        referenceGifPath: 'Peito/SUP.RETO.BARRA.jfif',
      ),
    ];

    return StudentMobileProfile(
      id: 1,
      name: 'Elizangela',
      plan: 'Trimestral',
      objective: 'Emagrecimento',
      avatarUrl: 'https://i.pravatar.cc/150?u=elizangela',
      startDate: '15/05/2026',
      subscriptionStatus: 'Em dia',
      currentWeightKg: 68.0,
      targetWeightKg: 60.0,
      bodyFatPercent: 28.3,
      dailyTargetNutrients: const NutrientProfile(
        calories: 1650,
        proteinG: 140,
        carbsG: 160,
        fatG: 55,
        fiberG: 28,
        sodiumMg: 1800,
        potassiumMg: 3200,
        calciumMg: 1000,
        ironMg: 15,
        magnesiumMg: 320,
        vitaminCMg: 90,
        vitaminDMcg: 15,
        vitaminB12Mcg: 2.4,
      ),
      waterTracker: WaterIntakeTracker(targetMl: 2800, consumedMl: 2250),
      workoutDays: workoutDays,
      completedSessions: sessions,
      suggestedMeals: _buildSuggestedMeals(isCalorieDeficit: true),
      customConsumedFoods: [
        CustomConsumedFood(
          id: 'cust-eli-1',
          name: 'Castanha-do-Pará (Porção Extra)',
          amountGrams: 15,
          mealOccasion: 'Lanche da Tarde',
          loggedAt: DateTime(2026, 10, 24, 16, 20),
          nutrients: const NutrientProfile(
            calories: 98,
            proteinG: 2.1,
            carbsG: 1.8,
            fatG: 9.9,
            fiberG: 1.1,
            sodiumMg: 1,
            potassiumMg: 99,
            calciumMg: 24,
            ironMg: 0.4,
            magnesiumMg: 56,
            vitaminCMg: 0.2,
            vitaminDMcg: 0,
            vitaminB12Mcg: 0,
          ),
        ),
      ],
      weeklyMetrics: RecoveryCalculator.computeWeeklyMetrics(
        sessions,
        referenceDate: defaultReferenceNow,
      ),
      muscleRecovery: RecoveryCalculator.computeMuscleRecovery(
        sessions,
        referenceTime: defaultReferenceNow,
      ),
      personalRecords: RecoveryCalculator.computePersonalRecords(
        sessions,
        seedRecords: seedPrs,
      ),
      exerciseEvolutions: RecoveryCalculator.computeExerciseEvolutions(
        sessions,
        prescribedDays: workoutDays,
        referenceDate: defaultReferenceNow,
      ),
      bodyMeasurements: [
        BodyMeasurementEntry(
          id: 'meas-1',
          dateLabel: '24/10/2026',
          weightKg: 68.0,
          bodyFatPercent: 28.3,
          circumferencesCm: {
            'Peitoral': 91.0,
            'Braço Direito': 29.5,
            'Braço Esquerdo': 29.3,
            'Antebraço': 24.5,
            'Cintura': 71.0,
            'Abdômen': 76.5,
            'Quadril': 99.0,
            'Coxa Direita': 57.5,
            'Coxa Esquerda': 57.2,
            'Panturrilha': 36.5,
          },
        ),
        BodyMeasurementEntry(
          id: 'meas-0',
          dateLabel: '15/08/2026',
          weightKg: 71.8,
          bodyFatPercent: 30.9,
          circumferencesCm: {
            'Peitoral': 94.0,
            'Braço Direito': 30.2,
            'Braço Esquerdo': 30.0,
            'Antebraço': 24.8,
            'Cintura': 76.5,
            'Abdômen': 82.0,
            'Quadril': 102.0,
            'Coxa Direita': 58.5,
            'Coxa Esquerda': 58.2,
            'Panturrilha': 36.8,
          },
        ),
      ],
      evolutionPhotos: const [
        EvolutionPhoto(
          id: 'photo-1',
          pose: 'Frente',
          dateLabel: '25/10/2026',
          weightKg: 68.0,
          notes: 'Semana 8 · Redução visível de linha de cintura.',
          imageUrl: 'https://i.pravatar.cc/300?u=eli_front',
        ),
        EvolutionPhoto(
          id: 'photo-2',
          pose: 'Costas',
          dateLabel: '25/10/2026',
          weightKg: 68.0,
          notes: 'Melhora postural e definição escapular.',
          imageUrl: 'https://i.pravatar.cc/300?u=eli_back',
        ),
        EvolutionPhoto(
          id: 'photo-3',
          pose: 'Perfil',
          dateLabel: '25/10/2026',
          weightKg: 68.0,
          notes: 'Evolução de glúteo e linha abdominal.',
          imageUrl: 'https://i.pravatar.cc/300?u=eli_side',
        ),
      ],
      anamnesisSubmissions: [
        AnamnesisSubmission(
          id: 2,
          studentName: 'Elizangela',
          type: 'Anamnese Corporal',
          dateLabel: '10/08/2026',
          status: 'Analisado',
          corporalAnswers: {
            'Peso e altura atuais': '68 kg · 1,63 m',
            'Percentual de Gordura e Massa Magra':
                '28,3% Gordura (19,2 kg) · 71,7% Massa Magra (48,8 kg)',
            'Possui lesões ou dores articulares?': 'Não.',
            'Histórico de cirurgias': 'Nenhuma cirurgia relevante.',
            'Pratica atividade física atualmente?':
                'Musculação 5x por semana com protocolo REC.',
          },
          alimentarAnswers: {
            'Quantas refeições faz por dia?': '5 refeições.',
            'Restrições ou alergias alimentares': 'Nenhuma.',
            'Consumo diário de água': '2,5 litros',
            'Uso de suplementos': 'Whey protein e creatina.',
          },
          espacialAnswers: {
            'Local de treino': 'Academia completa.',
            'Equipamentos disponíveis': 'Todos os equipamentos convencionais.',
            'Disponibilidade semanal': '5 dias · 1h15',
          },
        ),
      ],
      coachPhysicalAssessment: const CoachPhysicalAssessment(
        id: 'eval-eli-1',
        coachName: 'Prof. Ruan Emanuel (REC Consultoria)',
        evaluatedAt: '24/10/2026',
        protocolName: 'Pollock 7 Dobras + Bioimpedância Tetrapolar',
        weightKg: 68.0,
        heightMeters: 1.63,
        bodyFatPercent: 28.3,
        leanMassPercent: 71.7,
        visceralFatLevel: 5.0,
        basalMetabolicRateKcal: 1420,
        previousWeightKg: 74.0,
        previousBodyFatPercent: 32.5,
        previousLeanMassPercent: 67.5,
        skinfoldsMm: {
          'Tricipital': 16.5,
          'Subescapular': 14.0,
          'Supra-ilíaca': 18.0,
          'Abdominal': 21.0,
          'Coxa Medial': 22.5,
        },
        keyCircumferencesCm: {
          'Cintura': 71.0,
          'Abdômen': 76.5,
          'Quadril': 99.0,
          'Coxa Direita': 57.5,
          'Braço Contraído': 29.5,
        },
        posturalAssessment:
            'Alinhamento escapular preservado; melhora acentuada no controle pélvico durante o agachamento.',
        coachDiagnosticNotes:
            'Redução consistente de -6,0 kg de peso total e -4,2% de gordura corporal desde a Semana 1, com preservação e ganho proporcional de massa magra (71,7%). Manter déficit calórico moderado e frequência de 5 sessões/semana.',
      ),
      agendaDays: _buildAgendaDaysFromSessions(sessions, 2026, 10),
      notifications: [
        RecNotificationItem(
          id: 'notif-1',
          title: 'Treino atualizado pelo Treinador',
          body:
              'Ruan adicionou 1 Top Set + 1 Backoff Set no Supino Reto do seu Treino A.',
          timeAgo: 'há 15 min',
          category: NotificationCategory.coachWorkoutUpdate,
          isRead: false,
        ),
        RecNotificationItem(
          id: 'notif-2',
          title: 'Nova curtida na Comunidade',
          body: 'Maycon e outros 4 alunos curtiram seu Treino B compartilhado.',
          timeAgo: 'há 1h',
          category: NotificationCategory.communityLike,
          isRead: false,
        ),
        RecNotificationItem(
          id: 'notif-3',
          title: 'Comentário do Treinador',
          body:
              'Ruan comentou: "Excelente constância na meta de água desta semana!"',
          timeAgo: 'há 3h',
          category: NotificationCategory.communityComment,
          isRead: false,
        ),
        RecNotificationItem(
          id: 'notif-4',
          title: 'Check-in de Anamnese Mensal',
          body:
              'Atualize sua Anamnese Corporal, Alimentar e Espacial para a revisão de protocolo.',
          timeAgo: 'há 1 dia',
          category: NotificationCategory.anamnesisRequest,
          isRead: true,
        ),
      ],
    );
  }

  static StudentMobileProfile _buildMaycon() {
    final workoutDays = _buildWorkoutDays(isHypertrophyHeavy: true);
    final sessions = _buildMultiMonthSessionsForStudent(
      studentPrefix: 'may',
      scale: 1.35,
    );
    final seedPrs = <PersonalRecord>[
      PersonalRecord(
        id: 'pr-may-1',
        exerciseName: 'Supino Reto com Barra',
        weightKg: 96.0,
        reps: 8,
        dateLabel: '23/10/2026',
        previousBestKg: 92.0,
        primaryMuscle: MuscleGroup.peitoralMaior,
        secondaryMuscles: const [
          MuscleGroup.deltoideAnterior,
          MuscleGroup.triceps,
          MuscleGroup.peitoralSuperior,
        ],
        animationKey: 'bench_press',
        referenceGifPath: 'Peito/SUP.RETO.BARRA.jfif',
      ),
      PersonalRecord(
        id: 'pr-may-2',
        exerciseName: 'Remada Curvada Pronada',
        weightKg: 88.0,
        reps: 8,
        dateLabel: '22/10/2026',
        previousBestKg: 84.0,
        primaryMuscle: MuscleGroup.dorsal,
        secondaryMuscles: const [
          MuscleGroup.trapezio,
          MuscleGroup.deltoidePosterior,
          MuscleGroup.lombar,
          MuscleGroup.biceps,
        ],
        animationKey: 'lat_pulldown',
      ),
    ];

    return StudentMobileProfile(
      id: 2,
      name: 'Maycon',
      plan: 'Mensal',
      objective: 'Hipertrofia',
      avatarUrl: 'https://i.pravatar.cc/150?u=maycon',
      startDate: '10/07/2026',
      subscriptionStatus: 'Atrasado',
      currentWeightKg: 75.0,
      targetWeightKg: 82.0,
      bodyFatPercent: 14.4,
      dailyTargetNutrients: const NutrientProfile(
        calories: 2900,
        proteinG: 175,
        carbsG: 380,
        fatG: 80,
        fiberG: 35,
        sodiumMg: 2300,
        potassiumMg: 3800,
        calciumMg: 1200,
        ironMg: 18,
        magnesiumMg: 410,
        vitaminCMg: 110,
        vitaminDMcg: 20,
        vitaminB12Mcg: 3.2,
      ),
      waterTracker: WaterIntakeTracker(targetMl: 3500, consumedMl: 3000),
      workoutDays: workoutDays,
      completedSessions: sessions,
      suggestedMeals: _buildSuggestedMeals(isCalorieDeficit: false),
      customConsumedFoods: [],
      weeklyMetrics: RecoveryCalculator.computeWeeklyMetrics(
        sessions,
        referenceDate: defaultReferenceNow,
      ),
      muscleRecovery: RecoveryCalculator.computeMuscleRecovery(
        sessions,
        referenceTime: defaultReferenceNow,
      ),
      personalRecords: RecoveryCalculator.computePersonalRecords(
        sessions,
        seedRecords: seedPrs,
      ),
      exerciseEvolutions: RecoveryCalculator.computeExerciseEvolutions(
        sessions,
        prescribedDays: workoutDays,
        referenceDate: defaultReferenceNow,
      ),
      bodyMeasurements: [
        BodyMeasurementEntry(
          id: 'meas-may-1',
          dateLabel: '24/10/2026',
          weightKg: 75.0,
          bodyFatPercent: 14.4,
          circumferencesCm: {
            'Peitoral': 106.5,
            'Braço Direito': 40.2,
            'Braço Esquerdo': 40.0,
            'Antebraço': 31.0,
            'Cintura': 78.0,
            'Abdômen': 80.0,
            'Quadril': 97.0,
            'Coxa Direita': 60.5,
            'Coxa Esquerda': 60.2,
            'Panturrilha': 39.5,
          },
        ),
      ],
      evolutionPhotos: const [
        EvolutionPhoto(
          id: 'photo-may-1',
          pose: 'Frente',
          dateLabel: '20/10/2026',
          weightKg: 75.0,
          notes: 'Ganho de densidade em peitoral e deltoides.',
          imageUrl: 'https://i.pravatar.cc/300?u=may_front',
        ),
      ],
      anamnesisSubmissions: [
        AnamnesisSubmission(
          id: 4,
          studentName: 'Maycon',
          type: 'Anamnese Alimentar',
          dateLabel: '08/08/2026',
          status: 'Analisado',
          corporalAnswers: {
            'Peso e altura atuais': '75 kg · 1,76 m',
            'Percentual de Gordura e Massa Magra':
                '14,4% Gordura (10,8 kg) · 85,6% Massa Magra (64,2 kg)',
            'Possui lesões ou dores articulares?': 'Não.',
          },
          alimentarAnswers: {
            'Quantas refeições faz por dia?': '5 refeições.',
            'Uso de suplementos': 'Whey protein, creatina e beta-alanina.',
          },
          espacialAnswers: {
            'Local de treino': 'Academia completa.',
            'Disponibilidade semanal': '5 dias · 1h15',
          },
        ),
      ],
      coachPhysicalAssessment: const CoachPhysicalAssessment(
        id: 'eval-may-1',
        coachName: 'Prof. Ruan Emanuel (REC Consultoria)',
        evaluatedAt: '20/10/2026',
        protocolName: 'Pollock 7 Dobras + Antropometria Avançada',
        weightKg: 75.0,
        heightMeters: 1.76,
        bodyFatPercent: 14.4,
        leanMassPercent: 85.6,
        visceralFatLevel: 3.0,
        basalMetabolicRateKcal: 1890,
        previousWeightKg: 71.2,
        previousBodyFatPercent: 14.0,
        previousLeanMassPercent: 86.0,
        skinfoldsMm: {
          'Peitoral': 7.5,
          'Tricipital': 8.0,
          'Subescapular': 10.5,
          'Abdominal': 13.0,
          'Coxa Medial': 11.5,
        },
        keyCircumferencesCm: {
          'Peitoral': 106.5,
          'Braço Contraído': 40.2,
          'Cintura': 78.0,
          'Coxa Direita': 60.5,
          'Panturrilha': 39.5,
        },
        posturalAssessment:
            'Excelente simetria escapular e hipertrofia visível na porção clavicular do peitoral e deltoide lateral.',
        coachDiagnosticNotes:
            'Ganho limpo de +3,8 kg de massa corporal mantendo o BF controlado em 14,4% (64,2 kg de Massa Magra). Foco agora em progredir cargas no Supino Inclinado e Remada Curvada.',
      ),
      agendaDays: _buildAgendaDaysFromSessions(sessions, 2026, 10),
      notifications: [
        RecNotificationItem(
          id: 'notif-may-1',
          title: 'Ajuste de Carga Sugerido',
          body:
              'Treinador Ruan sugeriu progredir 2kg nos Working Sets de Supino.',
          timeAgo: 'há 30 min',
          category: NotificationCategory.coachWorkoutUpdate,
          isRead: false,
        ),
      ],
    );
  }

  static StudentMobileProfile _buildCarlos() {
    final workoutDays = _buildWorkoutDays(isHypertrophyHeavy: true);
    final sessions = _buildMultiMonthSessionsForStudent(
      studentPrefix: 'car',
      scale: 1.10,
    );
    final seedPrs = <PersonalRecord>[
      PersonalRecord(
        id: 'pr-car-1',
        exerciseName: 'Agachamento Livre com Barra',
        weightKg: 112.0,
        reps: 5,
        dateLabel: '24/10/2026',
        previousBestKg: 106.0,
        primaryMuscle: MuscleGroup.quadriceps,
        secondaryMuscles: const [
          MuscleGroup.gluteoMaximo,
          MuscleGroup.adutores,
          MuscleGroup.lombar,
        ],
        animationKey: 'squat',
      ),
    ];

    return StudentMobileProfile(
      id: 3,
      name: 'Carlos Souza',
      plan: 'Anual',
      objective: 'Emagrecimento',
      avatarUrl: 'https://i.pravatar.cc/150?u=carlos',
      startDate: '01/01/2026',
      subscriptionStatus: 'Em dia',
      currentWeightKg: 94.0,
      targetWeightKg: 85.0,
      bodyFatPercent: 26.7,
      dailyTargetNutrients: const NutrientProfile(
        calories: 2200,
        proteinG: 180,
        carbsG: 200,
        fatG: 65,
        fiberG: 30,
        sodiumMg: 2000,
        potassiumMg: 3400,
        calciumMg: 1000,
        ironMg: 16,
        magnesiumMg: 360,
        vitaminCMg: 95,
        vitaminDMcg: 15,
        vitaminB12Mcg: 2.6,
      ),
      waterTracker: WaterIntakeTracker(targetMl: 3200, consumedMl: 1800),
      workoutDays: workoutDays,
      completedSessions: sessions,
      suggestedMeals: _buildSuggestedMeals(isCalorieDeficit: true),
      customConsumedFoods: [],
      weeklyMetrics: RecoveryCalculator.computeWeeklyMetrics(
        sessions,
        referenceDate: defaultReferenceNow,
      ),
      muscleRecovery: RecoveryCalculator.computeMuscleRecovery(
        sessions,
        referenceTime: defaultReferenceNow,
      ),
      personalRecords: RecoveryCalculator.computePersonalRecords(
        sessions,
        seedRecords: seedPrs,
      ),
      exerciseEvolutions: RecoveryCalculator.computeExerciseEvolutions(
        sessions,
        prescribedDays: workoutDays,
        referenceDate: defaultReferenceNow,
      ),
      bodyMeasurements: [
        BodyMeasurementEntry(
          id: 'meas-car-1',
          dateLabel: '24/10/2026',
          weightKg: 94.0,
          bodyFatPercent: 26.7,
          circumferencesCm: {
            'Peitoral': 110.0,
            'Braço Direito': 38.5,
            'Braço Esquerdo': 38.2,
            'Antebraço': 30.2,
            'Cintura': 96.0,
            'Abdômen': 99.0,
            'Quadril': 104.0,
            'Coxa Direita': 61.0,
            'Coxa Esquerda': 60.8,
            'Panturrilha': 40.5,
          },
        ),
      ],
      evolutionPhotos: const [],
      anamnesisSubmissions: [
        AnamnesisSubmission(
          id: 1,
          studentName: 'Carlos Souza',
          type: 'Pré-seleção',
          dateLabel: '12/08/2026',
          status: 'Pendente',
          corporalAnswers: {
            'Peso e altura atuais': '94 kg · 1,78 m',
            'Percentual de Gordura e Massa Magra':
                '26,7% Gordura (25,1 kg) · 73,3% Massa Magra (68,9 kg)',
            'Possui lesões ou dores articulares?':
                'Desconforto leve no joelho direito.',
          },
          alimentarAnswers: {
            'Quantas refeições faz por dia?':
                '3 refeições, pula o café da manhã.',
            'Restrições ou alergias alimentares': 'Intolerância à lactose.',
          },
          espacialAnswers: {
            'Local de treino': 'Academia de condomínio.',
            'Disponibilidade semanal': '3 dias · 50 min',
          },
        ),
      ],
      coachPhysicalAssessment: const CoachPhysicalAssessment(
        id: 'eval-car-1',
        coachName: 'Prof. Ruan Emanuel (REC Consultoria)',
        evaluatedAt: '18/10/2026',
        protocolName: 'Bioimpedância InBody + Perimetria Clínica',
        weightKg: 94.0,
        heightMeters: 1.78,
        bodyFatPercent: 26.7,
        leanMassPercent: 73.3,
        visceralFatLevel: 9.0,
        basalMetabolicRateKcal: 1960,
        previousWeightKg: 96.0,
        previousBodyFatPercent: 27.8,
        previousLeanMassPercent: 72.2,
        skinfoldsMm: {
          'Tricipital': 15.0,
          'Subescapular': 22.0,
          'Supra-ilíaca': 24.0,
          'Abdominal': 28.0,
          'Coxa Medial': 18.0,
        },
        keyCircumferencesCm: {
          'Peitoral': 110.0,
          'Cintura': 96.0,
          'Abdômen': 99.0,
          'Quadril': 104.0,
          'Coxa Direita': 61.0,
        },
        posturalAssessment:
            'Cautela na flexão profunda de joelho direito; fortalecimento de glúteo médio e vasto medial em andamento.',
        coachDiagnosticNotes:
            'Redução inicial de -2,0 kg e queda de 1,1% no percentual de gordura, elevando a Massa Magra para 73,3% (68,9 kg). Priorizar hidratação (meta de 3,2L) e constância nas 3-4 sessões semanais.',
      ),
      agendaDays: _buildAgendaDaysFromSessions(sessions, 2026, 10),
      notifications: [
        RecNotificationItem(
          id: 'notif-car-1',
          title: 'Anamnese Pendente de Revisão',
          body:
              'Complete seu check-in mensal na aba You para ajustarmos seu treino 5x5.',
          timeAgo: 'há 2h',
          category: NotificationCategory.anamnesisRequest,
          isRead: false,
        ),
      ],
    );
  }

  /// Gera ~4 meses de sessões detalhadas (Agosto, Setembro, Outubro e Novembro de 2026)
  /// garantindo:
  /// - Na semana ativa de Outubro (19/10 Seg a 25/10 Dom):
  ///   * Seg 19/10: Treino A (4920 kg, 52 min) -> Supino Reto com Barra (sessão 1 na semana)
  ///   * Ter 20/10: Treino B (6840 kg, 58 min) -> Agachamento Livre com Barra (1x na semana, mas presente em 06/10, 13/10, 20/10, 27/10!)
  ///   * Qui 22/10: Treino C (4610 kg, 48 min) -> Puxada Frontal Aberta, Remada Curvada, Rosca Direta
  ///   * Sex 23/10: Treino D + Upper Pump (7150 kg, 61 min) -> Elevação Pélvica, Stiff e Supino Reto com Barra (sessão 2 na mesma semana!)
  ///   * Sáb 24/10: Treino E Complementar (3890 kg, 45 min) -> Elevação Pélvica (sessão 2 na semana!), Panturrilha, Abdominal
  static List<CompletedWorkoutSession> _buildMultiMonthSessionsForStudent({
    required String studentPrefix,
    required double scale,
  }) {
    double w(double base) => (base * scale).roundToDouble();
    int vol(int base) => (base * scale).round();

    CompletedExerciseLog makeLog({
      required String name,
      required MuscleGroup primary,
      required List<MuscleGroup> secondary,
      required double topWeight,
      required int reps,
      int setsCount = 3,
    }) {
      return CompletedExerciseLog(
        exerciseName: name,
        primaryMuscle: primary,
        secondaryMuscles: secondary,
        sets: List.generate(setsCount, (idx) {
          final isTop = idx == setsCount - 1;
          final setWeight = isTop
              ? topWeight
              : (topWeight * 0.90).roundToDouble();
          return ExerciseSet(
            id: 'set-${name.hashCode.abs()}-$idx',
            index: idx + 1,
            type: isTop ? SetType.top : SetType.working,
            targetReps: '$reps',
            weightKg: setWeight,
            completedReps: reps,
            completed: true,
          );
        }),
      );
    }

    final sessions = <CompletedWorkoutSession>[
      // ===================== SEMANA ATIVA (19/10/2026 a 25/10/2026) =====================
      // Sábado 24/10/2026
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct24',
        workoutName: 'Treino E · Costas Densidade (Dorsal, Trapézio & Delt. Post.)',
        totalWeightLiftedKg: vol(5120).toDouble(),
        totalSets: 14,
        durationMinutes: 45,
        completedAt: DateTime(2026, 10, 24, 11, 0),
        workedMuscles: const [
          MuscleGroup.dorsal,
          MuscleGroup.trapezio,
          MuscleGroup.deltoidePosterior,
          MuscleGroup.biceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Remada Curvada Pronada',
            primary: MuscleGroup.trapezio,
            secondary: const [
              MuscleGroup.dorsal,
              MuscleGroup.deltoidePosterior,
            ],
            topWeight: w(68),
            reps: 8,
            setsCount: 4,
          ),
          makeLog(
            name: 'Puxada Frontal Aberta',
            primary: MuscleGroup.dorsal,
            secondary: const [
              MuscleGroup.trapezio,
              MuscleGroup.biceps,
            ],
            topWeight: w(70),
            reps: 10,
            setsCount: 4,
          ),
        ],
        isSaved: true,
        notes: 'Foco em pico de contração escapular e densidade de dorsal/trapézio.',
      ),

      // Sexta 23/10/2026 (Inclui 2ª sessão de Supino Reto na semana!)
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct23',
        workoutName: 'Treino D · Peitoral Intenso (Superior & Maior)',
        totalWeightLiftedKg: vol(9410).toDouble(),
        totalSets: 16,
        durationMinutes: 61,
        completedAt: DateTime(2026, 10, 23, 18, 30),
        workedMuscles: const [
          MuscleGroup.peitoralMaior,
          MuscleGroup.peitoralSuperior,
          MuscleGroup.deltoideAnterior,
          MuscleGroup.triceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Supino Reto com Barra',
            primary: MuscleGroup.peitoralMaior,
            secondary: const [
              MuscleGroup.deltoideAnterior,
              MuscleGroup.triceps,
            ],
            topWeight: w(50),
            reps: 8,
            setsCount: 3,
          ),
          makeLog(
            name: 'Crucifixo Inclinado c/ Halteres',
            primary: MuscleGroup.peitoralSuperior,
            secondary: const [
              MuscleGroup.peitoralMaior,
              MuscleGroup.deltoideAnterior,
            ],
            topWeight: w(22),
            reps: 10,
            setsCount: 4,
          ),
          makeLog(
            name: 'Crossover Polia Alta',
            primary: MuscleGroup.peitoralMaior,
            secondary: const [
              MuscleGroup.peitoralSuperior,
            ],
            topWeight: w(28),
            reps: 12,
            setsCount: 2,
          ),
        ],
        isSaved: true,
        isShared: true,
        notes: 'Segunda sessão de Supino na semana batendo novo recorde!',
      ),

      // Quinta 22/10/2026
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct22',
        workoutName: 'Treino C · Puxar (Dorsal, Trapézio, Delt. Post. e Bíceps)',
        totalWeightLiftedKg: vol(6065).toDouble(),
        totalSets: 15,
        durationMinutes: 48,
        completedAt: DateTime(2026, 10, 22, 19, 0),
        workedMuscles: const [
          MuscleGroup.dorsal,
          MuscleGroup.trapezio,
          MuscleGroup.deltoidePosterior,
          MuscleGroup.biceps,
          MuscleGroup.antebraco,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Puxada Frontal Aberta',
            primary: MuscleGroup.dorsal,
            secondary: const [
              MuscleGroup.trapezio,
              MuscleGroup.biceps,
            ],
            topWeight: w(68),
            reps: 10,
            setsCount: 4,
          ),
          makeLog(
            name: 'Remada Curvada Pronada',
            primary: MuscleGroup.trapezio,
            secondary: const [
              MuscleGroup.dorsal,
              MuscleGroup.deltoidePosterior,
            ],
            topWeight: w(65),
            reps: 8,
            setsCount: 4,
          ),
          makeLog(
            name: 'Rosca Direta Barra W',
            primary: MuscleGroup.biceps,
            secondary: const [MuscleGroup.antebraco],
            topWeight: w(32),
            reps: 10,
            setsCount: 2,
          ),
        ],
        notes: 'Pico de contração de 2s na puxada e controle excêntrico.',
      ),

      // Terça 20/10/2026 (Agachamento Livre aparece 1x na semana -> compara com as semanas do mês!)
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct20',
        workoutName: 'Treino B · Inferiores Técnico (Agachamento & Leg Press)',
        totalWeightLiftedKg: vol(9000).toDouble(),
        totalSets: 16,
        durationMinutes: 58,
        completedAt: DateTime(2026, 10, 20, 19, 0),
        workedMuscles: const [
          MuscleGroup.quadriceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Agachamento Livre com Barra',
            primary: MuscleGroup.quadriceps,
            secondary: const [],
            topWeight: w(100),
            reps: 8,
            setsCount: 2,
          ),
          makeLog(
            name: 'Leg Press 45°',
            primary: MuscleGroup.quadriceps,
            secondary: const [],
            topWeight: w(220),
            reps: 10,
            setsCount: 2,
          ),
        ],
        isShared: true,
        notes: 'Cluster set no Leg Press 45° exigiu bastante foco.',
      ),

      // Segunda 19/10/2026 (1ª sessão de Supino Reto na semana!)
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct19',
        workoutName: 'Treino A · Empurrar (Peitoral, Deltoides e Tríceps)',
        totalWeightLiftedKg: vol(6475).toDouble(),
        totalSets: 15,
        durationMinutes: 52,
        completedAt: DateTime(2026, 10, 19, 18, 30),
        workedMuscles: const [
          MuscleGroup.peitoralMaior,
          MuscleGroup.peitoralSuperior,
          MuscleGroup.deltoideAnterior,
          MuscleGroup.deltoideLateral,
          MuscleGroup.triceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Supino Reto com Barra',
            primary: MuscleGroup.peitoralMaior,
            secondary: const [
              MuscleGroup.deltoideAnterior,
              MuscleGroup.triceps,
            ],
            topWeight: w(47),
            reps: 8,
            setsCount: 3,
          ),
          makeLog(
            name: 'Supino Inclinado no Smith',
            primary: MuscleGroup.peitoralSuperior,
            secondary: const [
              MuscleGroup.peitoralMaior,
              MuscleGroup.deltoideAnterior,
            ],
            topWeight: w(38),
            reps: 10,
            setsCount: 3,
          ),
          makeLog(
            name: 'Elevação Lateral Controlada',
            primary: MuscleGroup.deltoideLateral,
            secondary: const [],
            topWeight: w(12),
            reps: 12,
            setsCount: 2,
          ),
          makeLog(
            name: 'Tríceps Corda na Polia',
            primary: MuscleGroup.triceps,
            secondary: const [MuscleGroup.antebraco],
            topWeight: w(30),
            reps: 12,
            setsCount: 2,
          ),
        ],
        isSaved: true,
        notes: 'Ótimo ritmo nas séries de trabalho, descanso controlado em 60s.',
      ),

      // ===================== OUTRAS SEMANAS DE OUTUBRO 2026 =====================
      // Semana 1, 2 e 3 de Outubro (para comparar exercícios feitos 1x na semana dentro do mês!)
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct02',
        workoutName: 'Treino A · Empurrar (Semana 1 Outubro)',
        totalWeightLiftedKg: vol(5950).toDouble(),
        totalSets: 15,
        durationMinutes: 50,
        completedAt: DateTime(2026, 10, 2, 18, 0),
        workedMuscles: const [
          MuscleGroup.peitoralMaior,
          MuscleGroup.peitoralSuperior,
          MuscleGroup.deltoideLateral,
          MuscleGroup.triceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Supino Reto com Barra',
            primary: MuscleGroup.peitoralMaior,
            secondary: const [MuscleGroup.deltoideAnterior, MuscleGroup.triceps],
            topWeight: w(43),
            reps: 8,
          ),
          makeLog(
            name: 'Desenvolvimento com Halteres',
            primary: MuscleGroup.deltoideAnterior,
            secondary: const [MuscleGroup.deltoideLateral, MuscleGroup.triceps],
            topWeight: w(20),
            reps: 10,
          ),
          makeLog(
            name: 'Elevação Lateral Controlada',
            primary: MuscleGroup.deltoideLateral,
            secondary: const [MuscleGroup.trapezio],
            topWeight: w(10),
            reps: 12,
          ),
          makeLog(
            name: 'Tríceps Corda na Polia',
            primary: MuscleGroup.triceps,
            secondary: const [MuscleGroup.antebraco],
            topWeight: w(26),
            reps: 12,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct05',
        workoutName: 'Treino B · Inferiores Completo (Semana 1 Outubro)',
        totalWeightLiftedKg: vol(8100).toDouble(),
        totalSets: 15,
        durationMinutes: 55,
        completedAt: DateTime(2026, 10, 5, 19, 0),
        workedMuscles: const [
          MuscleGroup.quadriceps,
          MuscleGroup.gluteoMaximo,
          MuscleGroup.posteriores,
          MuscleGroup.adutores,
          MuscleGroup.panturrilhas,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Agachamento Livre com Barra',
            primary: MuscleGroup.quadriceps,
            secondary: const [MuscleGroup.gluteoMaximo, MuscleGroup.adutores],
            topWeight: w(90),
            reps: 8,
          ),
          makeLog(
            name: 'Stiff com Barra Olímpica',
            primary: MuscleGroup.posteriores,
            secondary: const [MuscleGroup.gluteoMaximo, MuscleGroup.lombar],
            topWeight: w(80),
            reps: 10,
          ),
          makeLog(
            name: 'Cadeira Adutora Isométrica',
            primary: MuscleGroup.adutores,
            secondary: const [MuscleGroup.gluteoMedio],
            topWeight: w(65),
            reps: 12,
          ),
          makeLog(
            name: 'Panturrilha em Pé na Máquina',
            primary: MuscleGroup.panturrilhas,
            secondary: const [],
            topWeight: w(85),
            reps: 15,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct08',
        workoutName: 'Treino C · Puxar Completo (Semana 2 Outubro)',
        totalWeightLiftedKg: vol(5600).toDouble(),
        totalSets: 14,
        durationMinutes: 47,
        completedAt: DateTime(2026, 10, 8, 18, 30),
        workedMuscles: const [
          MuscleGroup.dorsal,
          MuscleGroup.trapezio,
          MuscleGroup.biceps,
          MuscleGroup.deltoidePosterior,
          MuscleGroup.antebraco,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Puxada Frontal Aberta',
            primary: MuscleGroup.dorsal,
            secondary: const [MuscleGroup.biceps, MuscleGroup.trapezio],
            topWeight: w(62),
            reps: 10,
          ),
          makeLog(
            name: 'Crucifixo Inverso na Máquina',
            primary: MuscleGroup.deltoidePosterior,
            secondary: const [MuscleGroup.trapezio],
            topWeight: w(42),
            reps: 12,
          ),
          makeLog(
            name: 'Rosca Martelo Alternada',
            primary: MuscleGroup.antebraco,
            secondary: const [MuscleGroup.biceps],
            topWeight: w(18),
            reps: 12,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct12',
        workoutName: 'Treino B · Inferiores & Core (Semana 2 Outubro)',
        totalWeightLiftedKg: vol(8450).toDouble(),
        totalSets: 15,
        durationMinutes: 56,
        completedAt: DateTime(2026, 10, 12, 19, 0),
        workedMuscles: const [
          MuscleGroup.quadriceps,
          MuscleGroup.gluteoMaximo,
          MuscleGroup.gluteoMedio,
          MuscleGroup.retoAbdominal,
          MuscleGroup.obliquos,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Agachamento Livre com Barra',
            primary: MuscleGroup.quadriceps,
            secondary: const [MuscleGroup.gluteoMaximo, MuscleGroup.adutores],
            topWeight: w(94),
            reps: 8,
          ),
          makeLog(
            name: 'Elevação Pélvica c/ Barra',
            primary: MuscleGroup.gluteoMaximo,
            secondary: const [MuscleGroup.posteriores],
            topWeight: w(145),
            reps: 10,
          ),
          makeLog(
            name: 'Abdução de Quadril na Polia',
            primary: MuscleGroup.gluteoMedio,
            secondary: const [MuscleGroup.gluteoMaximo],
            topWeight: w(35),
            reps: 12,
          ),
          makeLog(
            name: 'Abdominal Infra Paralela',
            primary: MuscleGroup.retoAbdominal,
            secondary: const [MuscleGroup.obliquos],
            topWeight: w(15),
            reps: 15,
          ),
          makeLog(
            name: 'Prancha Lateral Dinâmica (Oblíquos)',
            primary: MuscleGroup.obliquos,
            secondary: const [MuscleGroup.retoAbdominal, MuscleGroup.lombar],
            topWeight: w(12),
            reps: 14,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct15',
        workoutName: 'Treino D · Posterior & Dorsal (Semana 3 Outubro)',
        totalWeightLiftedKg: vol(6900).toDouble(),
        totalSets: 15,
        durationMinutes: 54,
        completedAt: DateTime(2026, 10, 15, 19, 0),
        workedMuscles: const [
          MuscleGroup.posteriores,
          MuscleGroup.dorsal,
          MuscleGroup.biceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Stiff com Barra Olímpica',
            primary: MuscleGroup.posteriores,
            secondary: const [MuscleGroup.gluteoMaximo, MuscleGroup.lombar],
            topWeight: w(85),
            reps: 8,
          ),
          makeLog(
            name: 'Puxada Frontal Aberta',
            primary: MuscleGroup.dorsal,
            secondary: const [MuscleGroup.biceps],
            topWeight: w(65),
            reps: 10,
          ),
          makeLog(
            name: 'Crucifixo Inclinado c/ Halteres',
            primary: MuscleGroup.peitoralSuperior,
            secondary: const [MuscleGroup.peitoralMaior],
            topWeight: w(18),
            reps: 10,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-oct16',
        workoutName: 'Treino B · Inferiores Progressão (Semana 3 Outubro)',
        totalWeightLiftedKg: vol(8720).toDouble(),
        totalSets: 16,
        durationMinutes: 57,
        completedAt: DateTime(2026, 10, 16, 18, 30),
        workedMuscles: const [
          MuscleGroup.quadriceps,
          MuscleGroup.gluteoMaximo,
          MuscleGroup.panturrilhas,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Agachamento Livre com Barra',
            primary: MuscleGroup.quadriceps,
            secondary: const [MuscleGroup.gluteoMaximo],
            topWeight: w(97),
            reps: 8,
          ),
          makeLog(
            name: 'Panturrilha em Pé na Máquina',
            primary: MuscleGroup.panturrilhas,
            secondary: const [],
            topWeight: w(80),
            reps: 15,
          ),
        ],
      ),

      // ===================== SETEMBRO 2026 (Histórico Mês Anterior) =====================
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-sep04',
        workoutName: 'Treino A · Base Hipertrofia Setembro',
        totalWeightLiftedKg: vol(5400).toDouble(),
        totalSets: 14,
        durationMinutes: 49,
        completedAt: DateTime(2026, 9, 4, 18, 30),
        workedMuscles: const [
          MuscleGroup.peitoralMaior,
          MuscleGroup.deltoideAnterior,
          MuscleGroup.triceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Supino Reto com Barra',
            primary: MuscleGroup.peitoralMaior,
            secondary: const [MuscleGroup.deltoideAnterior, MuscleGroup.triceps],
            topWeight: w(41),
            reps: 8,
          ),
          makeLog(
            name: 'Desenvolvimento com Halteres',
            primary: MuscleGroup.deltoideAnterior,
            secondary: const [MuscleGroup.deltoideLateral],
            topWeight: w(19),
            reps: 10,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-sep11',
        workoutName: 'Treino B · Inferiores Força Setembro',
        totalWeightLiftedKg: vol(7650).toDouble(),
        totalSets: 15,
        durationMinutes: 55,
        completedAt: DateTime(2026, 9, 11, 19, 0),
        workedMuscles: const [
          MuscleGroup.quadriceps,
          MuscleGroup.gluteoMaximo,
          MuscleGroup.posteriores,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Agachamento Livre com Barra',
            primary: MuscleGroup.quadriceps,
            secondary: const [MuscleGroup.gluteoMaximo],
            topWeight: w(88),
            reps: 8,
          ),
          makeLog(
            name: 'Elevação Pélvica c/ Barra',
            primary: MuscleGroup.gluteoMaximo,
            secondary: const [MuscleGroup.posteriores],
            topWeight: w(125),
            reps: 10,
          ),
          makeLog(
            name: 'Stiff com Barra Olímpica',
            primary: MuscleGroup.posteriores,
            secondary: const [MuscleGroup.lombar],
            topWeight: w(76),
            reps: 10,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-sep18',
        workoutName: 'Treino C · Dorsal & Bíceps Setembro',
        totalWeightLiftedKg: vol(5250).toDouble(),
        totalSets: 14,
        durationMinutes: 46,
        completedAt: DateTime(2026, 9, 18, 18, 0),
        workedMuscles: const [
          MuscleGroup.dorsal,
          MuscleGroup.trapezio,
          MuscleGroup.biceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Puxada Frontal Aberta',
            primary: MuscleGroup.dorsal,
            secondary: const [MuscleGroup.biceps],
            topWeight: w(60),
            reps: 10,
          ),
          makeLog(
            name: 'Remada Curvada Pronada',
            primary: MuscleGroup.dorsal,
            secondary: const [MuscleGroup.trapezio],
            topWeight: w(58),
            reps: 8,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-sep25',
        workoutName: 'Treino D · Deload Ativo & Core Setembro',
        totalWeightLiftedKg: vol(4890).toDouble(),
        totalSets: 13,
        durationMinutes: 44,
        completedAt: DateTime(2026, 9, 25, 19, 15),
        workedMuscles: const [
          MuscleGroup.retoAbdominal,
          MuscleGroup.obliquos,
          MuscleGroup.panturrilhas,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Abdominal Infra Paralela',
            primary: MuscleGroup.retoAbdominal,
            secondary: const [MuscleGroup.obliquos],
            topWeight: w(12),
            reps: 15,
          ),
          makeLog(
            name: 'Panturrilha em Pé na Máquina',
            primary: MuscleGroup.panturrilhas,
            secondary: const [],
            topWeight: w(75),
            reps: 15,
          ),
        ],
      ),

      // ===================== AGOSTO 2026 (Histórico 2 Meses Atrás) =====================
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-aug07',
        workoutName: 'Treino A · Adaptação Anatômica Agosto',
        totalWeightLiftedKg: vol(4800).toDouble(),
        totalSets: 14,
        durationMinutes: 48,
        completedAt: DateTime(2026, 8, 7, 18, 30),
        workedMuscles: const [
          MuscleGroup.peitoralMaior,
          MuscleGroup.deltoideAnterior,
          MuscleGroup.triceps,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Supino Reto com Barra',
            primary: MuscleGroup.peitoralMaior,
            secondary: const [MuscleGroup.deltoideAnterior, MuscleGroup.triceps],
            topWeight: w(38),
            reps: 10,
          ),
          makeLog(
            name: 'Crucifixo Inclinado c/ Halteres',
            primary: MuscleGroup.peitoralSuperior,
            secondary: const [MuscleGroup.peitoralMaior],
            topWeight: w(15),
            reps: 12,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-aug14',
        workoutName: 'Treino B · Inferiores Base Agosto',
        totalWeightLiftedKg: vol(6950).toDouble(),
        totalSets: 15,
        durationMinutes: 53,
        completedAt: DateTime(2026, 8, 14, 19, 0),
        workedMuscles: const [
          MuscleGroup.quadriceps,
          MuscleGroup.gluteoMaximo,
          MuscleGroup.posteriores,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Agachamento Livre com Barra',
            primary: MuscleGroup.quadriceps,
            secondary: const [MuscleGroup.gluteoMaximo],
            topWeight: w(82),
            reps: 10,
          ),
          makeLog(
            name: 'Elevação Pélvica c/ Barra',
            primary: MuscleGroup.gluteoMaximo,
            secondary: const [MuscleGroup.posteriores],
            topWeight: w(115),
            reps: 10,
          ),
        ],
      ),
      CompletedWorkoutSession(
        id: 'sess-$studentPrefix-aug21',
        workoutName: 'Treino C · Costas & Braços Agosto',
        totalWeightLiftedKg: vol(4980).toDouble(),
        totalSets: 14,
        durationMinutes: 46,
        completedAt: DateTime(2026, 8, 21, 18, 30),
        workedMuscles: const [
          MuscleGroup.dorsal,
          MuscleGroup.biceps,
          MuscleGroup.antebraco,
        ],
        exerciseLogs: [
          makeLog(
            name: 'Puxada Frontal Aberta',
            primary: MuscleGroup.dorsal,
            secondary: const [MuscleGroup.biceps],
            topWeight: w(55),
            reps: 10,
          ),
          makeLog(
            name: 'Rosca Direta Barra W',
            primary: MuscleGroup.biceps,
            secondary: const [MuscleGroup.antebraco],
            topWeight: w(26),
            reps: 12,
          ),
        ],
      ),
    ];

    return sessions;
  }

  static List<WorkoutPlanDay> _buildWorkoutDays({
    required bool isHypertrophyHeavy,
  }) {
    final baseW = isHypertrophyHeavy ? 80.0 : 34.0;
    return [
      WorkoutPlanDay(
        id: 'plan-a',
        code: 'A',
        title: 'Treino A · Empurrar (Peito, Ombro e Tríceps)',
        subtitle: 'Periodização Base REC · Foco em tensão mecânica',
        durationWeeks: 6,
        startDate: '15/08/2026',
        status: 'Ativo',
        exercises: [
          WorkoutExercise(
            id: 'ex-a1',
            name: 'Supino Reto com Barra',
            primaryMuscle: MuscleGroup.peitoralMaior,
            secondaryMuscles: [
              MuscleGroup.deltoideAnterior,
              MuscleGroup.triceps,
              MuscleGroup.peitoralSuperior,
            ],
            targetRepsRange: '6 a 10',
            restSeconds: 90,
            advancedTechnique:
                'Ponto Zero (2s pausa no peito) + Top/Backoff Set',
            coachNotes:
                'Manter escápulas retraídas e pés firmes no solo em todas as séries.',
            sets: [
              ExerciseSet(
                id: 's-a1-1',
                index: 1,
                type: SetType.warmUp,
                targetReps: '15',
                weightKg: (baseW * 0.5).roundToDouble(),
                completedReps: 15,
                completed: true,
              ),
              ExerciseSet(
                id: 's-a1-2',
                index: 2,
                type: SetType.feeder,
                targetReps: '10',
                weightKg: (baseW * 0.75).roundToDouble(),
                completedReps: 10,
                completed: true,
              ),
              ExerciseSet(
                id: 's-a1-3',
                index: 3,
                type: SetType.working,
                targetReps: '8 a 10',
                weightKg: baseW,
                completedReps: 9,
                completed: true,
              ),
              ExerciseSet(
                id: 's-a1-4',
                index: 4,
                type: SetType.top,
                targetReps: '6 a 8',
                weightKg: baseW + 6,
                completedReps: 7,
                completed: false,
              ),
              ExerciseSet(
                id: 's-a1-5',
                index: 5,
                type: SetType.backoff,
                targetReps: '10 a 12',
                weightKg: baseW - 4,
                completedReps: 12,
                completed: false,
              ),
            ],
          ),
          WorkoutExercise(
            id: 'ex-a2',
            name: 'Crucifixo Inclinado c/ Halteres',
            primaryMuscle: MuscleGroup.peitoralSuperior,
            secondaryMuscles: [
              MuscleGroup.peitoralMaior,
              MuscleGroup.deltoideAnterior,
            ],
            targetRepsRange: '10 a 12',
            restSeconds: 60,
            advancedTechnique: 'Drop-set na última série (-30% carga)',
            coachNotes: 'Alongar bem as fibras peitorais na fase excêntrica.',
            sets: [
              ExerciseSet(
                id: 's-a2-1',
                index: 1,
                type: SetType.working,
                targetReps: '12',
                weightKg: isHypertrophyHeavy ? 26 : 12,
                completedReps: 12,
                completed: true,
              ),
              ExerciseSet(
                id: 's-a2-2',
                index: 2,
                type: SetType.working,
                targetReps: '10 a 12',
                weightKg: isHypertrophyHeavy ? 28 : 14,
                completedReps: 11,
                completed: false,
              ),
              ExerciseSet(
                id: 's-a2-3',
                index: 3,
                type: SetType.drop,
                targetReps: '10 + falha',
                weightKg: isHypertrophyHeavy ? 28 : 14,
                completedReps: 10,
                completed: false,
              ),
            ],
          ),
          WorkoutExercise(
            id: 'ex-a3',
            name: 'Elevação Lateral Controlada + Tríceps Corda',
            primaryMuscle: MuscleGroup.deltoideLateral,
            secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.trapezio],
            targetRepsRange: '12 a 15',
            restSeconds: 75,
            advancedTechnique:
                'Bi-Set / Super Set agonista-sinergista + Cluster final',
            coachNotes: 'Sem impulso de tronco na elevação lateral.',
            sets: [
              ExerciseSet(
                id: 's-a3-1',
                index: 1,
                type: SetType.superSet,
                targetReps: '12 + 12',
                weightKg: isHypertrophyHeavy ? 14 : 8,
                completedReps: 12,
                completed: false,
              ),
              ExerciseSet(
                id: 's-a3-2',
                index: 2,
                type: SetType.cluster,
                targetReps: '4+4+4 (15s pausa)',
                weightKg: isHypertrophyHeavy ? 16 : 9,
                completedReps: 12,
                completed: false,
              ),
            ],
          ),
        ],
      ),
      WorkoutPlanDay(
        id: 'plan-b',
        code: 'B',
        title: 'Treino B · Inferiores Completo (Quads & Glúteos)',
        subtitle: 'Ênfase em amplitude máxima e controle excêntrico',
        durationWeeks: 6,
        startDate: '15/08/2026',
        status: 'Ativo',
        exercises: [
          WorkoutExercise(
            id: 'ex-b1',
            name: 'Agachamento Livre com Barra',
            primaryMuscle: MuscleGroup.quadriceps,
            secondaryMuscles: [
              MuscleGroup.gluteoMaximo,
              MuscleGroup.adutores,
              MuscleGroup.posteriores,
              MuscleGroup.lombar,
            ],
            targetRepsRange: '6 a 10',
            restSeconds: 120,
            advancedTechnique: 'Feeder progressivo + Top Set',
            coachNotes: 'Descer quebrando a paralela com coluna neutra.',
            sets: [
              ExerciseSet(
                id: 's-b1-1',
                index: 1,
                type: SetType.warmUp,
                targetReps: '12',
                weightKg: 40,
                completedReps: 12,
                completed: false,
              ),
              ExerciseSet(
                id: 's-b1-2',
                index: 2,
                type: SetType.feeder,
                targetReps: '8',
                weightKg: 60,
                completedReps: 8,
                completed: false,
              ),
              ExerciseSet(
                id: 's-b1-3',
                index: 3,
                type: SetType.top,
                targetReps: '6 a 8',
                weightKg: 76,
                completedReps: 8,
                completed: false,
              ),
              ExerciseSet(
                id: 's-b1-4',
                index: 4,
                type: SetType.backoff,
                targetReps: '10',
                weightKg: 64,
                completedReps: 10,
                completed: false,
              ),
            ],
          ),
          WorkoutExercise(
            id: 'ex-b2',
            name: 'Leg Press 45°',
            primaryMuscle: MuscleGroup.quadriceps,
            secondaryMuscles: [MuscleGroup.gluteoMaximo, MuscleGroup.adutores],
            targetRepsRange: '10 a 12',
            restSeconds: 90,
            advancedTechnique: 'Cluster Set (3 blocos de 4 reps com 15s)',
            sets: [
              ExerciseSet(
                id: 's-b2-1',
                index: 1,
                type: SetType.working,
                targetReps: '12',
                weightKg: 160,
                completedReps: 12,
                completed: false,
              ),
              ExerciseSet(
                id: 's-b2-2',
                index: 2,
                type: SetType.cluster,
                targetReps: '4+4+4',
                weightKg: 180,
                completedReps: 12,
                completed: false,
              ),
            ],
          ),
        ],
      ),
      WorkoutPlanDay(
        id: 'plan-c',
        code: 'C',
        title: 'Treino C · Puxar (Costas, Trapézio e Bíceps)',
        subtitle: 'Densidade dorsal e pico de contração',
        durationWeeks: 6,
        startDate: '15/08/2026',
        status: 'Ativo',
        exercises: [
          WorkoutExercise(
            id: 'ex-c1',
            name: 'Puxada Frontal Aberta',
            primaryMuscle: MuscleGroup.dorsal,
            secondaryMuscles: [
              MuscleGroup.biceps,
              MuscleGroup.trapezio,
              MuscleGroup.antebraco,
            ],
            targetRepsRange: '8 a 12',
            restSeconds: 90,
            advancedTechnique: 'Pico de contração 2s + Drop Set final',
            sets: [
              ExerciseSet(
                id: 's-c1-1',
                index: 1,
                type: SetType.warmUp,
                targetReps: '15',
                weightKg: 35,
                completedReps: 15,
                completed: false,
              ),
              ExerciseSet(
                id: 's-c1-2',
                index: 2,
                type: SetType.working,
                targetReps: '10',
                weightKg: 52,
                completedReps: 10,
                completed: false,
              ),
              ExerciseSet(
                id: 's-c1-3',
                index: 3,
                type: SetType.drop,
                targetReps: '8 + 8',
                weightKg: 55,
                completedReps: 8,
                completed: false,
              ),
            ],
          ),
        ],
      ),
      WorkoutPlanDay(
        id: 'plan-d',
        code: 'D',
        title: 'Treino D · Posteriores, Glúteos e Panturrilhas',
        subtitle: 'Cadeia posterior e estabilidade de core',
        durationWeeks: 6,
        startDate: '15/08/2026',
        status: 'Ativo',
        exercises: [
          WorkoutExercise(
            id: 'ex-d1',
            name: 'Stiff com Barra Olímpica',
            primaryMuscle: MuscleGroup.posteriores,
            secondaryMuscles: [
              MuscleGroup.gluteoMaximo,
              MuscleGroup.lombar,
              MuscleGroup.antebraco,
            ],
            targetRepsRange: '8 a 10',
            restSeconds: 90,
            advancedTechnique: 'Cadência controlada 3-1-1',
            sets: [
              ExerciseSet(
                id: 's-d1-1',
                index: 1,
                type: SetType.feeder,
                targetReps: '10',
                weightKg: 50,
                completedReps: 10,
                completed: false,
              ),
              ExerciseSet(
                id: 's-d1-2',
                index: 2,
                type: SetType.top,
                targetReps: '8',
                weightKg: 68,
                completedReps: 8,
                completed: false,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  static List<SuggestedMeal> _buildSuggestedMeals({
    required bool isCalorieDeficit,
  }) {
    final riceGrams = isCalorieDeficit ? 120.0 : 220.0;
    final chickenGrams = isCalorieDeficit ? 130.0 : 180.0;
    return [
      SuggestedMeal(
        id: 'meal-1',
        title: 'Café da Manhã',
        timeLabel: '07:30',
        items: [
          SuggestedDietFoodItem(
            id: 'item-1',
            name: 'Ovos Inteiros Mexidos',
            prescribedAmountGrams: 150,
            unitLabel: 'g (3 unid)',
            isConfirmed: true,
            confirmedAmountGrams: 150,
            baseNutrients: const NutrientProfile(
              calories: 215,
              proteinG: 19.0,
              carbsG: 1.5,
              fatG: 15.0,
              fiberG: 0,
              sodiumMg: 210,
              potassiumMg: 198,
              calciumMg: 75,
              ironMg: 2.7,
              magnesiumMg: 18,
              vitaminCMg: 0,
              vitaminDMcg: 3.0,
              vitaminB12Mcg: 1.3,
            ),
          ),
          SuggestedDietFoodItem(
            id: 'item-2',
            name: 'Aveia em Flocos + Banana Prata',
            prescribedAmountGrams: 90,
            unitLabel: 'g',
            isConfirmed: true,
            confirmedAmountGrams: 90,
            baseNutrients: const NutrientProfile(
              calories: 210,
              proteinG: 6.2,
              carbsG: 41.0,
              fatG: 2.8,
              fiberG: 5.4,
              sodiumMg: 4,
              potassiumMg: 360,
              calciumMg: 28,
              ironMg: 1.9,
              magnesiumMg: 68,
              vitaminCMg: 8.5,
              vitaminDMcg: 0,
              vitaminB12Mcg: 0,
            ),
          ),
        ],
      ),
      SuggestedMeal(
        id: 'meal-2',
        title: 'Almoço Protocolo',
        timeLabel: '12:30',
        items: [
          SuggestedDietFoodItem(
            id: 'item-3',
            name: 'Peito de Frango Grelhado',
            prescribedAmountGrams: chickenGrams,
            unitLabel: 'g',
            isConfirmed: true,
            confirmedAmountGrams: chickenGrams,
            baseNutrients: const NutrientProfile(
              calories: 215,
              proteinG: 40.0,
              carbsG: 0,
              fatG: 4.5,
              fiberG: 0,
              sodiumMg: 95,
              potassiumMg: 330,
              calciumMg: 18,
              ironMg: 1.1,
              magnesiumMg: 38,
              vitaminCMg: 0,
              vitaminDMcg: 0.2,
              vitaminB12Mcg: 0.4,
            ),
          ),
          SuggestedDietFoodItem(
            id: 'item-4',
            name: 'Arroz Branco / Integral Cozido',
            prescribedAmountGrams: riceGrams,
            unitLabel: 'g',
            isConfirmed: true,
            confirmedAmountGrams: riceGrams,
            baseNutrients: const NutrientProfile(
              calories: 165,
              proteinG: 3.5,
              carbsG: 36.0,
              fatG: 0.4,
              fiberG: 2.2,
              sodiumMg: 15,
              potassiumMg: 85,
              calciumMg: 14,
              ironMg: 0.8,
              magnesiumMg: 42,
              vitaminCMg: 0,
              vitaminDMcg: 0,
              vitaminB12Mcg: 0,
            ),
          ),
          SuggestedDietFoodItem(
            id: 'item-5',
            name: 'Brócolis e Mix de Folhas Verdes',
            prescribedAmountGrams: 100,
            unitLabel: 'g',
            isConfirmed: true,
            confirmedAmountGrams: 100,
            baseNutrients: const NutrientProfile(
              calories: 35,
              proteinG: 2.8,
              carbsG: 6.5,
              fatG: 0.4,
              fiberG: 3.3,
              sodiumMg: 33,
              potassiumMg: 316,
              calciumMg: 47,
              ironMg: 0.9,
              magnesiumMg: 21,
              vitaminCMg: 64.0,
              vitaminDMcg: 0,
              vitaminB12Mcg: 0,
            ),
          ),
        ],
      ),
      SuggestedMeal(
        id: 'meal-3',
        title: 'Lanche / Pré-Treino',
        timeLabel: '16:30',
        items: [
          SuggestedDietFoodItem(
            id: 'item-6',
            name: 'Whey Protein Concentrado + Morangos',
            prescribedAmountGrams: 130,
            unitLabel: 'g',
            isConfirmed: true,
            confirmedAmountGrams: 130,
            baseNutrients: const NutrientProfile(
              calories: 160,
              proteinG: 25.0,
              carbsG: 10.0,
              fatG: 2.0,
              fiberG: 2.0,
              sodiumMg: 110,
              potassiumMg: 240,
              calciumMg: 150,
              ironMg: 0.6,
              magnesiumMg: 25,
              vitaminCMg: 45.0,
              vitaminDMcg: 1.5,
              vitaminB12Mcg: 0.5,
            ),
          ),
        ],
      ),
      SuggestedMeal(
        id: 'meal-4',
        title: 'Jantar Recuperador',
        timeLabel: '20:30',
        items: [
          SuggestedDietFoodItem(
            id: 'item-7',
            name: 'Patinho Moído Refogado',
            prescribedAmountGrams: 130,
            unitLabel: 'g',
            isConfirmed: false,
            confirmedAmountGrams: 130,
            baseNutrients: const NutrientProfile(
              calories: 240,
              proteinG: 36.0,
              carbsG: 0,
              fatG: 9.5,
              fiberG: 0,
              sodiumMg: 85,
              potassiumMg: 390,
              calciumMg: 16,
              ironMg: 3.4,
              magnesiumMg: 32,
              vitaminCMg: 0,
              vitaminDMcg: 0.4,
              vitaminB12Mcg: 2.1,
            ),
          ),
          SuggestedDietFoodItem(
            id: 'item-8',
            name: 'Batata Inglesa Assada',
            prescribedAmountGrams: 160,
            unitLabel: 'g',
            isConfirmed: false,
            confirmedAmountGrams: 160,
            baseNutrients: const NutrientProfile(
              calories: 145,
              proteinG: 3.2,
              carbsG: 33.0,
              fatG: 0.2,
              fiberG: 3.0,
              sodiumMg: 12,
              potassiumMg: 620,
              calciumMg: 18,
              ironMg: 1.1,
              magnesiumMg: 36,
              vitaminCMg: 16.0,
              vitaminDMcg: 0,
              vitaminB12Mcg: 0,
            ),
          ),
        ],
      ),
    ];
  }

  /// Gera os dias do mês sincronizados com as sessões registradas para a Agenda Comparativa e Calendário.
  static List<AgendaDayComparison> _buildAgendaDaysFromSessions(
    List<CompletedWorkoutSession> sessions,
    int year,
    int month,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final days = <AgendaDayComparison>[];
    for (int d = 1; d <= daysInMonth; d++) {
      final daySessions = sessions
          .where(
            (s) =>
                s.completedAt.year == year &&
                s.completedAt.month == month &&
                s.completedAt.day == d,
          )
          .toList();
      final trained = daySessions.isNotEmpty;
      final calMet = d % 5 != 0;
      final waterMet = d % 4 != 0;
      days.add(
        AgendaDayComparison(
          dayOfMonth: d,
          dateLabel:
              '${d.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}',
          trained: trained,
          caloriesGoalMet: calMet,
          waterGoalMet: waterMet,
          workoutTitle: trained ? daySessions.first.workoutName : null,
        ),
      );
    }
    return days;
  }
}
