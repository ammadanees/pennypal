import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/cloudinary_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/theme_mode_selector.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/presentation/auth_controller.dart';
import 'edit_profile_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploadingPhoto = false;

  Future<void> _edit(BuildContext context, AppUser user) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => EditProfileSheet(user: user),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.profileSaved)));
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.signOutConfirmTitle),
        content: const Text(AppStrings.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _changePhoto(AppUser user) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800, maxHeight: 800);
    if (file == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await ref.read(cloudinaryServiceProvider).uploadImage(bytes, fileName: file.name);
      await ref.read(authControllerProvider.notifier).updateProfile(
            fullName: user.fullName,
            mobile: user.mobile,
            photoUrl: url,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The photo could not be uploaded.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      // Signing out: the router is already sending the student to sign in.
      return const Scaffold(body: AppLoading());
    }
    final c = context.colors;
    final t = context.text;

    return AppScaffold(
      title: AppStrings.profileTitle,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _uploadingPhoto ? null : () => _changePhoto(user),
                child: Stack(
                  children: [
                    Container(
                      width: AppDimensions.avatar,
                      height: AppDimensions.avatar,
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: user.photoUrl == null
                          ? Text(user.initials,
                              style: t.titleLarge?.copyWith(color: c.primary))
                          : Image.network(
                              user.photoUrl!,
                              width: AppDimensions.avatar,
                              height: AppDimensions.avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                user.initials,
                                style: t.titleLarge?.copyWith(color: c.primary),
                              ),
                            ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.background, width: 2),
                        ),
                        child: _uploadingPhoto
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: c.onPrimary),
                              )
                            : Icon(Icons.edit, size: 14, color: c.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName,
                        style: t.headlineMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(user.email,
                        style: t.bodyMedium?.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vLg,
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline,
                  label: AppStrings.labelFullName,
                  value: user.fullName,
                ),
                if (user.studentId != null && user.studentId!.isNotEmpty) ...[
                  const Divider(),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: AppStrings.labelStudentId,
                    value: user.studentId!,
                  ),
                ],
                const Divider(),
                _InfoRow(
                  icon: Icons.mail_outline,
                  label: AppStrings.labelEmail,
                  value: user.email,
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: AppStrings.labelMobile,
                  value: user.mobile.isEmpty ? 'Not added' : user.mobile,
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          AppButton(
            label: AppStrings.editProfile,
            icon: Icons.edit_outlined,
            variant: AppButtonVariant.outlined,
            onPressed: () => _edit(context, user),
          ),
          const SectionHeader(title: AppStrings.appearance),
          const ThemeModeSelector(),
          const SectionHeader(title: AppStrings.account),
          AppButton(
            label: AppStrings.signOut,
            icon: Icons.logout,
            variant: AppButtonVariant.tonal,
            onPressed: () => _confirmSignOut(context, ref),
          ),
          AppSpacing.vLg,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMd, color: c.textSecondary),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.bodySmall),
                Text(value, style: context.text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
