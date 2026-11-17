import 'package:flutter/material.dart';

import '../models/nutrition_models.dart';
import '../state/app_state.dart';
import '../theme/rec_theme.dart';

class DietaScreen extends StatelessWidget {
  final RecAppState appState;

  const DietaScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final student = appState.activeStudent;
    final ingested = student.totalIngestedNutrients;
    final target = student.dailyTargetNutrients;
    final water = student.waterTracker;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cabeçalho da Aba Dieta
        const Text(
          'Plano Alimentar, Água & Nutrientes',
          style: TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Confirme sua dieta sugerida, registre alimentos avulsos e acompanhe macros e micros',
          style: TextStyle(color: RecTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 16),

        // 1. Card de Meta de Água (integrado dentro da tab Dieta)
        _buildWaterGoalCard(context, water),
        const SizedBox(height: 14),

        // 2. Gráfico das Calorias Ingeridas + Gráfico de Macronutrientes
        _buildCaloriesAndMacrosCharts(ingested, target),
        const SizedBox(height: 14),

        // 3. Lista com Macro e Micronutrientes Ingeridos (abaixo dos gráficos)
        _buildMacroAndMicronutrientsList(ingested, target),
        const SizedBox(height: 18),

        // 4. Dieta Sugerida pelo Treinador (pré-visualizada, confirmar quantidade ou substituir fora da dieta)
        const Text(
          'Dieta Sugerida pelo Treinador',
          style: TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Confirme a quantidade ingerida ou toque em "Fora da dieta" caso tenha substituído o alimento.',
          style: TextStyle(color: RecTheme.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 10),
        ...student.suggestedMeals.map(
          (meal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSuggestedMealCard(context, meal),
          ),
        ),
        const SizedBox(height: 8),

        // 5. Espaço para cadastrar alimentos consumidos ao longo do dia (fora da dieta do treinador)
        _buildCustomConsumedFoodSection(context, student.customConsumedFoods),
      ],
    );
  }

  Widget _buildWaterGoalCard(BuildContext context, WaterIntakeTracker water) {
    final pct = (water.progress * 100).clamp(0, 150).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RecTheme.cyan.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: RecTheme.cyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meta de Água Diária',
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${water.consumedMl} ml / ${water.targetMl} ml ($pct%)',
                      style: const TextStyle(
                        color: RecTheme.cyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  OutlinedButton(
                    key: const Key('water_add_250_button'),
                    onPressed: () => appState.addWaterIntake(250),
                    child: const Text('+250ml'),
                  ),
                  ElevatedButton(
                    key: const Key('water_add_500_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RecTheme.cyan,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => appState.addWaterIntake(500),
                    child: const Text('+500ml'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: water.progress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: RecTheme.surfaceInput,
              valueColor: const AlwaysStoppedAnimation<Color>(RecTheme.cyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesAndMacrosCharts(
    NutrientProfile ingested,
    NutrientProfile target,
  ) {
    final calPct = target.calories <= 0
        ? 0.0
        : (ingested.calories / target.calories);
    final isOver = calPct > 1.05;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gráfico de Calorias & Macronutrientes Ingeridos',
            style: TextStyle(
              color: RecTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          // Gráfico de Calorias Ingeridas
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RecTheme.surfaceInput,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: RecTheme.primaryRed,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Calorias Ingeridas Hoje',
                          style: TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(calPct * 100).toStringAsFixed(0)}% da meta',
                      style: TextStyle(
                        color: isOver
                            ? RecTheme.primaryRedLight
                            : RecTheme.emerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${ingested.calories.toStringAsFixed(0)} / ${target.calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    color: RecTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: calPct.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOver ? RecTheme.primaryRed : RecTheme.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Gráfico Comparativo de Barras de Macronutrientes
          _macroBarRow(
            label: 'Proteínas',
            current: ingested.proteinG,
            target: target.proteinG,
            unit: 'g',
            color: RecTheme.primaryRed,
          ),
          const SizedBox(height: 10),
          _macroBarRow(
            label: 'Carboidratos',
            current: ingested.carbsG,
            target: target.carbsG,
            unit: 'g',
            color: RecTheme.primaryRedLight,
          ),
          const SizedBox(height: 10),
          _macroBarRow(
            label: 'Gorduras',
            current: ingested.fatG,
            target: target.fatG,
            unit: 'g',
            color: RecTheme.amber,
          ),
        ],
      ),
    );
  }

  Widget _macroBarRow({
    required String label,
    required double current,
    required double target,
    required String unit,
    required Color color,
  }) {
    final pct = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: RecTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)}$unit / ${target.toStringAsFixed(0)}$unit',
              style: const TextStyle(
                color: RecTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: RecTheme.surfaceInput,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Lista detalhada com Macro e Micronutrientes ingeridos abaixo dos gráficos.
  Widget _buildMacroAndMicronutrientsList(
    NutrientProfile ingested,
    NutrientProfile target,
  ) {
    final rows = [
      (
        'Proteínas (Macro)',
        '${ingested.proteinG.toStringAsFixed(1)} g',
        'Meta ${target.proteinG.toStringAsFixed(0)} g',
      ),
      (
        'Carboidratos (Macro)',
        '${ingested.carbsG.toStringAsFixed(1)} g',
        'Meta ${target.carbsG.toStringAsFixed(0)} g',
      ),
      (
        'Gorduras Totais (Macro)',
        '${ingested.fatG.toStringAsFixed(1)} g',
        'Meta ${target.fatG.toStringAsFixed(0)} g',
      ),
      (
        'Fibras Alimentares (Micro)',
        '${ingested.fiberG.toStringAsFixed(1)} g',
        'Meta ${target.fiberG.toStringAsFixed(0)} g',
      ),
      (
        'Sódio (Micro)',
        '${ingested.sodiumMg.toStringAsFixed(0)} mg',
        'Limite ${target.sodiumMg.toStringAsFixed(0)} mg',
      ),
      (
        'Potássio (Micro)',
        '${ingested.potassiumMg.toStringAsFixed(0)} mg',
        'Meta ${target.potassiumMg.toStringAsFixed(0)} mg',
      ),
      (
        'Cálcio (Micro)',
        '${ingested.calciumMg.toStringAsFixed(0)} mg',
        'Meta ${target.calciumMg.toStringAsFixed(0)} mg',
      ),
      (
        'Ferro (Micro)',
        '${ingested.ironMg.toStringAsFixed(1)} mg',
        'Meta ${target.ironMg.toStringAsFixed(0)} mg',
      ),
      (
        'Magnésio (Micro)',
        '${ingested.magnesiumMg.toStringAsFixed(0)} mg',
        'Meta ${target.magnesiumMg.toStringAsFixed(0)} mg',
      ),
      (
        'Vitamina C (Micro)',
        '${ingested.vitaminCMg.toStringAsFixed(1)} mg',
        'Meta ${target.vitaminCMg.toStringAsFixed(0)} mg',
      ),
      (
        'Vitamina D (Micro)',
        '${ingested.vitaminDMcg.toStringAsFixed(1)} mcg',
        'Meta ${target.vitaminDMcg.toStringAsFixed(0)} mcg',
      ),
      (
        'Vitamina B12 (Micro)',
        '${ingested.vitaminB12Mcg.toStringAsFixed(1)} mcg',
        'Meta ${target.vitaminB12Mcg.toStringAsFixed(1)} mcg',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lista de Macro e Micronutrientes Ingeridos',
            style: TextStyle(
              color: RecTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r.$1,
                    style: const TextStyle(
                      color: RecTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        r.$2,
                        style: const TextStyle(
                          color: RecTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${r.$3})',
                        style: const TextStyle(
                          color: RecTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedMealCard(BuildContext context, SuggestedMeal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    color: RecTheme.primaryRed,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${meal.title} · ${meal.timeLabel}',
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Text(
                '${meal.totalIngestedNutrients.calories.toStringAsFixed(0)} kcal ingeridas',
                style: const TextStyle(
                  color: RecTheme.primaryRedLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...meal.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RecTheme.surfaceInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item.isReplacedOffDiet
                        ? RecTheme.amber.withValues(alpha: 0.5)
                        : (item.isConfirmed
                              ? RecTheme.emerald.withValues(alpha: 0.45)
                              : RecTheme.borderSubtle),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          key: Key('confirm_diet_item_${item.id}'),
                          value: item.isConfirmed,
                          onChanged: (v) {
                            appState.confirmSuggestedDietFood(
                              mealId: meal.id,
                              foodItemId: item.id,
                              isConfirmed: v ?? false,
                            );
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.isReplacedOffDiet
                                    ? 'Substituído: ${item.offDietFoodName} (${item.offDietAmountGrams?.toStringAsFixed(0)}g)'
                                    : item.name,
                                style: const TextStyle(
                                  color: RecTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                item.isReplacedOffDiet
                                    ? 'Original prescrito: ${item.name} (${item.prescribedAmountGrams.toStringAsFixed(0)}${item.unitLabel})'
                                    : 'Sugerido: ${item.prescribedAmountGrams.toStringAsFixed(0)} ${item.unitLabel} · Confirmado: ${item.confirmedAmountGrams.toStringAsFixed(0)}g',
                                style: const TextStyle(
                                  color: RecTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showConfirmQuantityDialog(
                            context,
                            meal.id,
                            item,
                          ),
                          icon: const Icon(Icons.scale_outlined, size: 14),
                          label: const Text('Confirmar Qtd.'),
                        ),
                        OutlinedButton.icon(
                          key: Key('replace_off_diet_${item.id}'),
                          onPressed: () =>
                              _showReplaceOffDietDialog(context, meal.id, item),
                          icon: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: RecTheme.amber,
                          ),
                          label: const Text(
                            'Fora da dieta / Outro alimento',
                            style: TextStyle(color: RecTheme.amber),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomConsumedFoodSection(
    BuildContext context,
    List<CustomConsumedFood> customFoods,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alimentos Consumidos no Dia (Avulso)',
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Cadastre qualquer alimento ingerido fora da dieta prescrita pelo treinador',
                      style: TextStyle(color: RecTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                key: const Key('add_custom_food_button'),
                onPressed: () => _showAddCustomFoodDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Cadastrar Alimento'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (customFoods.isEmpty)
            const Text(
              'Nenhum alimento avulso registrado hoje.',
              style: TextStyle(color: RecTheme.textSecondary, fontSize: 12),
            )
          else
            ...customFoods.map(
              (food) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${food.name} (${food.amountGrams.toStringAsFixed(0)}g)',
                  style: const TextStyle(
                    color: RecTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  '${food.mealOccasion} · ${food.nutrients.calories.toStringAsFixed(0)} kcal | P: ${food.nutrients.proteinG.toStringAsFixed(1)}g · C: ${food.nutrients.carbsG.toStringAsFixed(1)}g · G: ${food.nutrients.fatG.toStringAsFixed(1)}g',
                  style: const TextStyle(
                    color: RecTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: RecTheme.primaryRedLight,
                    size: 18,
                  ),
                  onPressed: () => appState.removeCustomConsumedFood(food.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showConfirmQuantityDialog(
    BuildContext context,
    String mealId,
    SuggestedDietFoodItem item,
  ) {
    final qtyCtrl = TextEditingController(
      text: item.confirmedAmountGrams.toStringAsFixed(0),
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Quantidade · ${item.name}'),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText:
                'Quantidade ingerida (${item.unitLabel}) · Prescrito: ${item.prescribedAmountGrams.toStringAsFixed(0)}',
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.confirmSuggestedDietFood(
                mealId: mealId,
                foodItemId: item.id,
                isConfirmed: true,
                confirmedAmountGrams:
                    double.tryParse(qtyCtrl.text) ?? item.prescribedAmountGrams,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Confirmar Ingestão'),
          ),
        ],
      ),
    );
  }

  void _showReplaceOffDietDialog(
    BuildContext context,
    String mealId,
    SuggestedDietFoodItem item,
  ) {
    final nameCtrl = TextEditingController(text: 'Pão Francês c/ Queijo');
    final gramsCtrl = TextEditingController(text: '100');
    final calCtrl = TextEditingController(text: '280');
    final protCtrl = TextEditingController(text: '12');
    final carbCtrl = TextEditingController(text: '38');
    final fatCtrl = TextEditingController(text: '9');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Consumido Fora da Dieta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Qual alimento você consumiu?',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: gramsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade Consumida (g)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calorias Estimadas (kcal)',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: protCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prot (g)'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: carbCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carb (g)'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Gord (g)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('confirm_off_diet_replacement'),
            onPressed: () {
              appState.replaceSuggestedFoodWithOffDiet(
                mealId: mealId,
                foodItemId: item.id,
                offDietFoodName: nameCtrl.text.trim(),
                offDietAmountGrams: double.tryParse(gramsCtrl.text) ?? 100,
                calories: double.tryParse(calCtrl.text) ?? 250,
                proteinG: double.tryParse(protCtrl.text) ?? 10,
                carbsG: double.tryParse(carbCtrl.text) ?? 30,
                fatG: double.tryParse(fatCtrl.text) ?? 8,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Registrar Substituição'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomFoodDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Iogurte Proteico Natural');
    final gramsCtrl = TextEditingController(text: '170');
    final occasionCtrl = TextEditingController(text: 'Ceia / Extra');
    final calCtrl = TextEditingController(text: '140');
    final protCtrl = TextEditingController(text: '15');
    final carbCtrl = TextEditingController(text: '12');
    final fatCtrl = TextEditingController(text: '3');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cadastrar Alimento Consumido'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do Alimento',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: gramsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade (g/ml)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: occasionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Momento / Refeição',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calorias (kcal)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: protCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prot (g)'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: carbCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Carb (g)'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Gord (g)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('submit_custom_food_button'),
            onPressed: () {
              appState.addCustomConsumedFood(
                name: nameCtrl.text.trim(),
                amountGrams: double.tryParse(gramsCtrl.text) ?? 100,
                mealOccasion: occasionCtrl.text.trim(),
                calories: double.tryParse(calCtrl.text) ?? 140,
                proteinG: double.tryParse(protCtrl.text) ?? 15,
                carbsG: double.tryParse(carbCtrl.text) ?? 12,
                fatG: double.tryParse(fatCtrl.text) ?? 3,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Salvar Alimento'),
          ),
        ],
      ),
    );
  }
}
