import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/auth_providers.dart';
import '../data/demo_auth_repository.dart';
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _error = null);
    final error = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
    if (mounted && error != null) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider);
    final isDemo = ref.watch(authRepositoryProvider).isDemo;

    return AuthScaffold(
      title: AppStrings.loginTitle,
      subtitle: AppStrings.loginSubtitle,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppStrings.newHere, style: context.text.bodyMedium),
          AppButton(
            label: AppStrings.createAccount,
            variant: AppButtonVariant.text,
            expand: false,
            onPressed: () => context.go(AppRoutes.register),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDemo) ...[
                const AppInlineMessage(
                  message: DemoAuthRepository.loginHint,
                  kind: InlineMessageKind.info,
                ),
                AppSpacing.vMd,
              ],
              AppTextField(
                label: AppStrings.labelEmail,
                hint: AppStrings.hintEmail,
                controller: _email,
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              AppSpacing.vMd,
              AppTextField(
                label: AppStrings.labelPassword,
                controller: _password,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: Validators.passwordPresent,
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: AppStrings.forgotPassword,
                  variant: AppButtonVariant.text,
                  expand: false,
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                ),
              ),
              if (_error != null) ...[
                AppInlineMessage(message: _error!),
                AppSpacing.vMd,
              ],
              AppButton(
                label: AppStrings.signIn,
                isLoading: busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
