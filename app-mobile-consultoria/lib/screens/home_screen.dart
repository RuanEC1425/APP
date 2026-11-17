import 'package:flutter/material.dart';

import '../data/mock_repository.dart';
import '../models/profile_evolution_models.dart';
import '../models/workout_models.dart';
import '../state/app_state.dart';
import '../theme/rec_theme.dart';

class HomeScreen extends StatelessWidget {
  final RecAppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final student = appState.activeStudent;
    final isCommunity = appState.avatarSpace == AvatarQuickSpace.community;

    return Column(
      children: [
        _buildTopHeader(context, student),
        Expanded(
          child: isCommunity
              ? _buildCommunityFeed(context)
              : _buildHomeContent(context, student),
        ),
      ],
    );
  }

  /// Header Superior com:
  /// - Canto superior esquerdo: Avatar interativo alternando entre 'Home', 'Community' e 'You'
  /// - Canto superior direito: Agenda comparativa (dias treinados/não treinados, metas batidas/não batidas) + Sininho
  Widget _buildTopHeader(BuildContext context, StudentMobileProfile student) {
    final unread = appState.unreadNotificationsCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: RecTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: RecTheme.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Canto Superior Esquerdo: Avatar Interativo + Seletor de Espaço
              InkWell(
                key: const Key('interactive_student_avatar'),
                borderRadius: BorderRadius.circular(30),
                onTap: () => _showAvatarSpaceSheet(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: RecTheme.primaryRed.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            student.name.substring(0, 2).toUpperCase(),
                            style: const TextStyle(
                              color: RecTheme.primaryRed,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: RecTheme.emerald,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: RecTheme.cardBackground,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                color: RecTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: RecTheme.primaryRed,
                            ),
                          ],
                        ),
                        Text(
                          'Visão: ${appState.avatarSpace.label} · ${student.plan}',
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
              const Spacer(),
              // Canto Superior Direito: Botão Agenda Comparativa
              IconButton(
                key: const Key('header_agenda_button'),
                tooltip: 'Agenda Comparativa e Metas',
                onPressed: () => _showAgendaComparisonModal(context, student),
                style: IconButton.styleFrom(
                  backgroundColor: RecTheme.surfaceInput,
                  side: const BorderSide(color: RecTheme.borderSubtle),
                ),
                icon: const Icon(
                  Icons.calendar_month_rounded,
                  color: RecTheme.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              // Canto Superior Direito: Sininho de Notificações
              Stack(
                children: [
                  IconButton(
                    key: const Key('header_notifications_bell'),
                    tooltip: 'Notificações',
                    onPressed: () => _showNotificationsModal(context, student),
                    style: IconButton.styleFrom(
                      backgroundColor: RecTheme.surfaceInput,
                      side: const BorderSide(color: RecTheme.borderSubtle),
                    ),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: RecTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: RecTheme.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Pílulas rápidas do Avatar Interativo ('Home' | 'Community' | 'You')
          Row(
            children: AvatarQuickSpace.values.map((space) {
              final selected = appState.avatarSpace == space;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  key: Key('avatar_space_${space.name}'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => appState.setAvatarSpace(space),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? RecTheme.primaryRed
                          : RecTheme.surfaceInput,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? RecTheme.primaryRed
                            : RecTheme.borderSubtle,
                      ),
                    ),
                    child: Text(
                      space.label,
                      style: TextStyle(
                        color: selected ? Colors.white : RecTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, StudentMobileProfile student) {
    final sessions = student.completedSessions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card Resumo Rápido + Botão "Iniciar sessão de treino" (fora do planejamento)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                RecTheme.primaryRed.withValues(alpha: 0.18),
                RecTheme.cardBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: RecTheme.primaryRed.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RecTheme.primaryRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'META: ${student.objective.toUpperCase()} · ${student.currentWeightKg}kg -> ${student.targetWeightKg}kg',
                      style: const TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Assinatura: ${student.subscriptionStatus}',
                    style: TextStyle(
                      color: student.subscriptionStatus == 'Em dia'
                          ? RecTheme.emerald
                          : RecTheme.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Treino Livre / Sessão Instantânea',
                style: TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Monte e registre um treino feito agora, mesmo fora do planejamento do treinador.',
                style: TextStyle(color: RecTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('start_free_workout_button'),
                  onPressed: () => _showStartFreeWorkoutModal(context),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text('Iniciar sessão de treino'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Seção: Último Treino Feito (e histórico de sessões com Editar, Compartilhar, Excluir, Salvar)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Último Treino Feito',
              style: TextStyle(
                color: RecTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${sessions.length} sessão(ões) registrada(s)',
              style: const TextStyle(color: RecTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: RecTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: const Center(
              child: Text(
                'Nenhum treino registrado ainda. Inicie uma sessão acima ou conclua sua ficha na aba Treino!',
                textAlign: TextAlign.center,
                style: TextStyle(color: RecTheme.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ...sessions.asMap().entries.map((entry) {
            final idx = entry.key;
            final session = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCompletedWorkoutCard(
                context,
                session,
                isLatest: idx == 0,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCompletedWorkoutCard(
    BuildContext context,
    CompletedWorkoutSession session, {
    required bool isLatest,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? RecTheme.primaryRed.withValues(alpha: 0.5)
              : RecTheme.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLatest
                      ? RecTheme.primaryRed.withValues(alpha: 0.16)
                      : RecTheme.surfaceInput,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLatest
                      ? (session.isFreeSession
                            ? 'ÚLTIMO TREINO · LIVRE'
                            : 'ÚLTIMO TREINO FEITO')
                      : 'HISTÓRICO',
                  style: TextStyle(
                    color: isLatest
                        ? RecTheme.primaryRedLight
                        : RecTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (session.isSaved)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: RecTheme.amber,
                    size: 16,
                  ),
                ),
              if (session.isShared)
                const Icon(
                  Icons.public_rounded,
                  color: RecTheme.emerald,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            session.workoutName,
            style: const TextStyle(
              color: RecTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (session.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              session.notes,
              style: const TextStyle(
                color: RecTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Métricas obrigatórias: [peso levantado, quantidade de séries, duração]
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: RecTheme.surfaceInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricColumn(
                  label: 'PESO LEVANTADO',
                  value: '${session.totalWeightLiftedKg.toStringAsFixed(0)} kg',
                  icon: Icons.fitness_center_rounded,
                ),
                Container(width: 1, height: 28, color: RecTheme.borderSubtle),
                _metricColumn(
                  label: 'SÉRIES FEITAS',
                  value: '${session.totalSets} séries',
                  icon: Icons.layers_rounded,
                ),
                Container(width: 1, height: 28, color: RecTheme.borderSubtle),
                _metricColumn(
                  label: 'DURAÇÃO',
                  value: session.formattedDuration,
                  icon: Icons.timer_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Barra de ações: Editar | Compartilhar | Excluir | Salvar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionChip(
                key: Key('edit_session_${session.id}'),
                icon: Icons.edit_outlined,
                label: 'Editar',
                onTap: () => _showEditSessionDialog(context, session),
              ),
              _actionChip(
                key: Key('share_session_${session.id}'),
                icon: Icons.share_outlined,
                label: session.isShared ? 'Compartilhado' : 'Compartilhar',
                highlightColor: session.isShared ? RecTheme.emerald : null,
                onTap: () {
                  appState.shareCompletedSessionToCommunity(session.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Treino compartilhado na aba Community com sucesso!',
                      ),
                    ),
                  );
                },
              ),
              _actionChip(
                key: Key('save_session_${session.id}'),
                icon: session.isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: session.isSaved ? 'Salvo' : 'Salvar',
                highlightColor: session.isSaved ? RecTheme.amber : null,
                onTap: () => appState.toggleSaveCompletedSession(session.id),
              ),
              _actionChip(
                key: Key('delete_session_${session.id}'),
                icon: Icons.delete_outline_rounded,
                label: 'Excluir',
                highlightColor: RecTheme.primaryRedLight,
                onTap: () => appState.deleteCompletedSession(session.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricColumn({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: RecTheme.primaryRed),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: RecTheme.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _actionChip({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? highlightColor,
  }) {
    final color = highlightColor ?? RecTheme.textSecondary;
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: RecTheme.surfaceInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlightColor != null
                ? highlightColor.withValues(alpha: 0.45)
                : RecTheme.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Visão 'Community' alternada pelo Avatar interativo no canto superior esquerdo.
  Widget _buildCommunityFeed(BuildContext context) {
    final posts = appState.communityPosts;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
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
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: RecTheme.primaryRed.withValues(alpha: 0.2),
                    child: Text(
                      post.authorName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: RecTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            color: RecTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: const TextStyle(
                            color: RecTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RecTheme.surfaceInput,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${post.totalVolumeKg.toStringAsFixed(0)} kg · ${post.setsCount} séries · ${post.durationLabel}',
                      style: const TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.workoutTitle,
                style: const TextStyle(
                  color: RecTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post.caption,
                style: const TextStyle(
                  color: RecTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => appState.toggleLikeCommunityPost(post.id),
                    icon: Icon(
                      post.isLikedByMe
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: post.isLikedByMe
                          ? RecTheme.primaryRed
                          : RecTheme.textSecondary,
                      size: 18,
                    ),
                    label: Text(
                      '${post.likesCount} curtidas',
                      style: const TextStyle(color: RecTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => _showAddCommentDialog(context, post),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 17,
                      color: RecTheme.textSecondary,
                    ),
                    label: Text(
                      '${post.comments.length} comentários',
                      style: const TextStyle(color: RecTheme.textSecondary),
                    ),
                  ),
                ],
              ),
              if (post.comments.isNotEmpty) ...[
                const Divider(height: 16),
                ...post.comments.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: '${c.authorName}: ',
                            style: const TextStyle(
                              color: RecTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: c.text,
                            style: const TextStyle(
                              color: RecTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAvatarSpaceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Navegação Rápida do Avatar',
                style: TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Alterne entre Home, Community e You ou troque o aluno sincronizado com a Web',
                style: TextStyle(color: RecTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Row(
                children: AvatarQuickSpace.values.map((space) {
                  final active = appState.avatarSpace == space;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: active
                              ? RecTheme.primaryRed
                              : RecTheme.surfaceInput,
                        ),
                        onPressed: () {
                          appState.setAvatarSpace(space);
                          Navigator.pop(ctx);
                        },
                        child: Text(space.label),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Trocar Aluno (Sincronizado com mock.ts da Web):',
                style: TextStyle(
                  color: RecTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...appState.students.map((s) {
                final isCurrent = s.id == appState.activeStudent.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: RecTheme.primaryRed.withValues(alpha: 0.2),
                    child: Text(
                      s.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: RecTheme.primaryRed),
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${s.plan} · ${s.objective} · Atual ${s.currentWeightKg}kg / Meta ${s.targetWeightKg}kg',
                    style: const TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isCurrent
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: RecTheme.primaryRed,
                        )
                      : null,
                  onTap: () {
                    appState.selectStudentById(s.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Modal da Agenda Comparativa (canto superior direito):
  /// Compara dias treinados vs. não treinados e metas batidas vs. não batidas num determinado prazo.
  void _showAgendaComparisonModal(
    BuildContext context,
    StudentMobileProfile student,
  ) {
    int selectedRangeDays = 14;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final allDays = student.agendaDays;
            final subset = allDays.length > selectedRangeDays
                ? allDays.sublist(allDays.length - selectedRangeDays)
                : allDays;
            final trainedCount = subset.where((d) => d.trained).length;
            final notTrainedCount = subset.length - trainedCount;
            final goalsMetCount = subset.where((d) => d.allGoalsMet).length;
            final goalsMissedCount = subset.length - goalsMetCount;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Agenda Comparativa de Metas',
                          style: TextStyle(
                            color: RecTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      DropdownButton<int>(
                        value: selectedRangeDays,
                        dropdownColor: RecTheme.surfaceInput,
                        style: const TextStyle(
                          color: RecTheme.primaryRedLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: 7,
                            child: Text('Últimos 7 dias'),
                          ),
                          DropdownMenuItem(
                            value: 14,
                            child: Text('Últimos 14 dias'),
                          ),
                          DropdownMenuItem(
                            value: 28,
                            child: Text('Últimos 28 dias'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() => selectedRangeDays = v);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryComparisonBox(
                          title: 'DIAS TREINADOS VS. NÃO',
                          positiveLabel: '$trainedCount treinados',
                          negativeLabel: '$notTrainedCount descanso/falta',
                          positiveColor: RecTheme.emerald,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryComparisonBox(
                          title: 'METAS BATIDAS VS. NÃO',
                          positiveLabel: '$goalsMetCount batidas',
                          negativeLabel: '$goalsMissedCount parciais',
                          positiveColor: RecTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: subset.map((day) {
                      return Container(
                        width: 68,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: RecTheme.surfaceInput,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: day.trained
                                ? RecTheme.emerald.withValues(alpha: 0.45)
                                : RecTheme.borderSubtle,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day.dateLabel,
                              style: const TextStyle(
                                color: RecTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              day.trained
                                  ? Icons.check_circle_rounded
                                  : Icons.remove_circle_outline_rounded,
                              size: 16,
                              color: day.trained
                                  ? RecTheme.emerald
                                  : RecTheme.textMuted,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              day.allGoalsMet ? 'Meta OK' : 'Parcial',
                              style: TextStyle(
                                color: day.allGoalsMet
                                    ? RecTheme.primaryRedLight
                                    : RecTheme.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryComparisonBox({
    required String title,
    required String positiveLabel,
    required String negativeLabel,
    required Color positiveColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RecTheme.surfaceInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: RecTheme.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            positiveLabel,
            style: TextStyle(
              color: positiveColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            negativeLabel,
            style: const TextStyle(color: RecTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Modal do Sininho de Notificações (canto superior direito):
  /// Exibe alterações do treino feitas pelo treinador, curtidas, comentários e atalho para Anamnese.
  void _showNotificationsModal(
    BuildContext context,
    StudentMobileProfile student,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final list = student.notifications;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Notificações & Avisos do Treinador',
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      appState.markAllNotificationsRead();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Marcar lidas'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...list.map((n) {
                IconData icon;
                Color iconColor;
                switch (n.category) {
                  case NotificationCategory.coachWorkoutUpdate:
                    icon = Icons.fitness_center_rounded;
                    iconColor = RecTheme.primaryRed;
                    break;
                  case NotificationCategory.communityLike:
                    icon = Icons.favorite_rounded;
                    iconColor = RecTheme.primaryRedLight;
                    break;
                  case NotificationCategory.communityComment:
                    icon = Icons.forum_rounded;
                    iconColor = RecTheme.cyan;
                    break;
                  case NotificationCategory.anamnesisRequest:
                    icon = Icons.assignment_late_rounded;
                    iconColor = RecTheme.amber;
                    break;
                  case NotificationCategory.coachMessage:
                    icon = Icons.campaign_rounded;
                    iconColor = RecTheme.emerald;
                    break;
                }
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withValues(alpha: 0.16),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  title: Text(
                    n.title,
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${n.body} · ${n.timeAgo}',
                    style: const TextStyle(
                      color: RecTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: n.category == NotificationCategory.anamnesisRequest
                      ? TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            appState.setBottomTab(3, targetYouSubTab: 3);
                          },
                          child: const Text('Abrir Check-in'),
                        )
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Modal para "Iniciar sessão de treino" (treino montado pelo aluno fora do planejamento).
  void _showStartFreeWorkoutModal(BuildContext context) {
    final nameCtrl = TextEditingController(
      text: 'Sessão Livre · Pump Superiores',
    );
    final weightCtrl = TextEditingController(text: '4250');
    final setsCtrl = TextEditingController(text: '14');
    final durationCtrl = TextEditingController(text: '45');
    final notesCtrl = TextEditingController(
      text: 'Treino extra montado na hora pelo aluno.',
    );
    MuscleGroup selectedMuscle = MuscleGroup.peito;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Iniciar Sessão de Treino Livre'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Treino / Sessão',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<MuscleGroup>(
                      initialValue: selectedMuscle,
                      dropdownColor: RecTheme.surfaceInput,
                      decoration: const InputDecoration(
                        labelText: 'Grupamento Principal Trabalhado',
                      ),
                      items: MuscleGroup.values
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedMuscle = v);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Peso Total (kg)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: setsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Qtd. Séries',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duração (minutos)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        labelText:
                            'Exercícios / Observações (${MockRepository.exerciseCatalog.length} no banco)',
                      ),
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
                  key: const Key('confirm_free_workout_submit'),
                  onPressed: () {
                    appState.recordWorkoutSession(
                      workoutName: nameCtrl.text.trim().isEmpty
                          ? 'Sessão Livre'
                          : nameCtrl.text.trim(),
                      totalWeightLiftedKg:
                          double.tryParse(weightCtrl.text) ?? 3500,
                      totalSets: int.tryParse(setsCtrl.text) ?? 12,
                      durationMinutes: int.tryParse(durationCtrl.text) ?? 45,
                      workedMuscles: [selectedMuscle],
                      isFreeSession: true,
                      notes: notesCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Concluir e Salvar na Home'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Modal para Editar informações de um treino feito na Home.
  void _showEditSessionDialog(
    BuildContext context,
    CompletedWorkoutSession session,
  ) {
    final nameCtrl = TextEditingController(text: session.workoutName);
    final weightCtrl = TextEditingController(
      text: session.totalWeightLiftedKg.toStringAsFixed(0),
    );
    final setsCtrl = TextEditingController(text: '${session.totalSets}');
    final durationCtrl = TextEditingController(
      text: '${session.durationMinutes}',
    );
    final notesCtrl = TextEditingController(text: session.notes);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Informações do Treino'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('edit_session_name_field'),
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Treino',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso Levantado (kg)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de Séries',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duração (minutos)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Observações'),
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
              key: const Key('save_edited_session_button'),
              onPressed: () {
                appState.editCompletedSession(
                  sessionId: session.id,
                  newWorkoutName: nameCtrl.text.trim(),
                  newTotalWeightKg:
                      double.tryParse(weightCtrl.text) ??
                      session.totalWeightLiftedKg,
                  newTotalSets:
                      int.tryParse(setsCtrl.text) ?? session.totalSets,
                  newDurationMinutes:
                      int.tryParse(durationCtrl.text) ??
                      session.durationMinutes,
                  newNotes: notesCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCommentDialog(BuildContext context, CommunityPost post) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Comentar no Treino'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Escreva um incentivo...',
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.addCommentToCommunityPost(post.id, ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}
