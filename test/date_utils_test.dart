import 'package:flutter_test/flutter_test.dart';
import 'package:hasi/utils/date_utils.dart';

void main() {
  group('HaDateUtils', () {
    test('isHaTimestamp should identify valid HA timestamps', () {
      expect(
        HaDateUtils.isHaTimestamp('2024-05-24T10:30:00.000000+00:00'),
        isTrue,
      );
      expect(
        HaDateUtils.isHaTimestamp('2024-02-10T11:47:01.123456+01:00'),
        isTrue,
      );
      expect(HaDateUtils.isHaTimestamp('not a date'), isFalse);
      expect(HaDateUtils.isHaTimestamp('2024-05-24'), isFalse);
    });

    test('formatHaTimestamp should return relative time by default', () {
      final now = DateTime.now();
      final oneHourAgo = now
          .subtract(const Duration(hours: 1))
          .toUtc()
          .toIso8601String();

      // We use 'contains' because '1h ago' is what we expect for exactly 1 hour,
      // but execution time might nudge it.
      expect(HaDateUtils.formatHaTimestamp(oneHourAgo), contains('h ago'));
    });

    test(
      'formatHaTimestamp should return formatted date if relative is false',
      () {
        const timestamp = '2024-05-24T10:30:00.000000+00:00';
        final formatted = HaDateUtils.formatHaTimestamp(
          timestamp,
          relative: false,
        );

        expect(formatted, contains('May 24, 2024'));
      },
    );
  });
}
