import 'package:flutter/material.dart';

import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';

/// Standard page: optional app bar, centered content with a max width,
/// and responsive side gutters.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padded = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final gutter = context.isCompact ? AppSpacing.md : AppSpacing.lg;
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
            child: Padding(
              padding: padded
                  ? EdgeInsets.symmetric(horizontal: gutter)
                  : EdgeInsets.zero,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
