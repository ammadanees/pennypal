import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/step5_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/accent_icon_box.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/insight_banner.dart';
import 'assistant_controller.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? text]) {
    final value = text ?? _input.text;
    if (value.trim().isEmpty) return;
    _input.clear();
    ref.read(assistantControllerProvider.notifier).send(value);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AssistantState>(assistantControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.isTyping != next.isTyping) {
        _scrollToEnd();
      }
    });
    final state = ref.watch(assistantControllerProvider);
    final c = context.colors;

    return AppScaffold(
      title: Step5Strings.assistantTitle,
      actions: [
        IconButton(
          tooltip: Step5Strings.clearChat,
          icon: const Icon(Icons.delete_sweep_outlined),
          onPressed: state.messages.isEmpty
              ? null
              : () => ref.read(assistantControllerProvider.notifier).clear(),
        ),
      ],
      body: Column(
        children: [
          AppSpacing.vSm,
          const InsightBanner(
            message: Step5Strings.assistantDisclaimer,
            accent: AppAccents.blue,
            icon: Icons.info_outline,
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                const _Bubble(text: Step5Strings.assistantIntro, fromUser: false),
                for (final m in state.messages)
                  _Bubble(
                    text: m.text,
                    fromUser: m.fromUser,
                    isError: m.isError,
                    onRetry: m.isError
                        ? () => ref.read(assistantControllerProvider.notifier).retry(m)
                        : null,
                  ),
                if (state.isTyping) const _TypingBubble(),
              ],
            ),
          ),
          if (state.suggestions.isNotEmpty && !state.isTyping)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final s in state.suggestions) ...[
                      AppChip(
                        label: s,
                        selected: false,
                        icon: Icons.bolt,
                        onSelected: () => _send(s),
                      ),
                      AppSpacing.hSm,
                    ],
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _send,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: Step5Strings.assistantHint,
                    ),
                  ),
                ),
                AppSpacing.hSm,
                Material(
                  color: c.primary,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: Step5Strings.send,
                    color: c.onPrimary,
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: state.isTyping ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.fromUser,
    this.isError = false,
    this.onRetry,
  });

  final String text;
  final bool fromUser;
  final bool isError;
  final VoidCallback? onRetry;

  static const double _maxWidth = 520;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final bg = fromUser ? c.primary : (isError ? c.error.withOpacity(0.12) : c.surface);
    final fg = fromUser ? c.onPrimary : c.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!fromUser) ...[
            const AccentIconBox(
              icon: Icons.auto_awesome,
              accent: AppAccents.amber,
              size: 32,
            ),
            AppSpacing.hSm,
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadius.lgAll,
                  border: (!fromUser && !isError) ? Border.all(color: c.border) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: t.bodyMedium?.copyWith(color: fg)),
                    if (onRetry != null) ...[
                      AppSpacing.vSm,
                      AppButton(
                        label: 'Try again',
                        icon: Icons.refresh,
                        variant: AppButtonVariant.tonal,
                        expand: false,
                        onPressed: onRetry,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three softly pulsing dots. Static when reduced motion is on.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: Step5Strings.typing,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            const AccentIconBox(
              icon: Icons.auto_awesome,
              accent: AppAccents.amber,
              size: 32,
            ),
            AppSpacing.hSm,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: c.border),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Opacity(
                          opacity: reduce
                              ? 0.7
                              : 0.3 +
                                  0.7 *
                                      (((_controller.value * 3 - i) % 3) < 1
                                          ? 1 - ((_controller.value * 3 - i) % 3)
                                          : 0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: c.textSecondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
