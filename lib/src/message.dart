import 'package:terminal_color_parser/terminal_color_parser.dart';

import 'consts.dart';
import 'parser.dart';
import 'symbols.dart';

class Message {
  /// The raw bytes of the message
  final List<int> bytes;

  /// The plaintext section of the message
  late final String text;

  /// The list of command bytes in the message
  late final List<List<int>> commands;

  /// The list of color tokens in the message. Each token contains the original text
  /// and color information
  ///
  /// See [ColorToken] for more information
  late final List<ColorToken> coloredText;

  Message(this.bytes) {
    final stringParser = MessageParser(bytes).parse();
    commands = stringParser.commands;
    text = stringParser.text;
    coloredText = ColorParser(text).parse();
  }

  /// Returns true if the message contains the given WILL command
  bool will(int option) => commands
      .any((element) => element[0] == Symbols.will && element[1] == option);

  /// Returns true if the message contains the given WONT command
  bool wont(int option) => commands
      .any((element) => element[0] == Symbols.wont && element[1] == option);

  /// Returns true if the message contains the given DO command
  bool doo(int option) => commands
      .any((element) => element[0] == Symbols.doo && element[1] == option);

  /// Returns true if the message contains the given DONT command
  bool dont(int option) => commands
      .any((element) => element[0] == Symbols.dont && element[1] == option);

  /// Returns true if the message starts the subnegotiation (with optional value)
  bool sb([int? option]) => commands.any((element) =>
      element[0] == Symbols.sb && (option == null || element[1] == option));

  /// Returns true if the message ends the subnegotiation
  bool se() => commands.any((element) => element[0] == Symbols.se);

  /// Returns the subnegotiation data for the given option
  /// Returns only the inner data, not the surrounding IAC SB and IAC SE
  /// If the data is not found or is not properly formatted (does not end with
  /// SE or is too short), returns null
  List<int>? subnegotiation(int option) {
    final subnegotiations = commands
        .where((element) => element[0] == Symbols.sb && element[1] == option);
    if (subnegotiations.isEmpty) {
      return null;
    }
    final sub = subnegotiations.first;
    if (sub.length < 3) {
      return null;
    }
    if (sub.last != Symbols.se) {
      return null;
    }
    return sub.sublist(2, subnegotiations.first.length - 2);
  }

  /// Returns true if the message has any commands
  bool get isCommand => commands.isNotEmpty;

  /// Returns true if the message has any text
  bool get isText => text.isNotEmpty;

  /// Returns true if the message has no data
  bool get isEmpty => !isCommand && !isText;

  /// Returns true if the message has any data
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return toDebugString();
  }

  /// Used for debugging - returns the message as a string with all commands in a human
  /// readable format followed by a newline, then the text
  String toDebugString() {
    return '${commands.map((e) => e.map((x) => symbolMap[x] ?? x)).join(' ')}$lf$text';
  }

  /// Get the index of the first byte that is not part of a command
  int get firstLiteralByteIndex {
    if (bytes.isEmpty) {
      return 0;
    }
    final commandsByteCount = commands.fold<int>(
        0, (previousValue, element) => previousValue + element.length);
    return commandsByteCount;
  }

  @override
  int get hashCode => bytes.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Message) {
      return toString() == other.toString();
    }
    return false;
  }
}
