import 'package:test/test.dart';
import 'package:client/utils/duration_extend.dart';

void main() {
  test('test duation format', () {
    var d = const Duration(
        days: 1, hours: 2, minutes: 3, seconds: 4, milliseconds: 567);
    expect(d.format(), "26h3m4.57s");

    d = const Duration(days: 1);
    expect(d.format(), "24h");

    d = const Duration(hours: 1);
    expect(d.format(), "1h");

    d = const Duration(minutes: 1);
    expect(d.format(), "1m");

    d = const Duration(seconds: 1);
    expect(d.format(), "1.00s");

    d = const Duration(milliseconds: 1);
    expect(d.format(), "0.00s");

    d = const Duration(milliseconds: 10);
    expect(d.format(), "0.01s");

    d = const Duration(microseconds: 1);
    expect(d.format(), "0.00s");

    d = const Duration(microseconds: 999);
    expect(d.format(), "0.00s");

    d = const Duration(hours: -1);
    expect(d.format(), "0.00s");
  });
}
