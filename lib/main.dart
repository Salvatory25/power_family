import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://lwrfjgnlepgsmsqzntvj.supabase.co');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_iRT1-Fbk4WnASkcsWuHXhw_VgpFCjCy');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully.');
  } catch (e) {
    debugPrint('Supabase initialization fallback: $e');
  }

  runApp(
    const ProviderScope(
      child: PowerFamilyApp(),
    ),
  );
}

class PowerFamilyApp extends ConsumerWidget {
  const PowerFamilyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
