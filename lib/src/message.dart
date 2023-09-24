import 'consts.dart';
import 'parser.dart';
import 'symbols.dart';

class Message {
  final List<int> bytes;
  late final String text;
  late final List<List<int>> commands;

  Message(this.bytes) {
    final parser = MessageParser(bytes).parse();
    commands = parser.commands;
    text = parser.text;
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
  List<int> subnegotiation(int option) {
    final subnegotiations = commands
        .where((element) => element[0] == Symbols.sb && element[1] == option);
    if (subnegotiations.isEmpty) {
      return [];
    }
    return subnegotiations.first.sublist(2, subnegotiations.first.length - 2);
  }

  /// Returns true if the message has any commands
  bool get isCommand => commands.isNotEmpty;

  /// Returns true if the message has any text
  bool get isText => text.isNotEmpty;

  /// Returns true if the message has any data
  bool get isEmpty => !isCommand && !isText;

  /// Returns true if the message has any data
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return toDebugString();
  }

  String toDebugString() {
    return '${commands.map((e) => e.map((x) => symbolMap[x] ?? x)).join(' ')}${lf}n$text';
  }

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
