import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/presentation/auth_controller.dart';

/// Bottom sheet for changing name and mobile. Pops `true` when saved.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.fullName);
  late final _mobile = TextEditingController(text: widget.user.mobile);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _error = null);
    final error = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(fullName: _name.text, mobile: _mobile.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.editProfile, style: context.text.titleLarge),
            AppSpacing.vMd,
            AppTextField(
              label: AppStrings.labelFullName,
              controller: _name,
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: Validators.fullName,
            ),
            AppSpacing.vMd,
            AppTextField(
              label: AppStrings.labelMobile,
              controller: _mobile,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
              ],
              validator: Validators.mobile,
              onSubmitted: (_) => _save(),
            ),
            AppSpacing.vMd,
            if (_error != null) ...[
              AppInlineMessage(message: _error!),
              AppSpacing.vMd,
            ],
            AppButton(label: AppStrings.save, isLoading: busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
