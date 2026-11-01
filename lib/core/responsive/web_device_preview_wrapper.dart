import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';

/// State provider to toggle between Full Desktop and Mobile Frame view on Web.
final webMobileFrameProvider = StateProvider<bool>((ref) => false);

/// Wraps the entire application on Web/Desktop to provide a 1-tap live switcher
/// between Full Desktop and a realistic Mobile Phone Frame for presentations/viva.
class WebDevicePreviewWrapper extends ConsumerWidget {
  const WebDevicePreviewWrapper({super.key, required this.child});

  final Widget child;

  static const double _targetWidth = 395.0;
  static const double _targetHeight = 840.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only enable switcher if running on Web or Desktop with wide screen
    final mediaQuery = MediaQuery.of(context);
    final isWideScreen = mediaQuery.size.width > 600;

    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows && defaultTargetPlatform != TargetPlatform.macOS && defaultTargetPlatform != TargetPlatform.linux) {
      return child;
    }

    if (!isWideScreen) {
      // Already running on an actual mobile device or narrow viewport
      return child;
    }

    final isMobileMode = ref.watch(webMobileFrameProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Main Content Area
        if (!isMobileMode)
          child
        else
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFE2E8F0),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: _targetWidth,
                    height: _targetHeight,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                        width: 8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.6 : 0.25),
                          blurRadius: 36,
                          spreadRadius: 4,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Stack(
                        children: [
                          // App Content inside Mobile MediaQuery
                          Positioned.fill(
                            child: MediaQuery(
                              data: mediaQuery.copyWith(
                                size: const Size(_targetWidth, _targetHeight),
                                padding: const EdgeInsets.only(top: 40, bottom: 20),
                                viewPadding: const EdgeInsets.only(top: 40, bottom: 20),
                              ),
                              child: child,
                            ),
                          ),

                          // Realistic Top Speaker / Camera Notch Pill
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 110,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF334155),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 44,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF334155),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Floating Presentation View Switcher Pill (Bottom Right)
        Positioned(
          bottom: 20,
          right: 20,
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(28),
            color: isMobileMode ? AppColors.indigo : (isDark ? const Color(0xFF1E293B) : Colors.white),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                ref.read(webMobileFrameProvider.notifier).state = !isMobileMode;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isMobileMode ? AppColors.indigo : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMobileMode ? Icons.laptop_mac_rounded : Icons.phone_iphone_rounded,
                      size: 18,
                      color: isMobileMode ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMobileMode ? 'Switch to Desktop' : 'Preview Mobile View',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isMobileMode ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
