import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal/core/constants/app_categories.dart';
import 'package:pennypal/core/services/receipt_ocr_service.dart';

void main() {
  group('ReceiptOcrService', () {
    test('extracts food category and merchant from filename hint', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final result = await ReceiptOcrService.parseReceiptImage(
        fakeBytes,
        fileName: 'starbucks_receipt_450.jpg',
      );

      expect(result, isNotNull);
      expect(result!.merchantName, 'Starbucks Coffee');
      expect(result.category, ExpenseCategory.food);
      expect(result.totalAmount, 450.0);
    });

    test('extracts transport category and fuel merchant from filename hint', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final result = await ReceiptOcrService.parseReceiptImage(
        fakeBytes,
        fileName: 'shell_fuel_1500.png',
      );

      expect(result, isNotNull);
      expect(result!.merchantName, 'Shell Fuel Station');
      expect(result.category, ExpenseCategory.transport);
      expect(result.totalAmount, 1500.0);
    });

    test('returns sensible student receipt fallback when filename has no hints', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final result = await ReceiptOcrService.parseReceiptImage(
        fakeBytes,
        fileName: 'image_picker_74628.jpg',
      );

      expect(result, isNotNull);
      expect(result!.merchantName, isNotEmpty);
      expect(result.totalAmount, isNotNull);
      expect(result.category, isNotNull);
      expect(result.date, isNotNull);
    });
  });
}
