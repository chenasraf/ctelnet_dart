import 'dart:async';
import 'dart:io';

import 'package:ctelnet/ctelnet.dart';
import 'package:test/test.dart';

final host = InternetAddress.anyIPv4;
final port = 5555;
ServerSocket? server;
Future<StreamSubscription<Socket>> startServer({bool verbose = false}) async {
  void d(Object msg) {
    if (verbose) {
      print(msg);
    }
  }

  Future<ServerSocket> serverFuture = ServerSocket.bind(host, port);
  final timeout = Duration(seconds: 1);
  await Future.delayed(timeout);
  d('Server init on $host:$port');
  server = await serverFuture;
  d('Server started on ${server!.address.address}:${server!.port}');
  return server!.listen(
    (Socket socket) {
      d('Listening on ${socket.remoteAddress.address}:${socket.port}');
      socket.listen((List<int> data) {
        String result = String.fromCharCodes(data);
        socket.write(result);
      });
    },
    onError: (e) {
      d('Server error: $e');
    },
    onDone: () {
      d('Server done');
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
