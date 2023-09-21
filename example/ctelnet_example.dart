import 'package:ctelnet/ctelnet.dart';

void main(List<String> args) async {
  final host = String.fromEnvironment('HOST', defaultValue: 'localhost');
  final port = int.tryParse(String.fromEnvironment('PORT', defaultValue: '23')) ?? 23;

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

  // await client.disconnect();
}

