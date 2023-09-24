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
    onData: (data) {
      print('DBG:        ${data.toDebugString()}');
      print('toString(): ${data.toString()}');
      print('.text:      ${data.text}');
      print('');
    },
    onError: (error) => print('Error: $error'),
  );

  await client.connect();

  client.send('Hello, world!');

  // ignore: constant_identifier_names
  const MCCP2 = 86;
  client.doo(MCCP2);

  // await client.disconnect();
}

