# CTelnet

This package is a telnet client implementation in dart. You can connect to a telnet server, and get
and send data in a simple interface.

## Features

- Parses data for easy querying
- Supports sending & receiving options and subnegotiations
- Works in plain Dart or Flutter environments

## Getting started

There are no prerequisites to using this package. Simply add it to your pubspec, and import the
client to be used.

```sh
dart pub add ctelnet
# or
flutter pub add ctelnet
```

All you normally need to import is in the main `ctelnet.dart` file:

```dart
import 'package:ctelnet/ctelnet.dart'
```

## Usage

### Connecting to a server

Just use `CTelnetClient` to connect. You first initialize it, then connect when you are ready.

```dart
Future<void> connect(String host, int port) {
  print('Connecting to $host:$port');

  final client = CTelnetClient(
    host: host,
    port: port,
    timeout: Duration(seconds: 30),
    onConnect: () => print('Connected'),
    onDisconnect: () => print('Disconnected'),
    onError: (error) => print('Error: $error'),
  );

  final stream = await client.connect();
  final subscription = stream.listen((data) => print('Data received: ${data.text}'));
}
```

### Sending data to server

To send data to the server, you can use the `send` and `sendBytes` methods on the client.

The method `send` will let you send any plaintext, which should be fine for most cases, but you may
send any raw information using `sendBytes` and supplying a byte array.

There are also built-in methods for sending commands to the telnet server, such as the `will`,
`wont`, `doo` and `dont` methods for handling telnet options.

```dart
const MCCP2 = 86;

void sendExamples() {
  // Send a string
  client.send('Hello, world');

  // Send raw bytes
  client.sendBytes([Symbols.iac, Symbols.sb] + 'Hello, world!'.codeUnits);

  // Send commands
  client.doo(Symbols.compression2);
}
```

You can see more methods in the documentation for the `CTelnetClient` object.

### Receiving data from server

You can also use parsed or raw information for received `Message` objects.

```dart
final stream = await client.connect();
final subscription = stream.listen(handleMessage);

bool isEncrypted = false;

void handleMessage(Message msg) {
  if (msg.will(Symbols.compression2)) {
    client.doo(Symbols.compression2)
  }

  if (msg.sb(Symbols.compression2)) {
    isEncrypted = true;
    /// proceed to process data
  }

  print('The plaintext portion of the message is: ${msg.text}');
  print('The attached commands are: ${msg.commands}');
}
```

You can see more methods in the documentation for the `Message` object.

### Using ANSI/xterm colors

CTelnet comes with a built-in ANSI/xterm color parser. You can get the list of colored segments
inside a message object using the `coloredText` property:

```dart
void handleMessage(Message msg) {
  for (final segment in msg.coloredText) {
    print('Uncolored: ${segment.text}');
    print('Foreground: ${segment.fgColor}');
    print('Background: ${segment.bgColor}');
    print('Colored for terminal: ${segment.formatted}');
  }
}
```

## Contributing

I am developing this package on my free time, so any support, whether code, issues, or just stars is
very helpful to sustaining its life. If you are feeling incredibly generous and would like to donate
just a small amount to help sustain this project, I would be very very thankful!

<a href='https://ko-fi.com/casraf' target='_blank'>
  <img height='36' style='border:0px;height:36px;'
    src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
    alt='Buy Me a Coffee at ko-fi.com' />
</a>

I welcome any issues or pull requests on GitHub. If you find a bug, or would like a new feature,
don't hesitate to open an appropriate issue and I will do my best to reply promptly.
