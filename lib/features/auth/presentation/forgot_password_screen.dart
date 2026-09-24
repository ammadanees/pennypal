import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _error = null);
    final error = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _error = error;
      _sent = error == null;
    });
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: AppStrings.forgotTitle,
      subtitle: AppStrings.forgotSubtitle,
      onBack: _back,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AppStrings.labelEmail,
              hint: AppStrings.hintEmail,
              controller: _email,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onSubmitted: (_) => _submit(),
            ),
            AppSpacing.vMd,
            if (_sent) ...[
              const AppInlineMessage(
                message: AppStrings.resetLinkSent,
                kind: InlineMessageKind.success,
              ),
              AppSpacing.vMd,
            ],
            if (_error != null) ...[
              AppInlineMessage(message: _error!),
              AppSpacing.vMd,
            ],
            AppButton(
              label: _sent ? AppStrings.backToSignIn : AppStrings.sendResetLink,
              isLoading: busy,
              onPressed: _sent ? _back : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
