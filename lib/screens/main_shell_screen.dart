import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/rec_theme.dart';
import 'dieta_screen.dart';
import 'home_screen.dart';
import 'treino_screen.dart';
import 'you_screen.dart';

class MainShellScreen extends StatelessWidget {
  final RecAppState appState;

  const MainShellScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final tabIndex = appState.bottomTabIndex;

        final Widget body = switch (tabIndex) {
          0 => HomeScreen(appState: appState),
          1 => TreinoScreen(appState: appState),
          2 => DietaScreen(appState: appState),
          _ => YouScreen(appState: appState),
        };

        return Scaffold(
          body: SafeArea(child: body),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: RecTheme.borderSubtle, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: tabIndex,
              onTap: (idx) => appState.setBottomTab(idx),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined),
                  activeIcon: Icon(Icons.fitness_center_rounded),
                  label: 'Treino',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Dieta',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'You',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
