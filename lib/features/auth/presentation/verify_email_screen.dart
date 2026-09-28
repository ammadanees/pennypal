import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_inline_message.dart';
import '../data/auth_providers.dart';
import 'auth_controller.dart';
import 'widgets/auth_scaffold.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _otpLength = 6;
  static const int _expirySeconds = 300;
  static const int _resendCooldownSeconds = 60;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _countdownTimer;
  int _secondsRemaining = _expirySeconds;
  int _resendCooldown = _resendCooldownSeconds;

  String? _error;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startTimers();
  }

  void _startTimers() {
    _countdownTimer?.cancel();
    _secondsRemaining = _expirySeconds;
    _resendCooldown = _resendCooldownSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) _secondsRemaining--;
        if (_resendCooldown > 0) _resendCooldown--;
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text.trim()).join();

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        for (var i = 0; i < _otpLength; i++) {
          if (i < digits.length) {
            _controllers[i].text = digits[i];
          }
        }
        final nextIndex =
            digits.length < _otpLength ? digits.length : _otpLength - 1;
        _focusNodes[nextIndex].requestFocus();
        if (digits.length >= _otpLength) {
          _verify();
        }
        return;
      }
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_currentOtp.length == _otpLength) {
          _verify();
        }
      }
    }
  }

  void _onRawKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    final otp = _currentOtp;
    if (otp.length != _otpLength) {
      setState(
          () => _error = 'Please enter all $_otpLength digits of your code.');
      return;
    }

    if (_secondsRemaining <= 0) {
      setState(() => _error =
          'This verification code has expired. Please tap Resend Code.');
      return;
    }

    setState(() {
      _error = null;
      _isVerifying = true;
    });

    final error =
        await ref.read(authControllerProvider.notifier).verifyEmailOtp(otp);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully! Welcome to PennyPal.'),
        ),
      );
      if (mounted) {
        final user = ref.read(authStateProvider).valueOrNull;
        final targetRoute =
            (user?.isAdmin ?? false) ? AppRoutes.admin : AppRoutes.home;
        context.go(targetRoute);
      }
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _error = null;
    });

    final error =
        await ref.read(authControllerProvider.notifier).sendEmailOtp();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _startTimers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A fresh verification code has been sent.'),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final user = ref.watch(authStateProvider).valueOrNull;
    final email = user?.email ?? 'your email';

    final isExpired = _secondsRemaining <= 0;

    return AuthScaffold(
      title: 'Verify Your Email',
      subtitle: 'Complete your registration by entering the code',
      onBack: _signOut,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Wrong email address?', style: t.bodyMedium),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.text,
            expand: false,
            onPressed: _signOut,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 38,
                color: c.primary,
              ),
            ),
          ),
          AppSpacing.vMd,
          Text(
            'We sent a 6-digit verification code to',
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
          AppSpacing.vXs,
          Text(
            email,
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: c.primary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              return SizedBox(
                width: 48,
                height: 56,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onRawKey(index, event),
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: index == 0,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: t.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: c.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide: BorderSide(color: c.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide: BorderSide(color: c.primary, width: 2),
                      ),
                    ),
                    onChanged: (val) => _onDigitChanged(index, val),
                  ),
                ),
              );
            }),
          ),
          AppSpacing.vMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpired ? Icons.error_outline : Icons.timer_outlined,
                size: 16,
                color: isExpired ? c.error : c.textMuted,
              ),
              AppSpacing.hXs,
              Text(
                isExpired
                    ? 'Code expired'
                    : 'Code expires in ${_formatTime(_secondsRemaining)}',
                style: t.bodySmall?.copyWith(
                  color: isExpired ? c.error : c.textMuted,
                  fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            AppSpacing.vMd,
            AppInlineMessage(message: _error!),
          ],
          AppSpacing.vLg,
          AppButton(
            label: 'Verify & Complete Sign Up',
            isLoading: _isVerifying,
            onPressed: _verify,
          ),
          AppSpacing.vMd,
          Center(
            child: _resendCooldown > 0
                ? Text(
                    'Resend code in ${_resendCooldown}s',
                    style: t.bodySmall?.copyWith(color: c.textMuted),
                  )
                : TextButton.icon(
                    onPressed: _isResending ? null : _resend,
                    icon: _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: const Text('Resend Code'),
                  ),
          ),
        ],
      ),
    );
  }
}
