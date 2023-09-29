import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'message.dart';
import 'symbols.dart';
import 'typedefs.dart';

export './typedefs.dart';

abstract class ITelnetClient {
  /// The connection status of the client.
  ConnectionStatus status = ConnectionStatus.disconnected;

  /// Connect to the server.
  Future<void> connect();

  /// Send data to the server.
  int send(String data);

  /// Send bytes to the server.
  int sendBytes(List<int> bytes);

  /// Disconnect from the server.
  Future<RawSocket> disconnect();

  /// Send a WILL command to the server.
  will(int option);

  /// Send a WONT command to the server.
  wont(int option);

  /// Send a DO command to the server.
  doo(int option);

  /// Send a DONT command to the server.
  dont(int option);

  /// Send a subnegotiation to the server.
  subnegotiate(int option, List<int> data);
}

class CTelnetClient implements ITelnetClient {
  CTelnetClient({
    required this.host,
    required this.port,
    this.timeout = const Duration(seconds: 30),
    required this.onConnect,
    required this.onDisconnect,
    required this.onData,
    required this.onError,
  });

  final String host;
  final int port;
  final Duration timeout;
  final ConnectionCallback onConnect;
  final ConnectionCallback onDisconnect;
  final DataCallback onData;
  final ErrorCallback onError;
  late RawSocket _socket;
  late ConnectionTask<RawSocket> _task;
  @override
  ConnectionStatus status = ConnectionStatus.disconnected;
  bool get connected => status == ConnectionStatus.connected;

  StreamSubscription<RawSocketEvent>? _subscription;

  /// Connect to the host and port.
  @override
  Future<void> connect() async {
    try {
      status = ConnectionStatus.connecting;
      final task = await RawSocket.startConnect(host, port);
      _task = task;
      _startTimeout();
      _socket = await task.socket;
      _subscription = _socket.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  int send(String data) {
    return _socket.write(Uint8List.fromList(data.codeUnits));
  }

  @override
  int sendBytes(List<int> bytes) {
    return _socket.write(Uint8List.fromList(bytes));
  }

  @override
  Future<RawSocket> disconnect() async {
    return _socket.close();
  }

  @override
  subnegotiate(int option, List<int> data) {
    sendBytes(
        [Symbols.iac, Symbols.sb, option, ...data, Symbols.iac, Symbols.se]);
  }

  @override
  dont(int option) {
    sendBytes([Symbols.iac, Symbols.dont, option]);
  }

  @override
  doo(int option) {
    sendBytes([Symbols.iac, Symbols.doo, option]);
  }

  @override
  will(int option) {
    sendBytes([Symbols.iac, Symbols.will, option]);
  }

  @override
  wont(int option) {
    sendBytes([Symbols.iac, Symbols.wont, option]);
  }

  Future<void> _startTimeout() async {
    await Future.delayed(timeout);
    if (!connected) {
      _dispose();
      _onError(
          TimeoutException(
              'Timeout for connection to $host:$port exceeded', timeout),
          StackTrace.current);
    }
  }

  void _onData(RawSocketEvent event) {
    if (!connected) {
      status = ConnectionStatus.connected;
      onConnect();
    }
    switch (event) {
      case RawSocketEvent.read:
        final data = _socket.read();
        if (data != null) {
          final msg = Message(data);
          onData(msg);
        }
        break;
      case RawSocketEvent.write:
        break;
      case RawSocketEvent.readClosed:
        break;
      case RawSocketEvent.closed:
        break;
    }
  }

  void _onError(error, StackTrace stackTrace) {
    onError(error.toString());
  }

  void _onDone() {
    status = ConnectionStatus.disconnected;
    onDisconnect();
    _subscription?.cancel();
    _task.cancel();
  }

  void _dispose() {
    _subscription?.cancel();
    _task.cancel();
  }
}

enum ConnectionStatus {
  /// The client is in the process of connecting to the server.
  connecting,

  /// The client is connected to the server and ready to send and receive data.
  connected,

  /// The client is not connected to the server.
  disconnected,
}

