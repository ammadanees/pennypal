import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/dev_tools.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import 'router.dart';

class PennyPalApp extends ConsumerWidget {
  const PennyPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
      // Device Preview (web only) simulates the chosen device's screen.
      locale: devicePreviewEnabled ? DevicePreview.locale(context) : null,
      builder: devicePreviewEnabled ? DevicePreview.appBuilder : null,
    );
  }
}
