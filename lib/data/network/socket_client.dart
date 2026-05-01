// data/network/socket_client.dart
// 📁 JAMOCHI_APP/lib/data/network/socket_client.dart

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/constants/api_constants.dart';

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;

  late IO.Socket _socket;
  bool get isConnected => _socket.connected;

  SocketClient._internal() {
    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket.onConnect((_)    => {});
    _socket.onDisconnect((_) => {});
    _socket.onConnectError((e) => {});
  }

  void connect(String token) {
    if (isConnected) return;
    _socket.auth = {'token': token};
    _socket.connect();
  }

  void disconnect() => _socket.disconnect();

  // ── Mood ──────────────────────────────────────────────────────────────────
  void onPartnerMoodChanged(void Function(Map<String, dynamic>) callback) {
    _socket.off('partner-mood-changed');
    _socket.on('partner-mood-changed', (raw) {
      try { callback(Map<String, dynamic>.from(raw as Map)); }
      catch (e) { /* Lỗi parse mood */ }
    });
  }

  // ── Chat ──────────────────────────────────────────────────────────────────
  void onReceiveMessage(void Function(Map<String, dynamic>) callback) {
    _socket.off('receive-message');
    _socket.on('receive-message', (raw) => callback(Map<String, dynamic>.from(raw as Map)));
  }

  void onPartnerTyping(void Function() callback) {
    _socket.off('partner-typing');
    _socket.on('partner-typing', (_) => callback());
  }

  void onPartnerStoppedTyping(void Function() callback) {
    _socket.off('partner-stopped-typing');
    _socket.on('partner-stopped-typing', (_) => callback());
  }

  // ── Reaction ──────────────────────────────────────────────────────────────
  // Server broadcast event 'message-reacted' khi ai đó react
  void onMessageReacted(void Function(Map<String, dynamic>) callback) {
    _socket.off('message-reacted');
    _socket.on('message-reacted', (raw) => callback(Map<String, dynamic>.from(raw as Map)));
  }

  // ── Online / Offline status ───────────────────────────────────────────────
  // Server emit 'user-online' và 'user-offline' khi partner connect/disconnect
  void onPartnerOnline(void Function(String userId) callback) {
    _socket.off('user-online');
    _socket.on('user-online', (raw) {
      final data = Map<String, dynamic>.from(raw as Map);
      callback(data['userId']?.toString() ?? '');
    });
  }

  void onPartnerOffline(void Function(String userId, DateTime lastSeen) callback) {
    _socket.off('user-offline');
    _socket.on('user-offline', (raw) {
      final data = Map<String, dynamic>.from(raw as Map);
      final userId   = data['userId']?.toString() ?? '';
      final lastSeen = data['lastSeen'] != null
          ? DateTime.tryParse(data['lastSeen'].toString()) ?? DateTime.now()
          : DateTime.now();
      callback(userId, lastSeen);
    });
  }

  // ── Locket ────────────────────────────────────────────────────────────────
  void onLocketReceived(void Function(Map<String, dynamic>) callback) {
    _socket.off('locket-photo-received');
    _socket.on('locket-photo-received', (raw) => callback(Map<String, dynamic>.from(raw as Map)));
  }

  // ── Video Call ────────────────────────────────────────────────────────────
  void onIncomingCall(void Function(Map<String, dynamic>) callback) {
    _socket.off('incoming-video-call');
    _socket.on('incoming-video-call', (raw) => callback(Map<String, dynamic>.from(raw as Map)));
  }

  void onCallAccepted(void Function(Map<String, dynamic>) callback) {
    _socket.off('video-call-accepted');
    _socket.on('video-call-accepted', (raw) => callback(Map<String, dynamic>.from(raw as Map)));
  }

  void onCallEnded(void Function() callback) {
    _socket.off('video-call-ended');
    _socket.on('video-call-ended', (_) => callback());
  }

  // ── Emit ──────────────────────────────────────────────────────────────────
  void sendMessage(Map<String, dynamic> data)    => _socket.emit('send-message',        data);
  void emitTyping(Map<String, dynamic> data)     => _socket.emit('user-typing',         data);
  void emitStopTyping(Map<String, dynamic> data) => _socket.emit('user-stopped-typing', data);
  void shareLocket(Map<String, dynamic> data)    => _socket.emit('share-locket-photo',  data);
  void initiateCall(Map<String, dynamic> data)   => _socket.emit('initiate-video-call', data);
  void acceptCall(Map<String, dynamic> data)     => _socket.emit('accept-video-call',   data);
  void endCall(Map<String, dynamic> data)        => _socket.emit('end-video-call',      data);
  
  // 🟢 Real-time online/offline status
  void emitUserOnline(String userId) => _socket.emit('user-online-status', {'userId': userId});
  void emitUserOffline(String userId) => _socket.emit('user-offline-status', {'userId': userId});

  void off(String event) => _socket.off(event);
}