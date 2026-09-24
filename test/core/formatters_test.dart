import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formats whole and fractional amounts', () {
      expect(Formatters.number(52450), '52,450');
      expect(Formatters.number(450.5), '450.50');
      expect(Formatters.money(450), 'Rs. 450');
    });

    test('formats percentages', () {
      expect(Formatters.percent(0.784), '78%');
    });

    test('labels days relative to now', () {
      final now = DateTime(2026, 9, 24, 12);
      expect(Formatters.dayLabel(DateTime(2026, 9, 24, 8), now: now), 'Today');
      expect(
          Formatters.dayLabel(DateTime(2026, 9, 23, 20), now: now), 'Yesterday');
      expect(Formatters.dayLabel(DateTime(2026, 9, 1), now: now), '1 Sep');
    });
  });
}
