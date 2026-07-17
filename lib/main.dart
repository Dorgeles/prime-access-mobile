import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prime_access/config/theme.dart';
import 'package:prime_access/services/hive_service.dart';
import 'package:prime_access/services/api_service.dart';
import 'package:prime_access/services/auth_service.dart';
import 'package:prime_access/providers/auth_provider.dart';
import 'package:prime_access/providers/movement_provider.dart';
import 'package:prime_access/routes/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final apiService = RealApiService();
  final authService = AuthService();

  final authProvider = AuthProvider(
    apiService: apiService,
    authService: authService,
  );
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => MovementProvider(
            hiveService: hiveService,
            apiService: apiService,
          ),
        ),
      ],
      child: PrimeAccessApp(authProvider: authProvider),
    ),
  );
}

class PrimeAccessApp extends StatefulWidget {
  final AuthProvider authProvider;

  const PrimeAccessApp({super.key, required this.authProvider});

  @override
  State<PrimeAccessApp> createState() => _PrimeAccessAppState();
}

class _PrimeAccessAppState extends State<PrimeAccessApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(widget.authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prime Access',
      theme: lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
