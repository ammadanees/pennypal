import 'package:flutter/services.dart';

abstract final class AppInputFormatters {
  static final List<TextInputFormatter> amount = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];
}
