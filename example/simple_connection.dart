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
    onData: (data) => print('Data: $data'),
    onError: (error) => print('Error: $error'),
  );

  await client.connect();

  client.send('Hello, world!');

  await client.disconnect();
}

