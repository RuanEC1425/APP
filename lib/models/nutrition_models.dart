/// Modelos de Dieta, Alimentos Sugeridos, Consumo Fora da Dieta,
/// Macro/Micronutrientes e Meta de Água.
/// Totalmente serializáveis em JSON para sincronização com a versão Web do professor.
library;

class NutrientProfile {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  // Micronutrientes
  final double fiberG;
  final double sodiumMg;
  final double potassiumMg;
  final double calciumMg;
  final double ironMg;
  final double magnesiumMg;
  final double vitaminCMg;
  final double vitaminDMcg;
  final double vitaminB12Mcg;

  const NutrientProfile({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.sodiumMg = 0,
    this.potassiumMg = 0,
    this.calciumMg = 0,
    this.ironMg = 0,
    this.magnesiumMg = 0,
    this.vitaminCMg = 0,
    this.vitaminDMcg = 0,
    this.vitaminB12Mcg = 0,
  });

  static const NutrientProfile zero = NutrientProfile();

  NutrientProfile scale(double factor) => NutrientProfile(
    calories: calories * factor,
    proteinG: proteinG * factor,
    carbsG: carbsG * factor,
    fatG: fatG * factor,
    fiberG: fiberG * factor,
    sodiumMg: sodiumMg * factor,
    potassiumMg: potassiumMg * factor,
    calciumMg: calciumMg * factor,
    ironMg: ironMg * factor,
    magnesiumMg: magnesiumMg * factor,
    vitaminCMg: vitaminCMg * factor,
    vitaminDMcg: vitaminDMcg * factor,
    vitaminB12Mcg: vitaminB12Mcg * factor,
  );

  NutrientProfile operator +(NutrientProfile other) => NutrientProfile(
    calories: calories + other.calories,
    proteinG: proteinG + other.proteinG,
    carbsG: carbsG + other.carbsG,
    fatG: fatG + other.fatG,
    fiberG: fiberG + other.fiberG,
    sodiumMg: sodiumMg + other.sodiumMg,
    potassiumMg: potassiumMg + other.potassiumMg,
    calciumMg: calciumMg + other.calciumMg,
    ironMg: ironMg + other.ironMg,
    magnesiumMg: magnesiumMg + other.magnesiumMg,
    vitaminCMg: vitaminCMg + other.vitaminCMg,
    vitaminDMcg: vitaminDMcg + other.vitaminDMcg,
    vitaminB12Mcg: vitaminB12Mcg + other.vitaminB12Mcg,
  );

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'fiberG': fiberG,
    'sodiumMg': sodiumMg,
    'potassiumMg': potassiumMg,
    'calciumMg': calciumMg,
    'ironMg': ironMg,
    'magnesiumMg': magnesiumMg,
    'vitaminCMg': vitaminCMg,
    'vitaminDMcg': vitaminDMcg,
    'vitaminB12Mcg': vitaminB12Mcg,
  };

  factory NutrientProfile.fromJson(Map<String, dynamic> json) =>
      NutrientProfile(
        calories: (json['calories'] as num?)?.toDouble() ?? 0,
        proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
        carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
        fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
        fiberG: (json['fiberG'] as num?)?.toDouble() ?? 0,
        sodiumMg: (json['sodiumMg'] as num?)?.toDouble() ?? 0,
        potassiumMg: (json['potassiumMg'] as num?)?.toDouble() ?? 0,
        calciumMg: (json['calciumMg'] as num?)?.toDouble() ?? 0,
        ironMg: (json['ironMg'] as num?)?.toDouble() ?? 0,
        magnesiumMg: (json['magnesiumMg'] as num?)?.toDouble() ?? 0,
        vitaminCMg: (json['vitaminCMg'] as num?)?.toDouble() ?? 0,
        vitaminDMcg: (json['vitaminDMcg'] as num?)?.toDouble() ?? 0,
        vitaminB12Mcg: (json['vitaminB12Mcg'] as num?)?.toDouble() ?? 0,
      );
}

/// Alimento pré-configurado na Dieta Sugerida pelo treinador.
/// O aluno pode apenas confirmar a quantidade sugerida (ou ajustar a quantidade ingerida),
/// ou marcar um alimento diferente caso tenha consumido fora da dieta naquele item.
class SuggestedDietFoodItem {
  final String id;
  final String name;
  final double prescribedAmountGrams;
  final String unitLabel; // ex: 'g', 'ml', 'unid'
  final NutrientProfile baseNutrients; // Nutrientes para a porção prescrita

  bool isConfirmed;
  double confirmedAmountGrams;

  // Campos para substituição / consumo fora da dieta neste item
  bool isReplacedOffDiet;
  String? offDietFoodName;
  double? offDietAmountGrams;
  NutrientProfile? offDietNutrients;

  SuggestedDietFoodItem({
    required this.id,
    required this.name,
    required this.prescribedAmountGrams,
    this.unitLabel = 'g',
    required this.baseNutrients,
    this.isConfirmed = false,
    double? confirmedAmountGrams,
    this.isReplacedOffDiet = false,
    this.offDietFoodName,
    this.offDietAmountGrams,
    this.offDietNutrients,
  }) : confirmedAmountGrams = confirmedAmountGrams ?? prescribedAmountGrams;

