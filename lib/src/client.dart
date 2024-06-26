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
  Future<Stream<Message>?> connect();

  /// Send data to the server.
  int send(String data);

  /// Send bytes to the server.
  int sendBytes(List<int> bytes);

  /// Disconnect from the server.
  Future<RawSocket?> disconnect();

  /// Send a WILL command to the server.
  void will(int option);

  /// Send a WONT command to the server.
  void wont(int option);

  /// Send a DO command to the server.
  void doo(int option);

  /// Send a DONT command to the server.
  void dont(int option);

  /// Send a subnegotiation to the server.
  void subnegotiate(int option, List<int> data);
}

class CTelnetClient implements ITelnetClient {
  CTelnetClient({
    required this.host,
    required this.port,
    this.timeout = const Duration(seconds: 30),
    required this.onConnect,
    required this.onDisconnect,
    required this.onError,
  });

  final String host;
  final int port;
  final Duration timeout;
  final ConnectionCallback onConnect;
  final ConnectionCallback onDisconnect;
  final ErrorCallback onError;
  RawSocket? _socket;
  ConnectionTask<RawSocket>? _task;
  Timer? _timeoutTask;
  bool _disposed = false;
  @override
  ConnectionStatus status = ConnectionStatus.disconnected;
  bool get connected => _socket != null && status == ConnectionStatus.connected;

  StreamSubscription<RawSocketEvent>? _subscription;
  StreamController<Message>? _controller;

  /// Connect to the host and port.
  ///
  /// Returns a [Stream] to listen for [Message]s if the connection is successful.
  @override
  Future<Stream<Message>?> connect() async {
    try {
      status = ConnectionStatus.connecting;
      final task = await RawSocket.startConnect(host, port);
      _task = task;
      _startTimeout();
      _socket = await task.socket;
      _assertSocket('Socket initialization failed');
      _subscription = _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDisconnect,
      );
      _controller?.close();
      _controller = StreamController<Message>();
      return _controller!.stream;
    } catch (e, stack) {
      if (!_disposed) {
        _dispose();
        _onError(e, stack);
      }
    }
    return null;
  }

  _assertSocket([String? message]) {
    if (_socket == null) {
      throw Exception(message ?? 'Socket is not available');
    }
  }

  @override
  int send(String data) {
    _assertSocket();
    return _socket!.write(Uint8List.fromList(data.codeUnits));
  }

  @override
  int sendBytes(List<int> bytes) {
    _assertSocket();
    return _socket!.write(Uint8List.fromList(bytes));
  }

  @override
  Future<RawSocket?> disconnect() async {
    _onDisconnect();
    return _socket;
  }

  @override
  void subnegotiate(int option, List<int> data) {
    sendBytes(
        [Symbols.iac, Symbols.sb, option, ...data, Symbols.iac, Symbols.se]);
  }

  @override
  void dont(int option) {
    sendBytes([Symbols.iac, Symbols.dont, option]);
  }

  @override
  void doo(int option) {
    sendBytes([Symbols.iac, Symbols.doo, option]);
  }

  @override
  void will(int option) {
    sendBytes([Symbols.iac, Symbols.will, option]);
  }

  @override
  void wont(int option) {
    sendBytes([Symbols.iac, Symbols.wont, option]);
  }

  Future<void> _startTimeout() async {
    _timeoutTask = Timer(timeout, () {
      if (status == ConnectionStatus.connecting) {
        _dispose();
        _onError(
          TimeoutException(
            'Timeout for connection to $host:$port exceeded',
            timeout,
          ),
          StackTrace.current,
        );
      }
    });
  }

  void _onData(RawSocketEvent event) {
    if (!connected) {
      status = ConnectionStatus.connected;
      onConnect();
    }
    switch (event) {
      case RawSocketEvent.read:
        final data = _socket!.read();
        if (data != null) {
          final msg = Message(data);
          _controller!.add(msg);
        }
        break;
      case RawSocketEvent.write:
        break;
      case RawSocketEvent.readClosed:
        _onDisconnect();
        break;
      case RawSocketEvent.closed:
        _onDisconnect();
        break;
    }
  }

  void _onError(error, StackTrace stackTrace) {
    onError(error);
  }

  void _onDisconnect() {
    status = ConnectionStatus.disconnected;
    _dispose();
    onDisconnect();
  }

  void _dispose() {
    status = ConnectionStatus.disconnected;
    _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
    _task?.cancel();
    _task = null;
    _timeoutTask?.cancel();
    _timeoutTask = null;
    _controller?.close();
    _controller = null;
    _disposed = true;
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
