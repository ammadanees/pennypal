import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/utils/app_dates.dart';
import 'package:pennypal/core/utils/formatters.dart';
import 'package:pennypal/core/utils/id_generator.dart';

void main() {
  test('addMonths clamps to the end of shorter months', () {
    expect(AppDates.addMonths(DateTime(2027, 1, 31), 1), DateTime(2027, 2, 28));
    expect(AppDates.addMonths(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
    expect(AppDates.addMonths(DateTime(2026, 11, 15), 3), DateTime(2027, 2, 15));
    expect(AppDates.addMonths(DateTime(2026, 3, 10), -4), DateTime(2025, 11, 10));
  });

  test('month key and months between', () {
    expect(AppDates.monthKey(DateTime(2026, 9, 24)), '2026-09');
    expect(AppDates.monthsBetween(DateTime(2026, 9, 24), DateTime(2027, 1, 1)), 4);
  });

  test('compact numbers for chart labels', () {
    expect(Formatters.compact(0), '0');
    expect(Formatters.compact(450), '450');
    expect(Formatters.compact(999), '999');
    expect(Formatters.compact(1000), '1k');
    expect(Formatters.compact(31200), '31.2k');
    expect(Formatters.compact(50000), '50k');
    expect(Formatters.compact(1200000), '1.2M');
    expect(Formatters.compact(-2500), '-2.5k');
  });

  test('generated ids are unique', () {
    final ids = {for (var i = 0; i < 500; i++) IdGenerator.next()};
    expect(ids, hasLength(500));
  });
}