  /// Nutrientes efetivamente ingeridos pelo aluno neste item.
  NutrientProfile get effectiveIngestedNutrients {
    if (!isConfirmed) return NutrientProfile.zero;
    if (isReplacedOffDiet && offDietNutrients != null) {
      return offDietNutrients!;
    }
    if (prescribedAmountGrams <= 0) return baseNutrients;
    final ratio = confirmedAmountGrams / prescribedAmountGrams;
    return baseNutrients.scale(ratio);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'prescribedAmountGrams': prescribedAmountGrams,
    'unitLabel': unitLabel,
    'baseNutrients': baseNutrients.toJson(),
    'isConfirmed': isConfirmed,
    'confirmedAmountGrams': confirmedAmountGrams,
    'isReplacedOffDiet': isReplacedOffDiet,
    if (offDietFoodName != null) 'offDietFoodName': offDietFoodName,
    if (offDietAmountGrams != null) 'offDietAmountGrams': offDietAmountGrams,
    if (offDietNutrients != null)
      'offDietNutrients': offDietNutrients!.toJson(),
  };

  factory SuggestedDietFoodItem.fromJson(
    Map<String, dynamic> json,
  ) => SuggestedDietFoodItem(
    id: json['id'] as String,
    name: json['name'] as String,
    prescribedAmountGrams: (json['prescribedAmountGrams'] as num).toDouble(),
    unitLabel: json['unitLabel'] as String? ?? 'g',
    baseNutrients: NutrientProfile.fromJson(
      json['baseNutrients'] as Map<String, dynamic>,
    ),
    isConfirmed: json['isConfirmed'] as bool? ?? false,
    confirmedAmountGrams: (json['confirmedAmountGrams'] as num?)?.toDouble(),
    isReplacedOffDiet: json['isReplacedOffDiet'] as bool? ?? false,
    offDietFoodName: json['offDietFoodName'] as String?,
    offDietAmountGrams: (json['offDietAmountGrams'] as num?)?.toDouble(),
    offDietNutrients: json['offDietNutrients'] != null
        ? NutrientProfile.fromJson(
            json['offDietNutrients'] as Map<String, dynamic>,
          )
        : null,
  );
}

/// Refeição da Dieta Sugerida pelo treinador (ex: Café da Manhã, Almoço, Jantar).
class SuggestedMeal {
  final String id;
  final String title;
  final String timeLabel; // ex: '07:30'
  final List<SuggestedDietFoodItem> items;

  SuggestedMeal({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.items,
  });

  NutrientProfile get totalPrescribedNutrients =>
      items.fold(NutrientProfile.zero, (acc, item) => acc + item.baseNutrients);

  NutrientProfile get totalIngestedNutrients => items.fold(
    NutrientProfile.zero,
    (acc, item) => acc + item.effectiveIngestedNutrients,
  );

  bool get allConfirmed =>
      items.isNotEmpty && items.every((item) => item.isConfirmed);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timeLabel': timeLabel,
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory SuggestedMeal.fromJson(Map<String, dynamic> json) => SuggestedMeal(
    id: json['id'] as String,
    title: json['title'] as String,
    timeLabel: json['timeLabel'] as String,
    items: (json['items'] as List<dynamic>)
        .map((i) => SuggestedDietFoodItem.fromJson(i as Map<String, dynamic>))
        .toList(),
  );
}

/// Alimento consumido avulso cadastrado pelo aluno ao longo do dia (fora da dieta prescrita).
class CustomConsumedFood {
  final String id;
  final String name;
  final double amountGrams;
  final String mealOccasion; // ex: 'Lanche Livre', 'Pós-Treino', 'Extra'
  final DateTime loggedAt;
  final NutrientProfile nutrients;

  CustomConsumedFood({
    required this.id,
    required this.name,
    required this.amountGrams,
    required this.mealOccasion,
    required this.loggedAt,
    required this.nutrients,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amountGrams': amountGrams,
    'mealOccasion': mealOccasion,
    'loggedAt': loggedAt.toIso8601String(),
    'nutrients': nutrients.toJson(),
  };

  factory CustomConsumedFood.fromJson(Map<String, dynamic> json) =>
      CustomConsumedFood(
        id: json['id'] as String,
        name: json['name'] as String,
        amountGrams: (json['amountGrams'] as num).toDouble(),
        mealOccasion: json['mealOccasion'] as String,
        loggedAt: DateTime.parse(json['loggedAt'] as String),
        nutrients: NutrientProfile.fromJson(
          json['nutrients'] as Map<String, dynamic>,
        ),
      );
}

/// Controle da meta de água diária dentro da aba Dieta.
class WaterIntakeTracker {
  int targetMl;
  int consumedMl;

  WaterIntakeTracker({required this.targetMl, required this.consumedMl});

  double get progress =>
      targetMl <= 0 ? 0.0 : (consumedMl / targetMl).clamp(0.0, 1.5);

  bool get isGoalMet => consumedMl >= targetMl;

  Map<String, dynamic> toJson() => {
    'targetMl': targetMl,
    'consumedMl': consumedMl,
  };

  factory WaterIntakeTracker.fromJson(Map<String, dynamic> json) =>
      WaterIntakeTracker(
        targetMl: json['targetMl'] as int,
        consumedMl: json['consumedMl'] as int,
      );
}
