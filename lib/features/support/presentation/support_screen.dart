import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/step5_strings.dart';
import '../../../core/theme/app_accents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/support_repository.dart';
import '../domain/support_query.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _error = null;
      _sent = false;
    });
    try {
      await ref
          .read(supportRepositoryProvider)
          .submitQuery(subject: _subject.text, message: _message.text);
      if (!mounted) return;
      _subject.clear();
      _message.clear();
      _formKey.currentState?.reset();
      setState(() => _sent = true);
    } catch (_) {
      if (mounted) setState(() => _error = Step5Strings.submitError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queries = ref.watch(supportQueriesProvider).valueOrNull ?? const [];
    final t = context.text;

    return AppScaffold(
      title: Step5Strings.supportTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          Text(Step5Strings.supportSubtitle,
              style: t.bodyMedium?.copyWith(color: context.colors.textSecondary)),
          AppSpacing.vMd,
          AppCard(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: Step5Strings.labelSubject,
                    controller: _subject,
                    prefixIcon: Icons.subject,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, 'subject') ?? Validators.maxLength(v, 80),
                  ),
                  AppSpacing.vMd,
                  AppTextField(
                    label: Step5Strings.labelMessage,
                    controller: _message,
                    maxLines: 5,
                    validator: (v) =>
                        Validators.required(v, 'message') ?? Validators.maxLength(v, 1000),
                  ),
                  AppSpacing.vMd,
                  if (_sent) ...[
                    const AppInlineMessage(
                      message: Step5Strings.supportSent,
                      kind: InlineMessageKind.success,
                    ),
                    AppSpacing.vMd,
                  ],
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
          const SectionHeader(title: Step5Strings.yourQueries),
          if (queries.isEmpty)
            Text(Step5Strings.noQueries, style: t.bodyMedium)
          else
            for (final q in queries)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _QueryCard(query: q),
              ),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}

class _QueryCard extends StatelessWidget {
  const _QueryCard({required this.query});

  final SupportQuery query;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final (String label, AppAccent accent) = switch (query.status) {
      SupportStatus.open => (Step5Strings.statusOpen, AppAccents.amber),
      SupportStatus.answered => (Step5Strings.statusAnswered, AppAccents.green),
      SupportStatus.closed => (Step5Strings.statusClosed, AppAccents.slate),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(query.subject, style: t.titleMedium)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: accent.color,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  label,
                  style: t.labelSmall?.copyWith(
                    color: accent.onColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Text(Formatters.relativeTime(query.submittedOn), style: t.bodySmall),
          AppSpacing.vSm,
          Text(query.message, style: t.bodyMedium),
          if (query.adminResponse != null && query.adminResponse!.isNotEmpty) ...[
            AppSpacing.vMd,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Step5Strings.teamReply,
                      style: t.labelLarge?.copyWith(color: c.primary)),
                  AppSpacing.vXs,
                  Text(query.adminResponse!, style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
