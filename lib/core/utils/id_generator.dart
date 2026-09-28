import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random.secure();

  static String next() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = _random.nextInt(0x7fffffff).toRadixString(36);
    return '$time$noise';
  }
}
