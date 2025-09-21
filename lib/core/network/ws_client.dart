import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WSClient {
  final String url;
  final Duration reconnectInterval;

  WebSocket? _socket;
  bool _isManuallyClosed = false;

  final StreamController<dynamic> _messageController = StreamController.broadcast();
  final StreamController<void> _connectedController = StreamController.broadcast();

  final List<dynamic> _pendingMessages = [];

  WSClient({required this.url, this.reconnectInterval = const Duration(seconds: 5)});

  Stream<dynamic> get onMessageStream => _messageController.stream;
  Stream<void> get onConnectedStream => _connectedController.stream;

  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  Future<void> connect() async {
    _isManuallyClosed = false;
    try {
      _socket = await WebSocket.connect(url);

      _socket?.listen(
            (data) {
          dynamic message;
          try {
            message = jsonDecode(data);
          } catch (_) {
            message = data;
          }
          _messageController.add(message); // gửi message qua stream
        },
        onDone: _handleDisconnect,
        onError: (error) => _handleDisconnect(),
        cancelOnError: true,
      );

      print('🔗 Connected to $url');

      // thông báo đã kết nối
      _connectedController.add(null);

      // gửi các message đã queue
      for (var msg in _pendingMessages) {
        send(msg);
      }
      _pendingMessages.clear();
    } catch (e) {
      print('❌ Connection failed: $e');
      _retryConnect();
    }
  }

  void send(dynamic data) {
    if (isConnected) {
      final payload = data is String ? data : jsonEncode(data);
      _socket!.add(payload);
    } else {
      print('⚠️ Socket chưa kết nối, thêm vào queue');
      _pendingMessages.add(data); // giữ message để gửi khi connect xong
    }
  }

  void close() {
    _isManuallyClosed = true;
    _socket?.close();
    _socket = null;
    _messageController.close();
    _connectedController.close();
    print('⚠️ WebSocket closed manually');
  }

  void _handleDisconnect() {
    _socket = null;
    if (!_isManuallyClosed) {
      print('⚠️ Disconnected, retrying in ${reconnectInterval.inSeconds}s...');
      _retryConnect();
    }
  }

  void _retryConnect() {
    Future.delayed(reconnectInterval, () {
      if (!_isManuallyClosed) {
        connect();
      }
    });
  }
}
