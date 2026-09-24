import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Lays children out in equal-width columns, top-aligned. Cards keep their
/// own height, so mixed content does not leave awkward gaps.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.columns = 1,
    this.spacing = AppSpacing.md,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.skip(i).take(columns).toList();
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: spacing),
                Expanded(child: j < slice.length ? slice[j] : const SizedBox()),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
