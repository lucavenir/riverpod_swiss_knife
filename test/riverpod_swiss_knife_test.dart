import "package:riverpod_swiss_knife/riverpod_swiss_knife.dart";
import "package:test/test.dart";

void main() {
  group("A group of tests", () {
    final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test("First Test", () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}
