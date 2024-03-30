import 'package:ctelnet/src/color_parser/parser.dart';
import 'package:ctelnet/src/consts.dart';
import 'package:test/test.dart';

const inputs = [
  '$esc[32mYou are standing in a small clearing.$esc[0m',
  'You are standing in a small clearing.',
  '$esc[0m$esc[1m$esc[0m$esc[1m$esc[31mWelcome to SimpleMUD$esc[0m$esc[1m$esc[0m',
  '$esc[0m$esc[37m$esc[0m$esc[37m$esc[1m[$esc[0m$esc[37m$esc[1m$esc[32m10$esc[0m$esc[37m$esc[1m/10]$esc[0m$esc[37m$esc[0m'
];

void main() {
  group('ColorParser', () {
    test('parse colors - simple', () {
      final input = inputs[0];
      final output = ColorParser(input).parse();
      expect(output, [
        ColorToken(text: 'You are standing in a small clearing.', fgColor: 32, bgColor: 0),
        ColorToken.empty(),
      ]);
    });

    test('formatted', () {
      final input = inputs[0];
      final output = ColorParser(input).parse();
      expect(output[0].formatted, inputs[0]);
    });
  });
}
