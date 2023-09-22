import 'parser.dart';
import 'symbols.dart';

abstract class IMessage {
  /// The message data in bytes.
  List<int> get bytes;

  MessageData get data;
}

class Message implements IMessage {
  @override
  List<int> bytes = [];

  Message(this.bytes) : data = MessageParser(bytes).parse();

  @override
  String toString() {
    return toDebugString();
  }

  String toDebugString() {
    return '${data.subnegotiations.map((e) => e.map((x) => symbolMap[x] ?? x)).join(' ')}\n${data.text}';
  }

  int get firstLiteralByte {
    return 0;
  }

  String get text => data.text;

  @override
  int get hashCode => bytes.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Message) {
      return toString() == other.toString();
    }
    return false;
  }

  @override
  MessageData data;
}

class StringMessage extends Message {
  StringMessage(String string) : super(string.codeUnits);
  StringMessage.fromBytes(List<int> bytes) : super(bytes);

  @override
  String toString() => String.fromCharCodes(bytes);
}

