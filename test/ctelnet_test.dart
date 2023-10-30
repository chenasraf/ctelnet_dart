import 'dart:async';
import 'dart:io';

import 'package:ctelnet/ctelnet.dart';
import 'package:test/test.dart';

final host = InternetAddress.anyIPv4;
final port = 5555;
ServerSocket? server;
Future<StreamSubscription<Socket>> startServer() async {
  Future<ServerSocket> serverFuture = ServerSocket.bind(host, port);
  final timeout = Duration(seconds: 1);
  await Future.delayed(timeout);
  print('Server init on $host:$port');
  server = await serverFuture;
  print('Server started on ${server!.address.address}:${server!.port}');
  return server!.listen(
    (Socket socket) {
      print('Listening on ${socket.remoteAddress.address}:${socket.port}');
      socket.listen((List<int> data) {
        String result = String.fromCharCodes(data);
        socket.write(result);
      });
    },
    onError: (e) {
      print('Server error: $e');
    },
    onDone: () {
      print('Server done');
    },
    cancelOnError: true,
  );
}

void main() {
  test('timeout', () async {
    final sub = await startServer();
    final client = CTelnetClient(
      host: host.address,
      port: port,
      timeout: Duration(microseconds: 1),
      onError: (e) {
        expect(e, isA<TimeoutException>());
      },
      onData: (d) {},
      onConnect: () {},
      onDisconnect: () {},
    );

    await client.connect();
    await Future.delayed(Duration(seconds: 1));
    sub.cancel();
  });

  test('connection status', () async {
    final sub = await startServer();
    CTelnetClient? client;
    client = CTelnetClient(
      host: host.address,
      port: port,
      timeout: Duration(seconds: 1),
      onError: (e) {},
      onData: (d) {},
      onConnect: () async {
        expect(client!.status, equals(ConnectionStatus.connected));
      },
      onDisconnect: () {},
    );

    expect(client.status, equals(ConnectionStatus.disconnected));
    await client.connect();
    await Future.delayed(Duration(seconds: 1));
    sub.cancel();
    await client.disconnect();
    expect(client.status, equals(ConnectionStatus.disconnected));
  });
}
