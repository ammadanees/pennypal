import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/currency_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/theme_mode_selector.dart';
import '../../../shared/widgets/user_avatar.dart';
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
      useRootNavigator: true,
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
      useRootNavigator: true,
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
              UserAvatar(
                photoUrl: user.photoUrl,
                initials: user.initials,
                size: AppDimensions.avatar,
                showEditBadge: true,
                isUploading: _uploadingPhoto,
                tooltip: 'Change profile picture',
                onTap: _uploadingPhoto ? null : () => _changePhoto(user),
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
          const SectionHeader(title: 'Preferences'),
          const _CurrencyPreferenceTile(),
          const SectionHeader(title: AppStrings.appearance),
          const ThemeModeSelector(),
          const SectionHeader(title: AppStrings.account),
          AppButton(
            label: AppStrings.signOut,
            icon: Icons.logout,
            variant: AppButtonVariant.tonal,
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: AppDimensions.bottomNavClearance),
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

class _CurrencyPreferenceTile extends ConsumerWidget {
  const _CurrencyPreferenceTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final t = context.text;
    final current = ref.watch(currencyProvider);
    final activeOption = supportedCurrencies.firstWhere(
      (opt) => opt.symbol == current,
      orElse: () => supportedCurrencies.first,
    );

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            activeOption.symbol,
            style: t.titleMedium?.copyWith(
              color: c.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: const Text('Currency'),
        subtitle: Text('${activeOption.name} (${activeOption.code})'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _pickCurrency(context, ref, current),
      ),
    );
  }

  void _pickCurrency(BuildContext context, WidgetRef ref, String selectedSymbol) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Select Currency', style: ctx.text.titleLarge),
              AppSpacing.vXs,
              Text(
                'Amounts throughout PennyPal will automatically display with this currency symbol.',
                style: ctx.text.bodySmall,
              ),
              AppSpacing.vMd,
              for (final opt in supportedCurrencies) ...[
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                  selected: opt.symbol == selectedSymbol,
                  selectedTileColor: ctx.colors.primarySoft.withOpacity(0.35),
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: opt.symbol == selectedSymbol
                          ? ctx.colors.primary
                          : ctx.colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: ctx.colors.border),
                    ),
                    child: Text(
                      opt.symbol,
                      style: ctx.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: opt.symbol == selectedSymbol
                            ? ctx.colors.onPrimary
                            : ctx.colors.textPrimary,
                      ),
                    ),
                  ),
                  title: Text(opt.name, style: ctx.text.labelLarge),
                  subtitle: Text('${opt.code} (${opt.symbol})'),
                  trailing: opt.symbol == selectedSymbol
                      ? Icon(Icons.check_circle, color: ctx.colors.primary)
                      : null,
                  onTap: () {
                    ref.read(currencyProvider.notifier).setCurrency(opt.symbol);
                    Navigator.of(ctx).pop();
                  },
                ),
                AppSpacing.vXs,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
