import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:weather_app/Providers/theme_provider.dart';
import 'package:weather_app/Theme/theme.dart';
import 'package:weather_app/view/splash_screen.dart';
import 'package:weather_app/Services/update_service.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for updates after the app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final themeType = ref.watch(themeNotifierProvider);

    return GetMaterialApp(
      theme: ligthTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.getThemeMode(context),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      defaultTransition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
    );
  }
}
