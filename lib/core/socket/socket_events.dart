abstract final class SocketEvents {
  // Lifecycle
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String connectError = 'connect_error';

  // Rooms
  static const String joinRoom = 'join_room';
  static const String leaveRoom = 'leave_room';

  // Messages
  static const String newMessage = 'new_message';
  static const String messageSent = 'message_sent';
  static const String messageDelivered = 'message_delivered';
  static const String messageRead = 'message_read';

  // Typing
  static const String typingStart = 'typing_start';
  static const String typingStop = 'typing_stop';

  // Presence
  static const String presenceUpdate = 'presence_update';
  static const String userOnline = 'user_online';
  static const String userOffline = 'user_offline';

  SocketEvents._();
}
