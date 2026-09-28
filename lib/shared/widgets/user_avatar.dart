import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.size = 48,
    this.onTap,
    this.tooltip,
    this.border,
    this.showEditBadge = false,
    this.isUploading = false,
  });

  final String? photoUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;
  final BoxBorder? border;
  final bool showEditBadge;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;
    final cleanUrl = photoUrl?.trim();

    Widget imageContent;
    if (!hasPhoto || cleanUrl == null) {
      imageContent = _fallbackInitials(context, c, t);
    } else if (cleanUrl.startsWith('http://') ||
        cleanUrl.startsWith('https://')) {
      imageContent = Image.network(
        cleanUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackInitials(context, c, t),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: c.primarySoft,
            alignment: Alignment.center,
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else if (!kIsWeb && _isValidLocalFile(cleanUrl)) {
      imageContent = Image.file(
        io.File(_toFilePath(cleanUrl)),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackInitials(context, c, t),
      );
    } else {
      imageContent = _fallbackInitials(context, c, t);
    }

    Widget avatar = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.primarySoft,
        shape: BoxShape.circle,
        border: border ??
            Border.all(
              color: c.primary.withOpacity(0.20),
              width: 1.5,
            ),
      ),
      child: imageContent,
    );

    if (showEditBadge || isUploading) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: (size * 0.38).clamp(24.0, 32.0),
              height: (size * 0.38).clamp(24.0, 32.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
                border: Border.all(color: c.background, width: 2),
              ),
              child: isUploading
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.edit,
                      size: (size * 0.22).clamp(12.0, 16.0),
                      color: c.onPrimary,
                    ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isUploading ? null : onTap,
          customBorder: const CircleBorder(),
          child: avatar,
        ),
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      avatar = Tooltip(
        message: tooltip!,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _fallbackInitials(BuildContext context, AppColors c, TextTheme t) {
    final fontSize = (size * 0.38).clamp(11.0, 26.0);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: c.primarySoft,
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: t.titleMedium?.copyWith(
          color: c.primary,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static bool _isValidLocalFile(String rawPath) {
    if (rawPath.startsWith('content://')) return false;
    try {
      final path = _toFilePath(rawPath);
      return io.File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  static String _toFilePath(String rawPath) {
    if (rawPath.startsWith('file://')) {
      try {
        return Uri.parse(rawPath).toFilePath();
      } catch (_) {
        return rawPath;
      }
    }
    return rawPath;
  }
}
