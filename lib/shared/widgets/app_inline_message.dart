import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum InlineMessageKind { error, success, info }

class AppInlineMessage extends StatelessWidget {
  const AppInlineMessage({
    super.key,
    required this.message,
    this.kind = InlineMessageKind.error,
  });

  final String message;
  final InlineMessageKind kind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color color, IconData icon) = switch (kind) {
      InlineMessageKind.error => (c.error, Icons.error_outline),
      InlineMessageKind.success => (c.success, Icons.check_circle_outline),
      InlineMessageKind.info => (c.info, Icons.info_outline),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppDimensions.iconMd, color: color),
            AppSpacing.hSm,
            Expanded(child: Text(message, style: context.text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
