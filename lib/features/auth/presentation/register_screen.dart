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
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _studentId.dispose();
    _email.dispose();
    _mobile.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _error = null);
    final error = await ref.read(authControllerProvider.notifier).register(
          fullName: _name.text,
          studentId: _studentId.text,
          email: _email.text,
          mobile: _mobile.text,
          password: _password.text,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
    } else {
      context.go(AppRoutes.verifyEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: AppStrings.registerTitle,
      subtitle: AppStrings.registerSubtitle,
      onBack: () => context.go(AppRoutes.login),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppStrings.haveAccount, style: context.text.bodyMedium),
          AppButton(
            label: AppStrings.signIn,
            variant: AppButtonVariant.text,
            expand: false,
            onPressed: () => context.go(AppRoutes.login),
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
              AppTextField(
                label: AppStrings.labelFullName,
                controller: _name,
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: Validators.fullName,
              ),
              AppSpacing.vMd,
              AppTextField(
                label: AppStrings.labelStudentId,
                hint: AppStrings.hintStudentId,
                controller: _studentId,
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                validator: Validators.studentId,
              ),
              AppSpacing.vMd,
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
                label: AppStrings.labelMobile,
                hint: AppStrings.hintMobile,
                controller: _mobile,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
                ],
                validator: Validators.mobile,
              ),
              AppSpacing.vMd,
              AppTextField(
                label: AppStrings.labelPassword,
                controller: _password,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                helperText: AppStrings.passwordRules,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.newPassword,
              ),
              AppSpacing.vMd,
              AppTextField(
                label: AppStrings.labelConfirmPassword,
                controller: _confirm,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirmPassword(v, _password.text),
                onSubmitted: (_) => _submit(),
              ),
              AppSpacing.vLg,
              if (_error != null) ...[
                AppInlineMessage(message: _error!),
                AppSpacing.vMd,
              ],
              AppButton(
                label: AppStrings.createAccount,
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
