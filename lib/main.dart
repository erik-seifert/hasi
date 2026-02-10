import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/discovery_service.dart';
import 'services/hass_websocket_service.dart';
import 'services/dashboard_service.dart';
import 'services/theme_service.dart';

import 'services/voice_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  final authService = AuthService();
  await authService.init();

  final dashboardService = DashboardService();
  await dashboardService.init();

  final themeService = ThemeService();
  await themeService.init();

  final wsService = HassWebSocketService();

  final voiceService = VoiceService(wsService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiscoveryService()),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: wsService),
        ChangeNotifierProvider.value(value: dashboardService),
        ChangeNotifierProvider.value(value: themeService),

        ChangeNotifierProvider.value(value: voiceService),
      ],
      child: const HasiApp(),
    ),
  );
}

class HasiApp extends StatelessWidget {
  const HasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hasi',
      theme: themeService.themeData,
      locale: themeService.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: authService.isLoggedIn
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
