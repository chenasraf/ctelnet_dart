import 'base.dart';
import 'reader.dart';
import '../consts.dart' as consts;

/// Represents a string value with color information.
///
/// Can be used to store the text and color information for a single token.
///
/// Use [ColorToken.formatted] to get the ANSI formatted text, usable in a terminal.
class ColorToken {
  /// The raw, uncoded text.
  String text;

  /// The foreground color code.
  int fgColor;

  /// The background color code.
  int bgColor;

  /// Whether the text is bold.
  bool bold;

  /// Whether the text is italic.
  bool italic;

  /// Whether the text is underlined.
  bool underline;

  /// Whether the text is an xterm256 color code. Otherwise, it is a standard color code.
  bool xterm256;

  ColorToken({
    required this.text,
    required this.fgColor,
    required this.bgColor,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.xterm256 = false,
  });

  /// Create an empty token.
  factory ColorToken.empty() => ColorToken(text: '', fgColor: 0, bgColor: 0);

  /// Create a token with default color and the given text.
  factory ColorToken.defaultColor(String text) =>
      ColorToken(text: text, fgColor: 0, bgColor: 0);

  /// Returns true if the text is empty.
  bool get isEmpty => text.isEmpty;

  /// Returns true if the text is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Get the formatted text as ANSI formatted text.
  ///
  /// Outputting this value to a terminal will display the text with the correct colors.
  ///
  /// To format the text in other ways, use the properties to get the [fgColor] and [bgColor],
  /// and construct it to whatever format you need.
  String get formatted => bgColor == 0
      ? '\x1B[${fgColor}m$text\x1B[0m'
      : '\x1B[$fgColor;${bgColor}m$text\x1B[0m';

  @override
  String toString() {
    final b = bold ? 'b' : '';
    final i = italic ? 'i' : '';
    final u = underline ? 'u' : '';
    final x = xterm256 ? 'x' : '';
    final flags = '$b$i$u$x';
    return 'ColoredText("$text", $fgColor:$bgColor, $flags)';
  }

  @override
  int get hashCode => text.hashCode ^ fgColor.hashCode ^ bgColor.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorToken &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          fgColor == other.fgColor &&
          bgColor == other.bgColor;

  /// Set the style based on the given code.
  void setStyle(int code) {
    // debugPrint('setStyle: $code');
    if (code == consts.boldByte) {
      bold = true;
    } else if (code == consts.italicByte) {
      italic = true;
    } else if (code == consts.underlineByte) {
      underline = true;
    }
  }
}

/// A parser to parse a string with color codes.
class ColorParser implements IReader {
  final IReader reader;
  final _tokens = <TokenValue>[];

  ColorParser._(this.reader);

  factory ColorParser(String text) => ColorParser._(StringReader(text));

  /// Parse the text and return a list of [ColorToken]s.
  ///
  /// Each token represents a piece of text with color information. You can join all the text
  /// together (without separators) to get the original text, uncolored.
  ///
  /// To get the colored text, use the [ColorToken.formatted] property of each token.
  List<ColorToken> parse() {
    final lexed = <ColorToken>[];
    while (!reader.isDone) {
      final token = reader.read();
      var cur = _getToken(token);
      lexed.add(cur);
    }
    return lexed;
  }

  ColorToken _getToken(String char) {
    var token = ColorToken.empty();
    switch (char) {
      case consts.esc:
        String? next;
        // keep reading until we hit the end of the escape sequence or the end of the string
        while (!reader.isDone) {
          next = reader.peek();
          if (next == consts.esc) {
            break;
          }
          reader.read();
          if (next == '[') {
            final color = _consumeUntil('m');
            reader.read();
            final colors = color.split(';');
            final first = int.tryParse(colors[0]) ?? 0;
            final second = colors.length > 1 ? int.tryParse(colors[1]) ?? 0 : 0;
            final third = colors.length > 2 ? int.tryParse(colors[2]) ?? 0 : 0;
            int fg;
            int bg;
            if (first < 30) {
              token.setStyle(first);
              fg = second;
              bg = third;
            } else {
              if (first == 38 && second == 5) {
                token.xterm256 = true;
                fg = third;
                bg = 0;
              } else {
                fg = first;
                bg = second;
              }
            }
            token.fgColor = fg;
            token.bgColor = bg;
            // if (colors.length == 1) {
            //   final code = int.tryParse(colors[0]) ?? 0;
            //   if (code == consts.boldByte) {
            //     token.bold = true;
            //   } else if (code == consts.italicByte) {
            //     token.italic = true;
            //   } else if (code == consts.underlineByte) {
            //     token.underline = true;
            //   } else {
            //     token.fgColor = int.tryParse(colors[0]) ?? 0;
            //   }
            // } else if (colors.length == 2) {
            //   final code = int.tryParse(colors[0]) ?? 0;
            //   if (code < 30) {
            //     token.fgColor = int.tryParse(colors[1]) ?? 0;
            //   } else {
            //     token.fgColor = int.tryParse(colors[1]) ?? 0;
            //     token.bgColor = int.tryParse(colors[0]) ?? 1;
            //   }
            // } else if (colors.length == 3) {
            //   if (colors[0] == '38' && colors[1] == '5') {
            //     token.xterm256 = true;
            //     token.fgColor = int.tryParse(colors[2]) ?? 0;
            //   } else {
            //     token.bgColor = int.tryParse(colors[0]) ?? 1;
            //     token.fgColor = int.tryParse(colors[1]) ?? 0;
            //   }
            // }
            token.text = _consumeUntil(consts.esc);
            return token;
          }
          if (next == null) {
            break;
          }
          token.text += next;
        }
        return token;
      default:
        token.text += char;
        return token;
    }
  }

  String _consumeUntil(String char) {
    String? next = reader.peek();
    if (next == null) {
      return '';
    }
    var result = '';
    while (!reader.isDone) {
      if (next == char) {
        break;
      }
      next = reader.peek();
      if (next == null) {
        break;
      }
      result += reader.read();
      next = reader.peek();
    }
    return result;
  }

  // String peekUntil(String char) {
  //   String? next = reader.peek();
  //   if (next == null) {
  //     return '';
  //   }
  //   var result = '';
  //   var originalIndex = reader.index;
  //   while (!reader.isDone) {
  //     if (next == char) {
  //       break;
  //     }
  //     next = reader.peek();
  //     if (next == null) {
  //       break;
  //     }
  //     result += reader.read();
  //     next = reader.peek();
  //   }
  //   reader.setPosition(originalIndex);
  //   return result;
  // }

  @override
  int index = 0;

  @override
  bool get isDone => index >= reader.length;

  @override
  peek() => _tokens[index];

  @override
  read() => _tokens[index++];

  @override
  int get length => _tokens.length;

  @override
  setPosition(int position) => index = position;
}
