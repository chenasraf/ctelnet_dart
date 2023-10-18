import 'client.dart';
import 'message.dart';
import 'symbols.dart';

/// A builder for [Message]s.
///
/// This lets you build a [Message] by adding bytes, subnegotiations, and
/// commands. For example:
///
/// ```dart
/// final builder = MessageBuilder()
///   ..addBytes([1, 2, 3])
///   ..addSubnegotiation(1, [4, 5, 6])
///   ..addDont(1)
///   ..addDoo(2)
///   ..addWill(3)
///   ..addWont(4)
///   ..build();
/// ```
///
/// You can also use the [MessageBuilder] to send the message to a client:
///
/// ```dart
/// builder.send(client);
/// ```
class MessageBuilder {
  final List<int> bytes;

  MessageBuilder({this.bytes = const []});

  /// Sends the message to the given [client].
  void send(ITelnetClient client) => client.sendBytes(bytes);

  /// Returns `true` if the message is empty.
  bool get isEmpty => bytes.isEmpty;

  /// Returns `true` if the message is not empty.
  bool get isNotEmpty => bytes.isNotEmpty;

  /// Adds the given [bytes] to the message.
  MessageBuilder addBytes(List<int> bytes) {
    bytes.addAll(bytes);
    return this;
  }

  /// Adds a subnegotiation to the message.
  MessageBuilder addSubnegotiation(int option, List<int> data) {
    bytes.addAll(
        [Symbols.iac, Symbols.sb, option, ...data, Symbols.iac, Symbols.se]);
    return this;
  }

  /// Adds a DONT command to the message.
  MessageBuilder addDont(int option) {
    bytes.addAll([Symbols.iac, Symbols.dont, option]);
    return this;
  }

  /// Adds a DO command to the message.
  MessageBuilder addDoo(int option) {
    bytes.addAll([Symbols.iac, Symbols.doo, option]);
    return this;
  }

  /// Adds a WILL command to the message.
  MessageBuilder addWill(int option) {
    bytes.addAll([Symbols.iac, Symbols.will, option]);
    return this;
  }

  /// Adds a WONT command to the message.
  MessageBuilder addWont(int option) {
    bytes.addAll([Symbols.iac, Symbols.wont, option]);
    return this;
  }

  /// Builds the message.
  Message build() => Message(bytes);
}
