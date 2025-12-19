import 'package:flutter/material.dart';
import '../views/home/home_view.dart';
import '../views/camera/camera_view.dart';
import '../views/memo/memo_detail_view.dart';
import '../views/settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapMemo',
      themeMode: ThemeMode.dark,
      // Keep a consistent black-themed dark UI across the app
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/camera': (context) => const CameraView(),
        '/settings': (context) => const SettingsView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/memo' && settings.arguments != null) {
          return MaterialPageRoute(
            builder: (_) => MemoDetailView(memo: settings.arguments as dynamic),
          );
        }
        return null;
      },
    );
  }
}
