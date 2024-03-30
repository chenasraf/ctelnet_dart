import 'dart:io';

import 'package:ctelnet/ctelnet.dart';

var env = Platform.environment;
final host = env['HOST'] ?? 'localhost';
final port = int.parse(env['PORT'] ?? '23');

void main(List<String> args) async {
  print('Connecting to $host:$port');

  final client = CTelnetClient(
    host: host,
    port: port,
    timeout: Duration(seconds: 30),
    onConnect: () => print('Connected'),
    onDisconnect: () => print('Disconnected'),
    onError: (error) => print('Error: $error'),
  );

  final sub = await client.connect();

  if (sub == null) {
    throw Exception('Failed to connect');
  }

  // listen to the stream of messages
  sub.listen((data) {
    print('Message received!');
    print('text:      ${data.text}');
    print('Debug:     ${data.toDebugString()}');
    print('Colored: ${data.coloredText.map((t) => t.formatted).join('')}');
    print('');
  });

  // send a message
  client.send('Hello, world!');

  // send a command
  client.doo(Symbols.compression2);

  await Future.delayed(Duration(seconds: 5));

  await client.disconnect();
}

