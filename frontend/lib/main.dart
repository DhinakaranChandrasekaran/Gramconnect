import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';

// Services
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/local_storage_service.dart';

// Router
import 'app_router.dart';

// Providers
import 'features/auth/providers/auth_provider.dart';
import 'features/complaints/providers/complaint_provider.dart';
import 'features/garbage/providers/garbage_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/profile/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.initialize();
  await LocalStorageService.initialize();

  runApp(const GramConnectApp());
}

class GramConnectApp extends StatelessWidget {
  const GramConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ComplaintProvider>(
          create: (context) => ComplaintProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<GarbageProvider>(
          create: (context) => GarbageProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(context.read<ApiService>()),
        ),
      ],
      child: MaterialApp(
        title: 'GramConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.splash,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ta', ''),
        ],
      ),
    );
  }
}
