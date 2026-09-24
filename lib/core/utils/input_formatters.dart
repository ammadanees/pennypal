import 'package:flutter/services.dart';

abstract final class AppInputFormatters {
  /// Digits and a decimal point. Validators reject malformed numbers.
  static final List<TextInputFormatter> amount = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];
}
