import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:weather_app/Providers/theme_provider.dart';
import 'package:weather_app/Theme/theme.dart';
import 'package:weather_app/view/splash_screen.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
