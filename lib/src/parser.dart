import 'symbols.dart';

class MessageData {
  final List<int> bytes;
  final String text;
  final List<List<int>> commands;

  MessageData(this.bytes, this.text, this.commands);
}

class Reader {
  Reader(this.buffer);

  final List<int> buffer;

  int _index = 0;

  int get index => _index;

  int get length => buffer.length;

  bool get isDone => _index >= buffer.length;

  int? read() {
    if (_index < buffer.length) {
      return buffer[_index++];
    }
    return null;
  }

  int? peek() {
    if (_index < buffer.length) {
      return buffer[_index];
    }
    return null;
  }
}

class MessageParser {
  final List<int> bytes;
  final Reader reader;

  MessageParser(this.bytes) : reader = Reader(bytes);

  MessageData parse() {
    final text = StringBuffer();
    final subnegotiations = <List<int>>[];
    while (!reader.isDone) {
      final byte = reader.read();
      if (byte == null) {
        break;
      }
      if (byte == Symbols.iac) {
        final nextByte = reader.read();
        final optionSymbols = [
          Symbols.sb,
          Symbols.se,
          Symbols.will,
          Symbols.wont,
          Symbols.doo,
          Symbols.dont,
        ];

        if (nextByte == null) {
          break;
        }
        if (nextByte == Symbols.iac) {
          text.writeCharCode(nextByte);
        } else if (optionSymbols.contains(nextByte)) {
          final option = reader.read();
          if (option == null) {
            break;
          }
          subnegotiations.add([nextByte, option]);
        } else {
          subnegotiations.add([nextByte]);
        }
      } else {
        text.writeCharCode(byte);
      }
    }
    return MessageData(bytes, text.toString(), subnegotiations);
  }
}

