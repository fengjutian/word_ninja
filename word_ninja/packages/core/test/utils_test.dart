import 'package:core/extensions/extensions.dart';
import 'package:core/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('experience helpers calculate increasing levels', () {
    expect(expForLevel(1), 0);
    expect(expForLevel(2), 1500);
    expect(0.toEstimatedLevel, 1);
    expect(1500.toEstimatedLevel, 2);
  });
}
