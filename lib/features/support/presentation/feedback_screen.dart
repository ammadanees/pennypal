import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/step5_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/accent_icon_box.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/data/auth_providers.dart';
import '../data/support_repository.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _comments = TextEditingController();
  int _rating = 0;
  bool _ratingMissing = false;
  bool _sending = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull;
    _name = TextEditingController(text: user?.fullName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _comments.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (_rating == 0) setState(() => _ratingMissing = true);
    if (!valid || _rating == 0) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(supportRepositoryProvider).submitFeedback(
            name: _name.text,
            email: _email.text,
            rating: _rating,
            comments: _comments.text,
          );
      if (mounted) setState(() => _done = true);
    } catch (_) {
      if (mounted) setState(() => _error = Step5Strings.submitError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return AppScaffold(
        title: Step5Strings.feedbackTitle,
        body: AppEmptyState(
          icon: Icons.favorite_outline,
          title: Step5Strings.feedbackThanksTitle,
          message: Step5Strings.feedbackThanksMessage,
          actionLabel: Step5Strings.done,
          onAction: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.more),
        ),
      );
    }

    final c = context.colors;
    final t = context.text;
    return AppScaffold(
      title: Step5Strings.feedbackTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          Row(
            children: [
              const AccentIconBox(
                  icon: Icons.favorite, accent: AppAccents.pink),
              AppSpacing.hMd,
              Expanded(
                child: Text(Step5Strings.feedbackSubtitle,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary)),
              ),
            ],
          ),
          AppSpacing.vMd,
          AppCard(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: AppStrings.labelFullName,
                    controller: _name,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                  ),
                  AppSpacing.vMd,
                  AppTextField(
                    label: AppStrings.labelEmail,
                    controller: _email,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  AppSpacing.vMd,
                  Text(Step5Strings.labelRating, style: t.labelLarge),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Semantics(
                          button: true,
                          label: 'Rate $i out of 5',
                          selected: i == _rating,
                          excludeSemantics: true,
                          child: IconButton(
                            iconSize: AppDimensions.iconLg + 4,
                            constraints: const BoxConstraints(
                              minWidth: AppDimensions.touchTarget,
                              minHeight: AppDimensions.touchTarget,
                            ),
                            onPressed: () => setState(() {
                              _rating = i;
                              _ratingMissing = false;
                            }),
                            icon: Icon(
                              i <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: i <= _rating
                                  ? AppAccents.amber.color
                                  : c.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_ratingMissing)
                    Text(Step5Strings.ratingRequired,
                        style: t.bodySmall?.copyWith(color: c.error)),
                  AppSpacing.vMd,
                  AppTextField(
                    label: Step5Strings.labelComments,
                    controller: _comments,
                    maxLines: 5,
                    validator: (v) =>
                        Validators.required(v, 'comments') ??
                        Validators.maxLength(v, 1000),
                  ),
                  AppSpacing.vMd,
                  if (_error != null) ...[
                    AppInlineMessage(message: _error!),
                    AppSpacing.vMd,
                  ],
                  AppButton(
                    label: Step5Strings.submit,
                    icon: Icons.send_outlined,
                    isLoading: _sending,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}
