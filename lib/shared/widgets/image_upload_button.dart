import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/errors/app_failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/cloudinary_service.dart';
import 'app_button.dart';
import 'app_inline_message.dart';

/// Pick an image, upload it to Cloudinary, and hand back the hosted URL.
/// Shows its own progress and error state so callers stay simple.
class ImageUploadButton extends ConsumerStatefulWidget {
  const ImageUploadButton({
    super.key,
    required this.label,
    required this.onUploaded,
    this.imageQuality = 80,
    this.maxDimension = 1600,
  });

  final String label;
  final ValueChanged<String> onUploaded;
  final int imageQuality;
  final double maxDimension;

  @override
  ConsumerState<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends ConsumerState<ImageUploadButton> {
  bool _busy = false;
  String? _error;

  Future<void> _pickAndUpload() async {
    setState(() => _error = null);
    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: widget.imageQuality,
        maxWidth: widget.maxDimension,
        maxHeight: widget.maxDimension,
      );
    } catch (_) {
      setState(() => _error = 'Could not open the photo picker.');
      return;
    }
    if (file == null) return;

    setState(() => _busy = true);
    try {
      final Uint8List bytes = await file.readAsBytes();
      final url = await ref
          .read(cloudinaryServiceProvider)
          .uploadImage(bytes, fileName: file.name);
      if (mounted) widget.onUploaded(url);
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'The photo could not be uploaded.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: widget.label,
          icon: Icons.add_a_photo_outlined,
          variant: AppButtonVariant.outlined,
          isLoading: _busy,
          onPressed: _pickAndUpload,
        ),
        if (_error != null) ...[
          AppSpacing.vSm,
          AppInlineMessage(message: _error!),
        ],
      ],
    );
  }
}
