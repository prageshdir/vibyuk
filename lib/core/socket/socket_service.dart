import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/socket/socket_config.dart';
import 'package:vibyuk/core/socket/socket_events.dart';

enum SocketConnectionState { disconnected, connecting, connected, reconnecting, error }

class SocketService {
  SocketService();

  IO.Socket? _socket;
  String? _authToken;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  final _connectionState = BehaviorSubject<SocketConnectionState>.seeded(
      SocketConnectionState.disconnected);
  final Map<String, StreamController<dynamic>> _eventControllers = {};

  Stream<SocketConnectionState> get connectionState$ => _connectionState.stream;
  SocketConnectionState get connectionState => _connectionState.value;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({required String token}) async {
    if (_socket?.connected ?? false) return;
    _authToken = token;
    _reconnectAttempts = 0;
    _connectionState.add(SocketConnectionState.connecting);
    AppLogger.info('SocketService: Connecting to ${SocketConfig.url}');

    _socket = IO.io(
      SocketConfig.url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .setReconnection(false)
          .build(),
    );

    _bindSocketEvents();
    _socket!.connect();
  }

  void _bindSocketEvents() {
    _socket?.on(SocketEvents.connect, (_) {
      AppLogger.info('SocketService: Connected');
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _connectionState.add(SocketConnectionState.connected);
      // Replay listeners after reconnect
      for (final event in _eventControllers.keys) {
        _listenToEvent(event);
      }
    });

    _socket?.on(SocketEvents.disconnect, (reason) {
      AppLogger.warning('SocketService: Disconnected — $reason');
      _connectionState.add(SocketConnectionState.disconnected);
      if (reason != 'io client disconnect') _scheduleReconnect();
    });

    _socket?.on(SocketEvents.connectError, (error) {
      AppLogger.error('SocketService: Connection error — $error');
      _connectionState.add(SocketConnectionState.error);
      _scheduleReconnect();
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= SocketConfig.maxReconnectAttempts) {
      AppLogger.error('SocketService: Max reconnect attempts reached');
      _connectionState.add(SocketConnectionState.error);
      return;
    }

    final delay = _calcBackoff(_reconnectAttempts);
    _reconnectAttempts++;
    AppLogger.info(
        'SocketService: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    _connectionState.add(SocketConnectionState.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      if (_authToken != null) {
        _socket?.dispose();
        _socket = null;
        await connect(token: _authToken!);
      }
    });
  }

  Duration _calcBackoff(int attempt) {
    final seconds =
        SocketConfig.initialReconnectDelay.inSeconds * (1 << attempt.clamp(0, 5));
    return Duration(
        seconds: seconds.clamp(
            SocketConfig.initialReconnectDelay.inSeconds,
            SocketConfig.maxReconnectDelay.inSeconds));
  }

  Stream<dynamic> on(String event) {
    if (!_eventControllers.containsKey(event)) {
      _eventControllers[event] = StreamController<dynamic>.broadcast();
      if (_socket != null) _listenToEvent(event);
    }
    return _eventControllers[event]!.stream;
  }

  void _listenToEvent(String event) {
    _socket?.off(event);
    _socket?.on(event, (data) => _eventControllers[event]?.add(data));
  }

  void emit(String event, dynamic data) {
    if (!isConnected) {
      AppLogger.warning('SocketService: Emit "$event" dropped — not connected');
      return;
    }
    _socket?.emit(event, data);
  }

  void joinRoom(String room) =>
      emit(SocketEvents.joinRoom, {'room': room});

  void leaveRoom(String room) =>
      emit(SocketEvents.leaveRoom, {'room': room});

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionState.add(SocketConnectionState.disconnected);
    AppLogger.info('SocketService: Manually disconnected');
  }

  void dispose() {
    disconnect();
    for (final ctrl in _eventControllers.values) {
      ctrl.close();
    }
    _eventControllers.clear();
    _connectionState.close();
  }
}
