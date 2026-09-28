import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/errors/app_failure.dart';
import '../../core/services/receipt_ocr_service.dart';
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
    this.onReceiptParsed,
    this.imageQuality = 80,
    this.maxDimension = 1600,
  });

  final String label;
  final ValueChanged<String> onUploaded;
  final ValueChanged<ParsedReceipt>? onReceiptParsed;
  final int imageQuality;
  final double maxDimension;

  @override
  ConsumerState<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends ConsumerState<ImageUploadButton> {
  bool _busy = false;
  String? _error;

  Future<void> _pickAndUpload() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Receipt Image',
                style: ctx.text.titleMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.vMd,
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo (Camera)'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              AppSpacing.vSm,
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    setState(() => _error = null);
    final picker = ImagePicker();
    XFile? file;
    try {
      file = await picker.pickImage(
        source: source,
        imageQuality: widget.imageQuality,
        maxWidth: widget.maxDimension,
        maxHeight: widget.maxDimension,
      );
    } catch (_) {
      setState(() => _error = 'Could not open the camera or photo picker.');
      return;
    }
    if (file == null) return;

    setState(() => _busy = true);
    try {
      final Uint8List bytes = await file.readAsBytes();

      // 1. Run receipt parsing immediately on image bytes so fields auto-fill
      // without waiting on external cloud image hosting.
      if (widget.onReceiptParsed != null) {
        try {
          final parsed = await ReceiptOcrService.parseReceiptImage(
            bytes,
            fileName: file.name,
          );
          if (mounted && parsed != null) {
            widget.onReceiptParsed!(parsed);
          }
        } catch (e) {
          debugPrint('[ImageUploadButton] Receipt OCR parsing notice: $e');
        }
      }

      // 2. Upload image to Cloudinary for persistence
      try {
        final url = await ref
            .read(cloudinaryServiceProvider)
            .uploadImage(bytes, fileName: file.name);
        if (mounted) widget.onUploaded(url);
      } catch (uploadError) {
        debugPrint('[ImageUploadButton] Cloudinary upload notice: $uploadError');
        // Even if Cloudinary image hosting is unreachable or fails,
        // provide a local data URI so receipt image preview still displays
        final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        if (mounted) widget.onUploaded(dataUri);
      }
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
