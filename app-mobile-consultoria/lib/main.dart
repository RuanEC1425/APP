import 'package:flutter/material.dart';

import 'screens/main_shell_screen.dart';
import 'state/app_state.dart';
import 'theme/rec_theme.dart';

void main() {
  runApp(const RecConsultoriaMobileApp());
}

class RecConsultoriaMobileApp extends StatefulWidget {
  final RecAppState? appState;

  const RecConsultoriaMobileApp({super.key, this.appState});

  @override
  State<RecConsultoriaMobileApp> createState() =>
      _RecConsultoriaMobileAppState();
}

class _RecConsultoriaMobileAppState extends State<RecConsultoriaMobileApp> {
  late final RecAppState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.appState ?? RecAppState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REC Consultoria Mobile',
      debugShowCheckedModeBanner: false,
      theme: RecTheme.darkTheme,
      home: MainShellScreen(appState: _state),
    );
  }
}
